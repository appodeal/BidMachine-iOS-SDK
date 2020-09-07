//
//  BDMMyTargetBannerAdapter.m
//  BDMMyTargetAdapter
//
//  Created by Stas Kochkin on 19/07/2019.
//  Copyright © 2019 Stas Kochkin. All rights reserved.
//

@import StackUIKit;
@import MyTargetSDK;
@import StackFoundation;

#import "BDMMyTargetCustomParams.h"
#import "BDMMyTargetBannerAdapter.h"


@interface BDMMyTargetBannerAdapter () <MTRGAdViewDelegate>

@property (nonatomic, strong) MTRGAdView *banner;

@end


@implementation BDMMyTargetBannerAdapter

- (UIView *)adView {
    return self.banner;
}

- (void)prepareContent:(NSDictionary<NSString *,NSString *> *)contentInfo {
    NSString *slot = ANY(contentInfo).from(@"slot_id").string;
    NSString *bid = ANY(contentInfo).from(@"bid_id").string;
    
    NSUInteger slotId = [slot integerValue];
    if (slotId == 0 || bid == nil) {
        NSError *error = [NSError bdm_errorWithCode:BDMErrorCodeBadContent description:@"MyTarget slot id or bid id wasn't found"];
        [self.loadingDelegate adapter:self failedToPrepareContentWithError:error];
        return;
    }
    
    self.banner = [[MTRGAdView alloc] initWithSlotId:slotId adSize:[self bannerSize]];
    self.banner.viewController = [self.displayDelegate rootViewControllerForAdapter:self];
    self.banner.delegate = self;

    [BDMMyTargetCustomParams populate:self.banner.customParams];
    [self.banner loadFromBid:bid];
}

- (void)presentInContainer:(UIView *)container {
    self.banner.viewController = [self.displayDelegate rootViewControllerForAdapter:self];
    [container.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.banner stk_edgesEqual:container];
}

#pragma mark - MTRGAdViewDelegate

- (void)onLoadWithAdView:(MTRGAdView *)adView {
    [self.loadingDelegate adapterPreparedContent:self];
}

- (void)onNoAdWithReason:(NSString *)reason adView:(MTRGAdView *)adView {
    NSString *_reason = [NSString stringWithFormat:@"MyTarget failed with reason: %@", reason ?: @"no reason"];
    NSError *error = [NSError bdm_errorWithCode:BDMErrorCodeNoContent description: _reason];
    [self.loadingDelegate adapter:self failedToPrepareContentWithError:error];
}

- (void)onAdClickWithAdView:(MTRGAdView *)adView {
    [self.displayDelegate adapterRegisterUserInteraction:self];
}

- (void)onShowModalWithAdView:(MTRGAdView *)adView {
    [self.displayDelegate adapterWillPresentScreen:self];
}

- (void)onLeaveApplicationWithAdView:(MTRGAdView *)adView {
    [self.displayDelegate adapterWillLeaveApplication:self];
}

- (void)onDismissModalWithAdView:(MTRGAdView *)adView {
    [self.displayDelegate adapterDidDismissScreen:self];
}

- (MTRGAdSize)bannerSize {
    CGSize bannerSize = [self.displayDelegate sizeForAdapter:self];
    MTRGAdSize adSize = MTRGAdSize_320x50;
    switch ((int)bannerSize.width) {
        case 320: adSize = MTRGAdSize_320x50; break;
        case 300: adSize = MTRGAdSize_300x250; break;
        case 728: adSize = MTRGAdSize_728x90; break;
        default: adSize = MTRGAdSize_320x50; break;
    }
    return adSize;
}

@end
