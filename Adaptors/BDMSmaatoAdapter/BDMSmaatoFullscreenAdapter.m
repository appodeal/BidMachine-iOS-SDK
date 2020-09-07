//
//  BDMSmaatoFullscreenAdapter.m
//  BDMSmaatoAdapter
//
//  Created by Ilia Lozhkin on 10/24/19.
//  Copyright © 2019 Stas Kochkin. All rights reserved.
//

@import SmaatoSDKCore;
@import StackFoundation;
@import SmaatoSDKRewardedAds;
@import SmaatoSDKInterstitial;

#import "BDMSmaatoAdNetwork.h"
#import "BDMSmaatoFullscreenAdapter.h"


@interface BDMSmaatoFullscreenAdapter()<SMAInterstitialDelegate, SMARewardedInterstitialDelegate>

@property (nonatomic, strong) SMAInterstitial *interstitial;
@property (nonatomic, strong) SMARewardedInterstitial *rewardedInterstitial;

@end

@implementation BDMSmaatoFullscreenAdapter

- (UIView *)adView {
    return nil;
}

- (void)prepareContent:(nonnull NSDictionary<NSString *,NSString *> *)contentInfo {
    NSString *adSpaceId = ANY(contentInfo).from(BDMSmaatoSpaceIDKey).string;
    if (!adSpaceId) {
        NSError *error = [NSError bdm_errorWithCode:BDMErrorCodeBadContent
                                        description:@"BDMSmaatoBannerAdapter wasn't recived valid bidding data"];
        [self.loadingDelegate adapter:self failedToPrepareContentWithError:error];
        return;
    }
    
    if (!self.rewarded) {
        [SmaatoSDK loadInterstitialForAdSpaceId:adSpaceId delegate:self];
    } else {
        [SmaatoSDK loadRewardedInterstitialForAdSpaceId:adSpaceId delegate:self];
    }
}

- (void)present {
    UIViewController *controller = [self.displayDelegate rootViewControllerForAdapter:self];
    if (self.rewarded && self.rewardedInterstitial.availableForPresentation) {
        [self.rewardedInterstitial showFromViewController:controller];
    } else if (!self.rewarded && self.interstitial.availableForPresentation) {
        [self.interstitial showFromViewController:controller];
    } else {
        NSError *error = [NSError bdm_errorWithCode:BDMErrorCodeInternal description:@"SmaatoInterstitial is invalid"];
        [self.displayDelegate adapter:self failedToPresentAdWithError:error];
    }
}

#pragma mark - SMAInterstitialDelegate

- (void)interstitialDidLoad:(SMAInterstitial *_Nonnull)interstitial {
    self.interstitial = interstitial;
    [self.loadingDelegate adapterPreparedContent:self];
}

- (void)interstitial:(SMAInterstitial *_Nullable)interstitial didFailWithError:(NSError *_Nonnull)error {
    [self.loadingDelegate adapter:self failedToPrepareContentWithError:error];
}

- (void)interstitialDidTTLExpire:(SMAInterstitial *_Nonnull)interstitial {
    NSError *error = [NSError bdm_errorWithCode:BDMErrorCodeWasExpired
                                    description:@"BDMSmaatoFullscreenAdapter was expired"];
    [self.loadingDelegate adapter:self failedToPrepareContentWithError:error];
}

- (void)interstitialWillAppear:(SMAInterstitial *_Nonnull)interstitial {
    [self.displayDelegate adapterWillPresent:self];
}

- (void)interstitialDidDisappear:(SMAInterstitial *_Nonnull)interstitial {
    [self.displayDelegate adapterDidDismiss:self];
}

- (void)interstitialDidClick:(SMAInterstitial *_Nonnull)interstitial {
    [self.displayDelegate adapterRegisterUserInteraction:self];
}

#pragma mark - SMARewardedInterstitialDelegate


- (void)rewardedInterstitialDidLoad:(SMARewardedInterstitial *_Nonnull)rewardedInterstitial {
    self.rewardedInterstitial = rewardedInterstitial;
    [self.loadingDelegate adapterPreparedContent:self];
}

- (void)rewardedInterstitialDidFail:(SMARewardedInterstitial *_Nullable)rewardedInterstitial withError:(NSError *_Nonnull)error {
    [self.loadingDelegate adapter:self failedToPrepareContentWithError:error];
}

- (void)rewardedInterstitialDidTTLExpire:(SMARewardedInterstitial *_Nonnull)rewardedInterstitial {
    NSError *error = [NSError bdm_errorWithCode:BDMErrorCodeWasExpired
                                    description:@"BDMSmaatoFullscreenAdapter was expired"];
    [self.loadingDelegate adapter:self failedToPrepareContentWithError:error];
}

- (void)rewardedInterstitialDidReward:(SMARewardedInterstitial *_Nonnull)rewardedInterstitial {
    [self.displayDelegate adapterFinishRewardAction:self];
}

- (void)rewardedInterstitialWillAppear:(SMARewardedInterstitial *_Nonnull)rewardedInterstitial {
    [self.displayDelegate adapterWillPresent:self];
}

- (void)rewardedInterstitialDidDisappear:(SMARewardedInterstitial *_Nonnull)rewardedInterstitial {
    [self.displayDelegate adapterDidDismiss:self];
}

- (void)rewardedInterstitialDidClick:(SMARewardedInterstitial *_Nonnull)rewardedInterstitial {
    [self.displayDelegate adapterRegisterUserInteraction:self];
}

@end
