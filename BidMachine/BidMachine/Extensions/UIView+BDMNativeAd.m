//
//  UIView+BDMNativeAd.m
//  BidMachine
//
//  Created by Stas Kochkin on 02/11/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import "UIView+BDMNativeAd.h"
#import <objc/runtime.h>

static const char kOPAssociatedNativeAdKey;


@implementation UIView (BDMNativeAd)

- (void)BDM_setAssociatedNativeAd:(id<BDMNativeAd>)nativeAd {
    objc_setAssociatedObject(self, &kOPAssociatedNativeAdKey, nativeAd, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id<BDMNativeAd>)BDM_associatedNativeAd {
    return objc_getAssociatedObject(self, &kOPAssociatedNativeAdKey);
}

@end
