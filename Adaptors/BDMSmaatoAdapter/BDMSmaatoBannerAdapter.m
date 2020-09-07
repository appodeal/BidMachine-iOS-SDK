//
//  BDMSmaatoBannerAdapter.m
//  BDMSmaatoAdapter
//
//  Created by Ilia Lozhkin on 10/24/19.
//  Copyright © 2019 Stas Kochkin. All rights reserved.
//

@import StackUIKit;
@import StackFoundation;
@import SmaatoSDKBanner;

#import "BDMSmaatoAdNetwork.h"
#import "BDMSmaatoBannerAdapter.h"


@interface BDMSmaatoBannerAdapter()<SMABannerViewDelegate>

@property (nonatomic, strong) SMABannerView *bannerView;

@end

@implementation BDMSmaatoBannerAdapter

- (UIView *)adView {
    return self.bannerView;
}

- (void)prepareContent:(NSDictionary<NSString *,NSString *> *)contentInfo {
    NSString *adSpaceId = ANY(contentInfo).from(BDMSmaatoSpaceIDKey).string;
    if (!adSpaceId) {
        NSError *error = [NSError bdm_errorWithCode:BDMErrorCodeBadContent
                                        description:@"BDMSmaatoBannerAdapter wasn't recived valid bidding data"];
        [self.loadingDelegate adapter:self failedToPrepareContentWithError:error];
        return;
    }
    
    CGSize size = [self.displayDelegate sizeForAdapter:self];
    self.bannerView = [[SMABannerView alloc] initWithFrame:(CGRect){ .size = size }];
    self.bannerView.delegate = self;
    self.bannerView.autoreloadInterval = NO;
    [self.bannerView loadWithAdSpaceId:adSpaceId adSize:[self smaatoBannerSize:size]];
}

- (void)presentInContainer:(UIView *)container {
    [container.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.bannerView stk_edgesEqual:container];
}

- (SMABannerAdSize)smaatoBannerSize:(CGSize)size {
    if (CGSizeEqualToSize(size, CGSizeMake(320, 50))) {
        return [UIDevice.currentDevice userInterfaceIdiom] == UIUserInterfaceIdiomPad ? kSMABannerAdSizeLeaderboard_728x90 : kSMABannerAdSizeXXLarge_320x50;
    }
    
    if (CGSizeEqualToSize(size, CGSizeMake(300, 250))) {
        return kSMABannerAdSizeMediumRectangle_300x250;
    }
    
    return kSMABannerAdSizeXXLarge_320x50;
}

#pragma mark - SMABannerViewDelegate


- (nonnull UIViewController *)presentingViewControllerForBannerView:(SMABannerView *_Nonnull)bannerView {
    return [self.displayDelegate rootViewControllerForAdapter:self];
}

- (void)bannerViewDidTTLExpire:(SMABannerView *_Nonnull)bannerView {
    NSError *error = [NSError bdm_errorWithCode:BDMErrorCodeWasExpired
                                    description:@"BDMSmaatoBannerAdapter was expired"];
    [self.loadingDelegate adapter:self failedToPrepareContentWithError:error];
}

- (void)bannerViewDidLoad:(SMABannerView *_Nonnull)bannerView {
    [self.loadingDelegate adapterPreparedContent:self];
}

- (void)bannerView:(SMABannerView *_Nonnull)bannerView didFailWithError:(NSError *_Nonnull)error {
    [self.loadingDelegate adapter:self failedToPrepareContentWithError:error];
}

- (void)bannerViewDidClick:(SMABannerView *_Nonnull)bannerView {
    [self.displayDelegate adapterRegisterUserInteraction:self];
}

- (void)bannerWillLeaveApplicationFromAd:(SMABannerView *_Nonnull)bannerView {
    [self.displayDelegate adapterWillLeaveApplication:self];
}

@end
