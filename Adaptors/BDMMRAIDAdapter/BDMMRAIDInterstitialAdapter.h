//
//  BDMMRAIDInterstitialAdapter.h
//
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>
@import BidMachine.Adapters;


@interface BDMMRAIDInterstitialAdapter : NSObject <BDMFullscreenAdapter>

@property (nonatomic, weak) id <BDMFullscreenAdapterDisplayDelegate> displayDelegate;
@property (nonatomic, weak) id <BDMAdapterLoadingDelegate> loadingDelegate;

@property (nonatomic, assign, readwrite) BOOL rewarded;

@end
