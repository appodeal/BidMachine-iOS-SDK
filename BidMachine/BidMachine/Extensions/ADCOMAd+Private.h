//
//  ADCOMAd+Private.h
//  BidMachine
//
//  Created by Stas Kochkin on 12/07/2019.
//  Copyright © 2019 Appodeal. All rights reserved.
//

#import "BDMProtoAPI-Umbrella.h"


@interface ADCOMAd (Private)

@property (nonatomic, copy, readonly) BDMHeaderBiddingAd *bdm_bannerHeaderBiddingAd;
@property (nonatomic, copy, readonly) BDMHeaderBiddingAd *bdm_videoHeaderBiddingAd;
@property (nonatomic, copy, readonly) BDMHeaderBiddingAd *bdm_nativeHeaderBiddingAd;

@end


