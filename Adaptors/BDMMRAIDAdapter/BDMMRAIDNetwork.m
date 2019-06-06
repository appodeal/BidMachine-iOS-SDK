//
//  BDMMRAIDNetwork
//  BDMMRAIDNetwork
//
//  Created by Pavel Dunyashev on 11/09/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import "BDMMRAIDNetwork.h"
#import "BDMMRAIDInterstitialAdapter.h"
#import "BDMMRAIDBannerAdapter.h"


@interface BDMMRAIDNetwork ()

@end


@implementation BDMMRAIDNetwork

#pragma mark - BDMNetwork

+ (NSString *)name {
    return @"mraid";
}

+ (NSString *)sdkVersion {
    return @"3.0";
}

+ (Class<BDMFullscreenAdapter>)interstitialAdAdapterClassForSdk:(BDMSdk *)sdk {
    return BDMMRAIDInterstitialAdapter.class;
}

+ (Class<BDMBannerAdapter>)bannerAdapterClassForSdk:(BDMSdk *)sdk {
    return BDMMRAIDBannerAdapter.class;
}

@end

