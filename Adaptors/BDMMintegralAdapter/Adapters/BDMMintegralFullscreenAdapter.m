//
//  BDMMintegralFullscreenAdapter.m
//  BDMMintegralAdapter
//
//  Created by Yaroslav Skachkov on 8/16/19.
//  Copyright © 2019 Stas Kochkin. All rights reserved.
//

#import "BDMMintegralFullscreenAdapter.h"
#import "BDMMintegralValueTransformer.h"

#import "BDMMintegralVideoAdProxy.h"
#import <MTGSDKInterstitialVideo/MTGBidInterstitialVideoAdManager.h>
#import <MTGSDK/MTGSDK.h>
#import <MTGSDKBidding/MTGBiddingRequest.h>


@interface BDMMintegralFullscreenAdapter() <MTGBidInterstitialVideoDelegate>

@property (nonatomic, strong) MTGBidInterstitialVideoAdManager *interstitialBidAdManager;
@property (nonatomic, strong) BDMMintegralVideoAdProxy *rewardedBidAdManagerProxy;
@property (nonatomic, copy) NSString *unitId;
@property (nonatomic, copy) NSString *placementId;

@end

@implementation BDMMintegralFullscreenAdapter

- (UIView *)adView {
    return nil;
}

- (BDMMintegralVideoAdProxy *)rewardedBidAdManagerProxy {
    return [BDMMintegralVideoAdProxy sharedInstance];
}

- (MTGBidInterstitialVideoAdManager *)interstitialBidAdManager {
    if (!_interstitialBidAdManager) {
        _interstitialBidAdManager = [[MTGBidInterstitialVideoAdManager alloc] initWithPlacementId:self.placementId
                                                                                           unitId:self.unitId
                                                                                         delegate:self];
    }
    return _interstitialBidAdManager;
}

- (void)prepareContent:(nonnull NSDictionary<NSString *,NSString *> *)contentInfo {
    BDMMintegralValueTransformer *transformer = [BDMMintegralValueTransformer new];
    NSString *bidToken = [transformer transformedValue:contentInfo[@"bid_token"]];
    self.unitId = [transformer transformedValue:contentInfo[@"unit_id"]];
    self.placementId = [transformer transformedValue:contentInfo[@"placement_id"]];
    if (!bidToken || !self.unitId) {
        NSError *error = [NSError bdm_errorWithCode:BDMErrorCodeBadContent
                                        description:@"Mintegral adapter was not recive valid bidding data"];
        [self.loadingDelegate adapter:self failedToPrepareContentWithError:error];
        return;
    }
    
    if (self.rewarded) {
        [self.rewardedBidAdManagerProxy loadVideoWithBidToken:bidToken
                                                  placementId:self.placementId
                                                       unitId:self.unitId
                                                      adapter:self];
    } else {
        [self.interstitialBidAdManager loadAdWithBidToken:bidToken];
    }
}

- (void)present {
    UIViewController *rootViewController = [self.displayDelegate rootViewControllerForAdapter:self];
    if ([self.rewardedBidAdManagerProxy.manager isVideoReadyToPlayWithPlacementId:self.placementId unitId:self.unitId] && self.rewarded) {
        [self.displayDelegate adapterWillPresent:self];
        [self.rewardedBidAdManagerProxy showVideoWithPlacementId:self.placementId
                                                          unitId:self.unitId withRewardId:@""
                                                          userId:@""
                                                         adapter:self];
    } else if ([self.interstitialBidAdManager isVideoReadyToPlayWithPlacementId:self.placementId unitId:self.unitId] && !self.rewarded) {
        [self.interstitialBidAdManager showFromViewController:rootViewController];
    }
}

#pragma mark - MTGBidInterstitialVideoDelegate

- (void)onInterstitialVideoLoadSuccess:(MTGBidInterstitialVideoAdManager *)adManager {
    [self.loadingDelegate adapterPreparedContent:self];
}

- (void)onInterstitialVideoLoadFail:(NSError *)error
                          adManager:(MTGBidInterstitialVideoAdManager *)adManager {
    [self.loadingDelegate adapter:self failedToPrepareContentWithError:error];
}

- (void)onInterstitialVideoShowFail:(NSError *)error
                          adManager:(MTGBidInterstitialVideoAdManager *)adManager {
    [self.displayDelegate adapter:self failedToPresentAdWithError:error];
}

- (void)onInterstitialVideoAdClick:(MTGBidInterstitialVideoAdManager *)adManager {
    [self.displayDelegate adapterRegisterUserInteraction:self];
}

- (void)onInterstitialVideoAdDismissedWithConverted:(BOOL)converted
                                          adManager:(MTGBidInterstitialVideoAdManager *)adManager {
    [self.displayDelegate adapterDidDismiss:self];
}

- (void)onInterstitialVideoAdDidClosed:(MTGBidInterstitialVideoAdManager *)adManager {
    [self.displayDelegate adapterDidDismiss:self];
}

// No-op
- (void)onInterstitialVideoPlayCompleted:(MTGBidInterstitialVideoAdManager *)adManager {}
- (void)onInterstitialVideoEndCardShowSuccess:(MTGBidInterstitialVideoAdManager *)adManager {}
- (void)onInterstitialVideoShowSuccess:(MTGBidInterstitialVideoAdManager *)adManager {}
- (void)onInterstitialAdLoadSuccess:(MTGBidInterstitialVideoAdManager *)adManager {}

@end
