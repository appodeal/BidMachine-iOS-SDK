//
//  BDMFacebookBannerAdapter.m
//  BDMFacebookAdapter
//
//  Created by Stas Kochkin on 23/07/2019.
//  Copyright © 2019 Stas Kochkin. All rights reserved.
//

@import StackUIKit;
@import StackFoundation;
@import FBAudienceNetwork;

#import "BDMFacebookAdNetwork.h"
#import "BDMFacebookBannerAdapter.h"


@interface BDMFacebookBannerAdapter () <FBAdViewDelegate>

@property (nonatomic, strong) FBAdView *bannerView;

@end


@implementation BDMFacebookBannerAdapter

- (UIView *)adView {
    return self.bannerView;
}

- (void)prepareContent:(NSDictionary<NSString *,NSString *> *)contentInfo {
    NSString *placement = ANY(contentInfo).from(BDMFacebookPlacementIDKey).string;
    NSString *payload = ANY(contentInfo).from(BDMFacebookBidPayloadIDKey).string;
    
    if (!placement || !payload) {
        NSError *error = [NSError bdm_errorWithCode:BDMErrorCodeBadContent
                                        description:@"FBAudienceNetwork wasn'r recived valid bidding data"];
        [self.loadingDelegate adapter:self failedToPrepareContentWithError:error];
        return;
    }
    
    UIViewController *rootViewController = [self.displayDelegate rootViewControllerForAdapter:self];
    NSError *error = nil;
    self.bannerView = [[FBAdView alloc] initWithPlacementID:placement
                                                 bidPayload:payload
                                         rootViewController:rootViewController
                                                      error:&error];
    if (error) {
        NSError *wrapper = [error bdm_wrappedWithCode:BDMErrorCodeUnknown];
        [self.loadingDelegate adapter:self failedToPrepareContentWithError:wrapper];
        return;
    }
    
    self.bannerView.delegate = self;
    [self.bannerView loadAdWithBidPayload:payload];
}

- (void)presentInContainer:(UIView *)container {
    [container.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [container addSubview:self.bannerView];
    [self.bannerView stk_edgesEqual:container];
}

#pragma mark - FBAdViewDelegate

- (UIViewController *)viewControllerForPresentingModalView {
    return [self.displayDelegate rootViewControllerForAdapter:self];
}

- (void)adViewDidLoad:(FBAdView *)adView {
    [self.loadingDelegate adapterPreparedContent:self];
}

- (void)adView:(FBAdView *)adView didFailWithError:(NSError *)error {
    NSError *wrapper = [error bdm_wrappedWithCode:BDMErrorCodeNoContent];
    [self.loadingDelegate adapter:self failedToPrepareContentWithError:wrapper];
}

- (void)adViewDidClick:(FBAdView *)adView {
    [self.displayDelegate adapterRegisterUserInteraction:self];
    [self.displayDelegate adapterWillPresentScreen:self];
}

- (void)adViewDidFinishHandlingClick:(FBAdView *)adView {
    [self.displayDelegate adapterDidDismissScreen:self];
}

@end
