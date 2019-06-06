//
//  BDMDisplayAd.h
//  BidMachine
//
//  Created by Stas Kochkin on 29/10/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BDMAdapterProtocol.h"
#import "BDMResponse.h"
#import "BDMRequest+Private.h"


@protocol BDMDisplayAd;

@protocol BDMDisplayAdDelegate  <NSObject>

- (void)displayAdReady:(id<BDMDisplayAd>)displayAd;
- (void)displayAd:(id<BDMDisplayAd>)displayAd failedWithError:(NSError *)error;
- (void)displayAdLogStartView:(id<BDMDisplayAd>)displayAd;
- (void)displayAdLogImpression:(id<BDMDisplayAd>)displayAd;
- (void)displayAdLogFinishView:(id<BDMDisplayAd>)displayAd;
- (void)displayAdLogUserInteraction:(id<BDMDisplayAd>)displayAd;
- (void)displayAd:(id<BDMDisplayAd>)displayAd failedToPresent:(NSError *)error;

@optional

- (void)displayAdCompleteRewardAction:(id<BDMDisplayAd>)displayAd;
- (void)displayAdWillLeaveApplication:(id<BDMDisplayAd>)displayAd;
- (void)displayAdWillPresentScreen:(id<BDMDisplayAd>)displayAd;
- (void)displayAdDidDismissScreen:(id<BDMDisplayAd>)displayAd;

@end

@protocol BDMDisplayAd <NSObject>

@property (nonatomic, weak, readwrite) id <BDMDisplayAdDelegate> delegate;
@property (nonatomic, weak, readonly) UIView * adView;
@property (nonatomic, copy, readonly) NSString * responseID;

@property (nonatomic, assign, readonly) BOOL hasLoadedCreative;
@property (nonatomic, assign, readonly) BOOL availableToPresent;

+ (instancetype)displayAdWithResponse:(id<BDMResponse>)response placementType:(BDMInternalPlacementType)placementType;
- (void)presentAd:(UIViewController *)controller container:(UIView *)container;
- (void)prepare;
- (void)invalidate;

@end
