//
//  BDMMRAIDBannerAdapter.m
//  BDMMRAIDBannerAdapter
//
//  Created by Pavel Dunyashev on 11/09/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import "BDMMRAIDBannerAdapter.h"
#import "BDMMRAIDNetwork.h"
#import "BDMBannerPreloadService.h"
#import <BidMachine/NSError+BDMSdk.h>

@import ASKSpinner;
@import ASKProductPresentation;
@import ASKExtension;

const CGSize kBDMAdSize320x50  = {.width = 320.0f, .height = 50.0f  };
const CGSize kBDMAdSize728x90  = {.width = 728.0f, .height = 90.0f  };


@interface BDMMRAIDBannerAdapter () <BDMBannerPreloadServiceDelegate, ASKProductControllerDelegate>

@property (nonatomic, assign) CGSize bannerSize;
@property (nonatomic, strong) SKMRAIDView* bannerView;
@property (nonatomic, strong) BDMBannerPreloadService * preloadService;
@property (nonatomic, strong) ASKProductController * productPresenter;

@end

@implementation BDMMRAIDBannerAdapter

- (Class)relativeAdNetworkClass {
    return BDMMRAIDNetwork.class;
}

- (UIView *)adView {
    return self.bannerView;
}

- (void)prepareContent:(NSDictionary *)contentInfo {
    self.adContent          = contentInfo[@"creative"];
    self.bannerSize         = [self sizeFromContentInfo:contentInfo];
    CGRect frame            = (CGRect){.size = self.bannerSize};
    NSArray * mraidFeatures = @[
                                MRAIDSupportsTel,
                                MRAIDSupportsCalendar,
                                MRAIDSupportsSMS,
                                MRAIDSupportsInlineVideo,
                                MRAIDSupportsStorePicture
                                ];
    
    
    
    self.preloadService = [[BDMBannerPreloadService alloc] initWithDelegate:self];
    if (contentInfo[@"should_cache"]) {
        [self.preloadService setPreload:[contentInfo[@"should_cache"] boolValue]];
    }
    if (contentInfo[@"closable_view_delay"]) {
        [self.preloadService setCloseTime:[contentInfo[@"closable_view_delay"] floatValue]];
    }
    
    __weak typeof(self) weakSelf = self;
    [self.preloadService loadProcess:^{
        weakSelf.bannerView = [[SKMRAIDView alloc] initWithFrame:frame
                                               supportedFeatures:mraidFeatures
                                                        delegate:weakSelf.preloadService
                                                 serviceDelegate:weakSelf.preloadService
                                              rootViewController:weakSelf.rootViewController];
        [weakSelf.bannerView loadAdHTML:weakSelf.adContent];
    }];
}


- (void)presentInContainer:(UIView *)container {
    __weak typeof(self) weakSelf = self;
    [self.preloadService presentProcess:container
                           preloadBlock:^{
                               [container.subviews enumerateObjectsUsingBlock:^(UIView * subview, NSUInteger idx, BOOL * stop) {
                                   [subview removeFromSuperview];
                               }];
                               [container addSubview:weakSelf.bannerView];
                               weakSelf.bannerView.rootViewController = weakSelf.rootViewController;
                               [weakSelf.bannerView setIsViewable:YES];
                           }];
}

#pragma mark - BDMBannerPreloadServiceDelegate

- (void)mraidViewAdReady:(SKMRAIDView *)mraidView {
    [self.loadingDelegate adapterPreparedContent:self];
}

- (void)mraidView:(SKMRAIDView *)mraidView failToLoadAdThrowError:(NSError *)error {
    [self.loadingDelegate adapter:self failedToPrepareContentWithError:[error bdm_wrappedWithCode:BDMErrorCodeNoContent]];
}

- (void)mraidView:(SKMRAIDView *)mraidView failToPresentAdThrowError:(NSError *)error {
    [self.displayDelegate adapter:self failedToPresentAdWithError:[error bdm_wrappedWithCode:BDMErrorCodeBadContent]];
}

- (void)mraidViewNavigate:(SKMRAIDView *)mraidView withURL:(NSURL *)url {
    [self.displayDelegate adapterRegisterUserInteraction:self];
    [ASKSpinnerScreen show];
    [self.productPresenter openURL:url];
}

- (BOOL)mraidViewShouldResize:(SKMRAIDView *)mraidView toPosition:(CGRect)position allowOffscreen:(BOOL)allowOffscreen {
    return YES;
}

#pragma mark - Private

- (CGSize)sizeFromContentInfo:(NSDictionary *)contentInfo {
    NSNumber * width = contentInfo[@"width"];
    NSNumber * height = contentInfo[@"height"];
    if ([width ask_number] != nil || [height ask_number] != nil) {
        return [self sizeFromDevice];
    }
    if (width.floatValue <= 0 ||
        height.floatValue <= 0) {
        return [self sizeFromDevice];
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

- (UIViewController *)rootViewController {
    return [self.displayDelegate rootViewControllerForAdapter:self] ?: UIViewController.ask_topPresentedViewController;
}

- (CGSize)sizeFromDevice {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? kBDMAdSize728x90 : kBDMAdSize320x50;
}

#pragma mark - ASKProductControllerDelegate

- (void)controller:(ASKProductController *)controller didFailToPresentWithError:(NSError *)error {
    [ASKSpinnerScreen hide];
}

- (void)controller:(ASKProductController *)controller willPresentProduct:(NSURL *)productURL {
    [ASKSpinnerScreen hide];
    [self.displayDelegate adapterWillPresentScreen:self];
}

- (void)controller:(ASKProductController *)controller didDissmissProduct:(NSURL *)productURL {
    [self.displayDelegate adapterDidDismissScreen:self];
}

- (void)controller:(ASKProductController *)controller willLeaveApplicationToProduct:(NSURL *)productURL {
    [ASKSpinnerScreen hide];
    [self.displayDelegate adapterWillLeaveApplication:self];
}

- (void)controller:(ASKProductController *)controller didDismissProduct:(NSURL *)productURL {}


@end
