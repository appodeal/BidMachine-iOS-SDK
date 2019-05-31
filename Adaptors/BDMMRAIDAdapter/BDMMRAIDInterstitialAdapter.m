//
//  BDMMRAIDInterstitialAdapter.m
//
//  Copyright © 2018 Appodeal. All rights reserved.
//

#define DEFAULT_SKIP_INTERVAL 3

#import "BDMMRAIDInterstitialAdapter.h"
#import "BDMMRAIDNetwork.h"
#import "NSError+BDMMRAIDAdapter.h"
#import "BDMInterstitialPreloadService.h"
#import <BidMachine/NSError+BDMSdk.h>

@import DisplayKit;
@import ASKExtension;
@import ASKProductPresentation;
@import ASKSpinner;

@interface BDMMRAIDInterstitialAdapter () <BDMInterstitialPreloadServiceDelegate, ASKProductControllerDelegate, DSKCustomControlLayerDelegate, DSKCustomControlLayerDataSource>

@property (nonatomic, strong) SKMRAIDInterstitial * interstitial;
@property (nonatomic, strong) DSKCustomControlLayer * controlLayer;
@property (nonatomic, strong) BDMInterstitialPreloadService *preloadService;
@property (nonatomic, strong) ASKProductController * productPresenter;

@end

@implementation BDMMRAIDInterstitialAdapter

- (Class)relativeAdNetworkClass {
    return BDMMRAIDNetwork.class;
}

- (UIView *)adView {
    return [self.interstitial ask_valueForKeyPath:@"mraidView.currentWebView"];
}

- (void)prepareContent:(NSDictionary *)contentInfo {
    self.adContent = contentInfo[@"creative"];
    
    NSArray * supportedFeatures = @[
                                    MRAIDSupportsTel,
                                    MRAIDSupportsCalendar,
                                    MRAIDSupportsSMS,
                                    MRAIDSupportsInlineVideo,
                                    MRAIDSupportsStorePicture
                                    ];
    
    self.preloadService = [[BDMInterstitialPreloadService alloc] initWithDelegate:self];
    if (contentInfo[@"should_cache"]) {
        [self.preloadService setPreload:[contentInfo[@"should_cache"] boolValue]];
    }
    if (contentInfo[@"closable_view_delay"]) {
        [self.preloadService setCloseTime:[contentInfo[@"closable_view_delay"] floatValue]];
    }
    
    self.controlLayer = [[DSKCustomControlLayer alloc] initWithScenario:mraidInterstitialScenario()];
    
    __weak typeof(self) weakSelf = self;
    [self.preloadService loadProcess:^{
        weakSelf.interstitial = [[SKMRAIDInterstitial alloc] initWithSupportedFeatures:supportedFeatures
                                                                              delegate:weakSelf.preloadService
                                                                       serviceDelegate:weakSelf.preloadService
                                                                    rootViewController:weakSelf.rootViewController];
        
        [weakSelf.interstitial loadAdHTML:weakSelf.adContent];
    }];
}

- (void)present {
    __weak typeof(self) weakSelf = self;
    [self.preloadService presentProcess:self.rootViewController preloadBlock:^{
        weakSelf.interstitial.rootViewController = weakSelf.rootViewController;
        [weakSelf.interstitial show];
    }];
}

- (void)addCustomControlOnInterstitial:(SKMRAIDInterstitial *)interstitial{
    [self.controlLayer addOnView:self.adView];
    [self.controlLayer setFrame:[self.adView frame]];
    [self.controlLayer setDelegate:self];
    [self.controlLayer setDataSource:self];
    [self.controlLayer processEvent:CCEventStartScenario];
}

- (UIViewController *)rootViewController {
    return [self.displayDelegate rootViewControllerForAdapter:self] ?: UIViewController.ask_topPresentedViewController;
}

- (ASKProductController *)productPresenter {
    if (!_productPresenter) {
        _productPresenter = [ASKProductController new];
        _productPresenter.delegate = self;
    }
    return _productPresenter;
}

#pragma mark - SKMRAIDInterstitialDelegate

- (void)mraidInterstitialAdReady:(SKMRAIDInterstitial *)mraidInterstitial {
    [self.loadingDelegate adapterPreparedContent:self];
}

- (void)mraidInterstitialAdFailed:(SKMRAIDInterstitial *)mraidInterstitial {
    NSError * error = [NSError bdm_errorWithCode:BDMErrorCodeNoContent description:@"Failed to load ad."];
    [self.loadingDelegate adapter:self failedToPrepareContentWithError:error];
}

- (void)mraidInterstitialWillShow:(SKMRAIDInterstitial *)mraidInterstitial {
    [self addCustomControlOnInterstitial:mraidInterstitial];
    [self.displayDelegate adapterWillPresent:self];
}

- (void)mraidInterstitial:(SKMRAIDInterstitial *)mraidInterstitial failToPresentAdThrowError:(NSError *)error {
    [self.displayDelegate adapter:self failedToPresentAdWithError:[error bdm_wrappedWithCode:BDMErrorCodeBadContent]];
}

- (void)mraidInterstitialDidHide:(SKMRAIDInterstitial *)mraidInterstitial {
    if (self.rewarded) {
        [self.displayDelegate adapterFinishRewardAction:self];
    }
    [self.displayDelegate adapterDidDismiss:self];
}

- (void)mraidInterstitialNavigate:(SKMRAIDInterstitial *)mraidInterstitial withURL:(NSURL *)url {
    [self.displayDelegate adapterRegisterUserInteraction:self];
    if (url) {
        [ASKSpinnerScreen show];
        [self.productPresenter openURL:url];
    }
}

- (void)mraidInterstitial:(SKMRAIDInterstitial *)mraidInterstitial useCustomClose:(BOOL)customClose {
    [self.controlLayer processEvent:customClose ? CCEventUseCustomCloseTrue : CCEventUseCustomCloseFalse];
}

#pragma mark - CustomControl

- (void)DSK_clickOnButtonType:(CCType)type {
    if (type == CCTypeClose || type == CCTypeTimerClose) {
        [self.interstitial close];
    }
}

- (NSNumber *)DSK_closeTime {
    return @DEFAULT_SKIP_INTERVAL;
}

#pragma mark - ASKProductControllerDelegate

- (void)controller:(ASKProductController *)controller didFailToPresentWithError:(NSError *)error {
    [ASKSpinnerScreen hide];
}

- (void)controller:(ASKProductController *)controller willPresentProduct:(NSURL *)productURL {
    [ASKSpinnerScreen hide];
}

- (void)controller:(ASKProductController *)controller willLeaveApplicationToProduct:(NSURL *)productURL {
    [ASKSpinnerScreen hide];
}

- (void)controller:(ASKProductController *)controller didDismissProduct:(NSURL *)productURL {}


@end
