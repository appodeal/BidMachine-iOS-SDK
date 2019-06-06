//
//  BDMSdk.m
//  BidMachine
//
//  Created by Stas Kochkin on 07/11/2017.
//  Copyright © 2017 Appodeal. All rights reserved.
//

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
#import "BDMServerCommunicator.h"
#import "BDMRetryTimer.h"
#import "BDMAuctionSettings.h"
#import "BDMEventMiddleware.h"

#import <ASKExtension/ASKExtension.h>


NSString * const BDMParallelBiddingNetworksExtensionKey = @"ParallelBiddingNetworksExtensionKey";
NSString * const BDMSSPExtensionKey = @"SSPExtensionKey";
NSString * const BDMParallelBiddingInitialisatationItemsExtensionKey = @"ParallelBiddingInitialisatationItemsExtensionKey";


@interface BDMSdk (ParallelBidding)

@property (nonatomic, copy, readonly) NSString * ssp;

- (void)initializeParallelBiddingNetworks:(NSArray <BDMNetworkItem *> *)networks
                               completion:(void(^)(void))completion;
- (void)registerNetworks;

@end


@interface BDMSdk () <BDMNetworkConfiguratorDataSource>

@property (nonatomic, assign, readwrite, getter=isInitialized) BOOL initialized;

@property (nonatomic, strong) BDMRegistry *registry;
@property (nonatomic, strong) BDMEventMiddleware *middleware;
@property (nonatomic, strong) BDMRetryTimer *retryTimer;
@property (nonatomic, strong) ASKNetworkReachability *reachability;
@property (nonatomic, strong) NSOperationQueue *operationQueue;

@property (nonatomic, copy) NSString *sellerID;
@property (nonatomic, copy) BDMSdkConfiguration *configuration;
@property (nonatomic, strong) BDMOpenRTBAuctionSettings *auctionSettings;

@end

@implementation BDMSdk

+ (instancetype)sharedSdk {
    static BDMSdk * _sharedSDK;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedSDK = [[BDMSdk alloc] initPrivately];
    });
    return _sharedSDK;
}

- (instancetype)initPrivately {
    self = [super init];
    if (self) {
        // Create registry
        self.auctionSettings    = [BDMOpenRTBAuctionSettings defaultAuctionSettings];
        self.registry           = [BDMFactory.sharedFactory registry];
        // Register viewability
        [BDMViewabilityMetricProvider registerMetric:BDMViewabilityMetricAppodeal.class];
    }
    return self;
}

- (BOOL)testMode {
    return self.configuration.testMode;
}

- (void)setEnableLogging:(BOOL)enableLogging {
    _enableLogging = enableLogging;
    BDMSdkLoggingEnabled = enableLogging;
}

- (void)startSessionWithSellerID:(NSString *)sellerID
                      completion:(void (^)(void))completion {
    BDMSdkConfiguration * configuration = [BDMSdkConfiguration new];
    
    [self startSessionWithSellerID:sellerID
                     configuration:configuration
                        completion:completion];
}

- (void)startSessionWithSellerID:(NSString *)sellerID
                   configuration:(BDMSdkConfiguration *)configuration
                      completion:(void (^)(void))completion {
    // Seller ID check
    if (!sellerID.length) {
        BDMLog(@"Seller ID should be valid string. Sdk not initialized properly, see docs: https://wiki.appodeal.com/display/BID/BidMachine+iOS+SDK+Documentation");
        return;
    }
    
    // Start location manager
    if (ask_locationTrackingEnabled()) {
        ask_startLocationMonitoring();
    }
    
    // Just save data
    self.sellerID = sellerID;
    self.configuration = configuration;
    
    // Parallel bidding
    [self registerNetworks];

    NSArray <BDMNetworkItem *> *networkItems = self.configuration.extensions[BDMParallelBiddingInitialisatationItemsExtensionKey];
    if (!networkItems.count) {
        self.initialized = YES;
        completion ? completion() : nil;
    } else {
        [self initializeParallelBiddingNetworks:networkItems
                                     completion:completion];
    }
    
    if (self.retryTimer) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    self.retryTimer = BDMRetryTimer.timer(^(BDMRetryTimer *timer){
        // Register initialisation event
        [weakSelf.middleware startEvent:BDMEventInitialisation];
        
        [BDMServerCommunicator.sharedCommunicator makeInitRequest:^(BDMSessionBuilder *builder) {
            builder
            .appendSellerID(weakSelf.sellerID)
            .appendTargeting(weakSelf.configuration.targeting);
        } success:^(id<BDMInitialisationResponse> response) {
            // Save auction config
            weakSelf.auctionSettings.auctionURL = response.auctionURL.absoluteString;
            weakSelf.auctionSettings.eventURLs = response.eventURLs;
            // Fulfill initialisation
            [weakSelf.middleware fulfillEvent:BDMEventInitialisation];
            timer.stop();
        } failure:^(NSError *error) {
            // Reject initialisation
            [weakSelf.middleware rejectEvent:BDMEventAuction code:error.code];
            // Repeat action
            timer.repeat();
        }];
    });
    self.retryTimer.start();
}

