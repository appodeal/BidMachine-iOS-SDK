//
//  BDMNASTDisplayAdapter.m
//  BDMNASTAdapter
//
//  Created by Stas Kochkin on 04/11/2018.
//  Copyright © 2018 Stas Kochkin. All rights reserved.
//

#import "BDMNASTDisplayAdapter.h"
#import <StackUIKit/StackUIKit.h>


@interface BDMNASTDisplayAdapter ()

@property (nonatomic, strong) STKNASTAd *ad;

@end

@implementation BDMNASTDisplayAdapter

+ (instancetype)displayAdapterForAd:(STKNASTAd *)ad {
    return [[self alloc] initWithNativeAd:ad];
}

- (instancetype)initWithNativeAd:(STKNASTAd *)ad {
    if (self = [super init]) {
        self.ad = ad;
    }
    return self;
}

#pragma mark - BDMNativeAd

- (void)renderOnView:(UIView <BDMNativeAdView> *)view {
    view.titleLabel.text = self.ad.title;
    view.descriptionLabel.text = self.ad.descriptionText;
    view.callToActionLabel.text = self.ad.callToAction;
    
    if (view.iconView) {
        view.iconView.stkFastImageCache([NSURL URLWithString:self.ad.iconURLString]);
    }

    if (view.mediaContainerView) {
        // TODO: Add media view to native ad
    }
}

@end
