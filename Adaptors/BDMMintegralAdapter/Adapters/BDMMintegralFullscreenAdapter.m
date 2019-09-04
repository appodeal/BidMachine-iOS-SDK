//
//  BDMMintegralFullscreenAdapter.m
//  BDMMintegralAdapter
//
//  Created by Yaroslav Skachkov on 8/16/19.
//  Copyright © 2019 Stas Kochkin. All rights reserved.
//

#import "BDMMintegralFullscreenAdapter.h"
#import "BDMMintegralValueTransformer.h"

#import <MTGSDKReward/MTGBidRewardAdManager.h>
#import <MTGSDKInterstitialVideo/MTGBidInterstitialVideoAdManager.h>
#import <MTGSDK/MTGSDK.h>
#import <MTGSDKBidding/MTGBiddingRequest.h>


@interface BDMMintegralFullscreenAdapter() <MTGRewardAdLoadDelegate, MTGRewardAdShowDelegate, MTGBidInterstitialVideoDelegate>

@property (nonatomic, strong) MTGBidInterstitialVideoAdManager *interstitialBidAdManager;
@property (nonatomic, strong) MTGBidRewardAdManager *rewardedBidAdManager;
@property (nonatomic, copy) NSString *unitId;

@end

@implementation BDMMintegralFullscreenAdapter

- (UIView *)adView {
    return nil;
}

- (MTGBidRewardAdManager *)rewardedBidAdManager {
    return [MTGBidRewardAdManager sharedInstance];
}

- (MTGBidInterstitialVideoAdManager *)interstitialBidAdManager {
    if (!_interstitialBidAdManager) {
        _interstitialBidAdManager = [[MTGBidInterstitialVideoAdManager alloc] initWithUnitID:self.unitId
                                                                                    delegate:self];
    }
    return _interstitialBidAdManager;
}

- (void)prepareContent:(nonnull NSDictionary<NSString *,NSString *> *)contentInfo {
    BDMMintegralValueTransformer *transformer = [BDMMintegralValueTransformer new];
    NSString *bidToken = [transformer transformedValue:contentInfo[@"bid_token"]];
    self.unitId = [transformer transformedValue:contentInfo[@"unit_id"]];
    if (!bidToken || !self.unitId) {
        NSError *error = [NSError bdm_errorWithCode:BDMErrorCodeBadContent
                                        description:@"Mintegral adapter was not recive valid bidding data"];
        [self.loadingDelegate adapter:self failedToPrepareContentWithError:error];
        return;
    }
    
    if (self.rewarded) {
        [self.rewardedBidAdManager loadVideoWithBidToken:bidToken
                                                  unitId:self.unitId
                                                delegate:self];
    } else {
        [self.interstitialBidAdManager loadAdWithBidToken:bidToken];
    }
}

- (void)present {
    UIViewController *rootViewController = [self.displayDelegate rootViewControllerForAdapter:self];
    if ([self.rewardedBidAdManager isVideoReadyToPlay:self.unitId] && self.rewarded) {
        [self.displayDelegate adapterWillPresent:self];
        [self.rewardedBidAdManager showVideo:self.unitId
                                             withRewardId:@""
                                                   userId:@""
                                                 delegate:self
                                           viewController:rootViewController];
    } else if ([self.interstitialBidAdManager isVideoReadyToPlay:self.unitId] && !self.rewarded) {
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

#pragma mark - MTGRewardAdShowDelegate

- (void)onVideoAdShowFailed:(NSString *)unitId
                  withError:(NSError *)error {
    [self.displayDelegate adapter:self failedToPresentAdWithError:error];
}

- (void)onVideoAdClicked:(NSString *)unitId {
    [self.displayDelegate adapterRegisterUserInteraction:self];
}

- (void)onVideoAdDismissed:(NSString *)unitId
             withConverted:(BOOL)converted
            withRewardInfo:(MTGRewardAdInfo *)rewardInfo {
    [self.displayDelegate adapterFinishRewardAction:self];
}

- (void)onVideoAdDidClosed:(NSString *)unitId {
    [self.displayDelegate adapterDidDismiss:self];
}

// No-op
- (void)onVideoAdShowSuccess:(NSString *)unitId {}
- (void)onVideoPlayCompleted:(NSString *)unitId {}
- (void)onVideoEndCardShowSuccess:(NSString *)unitId {}

#pragma mark - MTGRewardAdLoadDelegate

- (void)onVideoAdLoadSuccess:(NSString *)unitId {
    [self.loadingDelegate adapterPreparedContent:self];
}

- (void)onVideoAdLoadFailed:(NSString *)unitId
                      error:(NSError *)error {
    [self.loadingDelegate adapter:self failedToPrepareContentWithError:error];
}

// No-op
- (void)onAdLoadSuccess:(NSString *)unitId {}

@end
