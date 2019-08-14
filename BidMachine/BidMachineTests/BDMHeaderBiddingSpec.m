//
//  BDMHeaderBiddingSpec.m
//  BidMachineTests
//
//  Created by Stas Kochkin on 08/08/2019.
//  Copyright © 2019 Appodeal. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "BDMSdk+Project.h"
#import "BDMFactory.h"
#import "BDMSdk+Tests.h"
#import "BDMSdkConfiguration+HeaderBidding.h"
#import "BDMAdNetworksMocks.h"
#import "BDMHeaderBiddingInitialisationOperation.h"
#import "BDMHeaderBiddingPreparationOperation.h"


SPEC_BEGIN(HeaderBiddingSpec)

describe(@"BDMSdkHeaderBiddingContext", ^{
    NSString *seller = @"seller id";
    __block BDMHeaderBiddingNetwork *networkMock;
    __block BDMSdk *sdk;
    __block BDMFactory *factoryMock;
    
    beforeEach(^{
        factoryMock = [BDMFactory nullMock];
        networkMock = BDMHeaderBiddingNetwork.nullMock;
        
        [networkMock stub:@selector(name) andReturn:@"headerbidding"];
        
        [BDMFactory stub:@selector(sharedFactory) andReturn:factoryMock];
        [BDMHeaderBiddingNetwork stub:@selector(new) andReturn:networkMock];
        
        [factoryMock stub:@selector(operationQueue) andReturn:NSOperationQueue.new];
        [factoryMock stub:@selector(registry) andReturn:BDMRegistry.new];
        
        sdk = [[BDMSdk alloc] initPrivately];
    });
    
    context(@"Network initialisation", ^{
        NSDictionary *initParams = @{@"a": @"b"};
        NSDictionary *unitParams = @{@"c": @"d"};
        
        BDMAdUnitFormat fmt = BDMAdUnitFormatBanner320x50;
        
        __block BDMSdkConfiguration *config;
        __block BDMAdNetworkConfiguration *networkConfig;
        
        beforeEach(^{
            config = [BDMSdkConfiguration new];
            [factoryMock stub:@selector(initialisationOperationForNetworks:controller:waitUntilFinished:) withBlock:^id(NSArray *params) {
                return [BDMHeaderBiddingInitialisationOperation initialisationOperationForNetworks:params[0]
                                                                                        controller:params[1]
                                                                                 waitUntilFinished:[params[2] boolValue]];
            }];
        });
        
        it(@"should initialise", ^{
            networkConfig = [BDMAdNetworkConfiguration buildWithBuilder:^(BDMAdNetworkConfigurationBuilder *builder) {
                builder.appendName(@"headerbidding");
                builder.appendAdUnit(fmt, unitParams);
                builder.appendInitializationParams(initParams);
                builder.appendNetworkClass(BDMHeaderBiddingNetwork.class);
            }];
            config.networkConfigurations = @[networkConfig];
            
            [[networkMock shouldEventually] receive:@selector(initialiseWithParameters:completion:)
                                      withArguments:initParams, kw_any()];
            
            [sdk startSessionWithSellerID:seller
                            configuration:config
                               completion:nil];
        });
        
        it(@"should skip initialisation failure", ^{
            __block BOOL wasCompleted;
            
            networkConfig = [BDMAdNetworkConfiguration buildWithBuilder:^(BDMAdNetworkConfigurationBuilder *builder) {
                builder.appendName(@"headerbidding");
                builder.appendAdUnit(fmt, unitParams);
                builder.appendInitializationParams(initParams);
                builder.appendNetworkClass(BDMHeaderBiddingNetwork.class);
            }];
            config.networkConfigurations = @[networkConfig];
            
            [networkMock stub:@selector(initialiseWithParameters:completion:) withBlock:^id(NSArray *params) {
                void(^completion)(BOOL, NSError *) = params[1];
                completion(YES, [NSError bdm_errorWithCode:BDMErrorCodeHeaderBiddingNetwork description:@"Some description"]);
                return nil;
            }];
            
            [sdk startSessionWithSellerID:seller
                            configuration:config
                               completion:^{ wasCompleted = YES; }];
            [[expectFutureValue(theValue(wasCompleted)) shouldEventually] beTrue];
        });
        
        context(@"Header bidding preparing", ^{
            NSDictionary *headerBiddingInfo = @{@"e": @"f"};
            beforeEach(^{
                [factoryMock stub:@selector(preparationOperationForNetworks:controller:placement:) withBlock:^id(NSArray *params) {
                    return [BDMHeaderBiddingPreparationOperation preparationOperationForNetworks:params[0]
                                                                                      controller:params[1]
                                                                                       placement:[params[2] integerValue]];
                }];
                
                networkConfig = [BDMAdNetworkConfiguration buildWithBuilder:^(BDMAdNetworkConfigurationBuilder *builder) {
                    builder.appendName(@"headerbidding");
                    builder.appendAdUnit(fmt, unitParams);
                    builder.appendInitializationParams(initParams);
                    builder.appendNetworkClass(BDMHeaderBiddingNetwork.class);
                }];
                config.networkConfigurations = @[networkConfig];
                [sdk startSessionWithSellerID:seller
                                configuration:config
                                   completion:nil];
            });
        
            it(@"should collect header bidding params", ^{
                __block id<BDMPlacementAdUnit> unit;
                [networkMock stub:@selector(initialiseWithParameters:completion:) withBlock:^id(NSArray *params) {
                    [[params[0] should] equal:initParams];
                    void(^completion)(BOOL, NSError *) = params[1];
                    completion(YES, nil);
                    return nil;
                }];
                
                [networkMock stub:@selector(collectHeaderBiddingParameters:completion:) withBlock:^id(NSArray *params) {
                    [[params[0] should] equal:unitParams];
                    void(^completion)(NSDictionary *, NSError *error) = params[1];
                    completion(headerBiddingInfo, nil);
                    return nil;
                }];
                
                [sdk collectHeaderBiddingAdUnits:BDMInternalPlacementTypeBanner
                                      completion:^(NSArray<id<BDMPlacementAdUnit>> *units) {
                                          unit = [units firstObject];
                }];
                
                [[expectFutureValue([unit clientParams]) shouldEventually] equal:headerBiddingInfo];
            });
            
            
            it(@"should collect header bidding params even if network initialisation failure", ^{
                __block id<BDMPlacementAdUnit> unit;
                [networkMock stub:@selector(initialiseWithParameters:completion:) withBlock:^id(NSArray *params) {
                    [[params[0] should] equal:initParams];
                    void(^completion)(BOOL, NSError *) = params[1];
                    completion(YES, [NSError bdm_errorWithCode:BDMErrorCodeHeaderBiddingNetwork description:@"Something went wrong"]);
                    return nil;
                }];
                
                [networkMock stub:@selector(collectHeaderBiddingParameters:completion:) withBlock:^id(NSArray *params) {
                    [[params[0] should] equal:unitParams];
                    void(^completion)(NSDictionary *, NSError *error) = params[1];
                    completion(headerBiddingInfo, nil);
                    return nil;
                }];
                
                [sdk collectHeaderBiddingAdUnits:BDMInternalPlacementTypeInterstitial
                                      completion:^(NSArray<id<BDMPlacementAdUnit>> *units) {
                                          unit = [units firstObject];
                                      }];
                
                [[expectFutureValue([unit clientParams]) shouldEventually] beNil];
            });
            
            it(@"should not collect header bidding params if network return error", ^{
                __block id<BDMPlacementAdUnit> unit;
                [networkMock stub:@selector(initialiseWithParameters:completion:) withBlock:^id(NSArray *params) {
                    void(^completion)(BOOL, NSError *) = params[1];
                    completion(NO, nil);
                    return nil;
                }];
                
                [networkMock stub:@selector(collectHeaderBiddingParameters:completion:) withBlock:^id(NSArray *params) {
                    [[params[0] should] equal:unitParams];
                    void(^completion)(NSDictionary *, NSError *error) = params[1];
                    completion(nil, [NSError bdm_errorWithCode:BDMErrorCodeHeaderBiddingNetwork description:@"Something went wrong"]);
                    return nil;
                }];
                
                [sdk collectHeaderBiddingAdUnits:BDMInternalPlacementTypeInterstitial
                                      completion:^(NSArray<id<BDMPlacementAdUnit>> *units) {
                                          unit = [units firstObject];
                                      }];
                
                [[expectFutureValue([unit clientParams]) shouldEventually] beNil];
            });
        });
    });
});

SPEC_END

