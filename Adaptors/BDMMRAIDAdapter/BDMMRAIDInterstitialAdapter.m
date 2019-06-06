//
//  BDMMRAIDInterstitialAdapter.m
//
//  Copyright © 2018 Appodeal. All rights reserved.
//

#define DEFAULT_SKIP_INTERVAL 3

#import "BDMMRAIDInterstitialAdapter.h"
#import "BDMMRAIDNetwork.h"
#import "NSError+BDMMRAIDAdapter.h"
#import "BDMMRAIDClosableView.h"
#import <BidMachine/NSError+BDMSdk.h>


@import ASKSpinner;
@import ASKProductPresentation;
@import ASKGraphicButton;
@import ASKExtension;
@import AppodealMRAIDKit;


@interface BDMMRAIDInterstitialAdapter () <AMKAdDelegate, AMKWebServiceDelegate, AMKInterstitialPresenterDelegate, ASKProductControllerDelegate>

@property (nonatomic, strong) AMKAd *ad;
@property (nonatomic, strong) AMKInterstitialPresenter *presenter;

@property (nonatomic, strong) ASKProductController *productPresenter;
@property (nonatomic, strong) ASKSpinnerWindow *activityWindow;

@property (nonatomic, assign) BOOL shouldCache;
@property (nonatomic, assign) NSTimeInterval closableViewDelay;

@end

@implementation BDMMRAIDInterstitialAdapter

- (Class)relativeAdNetworkClass {
    return BDMMRAIDNetwork.class;
}

- (UIView *)adView {
    return self.ad.webView;
}

- (void)prepareContent:(NSDictionary *)contentInfo {
    self.adContent          = contentInfo[@"creative"];
    self.shouldCache        = contentInfo[@"should_cache"] ? [contentInfo[@"should_cache"] boolValue] : YES;
    self.closableViewDelay  = contentInfo[@"closable_view_delay"] ? [contentInfo[@"closable_view_delay"] floatValue] : 10.0f;
    
    NSArray *mraidFeatures  = @[
                                kMRAIDSupportsInlineVideo,
                                kMRAIDSupportsLoging,
                                kMRAIDPreloadURL
                                ];
    
    self.ad = [AMKAd new];
    self.ad.delegate = self;
    self.ad.serviceManager.delegate = self;
    [self.ad.serviceManager.configuration registerServices:mraidFeatures];
    
    self.presenter = [AMKInterstitialPresenter new];
    self.presenter.delegate = self;
    
    if (self.shouldCache) {
        [self.ad loadHTML:self.adContent];
    } else {
        [self.loadingDelegate adapterPreparedContent:self];
    }
}

- (void)present {
    if (self.shouldCache) {
        [self.presenter presentAd:self.ad];
    } else {
        self.activityWindow = [[ASKSpinnerWindow alloc] initWithBlur:YES];
        __weak typeof(self) weakSelf = self;
        BDMMRAIDClosableView *closableView = [BDMMRAIDClosableView closableView:self.closableViewDelay action:^(BDMMRAIDClosableView *closableView) {
            [weakSelf hideActivityWindow];
            NSError *error = NSError.bdm_error(@"User skip interstitial");
            [weakSelf.displayDelegate adapter:weakSelf failedToPresentAdWithError:error];
        }];
        self.activityWindow.hidden = NO;
        [closableView render:self.activityWindow];
        [self.ad loadHTML:self.adContent];
    }
}

- (void)hideActivityWindow {
    self.activityWindow.hidden = YES;
    self.activityWindow = nil;
}

- (ASKProductController *)productPresenter {
    if (!_productPresenter) {
        _productPresenter = [ASKProductController new];
        _productPresenter.delegate = self;
    }
    return _productPresenter;
}

#pragma mark - AMKAdDelegate

- (void)didLoadAd:(AMKAd *)ad {
    if (self.shouldCache) {
        [self.loadingDelegate adapterPreparedContent:self];
    } else {
        [self hideActivityWindow];
        [self.presenter presentAd:ad];
    }
}

- (void)didFailToLoadAd:(AMKAd *)ad withError:(NSError *)error {
    if (self.shouldCache) {
        [self.loadingDelegate adapter:self failedToPrepareContentWithError:error];
    } else {
        [self hideActivityWindow];
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

#pragma mark - AMKInterstitialPresenterDelegate

- (void)presenterDidAppear:(id<AMKPresenter>)presenter {
    [self.displayDelegate adapterWillPresent:self];
}

- (void)presenterDidDisappear:(id<AMKPresenter>)presenter {
    [self.displayDelegate adapterDidDismiss:self];
}

- (void)presenterFailToPresent:(id<AMKPresenter>)presenter withError:(NSError *)error {
    NSError *wrappedError = [error bdm_wrappedWithCode:BDMErrorCodeBadContent];
    [self.displayDelegate adapter:self failedToPresentAdWithError:wrappedError];
}

#pragma mark - ASKProductControllerDelegate

- (UIViewController *)presenterRootViewController {
    return [self.displayDelegate rootViewControllerForAdapter:self] ?: UIViewController.ask_topPresentedViewController;
}

- (void)controller:(ASKProductController *)controller didFailToPresentWithError:(NSError *)error {
    [ASKSpinnerScreen hide];
}

- (void)controller:(ASKProductController *)controller willLeaveApplicationToProduct:(NSURL *)productURL {
    [ASKSpinnerScreen hide];
}

- (void)controller:(ASKProductController *)controller willPresentProduct:(NSURL *)productURL {
    [ASKSpinnerScreen hide];
}

- (void)controller:(ASKProductController *)controller didDismissProduct:(NSURL *)productURL {}

@end