- (ASKNetworkReachability *)reachability {
    if (!_reachability) {
        NSString * host = [NSURL URLWithString:self.auctionSettings.auctionURL].host;
        _reachability = [ASKNetworkReachability reachabilityWithHostName:host];
    }
    return _reachability;
}

- (BOOL)isDeviceReachable {
    if ([self.reachability currentReachabilityStatus] == 0) {
        return NO;
    }
    return YES;
}

#pragma mark - Private

- (NSOperationQueue *)operationQueue {
    if (!_operationQueue) {
        _operationQueue = [BDMFactory.sharedFactory operationQueue];
        _operationQueue.maxConcurrentOperationCount = 1;
        _operationQueue.qualityOfService = NSQualityOfServiceUtility;
    }
    return _operationQueue;
}

- (BDMEventMiddleware *)middleware {
    if (!_middleware) {
        _middleware = [BDMEventMiddleware buildMiddleware:^(BDMEventMiddlewareBuilder *builder) {
            __weak typeof(self) weakSelf = self;
            builder.events(^NSArray<BDMEventURL *> *{
                return weakSelf.auctionSettings.eventURLs;
            });
        }];
    }
    return _middleware;
}

#pragma mark - BDMNetworkConfiguratorDataSource

- (id <BDMAdapter>)adapterWithName:(NSString *)name
                            adType:(BDMFullscreenAdType)type
                      interstitial:(BOOL)interstitial {
    id <BDMAdapter> adapter;
    // Try to select adapter for ad type
    switch (type) {
            // Banner can be fullscreen or not
        case BDMFullsreenAdTypeBanner: {
            if (interstitial) {
                adapter = [self interstitialAdAdapterForNetwork:name];
            } else {
                adapter = [self bannerAdapterForNetwork:name];
            }
        } break;
            // Video and native can't be fullscreen
        case BDMFullscreenAdTypeVideo: adapter = [self videoAdapterForNetwork:name]; break;
        case BDMFullscreenAdTypeAll: adapter = [self nativeAdAdapterForNetwork:name]; break;
        default: break;
    }
    return adapter;
}

- (Class <BDMNetwork>)networkClassWithName:(NSString *)name forConfigurator:(BDMNetworkConfigurator *)congigurator {
    return [self.registry networkClassByName:name];
}

@end


@implementation BDMSdk (Project)

- (id <BDMBannerAdapter>)bannerAdapterForNetwork:(NSString *)networkName {
    return [self.registry bannerAdapterForNetwork:networkName];
}

- (id <BDMFullscreenAdapter>)interstitialAdAdapterForNetwork:(NSString *)networkName {
    return [self.registry interstitialAdAdapterForNetwork:networkName];
}

- (id <BDMFullscreenAdapter>)videoAdapterForNetwork:(NSString *)networkName {
    return [self.registry videoAdapterForNetwork:networkName];
}

- (id <BDMNativeAdServiceAdapter>)nativeAdAdapterForNetwork:(NSString *)networkName {
    return [self.registry nativeAdAdapterForNetwork:networkName];
}

- (NSSet *)exchangeRequestBodyFromSdkRequest:(BDMRequest *)request
                                interstitial:(BOOL)intserstitial {
    BDMNetworkConfigurator * configurator = [BDMFactory.sharedFactory configurator];
    configurator.dataSource = self;
    return [configurator exchangeRequestBodyFromSdkRequest:request
                                              interstitial:intserstitial
                                                       ssp:self.ssp];
}

- (BDMTargeting *)targeting {
    return self.configuration.targeting;
}

@end

@implementation BDMSdk (ParallelBidding)

- (NSString *)ssp {
    return self.configuration.extensions[BDMSSPExtensionKey];
}

- (void)registerNetworks {
    // Register networks first
    NSArray <NSString *> * embeddedNetworks = @[ @"BDMMRAIDNetwork", @"BDMVASTNetwork", @"BDMNASTNetwork" ];
    NSMutableArray <NSString *> * networkClassesString = [self.configuration.extensions[BDMParallelBiddingNetworksExtensionKey] mutableCopy] ?: [NSMutableArray new];
    [embeddedNetworks enumerateObjectsUsingBlock:^(NSString * networkClassString, NSUInteger idx, BOOL * stop) {
        if ([NSClassFromString(networkClassString) conformsToProtocol:@protocol(BDMNetwork)]) {
            [networkClassesString addObject:networkClassString];
        }
    }];
    
    [networkClassesString enumerateObjectsUsingBlock:^(NSString * network, NSUInteger idx, BOOL * stop) {
        [self.registry registerNetworkClass:network];
    }];
}

- (void)initializeParallelBiddingNetworks:(NSArray <BDMNetworkItem *> *)networks
                               completion:(void(^)(void))completion {
    BDMInitializationOperation *operation = [BDMFactory.sharedFactory initializeNetworkOperation:networks];
    operation.dataSource = self;
    __weak typeof(self) weakSelf = self;
    operation.completionBlock = ^{
        weakSelf.initialized = YES;
        dispatch_async(dispatch_get_main_queue(), completion);
    };
    [self.operationQueue addOperation:operation];
}

@end
