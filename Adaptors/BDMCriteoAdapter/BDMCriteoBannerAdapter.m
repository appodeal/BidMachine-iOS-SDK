//
//  BDMCriteoBannerAdapter.m
//
//  Copyright © 2020 Stas Kochkin. All rights reserved.
//

#import "BDMCriteoBannerAdapter.h"

#import <StackUIKit/StackUIKit.h>
#import <StackFoundation/StackFoundation.h>

@interface BDMCriteoBannerAdapter () <CRBannerViewDelegate>

@property (nonatomic, weak) id<BDMCriteoAdNetworkProvider> provider;
@property (nonatomic, strong) CRBannerView *bannerView;

@end

@implementation BDMCriteoBannerAdapter

- (instancetype)initWithProvider:(id<BDMCriteoAdNetworkProvider>)provider {
    if (self = [super init]) {
        self.provider = provider;
    }
    return self;
}

- (UIView *)adView {
    return self.bannerView;
}

- (void)prepareContent:(NSDictionary<NSString *,NSString *> *)contentInfo {
    NSString *adUnitId = contentInfo[@"ad_unit_id"];
    if (!NSString.stk_isValid(adUnitId)) {
        NSError *error = [NSError bdm_errorWithCode:BDMErrorCodeBadContent
                                        description:@"Criteo wasn't recived valid bidding data"];
        [self.loadingDelegate adapter:self failedToPrepareContentWithError:error];
        return;
    }
    
    CRBannerAdUnit *adUnit = [[CRBannerAdUnit alloc] initWithAdUnitId:adUnitId size:[self.displayDelegate sizeForAdapter:self]];
    CRBidToken *bidToken = [self.provider bidTokenForAdUnitId:adUnitId];
    
    if (!bidToken) {
        NSError *error = [NSError bdm_errorWithCode:BDMErrorCodeBadContent
                                        description:@"Criteo bid token nil"];
        [self.loadingDelegate adapter:self failedToPrepareContentWithError:error];
        return;
    }
    
    self.bannerView = [[CRBannerView alloc] initWithAdUnit:adUnit];
    self.bannerView.delegate = self;
    [self.bannerView loadAdWithBidToken:bidToken];
}

- (void)presentInContainer:(UIView *)container {
    [container.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [container addSubview:self.bannerView];
    [self.bannerView stk_edgesEqual:container];
}

#pragma mark - CRBannerViewDelegate

- (void)banner:(CRBannerView *)bannerView didFailToReceiveAdWithError:(NSError *)error {
    [self.loadingDelegate adapter:self failedToPrepareContentWithError:error];
}

- (void)bannerDidReceiveAd:(CRBannerView *)bannerView {
    [self.loadingDelegate adapterPreparedContent:self];
}

- (void)bannerWillLeaveApplication:(CRBannerView *)bannerView {
    [self.displayDelegate adapterWillLeaveApplication:self];
}

- (void)bannerWasClicked:(CRBannerView *)bannerView {
    [self.displayDelegate adapterRegisterUserInteraction:self];
}

@end
