//
//  BDMAdTypePlacement.h
//
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BDMPlacementRequestBuilderProtocol.h"
#import "BDMDefines.h"


@interface BDMAdTypePlacement : NSObject

+ (id<BDMPlacementRequestBuilder>)interstitialPlacementWithAdType:(BDMFullscreenAdType)type;
+ (id<BDMPlacementRequestBuilder>)rewardedPlacementWithAdType:(BDMFullscreenAdType)type;
+ (id<BDMPlacementRequestBuilder>)bannerPlacementWithAdSize:(BDMBannerAdSize)adSize;
+ (id<BDMPlacementRequestBuilder>)nativePlacementWithAdType:(BDMNativeAdType)type;


@end
