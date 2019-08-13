//
//  BDMFacebookFullscreenAdapter.m
//  BDMFacebookAdapter
//
//  Created by Stas Kochkin on 23/07/2019.
//  Copyright © 2019 Stas Kochkin. All rights reserved.
//

#import "BDMFacebookFullscreenAdapter.h"
#import "BDMFacebookStringValueTransformer.h"

@import FBAudienceNetwork;
@import StackFoundation;
@import StackUIKit;


@interface BDMFacebookFullscreenAdapter () <FBInterstitialAdDelegate, FBRewardedVideoAdDelegate>

@property (nonatomic, strong) FBInterstitialAd *interstitialAd;
@property (nonatomic, strong) FBRewardedVideoAd *rewardedVideo;

@end


@implementation BDMFacebookFullscreenAdapter

- (UIView *)adView {
    return nil;
}

- (void)prepareContent:(NSDictionary<NSString *,NSString *> *)contentInfo {
    BDMFacebookStringValueTransformer *transformer = [BDMFacebookStringValueTransformer new];
    NSString *placement = [transformer transformedValue:contentInfo[@"facebook_key"]];
    NSString *payload = [transformer transformedValue:contentInfo[@"bid_payload"]];
    if (!placement || !payload) {
        NSError *error = [NSError bdm_errorWithCode:BDMErrorCodeBadContent
                                        description:@"FBAudienceNetwork wasn'r recived valid bidding data"];
        [self.loadingDelegate adapter:self failedToPrepareContentWithError:error];
        return;
    }
    
    if (self.rewarded) {
        self.rewardedVideo = [[FBRewardedVideoAd alloc] initWithPlacementID:placement];
        self.rewardedVideo.delegate = self;
        [self.rewardedVideo loadAdWithBidPayload:payload];
    } else {
        self.interstitialAd = [[FBInterstitialAd alloc] initWithPlacementID:placement];
        self.interstitialAd.delegate = self;
        [self.interstitialAd loadAdWithBidPayload:payload];
    }
}

- (void)present {
    if (self.interstitialAd.isAdValid && !self.rewarded) {
        [self.displayDelegate adapterWillPresent:self];
        UIViewController *rootViewController = [self.displayDelegate rootViewControllerForAdapter:self];
        [self.interstitialAd showAdFromRootViewController:rootViewController];
    } else if (self.rewardedVideo.isAdValid && self.rewarded) {
        [self.displayDelegate adapterWillPresent:self];
        UIViewController *rootViewController = [self.displayDelegate rootViewControllerForAdapter:self];
        [self.rewardedVideo showAdFromRootViewController:rootViewController];
    } else {
        NSError *error = [NSError bdm_errorWithCode:BDMErrorCodeInternal description:@"FBInterstitialAd is invalid"];
        [self.displayDelegate adapter:self failedToPresentAdWithError:error];
    }
}

#pragma mark - FBInterstitialAdDelegate

- (void)interstitialAdDidLoad:(FBInterstitialAd *)interstitialAd {
    [self.loadingDelegate adapterPreparedContent:self];
}

- (void)interstitialAd:(FBInterstitialAd *)interstitialAd didFailWithError:(NSError *)error {
    NSError *wrapper = [error bdm_wrappedWithCode:BDMErrorCodeNoContent];
    [self.loadingDelegate adapter:self failedToPrepareContentWithError:wrapper];
}

- (void)interstitialAdDidClick:(FBInterstitialAd *)interstitialAd {
    [self.displayDelegate adapterRegisterUserInteraction:self];
}

- (void)interstitialAdDidClose:(FBInterstitialAd *)interstitialAd {
    [self.displayDelegate adapterDidDismiss:self];
}

/// Noop
- (void)interstitialAdWillClose:(FBInterstitialAd *)interstitialAd {}
- (void)interstitialAdWillLogImpression:(FBInterstitialAd *)interstitialAd {}

#pragma mark - FBRewardedVideoDelegate

- (void)rewardedVideoAdDidClick:(FBRewardedVideoAd *)rewardedVideoAd {
    [self.displayDelegate adapterRegisterUserInteraction:self];
}

- (void)rewardedVideoAdDidLoad:(FBRewardedVideoAd *)rewardedVideoAd {
    [self.loadingDelegate adapterPreparedContent:self];
}

- (void)rewardedVideoAdDidClose:(FBRewardedVideoAd *)rewardedVideoAd {
    [self.displayDelegate adapterDidDismiss:self];
}

- (void)rewardedVideoAd:(FBRewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error {
    NSError *wrapper = [error bdm_wrappedWithCode:BDMErrorCodeNoContent];
    [self.loadingDelegate adapter:self failedToPrepareContentWithError:wrapper];
}

- (void)rewardedVideoAdVideoComplete:(FBRewardedVideoAd *)rewardedVideoAd {
    [self.displayDelegate adapterFinishRewardAction:self];
}

/// Noop
- (void)rewardedVideoAdWillClose:(FBRewardedVideoAd *)rewardedVideoAd {}
- (void)rewardedVideoAdWillLogImpression:(FBRewardedVideoAd *)rewardedVideoAd {}
- (void)rewardedVideoAdServerRewardDidSucceed:(FBRewardedVideoAd *)rewardedVideoAd {}
- (void)rewardedVideoAdServerRewardDidFail:(FBRewardedVideoAd *)rewardedVideoAd {}

@end
