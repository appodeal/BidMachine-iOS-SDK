//
//  BDMAmazonNetwork.m
//  BDMAmazonNetwork
//
//  Created by Yaroslav Skachkov on 9/10/19.
//  Copyright © 2019 Stas Kochkin. All rights reserved.
//

@import DTBiOSSDK;
@import StackFoundation;

#import "BDMAmazonNetwork.h"
#import "BDMAmazonBannerAdapter.h"
#import "BDMAmazonInterstitialAdapter.h"

@interface BDMAmazonNetwork() <DTBAdCallback>

@property (nonatomic, copy) void (^completion)(NSDictionary<NSString *,id> * _Nullable, NSError * _Nullable);

@end

@implementation BDMAmazonNetwork

- (NSString *)name {
    return @"amazon_ads";
}

- (NSString *)sdkVersion {
    return [DTBAds version];
}

- (void)initialiseWithParameters:(NSDictionary<NSString *,id> *)parameters
                      completion:(void (^)(BOOL, NSError * _Nullable))completion {
    [[DTBAds sharedInstance] setAppKey: @"your_app_id"];
    [self syncMetadata];
}

- (void)collectHeaderBiddingParameters:(NSDictionary<NSString *,id> *)parameters
                            completion:(void (^)(NSDictionary<NSString *,id> * _Nullable, NSError * _Nullable))completion {
    DTBAdLoader *amazonAdLoader = [DTBAdLoader new];
    [amazonAdLoader setAdSizes:@[[[DTBAdSize alloc] initBannerAdSizeWithWidth:320 height:50 andSlotUUID:@""]]];
    [amazonAdLoader loadAd:self];
    [self saveCompletion:completion];
}

- (id<BDMBannerAdapter>)bannerAdapterForSdk:(BDMSdk *)sdk {
    return [BDMAmazonBannerAdapter new];
}

- (id<BDMFullscreenAdapter>)interstitialAdAdapterForSdk:(BDMSdk *)sdk {
    return [BDMAmazonInterstitialAdapter new];
}

#pragma mark - Private

- (void)syncMetadata {
    [[DTBAds sharedInstance] setLogLevel:BDMSdkLoggingEnabled ? DTBLogLevelAll : DTBLogLevelOff];
//    [DTBAds enableGDPRSubjectWithConsentString:<#(NSString * _Nonnull)#>];
    [DTBAds sharedInstance].mraidPolicy = CUSTOM_MRAID;
    [DTBAds sharedInstance].mraidCustomVersions = @[@"1.0", @"2.0", @"3.0"];
    [[DTBAds sharedInstance] setUseGeoLocation:YES];
    [[DTBAds sharedInstance] setLogLevel:DTBLogLevelAll];
    [[DTBAds sharedInstance] setTestMode:YES];
//    A9_PRICE_POINTS_KEY
}

- (void)saveCompletion:(void (^)(NSDictionary<NSString *,id> * _Nullable, NSError * _Nullable))completion {
    self.completion = completion;
}

#pragma mark - DTBAdCallback

- (void)onSuccess:(DTBAdResponse *)adResponse {
    
}

- (void)onFailure:(DTBAdError)error {
    
}

@end
