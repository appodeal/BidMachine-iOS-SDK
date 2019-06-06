//
//  BDMMRAIDBannerAdapter.m
//  BDMMRAIDBannerAdapter
//
//  Created by Pavel Dunyashev on 11/09/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import "BDMMRAIDBannerAdapter.h"
#import "BDMMRAIDNetwork.h"
#import "BDMMRAIDClosableView.h"
#import "NSError+BDMMRAIDAdapter.h"
#import <BidMachine/NSError+BDMSdk.h>

@import ASKSpinner;
@import ASKProductPresentation;
@import ASKGraphicButton;
@import ASKExtension;
@import AppodealMRAIDKit;


const CGSize kBDMAdSize320x50  = {.width = 320.0f, .height = 50.0f  };
const CGSize kBDMAdSize728x90  = {.width = 728.0f, .height = 90.0f  };


@interface BDMMRAIDBannerAdapter () <AMKAdDelegate, AMKWebServiceDelegate, AMKViewPresenterDelegate, ASKProductControllerDelegate>

@property (nonatomic, strong) AMKAd *ad;
@property (nonatomic, strong) AMKViewPresenter *presenter;

@property (nonatomic, strong) ASKProductController *productPresenter;
@property (nonatomic, strong) ASKSpinnerView *activityIndicatorView;

@property (nonatomic, weak) UIView *container;

@property (nonatomic, assign) BOOL shouldCache;
@property (nonatomic, assign) NSTimeInterval closableViewDelay;

@end

@implementation BDMMRAIDBannerAdapter

- (Class)relativeAdNetworkClass {
    return BDMMRAIDNetwork.class;
}

- (UIView *)adView {
    return self.presenter;
}

- (void)prepareContent:(NSDictionary *)contentInfo {
    self.adContent          = contentInfo[@"creative"];
    self.shouldCache        = contentInfo[@"should_cache"] ? [contentInfo[@"should_cache"] boolValue] : YES;
    self.closableViewDelay  = contentInfo[@"closable_view_delay"] ? [contentInfo[@"closable_view_delay"] floatValue] : 10.0f;
    
    CGSize bannerSize       = [self sizeFromContentInfo:contentInfo];
    CGRect frame            = (CGRect){.size = bannerSize};
    
    NSArray *mraidFeatures  = @[
                                kMRAIDSupportsInlineVideo,
                                kMRAIDSupportsLoging
                                ];
    self.ad = [AMKAd new];
    self.ad.delegate = self;
    self.ad.serviceManager.delegate = self;
    [self.ad.serviceManager.configuration registerServices:mraidFeatures];
    
    self.presenter = [AMKViewPresenter new];
    self.presenter.delegate = self;
    self.presenter.frame = frame;
    
    if (self.shouldCache) {
        [self.ad loadHTML:self.adContent];
    } else {
        [self.loadingDelegate adapterPreparedContent:self];
    }
}

- (void)presentInContainer:(UIView *)container {
    [container.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.container = container;
    if (self.shouldCache) {
        [container addSubview:self.presenter];
        [self.presenter presentAd:self.ad];
    } else {
        self.activityIndicatorView = [[ASKSpinnerView alloc] initWithFrame:self.presenter.frame blurred:YES];
        self.activityIndicatorView.hidden = NO;
        [container addSubview:self.activityIndicatorView];
        [self.ad loadHTML:self.adContent];
    }
}

#pragma mark - AMKAdDelegate

- (void)didLoadAd:(AMKAd *)ad {
    if (self.shouldCache) {
        [self.loadingDelegate adapterPreparedContent:self];
    } else {
        [self.presenter presentAd:ad];
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:0.2 animations:^{
            [weakSelf.activityIndicatorView removeFromSuperview];
            [weakSelf.container addSubview:weakSelf.presenter];
        }];
    }
}

- (void)didFailToLoadAd:(AMKAd *)ad withError:(NSError *)error {
     if (self.shouldCache) {
         [self.loadingDelegate adapter:self failedToPrepareContentWithError:error];
     } else {
         [self.activityIndicatorView removeFromSuperview];
         [self.displayDelegate adapter:self failedToPresentAdWithError:error];
     }
}

- (void)didUserInteractionAd:(AMKAd *)ad withURL:(NSURL *)url {
    [self.displayDelegate adapterRegisterUserInteraction:self];
    NSArray <NSURL *> *urls = url ? @[url] : @[];
    [ASKSpinnerScreen show];
    [self.productPresenter presentUrls:urls];
}

#pragma mark - AMKWebServiceDelegate

- (void)mraidServiceDidReceiveLogMessage:(NSString *)message {
    BDMLog(@"%@", message);
}

- (void)mraidServicePreloadProductUrl:(NSURL *)url {
    NSArray <NSURL *> *urls = url ? @[url] : @[];
    [self.productPresenter prepareUrls:urls];
}

#pragma mark - ASKProductControllerDelegate

- (UIViewController *)presenterRootViewController {
    return [self.displayDelegate rootViewControllerForAdapter:self] ?: UIViewController.ask_topPresentedViewController;
}

- (void)controller:(ASKProductController *)controller didDismissProduct:(NSURL *)productURL {
    [self.displayDelegate adapterDidDismissScreen:self];
}

- (void)controller:(ASKProductController *)controller didFailToPresentWithError:(NSError *)error {
    [ASKSpinnerScreen hide];
}

- (void)controller:(ASKProductController *)controller willLeaveApplicationToProduct:(NSURL *)productURL {
    [ASKSpinnerScreen hide];
    [self.displayDelegate adapterWillLeaveApplication:self];
}

- (void)controller:(ASKProductController *)controller willPresentProduct:(NSURL *)productURL {
    [ASKSpinnerScreen hide];
    [self.displayDelegate adapterWillPresentScreen:self];
}

#pragma mark - Private

- (CGSize)sizeFromContentInfo:(NSDictionary *)contentInfo {
    NSNumber * width = contentInfo[@"width"];
    NSNumber * height = contentInfo[@"height"];
    if ([width ask_number] != nil || [height ask_number] != nil) {
        return [self defaultAdSize];
    }
    if (width.floatValue <= 0 ||
        height.floatValue <= 0) {
        return [self defaultAdSize];
    }
    
    return CGSizeMake(width.floatValue,
                      height.floatValue);
}

- (ASKProductController *)productPresenter {
    if (!_productPresenter) {
        _productPresenter = [ASKProductController new];
        _productPresenter.delegate = self;
    }
    return _productPresenter;
}

- (CGSize)defaultAdSize {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? kBDMAdSize728x90 : kBDMAdSize320x50;
}

@end
