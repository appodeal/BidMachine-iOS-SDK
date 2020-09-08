//
//  BDMMyTargetFullscreenAdapter.m
//  BDMMyTargetAdapter
//
//  Created by Stas Kochkin on 19/07/2019.
//  Copyright © 2019 Stas Kochkin. All rights reserved.
//

@import MyTargetSDK;
@import StackFoundation;

#import "BDMMyTargetAdNetwork.h"
#import "BDMMyTargetCustomParams.h"
#import "BDMMyTargetFullscreenAdapter.h"


@interface BDMMyTargetFullscreenAdapter () <MTRGInterstitialAdDelegate>

@property (nonatomic, strong) MTRGInterstitialAd *interstitialAd;

@end


@implementation BDMMyTargetFullscreenAdapter

- (UIView *)adView {
    return nil;
}

- (void)prepareContent:(NSDictionary<NSString *,NSString *> *)contentInfo {
    NSString *slot = ANY(contentInfo).from(BDMMyTargetSlotIDKey).string;
    NSString *bid = ANY(contentInfo).from(BDMMyTargetBidIDKey).string;

    NSUInteger slotId = [slot integerValue];
    if (slotId == 0 || bid == nil) {
        NSError *error = [NSError bdm_errorWithCode:BDMErrorCodeBadContent description:@"MyTarget slot id or bid id wasn't found"];
        [self.loadingDelegate adapter:self failedToPrepareContentWithError:error];
        return;
    }
    
    self.interstitialAd = [[MTRGInterstitialAd alloc] initWithSlotId:slotId];
    [BDMMyTargetCustomParams populate:self.interstitialAd.customParams];
    self.interstitialAd.delegate = self;
    [self.interstitialAd loadFromBid:bid];
}

- (void)present {
    UIViewController *rootViewController = [self.displayDelegate rootViewControllerForAdapter:self];
    [self.interstitialAd showWithController: rootViewController];
}

#pragma mark - MTRGInterstitialAdDelegate

- (void)onLoadWithInterstitialAd:(MTRGInterstitialAd *)interstitialAd {
    [self.loadingDelegate adapterPreparedContent:self];
}

- (void)onNoAdWithReason:(NSString *)reason interstitialAd:(MTRGInterstitialAd *)interstitialAd {
    NSString *_reason = [NSString stringWithFormat:@"MyTarget failed with reason: %@", reason ?: @"no reason"];
    NSError *error = [NSError bdm_errorWithCode:BDMErrorCodeNoContent description: _reason];
    [self.loadingDelegate adapter:self failedToPrepareContentWithError:error];
}

- (void)onDisplayWithInterstitialAd:(MTRGInterstitialAd *)interstitialAd {
    [self.displayDelegate adapterWillPresent:self];
}

- (void)onClickWithInterstitialAd:(MTRGInterstitialAd *)interstitialAd {
    [self.displayDelegate adapterRegisterUserInteraction:self];
}

- (void)onVideoCompleteWithInterstitialAd:(MTRGInterstitialAd *)interstitialAd {
    [self.displayDelegate adapterFinishRewardAction:self];
}

- (void)onCloseWithInterstitialAd:(MTRGInterstitialAd *)interstitialAd {
    [self.displayDelegate adapterDidDismiss:self];
}

@end
