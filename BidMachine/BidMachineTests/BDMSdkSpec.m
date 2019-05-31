//
//  BDMSdkSpec.m
//  BidMachineKiwiTests
//
//  Created by Yaroslav Skachkov on 11/16/18.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <BidMachine/BDMSdkConfiguration.h>

#import "BDMSdk.h"
#import "BDMSdk+Project.h"
#import "BDMSdk+ParallelBidding.h"

#import "BDMRegistry.h"
#import "BDMFactory.h"
#import "BDMNetworkConfigurator.h"
#import "BDMAsyncOperation.h"
#import "BDMFactory+BDMOperation.h"
#import "BDMInitializationOperation.h"
#import "BDMViewabilityMetricAppodeal.h"

@interface BDMMRAIDNetwork : NSObject<BDMNetwork>

@end

@implementation BDMMRAIDNetwork

+ (NSString *)name {
    return @"BDMMRAIDNetwork";
}

@end

@interface BDMVASTNetwork : NSObject<BDMNetwork>

@end

@implementation BDMVASTNetwork

+ (NSString *)name {
    return @"BDMVASTNetwork";
}

@end

@interface BDMNASTNetwork : NSObject<BDMNetwork>

@end

@implementation BDMNASTNetwork

+ (NSString *)name {
    return @"BDMNASTNetwork";
}

@end

@interface BDMSdk (ParallelBidding)

@property (nonatomic, copy, readonly) NSString * ssp;

- (void)initializeParallelBiddingNetworks:(NSArray <BDMNetworkItem *> *)networks
                               completion:(void(^)(void))completion;
- (void)registerNetworks;

@end

@interface BDMSdk (BDMSdkSpec) <BDMNetworkConfiguratorDataSource>

@property (nonatomic, readwrite) BDMRegistry * registry;
@property (nonatomic, assign, readwrite, getter=isInitialized) BOOL initialized;
@property (nonatomic, strong) NSOperationQueue * operationQueue;
@property (nonatomic, copy) NSString * publiserID;
@property (nonatomic, copy) BDMSdkConfiguration * configuration;

@end

SPEC_BEGIN(BDMSdkSpec)

