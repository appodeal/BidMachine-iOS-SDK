//
//  BDMFactory+BDMDisplayAd.m
//  BidMachine
//
//  Created by Stas Kochkin on 01/11/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import "BDMFactory+BDMDisplayAd.h"
#import "BDMFullscreenAdDisplayAd.h"
#import "BDMBannerViewDisplayAd.h"
#import "BDMNativeAdViewDisplayAd.h"
#import "BDMNativeAdProtocol.h"
#import "BDMRequest+Private.h"
#import "NSError+BDMSdk.h"
#import <ASKExtension/ASKExtension.h>

@implementation BDMFactory (BDMDisplayAd)

- (id<BDMDisplayAd>)displayAdWithResponse:(id<BDMResponse>)response plecementType:(BDMPlacementType)placementType {
    id <BDMDisplayAd> displayAd;
    switch (placementType) {
        case BDMPlacementBanner: displayAd = [BDMBannerViewDisplayAd displayAdWithResponse:response placementType:placementType]; break;
        case BDMPlacementNative: displayAd = [BDMNativeAdViewDisplayAd displayAdWithResponse:response placementType:placementType]; break;
        case BDMPlacementInterstitial: displayAd = [BDMFullscreenAdDisplayAd displayAdWithResponse:response placementType:placementType]; break;
        case BDMPlacementRewardedVideo: displayAd = [BDMFullscreenAdDisplayAd displayAdWithResponse:response placementType:placementType]; break;
    }
    return displayAd;
}

- (id<BDMDisplayAd>)displayAdWithRequest:(BDMRequest *)request error:(NSError *__autoreleasing *)error {
    if (!request) {
        NSError * errorObject = [NSError bdm_errorWithCode:BDMErrorCodeInternal
                                               description:@"You should pass request to ad object before try to show any ad!"];
        ASK_SET_AUTORELASE_VAR(error, errorObject);
    }
    return [request displayAdWithError:error];
}

@end
