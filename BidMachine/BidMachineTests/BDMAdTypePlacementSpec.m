//
//  BDMAdTypePlacementSpec.m
//  BidMachineKiwiTests
//
//  Created by Yaroslav Skachkov on 11/20/18.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <StackFoundation/StackFoundation.h>

#import "BDMProtoAPI-Umbrella.h"
#import "BDMAdTypePlacement.h"
#import "BDMPlacementRequestBuilder.h"
#import "BDMPlacementRequestBuilderProtocol.h"
#import "BDMAdNetworkConfiguration.h"
#import "BDMDefines.h"



SPEC_BEGIN(BDMAdTypePlacementSpec)

describe(@"BDMAdTypePlacementSpec", ^{
    
    __block BDMAdTypePlacement * placementClass;
    __block NSArray<NSNumber *> * cTypeArray;
    
    beforeEach(^{
        placementClass = [BDMAdTypePlacement new];
    });
    
    context(@"Placement", ^{
        cTypeArray = [[NSArray alloc] initWithObjects:@2, @3, @5, @6, nil];
        it(@"should return BDMPlacementRequestBuilder from interstitial placement with Banner ad type", ^{
            id interstitial = [BDMAdTypePlacement interstitialPlacementWithAdType:BDMFullsreenAdTypeBanner];
            
            [[[interstitial valueForKeyPath:@"placement.display.pos"] should] equal:theValue(7)];
            [[[interstitial valueForKeyPath:@"placement.display.instl"] should] equal:theValue(YES)];
            [[[interstitial valueForKeyPath:@"placement.display.apiArray"] should] equal:[GPBEnumArray arrayWithValidationFunction:nil rawValue:5]];
            [[[interstitial valueForKeyPath:@"placement.display.unit"] should] equal:theValue(1)];
            [[[interstitial valueForKeyPath:@"placement.display.w"] should] equal:theValue(STKScreen.width)];
            [[[interstitial valueForKeyPath:@"placement.display.h"] should] equal:theValue(STKScreen.height)];
            [[[interstitial valueForKeyPath:@"placement.display.mimeArray"] should] equal:@[@"image/jpeg", @"image/jpg", @"image/gif", @"image/png"]];
            [[[interstitial valueForKeyPath:@"placement.extArray.adSpaceId"] should] equal:@[]];
        });
        it(@"should return BDMPlacementRequestBuilder from interstitial placement with Video ad type", ^{
            id interstitial = [BDMAdTypePlacement interstitialPlacementWithAdType:BDMFullscreenAdTypeVideo];

            [[[interstitial valueForKeyPath:@"placement.video.pos"] should] equal:theValue(7)];
            [[[interstitial valueForKeyPath:@"placement.video.skip"] should] equal:theValue(YES)];
            [[[interstitial valueForKeyPath:@"placement.video.ctypeArray"] should] equal:ANY(cTypeArray).reduce([GPBEnumArray array], ^(GPBEnumArray *array, NSNumber *value){
                [array addValue:value.unsignedIntValue];
            }).value];
            [[[interstitial valueForKeyPath:@"placement.video.unit"] should] equal:theValue(1)];
            [[[interstitial valueForKeyPath:@"placement.video.w"] should] equal:theValue(STKScreen.width)];
            [[[interstitial valueForKeyPath:@"placement.video.h"] should] equal:theValue(STKScreen.height)];
            [[[interstitial valueForKeyPath:@"placement.video.mimeArray"] should] equal:@[@"video/mpeg" , @"video/mp4", @"video/quicktime", @"video/avi"]];
            [[[interstitial valueForKeyPath:@"placement.video.maxdur"] should] equal:theValue(30)];
            [[[interstitial valueForKeyPath:@"placement.video.mindur"] should] equal:theValue(5)];
            [[[interstitial valueForKeyPath:@"placement.video.minbitr"] should] equal:theValue(56)];
            [[[interstitial valueForKeyPath:@"placement.video.maxbitr"] should] equal:theValue(4096)];
            [[[interstitial valueForKeyPath:@"placement.video.linear"] should] equal:theValue(1)];
            [[[interstitial valueForKeyPath:@"placement.extArray.adSpaceId"] should] equal:@[]];
        });
        it(@"should return BDMPlacementRequestBuilder from rewarded placement with Banner ad type", ^{
            id rewarded = [BDMAdTypePlacement rewardedPlacementWithAdType:BDMFullsreenAdTypeBanner];

            [[[rewarded valueForKeyPath:@"placement.display.pos"] should] equal:theValue(7)];
            [[[rewarded valueForKeyPath:@"placement.display.instl"] should] equal:theValue(YES)];
            [[[rewarded valueForKeyPath:@"placement.display.apiArray"] should] equal:[GPBEnumArray arrayWithValidationFunction:nil rawValue:5]];
            [[[rewarded valueForKeyPath:@"placement.display.unit"] should] equal:theValue(1)];
            [[[rewarded valueForKeyPath:@"placement.display.w"] should] equal:theValue(STKScreen.width)];
            [[[rewarded valueForKeyPath:@"placement.display.h"] should] equal:theValue(STKScreen.height)];
            [[[rewarded valueForKeyPath:@"placement.display.mimeArray"] should] equal:@[@"image/jpeg", @"image/jpg", @"image/gif", @"image/png"]];
            [[[rewarded valueForKeyPath:@"placement.extArray.adSpaceId"] should] equal:@[]];
        });
        it(@"should return BDMPlacementRequestBuilder from rewarded placement with Video ad type", ^{
            id rewarded = [BDMAdTypePlacement rewardedPlacementWithAdType:BDMFullscreenAdTypeVideo];
            
            [[[rewarded valueForKeyPath:@"placement.video.pos"] should] equal:theValue(7)];
            [[[rewarded valueForKeyPath:@"placement.video.skip"] should] equal:theValue(NO)];
            [[[rewarded valueForKeyPath:@"placement.video.ctypeArray"] should] equal:ANY(cTypeArray).reduce([GPBEnumArray array], ^(GPBEnumArray *array, NSNumber *value){
                [array addValue:value.unsignedIntValue];
            }).value];
            [[[rewarded valueForKeyPath:@"placement.video.unit"] should] equal:theValue(1)];
            [[[rewarded valueForKeyPath:@"placement.video.w"] should] equal:theValue(STKScreen.width)];
            [[[rewarded valueForKeyPath:@"placement.video.h"] should] equal:theValue(STKScreen.height)];
            [[[rewarded valueForKeyPath:@"placement.video.mimeArray"] should] equal:@[@"video/mpeg" , @"video/mp4", @"video/quicktime", @"video/avi"]];
            [[[rewarded valueForKeyPath:@"placement.video.maxdur"] should] equal:theValue(30)];
            [[[rewarded valueForKeyPath:@"placement.video.mindur"] should] equal:theValue(5)];
            [[[rewarded valueForKeyPath:@"placement.video.minbitr"] should] equal:theValue(56)];
            [[[rewarded valueForKeyPath:@"placement.video.maxbitr"] should] equal:theValue(4096)];
            [[[rewarded valueForKeyPath:@"placement.video.linear"] should] equal:theValue(1)];
            [[[rewarded valueForKeyPath:@"placement.extArray.adSpaceId"] should] equal:@[]];
        });
        it(@"should return BDMPlacementRequestBuilder from banner placement", ^{
            id banner = [BDMAdTypePlacement bannerPlacementWithAdSize:BDMBannerAdSize320x50];

            [[[banner valueForKeyPath:@"placement.display.instl"] should] equal:theValue(NO)];
            [[[banner valueForKeyPath:@"placement.display.apiArray"] should] equal:[GPBEnumArray arrayWithValidationFunction:nil rawValue:5]];
            [[[banner valueForKeyPath:@"placement.display.w"] should] equal:theValue(CGSizeFromBDMSize(BDMBannerAdSize320x50).width)];
            [[[banner valueForKeyPath:@"placement.display.h"] should] equal:theValue(CGSizeFromBDMSize(BDMBannerAdSize320x50).height)];
            [[[banner valueForKeyPath:@"placement.display.mimeArray"] should] equal:@[@"image/jpeg", @"image/jpg", @"image/gif", @"image/png"]];
            [[[banner valueForKeyPath:@"placement.extArray.adSpaceId"] should] equal:@[]];
            [[[banner valueForKeyPath:@"placement.display.unit"] should] equal:theValue(1)];
        });
        it(@"should return BDMPlacementRequestBuilder from native placement", ^{
            id native = [BDMAdTypePlacement nativePlacementWithAdType:BDMNativeAdTypeAllMedia];
            
            [[[native valueForKeyPath:@"placement.display.instl"] should] equal:theValue(NO)];
            [[[native valueForKeyPath:@"placement.display.mimeArray"] should] equal:@[@"image/jpeg", @"image/jpg", @"image/gif", @"image/png"]];
            [[[native valueForKeyPath:@"placement.extArray.adSpaceId"] should] equal:@[]];
            
            [[[[native valueForKeyPath:@"placement.display.nativefmt.assetArray.id_p"] objectAtIndex:0] should] equal:theValue(0)];
            [[[[native valueForKeyPath:@"placement.display.nativefmt.assetArray.req"] objectAtIndex:0]  should] equal:theValue(1)];
            [[[[[native valueForKeyPath:@"placement.display.nativefmt.assetArray.title"] objectAtIndex:0] valueForKey:@"len"] should] equal:theValue(104)];
            
            [[[[native valueForKeyPath:@"placement.display.nativefmt.assetArray.id_p"] objectAtIndex:1] should] equal:theValue(1)];
            [[[[native valueForKeyPath:@"placement.display.nativefmt.assetArray.req"] objectAtIndex:1]  should] equal:theValue(1)];
            [[[[[native valueForKeyPath:@"placement.display.nativefmt.assetArray.img"] objectAtIndex:1] valueForKey:@"type"] should] equal:theValue(1)];
            
            [[[[native valueForKeyPath:@"placement.display.nativefmt.assetArray.id_p"] objectAtIndex:2] should] equal:theValue(2)];
            [[[[native valueForKeyPath:@"placement.display.nativefmt.assetArray.req"] objectAtIndex:2]  should] equal:theValue(1)];
            [[[[[native valueForKeyPath:@"placement.display.nativefmt.assetArray.img"] objectAtIndex:2] valueForKey:@"type"] should] equal:theValue(3)];
            
            [[[[native valueForKeyPath:@"placement.display.nativefmt.assetArray.id_p"] objectAtIndex:3] should] equal:theValue(3)];
            [[[[native valueForKeyPath:@"placement.display.nativefmt.assetArray.req"] objectAtIndex:3]  should] equal:theValue(1)];
            [[[[[native valueForKeyPath:@"placement.display.nativefmt.assetArray.data_p"] objectAtIndex:3] valueForKey:@"type"] should] equal:theValue(2)];
            
            [[[[native valueForKeyPath:@"placement.display.nativefmt.assetArray.id_p"] objectAtIndex:4] should] equal:theValue(4)];
            [[[[native valueForKeyPath:@"placement.display.nativefmt.assetArray.req"] objectAtIndex:4]  should] equal:theValue(1)];
            [[[[[native valueForKeyPath:@"placement.display.nativefmt.assetArray.data_p"] objectAtIndex:4] valueForKey:@"type"] should] equal:theValue(12)];
            
            [[[[native valueForKeyPath:@"placement.display.nativefmt.assetArray.id_p"] objectAtIndex:5] should] equal:theValue(5)];
            [[[[native valueForKeyPath:@"placement.display.nativefmt.assetArray.req"] objectAtIndex:5]  should] equal:theValue(0)];
            [[[[[native valueForKeyPath:@"placement.display.nativefmt.assetArray.data_p"] objectAtIndex:5] valueForKey:@"type"] should] equal:theValue(3)];
            
            [[[[native valueForKeyPath:@"placement.display.nativefmt.assetArray.id_p"] objectAtIndex:6] should] equal:theValue(6)];
            [[[[native valueForKeyPath:@"placement.display.nativefmt.assetArray.req"] objectAtIndex:6]  should] equal:theValue(0)];
            [[[[[native valueForKeyPath:@"placement.display.nativefmt.assetArray.data_p"] objectAtIndex:6] valueForKey:@"type"] should] equal:theValue(1)];
            
            [[[[native valueForKeyPath:@"placement.display.nativefmt.assetArray.id_p"] objectAtIndex:7] should] equal:theValue(7)];
            [[[[native valueForKeyPath:@"placement.display.nativefmt.assetArray.req"] objectAtIndex:7]  should] equal:theValue(0)];
            [[[[[native valueForKeyPath:@"placement.display.nativefmt.assetArray.video"] objectAtIndex:7] valueForKey:@"skip"] should] equal:theValue(0)];
            [[[[[native valueForKeyPath:@"placement.display.nativefmt.assetArray.video"] objectAtIndex:7] valueForKey:@"ctypeArray"] should] equal:ANY(cTypeArray).reduce([GPBEnumArray array], ^(GPBEnumArray *array, NSNumber *value){
                [array addValue:value.unsignedIntValue];
            }).value];
        });
    });
    
});

SPEC_END