describe(@"BDMSdkSpec", ^{
    __block BDMSdk * sdk;
    __block BDMRegistry * registryMock;
    __block BDMSdkConfiguration * configurationMock;
    __block BDMNetworkItem * networkItemMock;
    __block BDMNetworkConfigurator * configuratorMock;
    __block NSObject<BDMNetworkConfiguratorDataSource> * configuratorDataSourceMock;
    __block BDMFactory * factoryMock;
    
    beforeEach(^{
        sdk = [BDMSdk sharedSdk];
        factoryMock = [BDMFactory nullMock];
        registryMock = [BDMRegistry nullMock];
        configurationMock = [BDMSdkConfiguration nullMock];
        networkItemMock = [BDMNetworkItem nullMock];
        configuratorMock = [BDMNetworkConfigurator nullMock];
        configuratorDataSourceMock = [KWMock nullMockForProtocol:@protocol(BDMNetworkConfiguratorDataSource)];
        
        [sdk stub:@selector(configuration) andReturn:configurationMock];
        [sdk stub:@selector(registry) andReturn:registryMock];
        [BDMFactory stub:@selector(sharedFactory) andReturn:factoryMock];
        [factoryMock stub:@selector(configurator) andReturn:configuratorMock];
        configuratorMock.dataSource = configuratorDataSourceMock;
    });
    
    context(@"Logging", ^{
        
        it(@"should enable logging", ^{
            [sdk setEnableLogging:YES];
            [[theValue(sdk.enableLogging) should] equal:theValue(YES)];
            [[theValue(BDMSdkLoggingEnabled) should] equal:theValue(YES)];
        });
    });
    context(@"Starting session", ^{
        it(@"should start session with seller ID", ^{
            [[sdk should] receive:@selector(registerNetworks)];
            [sdk startSessionWithSellerID:@"sellerID" configuration:configurationMock completion:^{
                NSLog(@"Session was started with seller ID");
            }];
            [[sdk.sellerID should] equal:@"sellerID"];
            [[configurationMock should] equal:configurationMock];
        });
        
        it(@"should initialize parallel bidding", ^{
            [configurationMock stub:@selector(extensions) andReturn:@{@"ParallelBiddingInitialisatationItemsExtensionKey" : @[networkItemMock]}];
            [[sdk should] receive:@selector(initializeParallelBiddingNetworks:completion:)];
            [sdk startSessionWithSellerID:@"sellerID" configuration:configurationMock completion:^{
                NSLog(@"Session was started with seller ID");
            }];
        });
    });
    
    context(@"BDMNetworkConfiguratorDataSource", ^{
        it(@"should return interstitial adapter", ^{
            BDMFullscreenAdType banner = BDMFullsreenAdTypeBanner;
            [[sdk should] receive:@selector(interstitialAdAdapterForNetwork:) withArguments:@"some string"];
            [sdk adapterWithName:@"some string" adType:banner interstitial:YES];
        });
        it(@"should return banner adapter", ^{
            BDMFullscreenAdType banner = BDMFullsreenAdTypeBanner;
            [[sdk should] receive:@selector(bannerAdapterForNetwork:) withArguments:@"some string"];
            [sdk adapterWithName:@"some string" adType:banner interstitial:NO];
        });
        it(@"should return video ad", ^{
            BDMFullscreenAdType video = BDMFullscreenAdTypeVideo;
            [[sdk should] receive:@selector(videoAdapterForNetwork:) withArguments:@"some string"];
            [sdk adapterWithName:@"some string" adType:video interstitial:NO];
        });
        it(@"should return native ad", ^{
            BDMFullscreenAdType native = BDMFullscreenAdTypeAll;
            [[sdk should] receive:@selector(nativeAdAdapterForNetwork:) withArguments:@"some string"];
            [sdk adapterWithName:@"some string" adType:native interstitial:NO];
        });
        
        it(@"should return network class with name", ^{
            NSString * name = @"some name";
            [[registryMock should] receive:@selector(networkClassByName:) withArguments:name];
            [sdk networkClassWithName:name forConfigurator:kw_any()];
        });
    });
    
    context(@"Adapters for networks", ^{
        __block NSString * name;
        
        beforeEach(^{
            name = @"some name";
        });
        
        it(@"should return banner adapter", ^{
            [[registryMock should] receive:@selector(bannerAdapterForNetwork:) withArguments:name];
            [sdk bannerAdapterForNetwork:name];
        });
        it(@"should return interstitial adapter", ^{
            [[registryMock should] receive:@selector(interstitialAdAdapterForNetwork:) withArguments:name];
            [sdk interstitialAdAdapterForNetwork:name];
        });
        it(@"should return video adapter", ^{
            [[registryMock should] receive:@selector(videoAdapterForNetwork:) withArguments:name];
            [sdk videoAdapterForNetwork:name];
        });
        it(@"should return native adapter", ^{
            [[registryMock should] receive:@selector(nativeAdAdapterForNetwork:) withArguments:name];
            [sdk nativeAdAdapterForNetwork:name];
        });
        
        it(@"should make exchange request body from Sdk request", ^{
            [[configuratorMock should] receive:@selector(exchangeRequestBodyFromSdkRequest:interstitial:ssp:)];
            [sdk exchangeRequestBodyFromSdkRequest:kw_any() interstitial:NO];
        });
    });
    
    context(@"ParallelBidding methods", ^{
        __block BDMInitializationOperation * operationMock;
        __block NSOperationQueue * operationQueueMock;
        
        beforeEach(^{
            operationMock = [BDMInitializationOperation nullMock];
            operationMock.dataSource = configuratorDataSourceMock;
            operationQueueMock = [NSOperationQueue nullMock];
            
            [sdk stub:@selector(operationQueue) andReturn:operationQueueMock];
        });
        
        it(@"should retrun ssp string", ^{
            NSString * sspString = @"ssp string";
            [configurationMock stub:@selector(extensions) andReturn:@{@"SSPExtensionKey" : sspString}];
            NSString * ssp = [sdk ssp];
            [[ssp should] equal:sspString];
        });
        
        it(@"should register networks", ^{
            [configurationMock stub:@selector(extensions) andReturn:@{@"ParallelBiddingNetworksExtensionKey" : @[]}];
            [[registryMock should] receive:@selector(registerNetworkClass:) withCount:3];
            [sdk registerNetworks];
        });
        
        it(@"should init parallel bidding networks", ^{
            KWCaptureSpy * spy = [operationMock captureArgument:@selector(setCompletionBlock:) atIndex:0];
            [[operationQueueMock should] receive:@selector(addOperation:)];
            [factoryMock stub:@selector(initializeNetworkOperation:) andReturn:operationMock];
            [sdk initializeParallelBiddingNetworks:kw_any() completion:^{
                NSLog(@"Parallel bidding networks were initialized");
            }];
            void(^block)(void) = spy.argument;
            block();
            [[theValue(sdk.initialized) should] equal:theValue(YES)];
        });
    });
});

SPEC_END
