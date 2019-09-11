//
//  BDMAmazonBannerAdapter.m
//  BDMAmazonAdapter
//
//  Created by Yaroslav Skachkov on 9/10/19.
//  Copyright © 2019 Stas Kochkin. All rights reserved.
//

#import "BDMAmazonBannerAdapter.h"

@import DTBiOSSDK;
@import StackFoundation;
@import StackUIKit;

@interface BDMAmazonBannerAdapter() <DTBAdCallback>

@end

@implementation BDMAmazonBannerAdapter

- (UIView *)adView {
    return UIView.new;
}

- (void)prepareContent:(NSDictionary<NSString *,NSString *> *)contentInfo {
    CGSize bannerSize = [self.displayDelegate sizeForAdapter:self];
    DTBAdSize *size = [[DTBAdSize alloc] initBannerAdSizeWithWidth:bannerSize.width
                                                            height:bannerSize.height
                                                       andSlotUUID:@"your_slot_uuid"];
    DTBAdLoader *adLoader = [DTBAdLoader new];
    [adLoader setSizes:size, nil];
    [adLoader loadAd:self];
}

- (void)presentInContainer:(UIView *)container {
    
}


// Callbacks
- (void)onFailure:(DTBAdError)error {
    
}

- (void)onSuccess:(DTBAdResponse *)adResponse {
    
}


@end
