//
//  BDMNativeAdViewDisplayAd.m
//  BidMachine
//
//  Created by Stas Kochkin on 31/10/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import "BDMNativeAdViewDisplayAd.h"
#import "BDMViewabilityMetricProvider.h"
#import "BDMNativeAd.h"
#import "UIView+BDMNativeAd.h"
#import "NSError+BDMSdk.h"
#import "BDMNativeAdProtocol.h"
#import "BDMSdk+Project.h"


@interface BDMNativeAdViewDisplayAd () <BDMViewabilityMetricProviderDelegate>

@property (nonatomic, strong) id <BDMNativeAd> adapter;
@property (nonatomic, strong) BDMViewabilityMetricProvider * metricProvider;
@property (nonatomic, strong) UITapGestureRecognizer * tapGestureRecognizer;

@property (nonatomic, weak) UIViewController * rootViewController;
@property (nonatomic, weak) UIView <BDMNativeAdView> * container;

@end

@implementation BDMNativeAdViewDisplayAd

+ (instancetype)displayAdWithResponse:(id<BDMResponse>)response placementType:(BDMInternalPlacementType)placementType {
    if (placementType != BDMInternalPlacementTypeNative) {
        BDMLog(@"Trying to initialise BDMNativeAdViewDisplayAd with placement of unsupported type");
        return nil;
    }
    return nil;
}

- (void)presentAd:(UIViewController *)controller container:(UIView <BDMNativeAdView> *)container {
    if (container.BDM_associatedNativeAd == self.adapter) {
        return;
    }
    
    self.rootViewController = controller;
    self.container = container;
    [self renderNativeAd];
}

- (UIView *)adView {
    return self.container;
}

- (void)prepare {
    // TODO: Do something with native ad
}

- (BDMViewabilityMetricProvider *)metricProvider {
    if (!_metricProvider) {
        _metricProvider = [BDMViewabilityMetricProvider new];
        _metricProvider.delegate = self;
    }
    return _metricProvider;
}

- (UITapGestureRecognizer *)tapGestureRecognizer {
    if (!_tapGestureRecognizer) {
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(registerTap)];
        _tapGestureRecognizer.numberOfTapsRequired = 1;
    }
    return _tapGestureRecognizer;
}

- (void)registerTap {
    // Register tap
}

- (void)invalidate {
    [self.container BDM_setAssociatedNativeAd:nil];
    [self.metricProvider finishViewabilityMonitoringForView:self.adView];
    [super invalidate]; 
}

- (void)renderNativeAd {
    // Rendering
    BDMLog(@"Trying to present adapter: %@ with viewability configuration: %@", self.adapter, self.viewabilityConfig);
    @try {
        if ([self.adapter respondsToSelector:@selector(renderOnView:)]) {
            [self.adapter renderOnView:self.container];
        }
        // Viewability
        [self.metricProvider startViewabilityMonitoringForView:self.container
                                                 configuration:self.viewabilityConfig
                                                      delegate:self];
        // Clicks
        if ([self.adapter respondsToSelector:@selector(clickableViews)]) {
            [[self.adapter clickableViews] enumerateObjectsUsingBlock:^(UIView * view, NSUInteger idx, BOOL * stop) {
                [view addGestureRecognizer:self.tapGestureRecognizer];
            }];
        } else {
            [self.container addGestureRecognizer:self.tapGestureRecognizer];
        }
    }
    @catch (NSException * exc) {
        BDMLog(@"Adapter: %@ raise exception: %@", self.adapter, exc);
        [self.delegate displayAd:self failedToPresent:exc.bdm_wrappedError];
    }
}

#pragma mark - BDMBannerAdapterDisplayDelegate

- (void)adapter:(id<BDMAdapter>)adapter failedToPresentAdWithError:(NSError *)error {
    BDMLog(@"Adapter: %@ failed to present with error: %@", adapter, error);
    [self.delegate displayAd:self failedToPresent:error];
}

- (void)adapterRegisterUserInteraction:(id<BDMBannerAdapter>)adapter {
    BDMLog(@"Adapter: %@ register user interaction", adapter);
    [self.delegate displayAdLogUserInteraction:self];
}

- (UIViewController *)rootViewControllerForAdapter:(id<BDMBannerAdapter>)adapter {
    return self.rootViewController;
}

#pragma mark - BDMViewabilityMetricProviderDelegate

- (void)viewabilityMetricProvider:(BDMViewabilityMetricProvider *)provider detectFinishView:(UIView *)view {
    BDMLog(@"Adapter: %@ finish view", self.adapter);
    [self.delegate displayAdLogFinishView:self];
}

- (void)viewabilityMetricProvider:(BDMViewabilityMetricProvider *)provider detectImpression:(UIView *)view {
    BDMLog(@"Adapter: %@ impression view", self.adapter);
    [self.delegate displayAdLogImpression:self];
}

- (void)viewabilityMetricProvider:(BDMViewabilityMetricProvider *)provider detectStartView:(UIView *)view {
    BDMLog(@"Adapter: %@ start view", self.adapter);
    [self.delegate displayAdLogStartView:self];
}

@end
