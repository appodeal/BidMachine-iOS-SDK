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

#import "BDMNativeMediaView.h"

@interface BDMNASTDisplayAdapter ()

@property (nonatomic, strong) ANKAd * ad;
@property (nonatomic, strong) BDMNativeMediaView *mediaView;

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
        NSString *videoURL = self.ad.VASTInLineModel.creatives.firstObject.linear.mediafiles.firstObject.content;
        [self.mediaView setController:nil];
        [self.mediaView setPlaceholderURL:[NSURL URLWithString:self.ad.mainURLString]];
        [self.mediaView setVideoUrl:[NSURL URLWithString:videoURL]];
        
        [self.mediaView ask_constraint_edgesEqualToEdgesOfView:view.mediaContainerView];
        [self.mediaView render];
    }
}

- (BDMNativeMediaView *)mediaView {
    if (!_mediaView) {
        _mediaView = [[BDMNativeMediaView alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];
    }
    return _mediaView;
}

@end
