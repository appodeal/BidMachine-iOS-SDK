//
//  BDMAdTypePlacement.m
//
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import "BDMAdTypePlacement.h"
#import "BDMPlacementRequestBuilder.h"
#import <StackFoundation/StackFoundation.h>
#import "BDMDefines.h"


@implementation BDMAdTypePlacement

+ (BDMPlacementRequestBuilder *)placementBuilder {
    BDMPlacementRequestBuilder *builder = [BDMPlacementRequestBuilder new];
    builder.appendSDK(@"BidMachine");
    builder.appendSDKVer(kBDMVersion);
    return builder;
}

+ (id<BDMPlacementRequestBuilder>)interstitialPlacementWithAdType:(BDMFullscreenAdType)type {
    BDMPlacementRequestBuilder * builder = self.placementBuilder;
    if (type & BDMFullsreenAdTypeBanner) {
        builder = builder.appendDisplayPlacement(({
            BDMDisplayPlacementBuilder *display = BDMDisplayPlacementBuilder.new;
            display.appendPos(7);
            display.appendInstl(YES);
            display.appendApi(5);
            display.appendUnit(1);
            display.appendWidth(STKScreen.width);
            display.appendHeight(STKScreen.height);
            display.appendMimes(@[@"image/jpeg", @"image/jpg", @"image/gif", @"image/png"]);
            display;
        }));
    }
    if (type & BDMFullscreenAdTypeVideo) {
        builder = builder.appendVideoPlacement(({
            BDMVideoPlacementBuilder *video = BDMVideoPlacementBuilder.new;
            video.appendPos(7);
            video.appendskip(YES);
            video.appendCType(@[@2, @3, @5, @6]);
            video.appendUnit(1);
            video.appendWidth(STKScreen.width);
            video.appendHeight(STKScreen.height);
            video.appendMimes(@[@"video/mpeg" , @"video/mp4", @"video/quicktime", @"video/avi"]);
            video.appendMaxdur(30);
            video.appendMindur(5);
            video.appendMinbitr(56);
            video.appendMaxbitr(4096);
            video.appendLinearity(1);
            video;
        }));
    }

    return builder;
}

+ (id<BDMPlacementRequestBuilder>)rewardedPlacementWithAdType:(BDMFullscreenAdType)type {
    BDMPlacementRequestBuilder * builder = self.placementBuilder;
    if (type & BDMFullsreenAdTypeBanner) {
        builder = builder.appendDisplayPlacement(({
            BDMDisplayPlacementBuilder *display = BDMDisplayPlacementBuilder.new;
            display.appendPos(7);
            display.appendInstl(YES);
            display.appendApi(5);
            display.appendUnit(1);
            display.appendWidth(STKScreen.width);
            display.appendHeight(STKScreen.height);
            display.appendMimes(@[@"image/jpeg", @"image/jpg", @"image/gif", @"image/png"]);
            display;
        }));
    }
    
    if (type & BDMFullscreenAdTypeVideo) {
        builder = builder.appendVideoPlacement(({
            BDMVideoPlacementBuilder *video = BDMVideoPlacementBuilder.new;
            video.appendPos(7);
            video.appendskip(false);
            video.appendCType(@[@2, @3, @5, @6]);
            video.appendUnit(1);
            video.appendWidth(STKScreen.width);
            video.appendHeight(STKScreen.height);
            video.appendMimes(@[@"video/mpeg" , @"video/mp4", @"video/quicktime", @"video/avi"]);
            video.appendMaxdur(30);
            video.appendMindur(5);
            video.appendMinbitr(56);
            video.appendMaxbitr(4096);
            video.appendLinearity(1);
            video;
        }));
    }
    return builder.appendReward(YES);
}

+ (id<BDMPlacementRequestBuilder>)bannerPlacementWithAdSize:(BDMBannerAdSize)adSize {
    BDMPlacementRequestBuilder *builder = self.placementBuilder
    .appendDisplayPlacement(({
        BDMDisplayPlacementBuilder *display = BDMDisplayPlacementBuilder.new;
        display.appendInstl(NO);
        display.appendApi(5);
        display.appendWidth(CGSizeFromBDMSize(adSize).width);
        display.appendHeight(CGSizeFromBDMSize(adSize).height);
        display.appendMimes(@[@"image/jpeg", @"image/jpg", @"image/gif", @"image/png"]);
        display.appendUnit(1);
        display;
    }));
    return builder;
}

+ (id<BDMPlacementRequestBuilder>)nativePlacementWithAdType:(BDMNativeAdType)type {
    BDMPlacementRequestBuilder *builder = self.placementBuilder
    .appendDisplayPlacement(({
        BDMDisplayPlacementBuilder *display = BDMDisplayPlacementBuilder.new;
        display.appendInstl(NO);
        display.appendMimes(@[@"image/jpeg", @"image/jpg", @"image/gif", @"image/png"]);
        display.appendNativeFmt(({
            BDMNativeFormatBuilder *native = BDMNativeFormatBuilder.new;
            native.appendTitle(({
                BDMNativeFormatTypeBuilder *fmt = BDMNativeFormatTypeBuilder.new;
                fmt.appendId(0);
                fmt.appendReq(1);
                fmt;
            }))
            .appendIcon(({
                BDMNativeFormatTypeBuilder *fmt = BDMNativeFormatTypeBuilder.new;
                fmt.appendId(1);
                fmt.appendReq(1);
                fmt = type & BDMNativeAdTypeIcon ? fmt : nil;
                fmt;
            }))
            .appendImage(({
                BDMNativeFormatTypeBuilder *fmt = BDMNativeFormatTypeBuilder.new;
                fmt.appendId(2);
                fmt.appendReq(1);
                fmt = type & BDMNativeAdTypeImage ? fmt : nil;
                fmt;
            }))
            .appendDescription(({
                BDMNativeFormatTypeBuilder *fmt = BDMNativeFormatTypeBuilder.new;
                fmt.appendId(3);
                fmt.appendReq(1);
                fmt;
            }))
            .appendCta(({
                BDMNativeFormatTypeBuilder *fmt = BDMNativeFormatTypeBuilder.new;
                fmt.appendId(4);
                fmt.appendReq(1);
                fmt;
            }))
            .appendRating(({
                BDMNativeFormatTypeBuilder *fmt = BDMNativeFormatTypeBuilder.new;
                fmt.appendId(5);
                fmt.appendReq(0);
                fmt;
            }))
            .appendSponsored(({
                BDMNativeFormatTypeBuilder *fmt = BDMNativeFormatTypeBuilder.new;
                fmt.appendId(6);
                fmt.appendReq(0);
                fmt;
            }))
            .appendVideo(({
                BDMNativeFormatTypeBuilder *fmt = BDMNativeFormatTypeBuilder.new;
                fmt.appendId(7);
                fmt.appendReq(0);
                fmt = type & BDMNativeAdTypeVideo ? fmt : nil;
                fmt;
            }));
            native;
        }));
        display;
    }));
    return builder;
}

@end
