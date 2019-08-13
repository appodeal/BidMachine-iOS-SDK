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

- (NSString *)name {
    return @"mraid";
}

- (NSString *)sdkVersion {
    return @"3.0";
}

- (id<BDMFullscreenAdapter>)interstitialAdAdapterForSdk:(BDMSdk *)sdk {
    return [BDMMRAIDInterstitialAdapter new];
}

- (id<BDMBannerAdapter>)bannerAdapterForSdk:(BDMSdk *)sdk {
    return [BDMMRAIDBannerAdapter new];
}

@end

