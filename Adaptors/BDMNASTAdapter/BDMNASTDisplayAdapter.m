//
//  BDMNASTDisplayAdapter.m
//  BDMNASTAdapter
//
//  Created by Stas Kochkin on 04/11/2018.
//  Copyright © 2018 Stas Kochkin. All rights reserved.
//

#import "BDMNASTDisplayAdapter.h"
#import <ASKDiskUtils/ASKDiskUtils.h>
#import <ASKExtension/ASKExtension.h>


@interface BDMNASTDisplayAdapter ()

@property (nonatomic, strong) ANKAd *ad;

@end

@implementation BDMNASTDisplayAdapter

+ (instancetype)displayAdapterForAd:(ANKAd *)ad {
    return [[self alloc] initWithNativeAd:ad];
}

- (instancetype)initWithNativeAd:(ANKAd *)ad {
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
        view.iconView.askFastImageCache([NSURL URLWithString:self.ad.iconURLString]);
    }

    if (view.mediaContainerView) {
        // TODO: Add media view to native ad
    }
}

@end
