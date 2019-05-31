//
//  UIView+BDMNativeAd.h
//  BidMachine
//
//  Created by Stas Kochkin on 02/11/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BDMAdapterProtocol.h"


@interface UIView (BDMNativeAd)

- (void)BDM_setAssociatedNativeAd:(id<BDMNativeAd>)nativeAd;
- (id<BDMNativeAd>)BDM_associatedNativeAd;

@end

