//
//  BDMSdkSpec.m
//  BidMachineKiwiTests
//
//  Created by Yaroslav Skachkov on 11/16/18.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <BidMachine/BDMSdkConfiguration.h>
#import <StackFoundation/StackFoundation.h>

#import "BDMSdk.h"
#import "BDMSdk+Project.h"
#import "BDMSdk+Tests.h"
#import "BDMRetryTimer.h"

#import "BDMRegistry.h"
#import "BDMFactory.h"
#import "BDMFactory+BDMOperation.h"
#import "BDMViewabilityMetricAppodeal.h"
#import "BDMViewabilityMetricAppodeal.h"
#import "BDMServerCommunicator.h"
#import "BDMAdNetworksMocks.h"


SPEC_BEGIN(BDMSdkSpec)

describe(@"BDMSdkSpec", ^{
    NSString *seller = @"seller id";
    
    __block BDMSdk *sdk;
    __block BDMFactory *factoryMock;
    
    beforeEach(^{
        factoryMock = [BDMFactory nullMock];
        [BDMFactory stub:@selector(sharedFactory) andReturn:factoryMock];
    });
    
    context(@"Initialization", ^{
        __block BDMEventMiddleware *middlewareMock;
        __block BDMRegistry *registryMock;
        __block BDMRetryTimer *timerMock;
        __block BDMServerCommunicator *communicatorMock;
        
        beforeEach(^{
            communicatorMock = BDMServerCommunicator.nullMock;
            timerMock = BDMRetryTimer.nullMock;
            registryMock = BDMRegistry.nullMock;
            middlewareMock = BDMEventMiddleware.nullMock;
            
            [factoryMock stub:@selector(registry) andReturn:registryMock];
            __block BDMActionBlock tick;
            [BDMRetryTimer stub:@selector(timer) andReturn:^id(BDMActionBlock action) {
                tick = action;
                return timerMock;
            }];
            [timerMock stub:@selector(start) andReturn:^{
                STK_RUN_BLOCK(tick, timerMock);
            }];
            [timerMock stub:@selector(stop) andReturn:^{
                tick = nil;
            }];
            [timerMock stub:@selector(repeat) andReturn:^{}];
            
            [BDMEventMiddleware stub:@selector(buildMiddleware:) withBlock:^id(NSArray *params) {
                return middlewareMock;
            }];
            
            [BDMServerCommunicator stub:@selector(sharedCommunicator) andReturn:communicatorMock];
            
            sdk = [[BDMSdk alloc] initPrivately];
        });
        
        it(@"should register embedded networks", ^{
            [[registryMock should] receive:@selector(registerNetworkClass:) withArguments:BDMMRAIDNetwork.class];
            [[registryMock should] receive:@selector(registerNetworkClass:) withArguments:BDMVASTNetwork.class];
            [[registryMock should] receive:@selector(registerNetworkClass:) withArguments:BDMNASTNetwork.class];
            [sdk startSessionWithSellerID:seller completion:nil];
        });
        
        it(@"should init networks", ^{
            [[registryMock should] receive:@selector(initNetworks)];
            [sdk startSessionWithSellerID:seller completion:nil];
        });
        
        it(@"should send init response", ^{
            NSObject <BDMInitialisationResponse> *responseMock = [KWMock nullMockForProtocol:@protocol(BDMInitialisationResponse)];
            BDMSdkConfiguration *config = [BDMSdkConfiguration new];
            config.baseURL = [NSURL URLWithString:@"http://a.com"];
            BDMSessionBuilder *builder = [BDMSessionBuilder new];
            [communicatorMock stub:@selector(makeInitRequest:success:failure:) withBlock:^id(NSArray *params) {
                void(^build)(BDMSessionBuilder *) = params[0];
                build(builder);
                void(^success)(id<BDMInitialisationResponse>) = params[1];
                success(responseMock);
                return nil;
            }];
            
            [[timerMock should] receive:@selector(stop)];
            [[middlewareMock should] receive:@selector(startEvent:) withArguments:theValue(BDMEventInitialisation)];
            [[middlewareMock should] receive:@selector(fulfillEvent:) withArguments:theValue(BDMEventInitialisation)];

            [sdk startSessionWithSellerID:seller configuration:config completion:nil];
            [[builder.baseURL should] equal:[config.baseURL URLByAppendingPathComponent:@"init"]];
            [[builder.message shouldNot] beNil];
        });
    });
    
    context(@"Logging", ^{
        beforeEach(^{
            sdk = [[BDMSdk alloc] initPrivately];
        });
        
        it(@"should enable logging", ^{
            [sdk setEnableLogging:YES];
            [[theValue(sdk.enableLogging) should] equal:theValue(YES)];
            [[theValue(BDMSdkLoggingEnabled) should] equal:theValue(YES)];
        });
    });
    
    context(@"BDMSdkContext", ^{
        __block BDMRegistry *registryMock;
        __block NSString *name;
        
        beforeEach(^{
            name = @"some name";
            registryMock = BDMRegistry.nullMock;
            [factoryMock stub:@selector(registry) andReturn:registryMock];
            sdk = [[BDMSdk alloc] initPrivately];
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
    });
});

SPEC_END


