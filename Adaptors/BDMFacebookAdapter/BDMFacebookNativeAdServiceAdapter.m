//
//  BDMFacebookNativeAdServiceAdapter.m
//  BDMFacebookAdapter
//
//  Created by Ilia Lozhkin on 11/20/19.
//  Copyright © 2019 Stas Kochkin. All rights reserved.
//

@import StackFoundation;
@import StackFoundation;
@import FBAudienceNetwork;

#import "BDMFacebookAdNetwork.h"
#import "BDMFacebookNativeAdServiceAdapter.h"
#import "BDMFacebookNativeAdDisplayAdapter.h"


@interface BDMFacebookNativeAdServiceAdapter()<FBNativeAdDelegate>

@property (nonatomic, strong) FBNativeAd *nativeAd;

@end

@implementation BDMFacebookNativeAdServiceAdapter

- (UIView *)adView {
    return nil;
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
    
    self.nativeAd = [[FBNativeAd alloc] initWithPlacementID:placement];
    self.nativeAd.delegate = self;
    [self.nativeAd loadAdWithBidPayload:payload mediaCachePolicy:FBNativeAdsCachePolicyNone];
}

#pragma mark - FBNativeAdDelegate

- (void)nativeAdDidLoad:(FBNativeAd *)nativeAd {
    BDMFacebookNativeAdDisplayAdapter *nativeAdAdapter = [BDMFacebookNativeAdDisplayAdapter displayAdapterForAd:nativeAd];
    [self.loadingDelegate service:self didLoadNativeAds:@[nativeAdAdapter]];
}

- (void)nativeAd:(FBNativeAd *)nativeAd didFailWithError:(NSError *)error {
    [self.loadingDelegate adapter:self failedToPrepareContentWithError: [error bdm_wrappedWithCode:BDMErrorCodeNoContent]];
}

@end
