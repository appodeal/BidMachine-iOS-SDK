//
//  BDMNativeAd.m
//  BidMachine
//
//  Created by Stas Kochkin on 31/10/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import "BDMNativeAd.h"
#import "BDMDefines.h"


@implementation BDMNativeAd

- (void)presentOnView:(UIView<BDMNativeAdView> *)adView fromRootViewController:(UIViewController *)rootViewController error:(NSError **)error {
    BDMLog(@"BDMNativeAd is under development and -presentOnView:fromRootViewController:error: call will be no-op");
}

- (void)makeRequest:(BDMRequest *)request {
    BDMLog(@"BDMNativeAd is under development and -makeRequest: call will be no-op");
}

- (void)invalidate {
    BDMLog(@"BDMNativeAd can't be invalidated");
}


@end
