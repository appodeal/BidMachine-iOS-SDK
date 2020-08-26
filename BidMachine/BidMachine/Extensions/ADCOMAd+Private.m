//
//  ADCOMAd+Private.m
//  BidMachine
//
//  Created by Stas Kochkin on 12/07/2019.
//  Copyright © 2019 Appodeal. All rights reserved.
//

#import "ADCOMAd+Private.h"
#import <StackFoundation/StackFoundation.h>


@implementation ADCOMAd (Private)

- (BDMHeaderBiddingAd *)bdm_bannerHeaderBiddingAd {
    return [self bdm_headerBiddingAdFromExtensions:self.display.banner.extProtoArray];
}

- (BDMHeaderBiddingAd *)bdm_videoHeaderBiddingAd {
    return [self bdm_headerBiddingAdFromExtensions:self.video.extProtoArray];
}

- (BDMHeaderBiddingAd *)bdm_nativeHeaderBiddingAd {
    return [self bdm_headerBiddingAdFromExtensions:self.display.native.extProtoArray];
}

- (BDMHeaderBiddingAd *)bdm_headerBiddingAdFromExtensions:(NSArray <GPBAny *> *)extensions {
    return ANY(extensions)
    .filter(^BOOL(GPBAny *ext) {
        return [ext.typeURL hasSuffix:@"HeaderBiddingAd"];
    })
    .flatMap(^id(GPBAny *ext) {
        return ext.value ? [[BDMHeaderBiddingAd alloc] initWithData:ext.value error:nil] : nil;
    })
    .array.firstObject;
}

@end
