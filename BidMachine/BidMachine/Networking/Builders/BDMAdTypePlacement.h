//
//  BDMAdTypePlacement.h
//
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BDMPlacementRequestBuilderProtocol.h"
#import "BDMDefines.h"


@interface BDMAdTypePlacement : NSObject

+ (id<BDMPlacementRequestBuilder>)interstitialPlacementWithAdSpace:(NSString *)spaceId adType:(BDMFullscreenAdType)type;
+ (id<BDMPlacementRequestBuilder>)rewardedPlacementWithAdSpace:(NSString *)spaceId adType:(BDMFullscreenAdType)type;
+ (id<BDMPlacementRequestBuilder>)bannerPlacementWithAdSpace:(NSString *)spaceId adSize:(BDMBannerAdSize)adSize;
+ (id<BDMPlacementRequestBuilder>)nativePlacementWithAdSpace:(NSString *)spaceId
                                                        type:(BDMNativeAdType)type;


+ (id<BDMPlacementRequestBuilder>)interstitialPlacementWithAdType:(BDMFullscreenAdType)type;
+ (id<BDMPlacementRequestBuilder>)rewardedPlacementWithAdType:(BDMFullscreenAdType)type;
+ (id<BDMPlacementRequestBuilder>)bannerPlacementWithAdSize:(BDMBannerAdSize)adSize;
+ (id<BDMPlacementRequestBuilder>)nativePlacementWithAdType:(BDMNativeAdType)type;


@end
