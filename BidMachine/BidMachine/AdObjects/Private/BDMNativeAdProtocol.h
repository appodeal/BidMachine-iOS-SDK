//
//  BDMNativeAd.h
//  BidMachine
//
//  Created by Lozhkin Ilya on 5/31/18.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BidMachine/BDMNativeAd.h>

#define concrete optional

/**
 Native ad object
 */
@protocol BDMNativeAd <NSObject>

@optional

- (void)renderOnView:(UIView <BDMNativeAdView> *)view;

@property (nonatomic, readonly) NSArray <UIView *> * clickableViews;

@concrete
/**
 Id of active placement
 */
@property (nonatomic, copy) NSNumber * placementId;
/**
 Response returned from exchange server
 */
@property (nonatomic, strong) id exchangeResponse;
/**
 Fire impression tracker
 */
- (void)trackExchangeImpression;
/**
 Fire interaction tracker
 */
- (void)trackExchangeInteraction;
/**
 Fire finish tracker
 */
- (void)trackExchangeFinish;

@end

