//
//  BDMCriteoInterstitialAdapter.h
//
//  Copyright © 2020 Stas Kochkin. All rights reserved.
//

@import Foundation;
@import BidMachine;
@import BidMachine.Adapters;
@import CriteoPublisherSdk;

#import "BDMCriteoAdNetwork.h"

NS_ASSUME_NONNULL_BEGIN

@interface BDMCriteoInterstitialAdapter : NSObject <BDMFullscreenAdapter>

- (instancetype)initWithProvider:(id<BDMCriteoAdNetworkProvider>)provider;

@property (nonatomic, weak, nullable) id <BDMFullscreenAdapterDisplayDelegate> displayDelegate;
@property (nonatomic, weak, nullable) id <BDMAdapterLoadingDelegate> loadingDelegate;
@property (nonatomic, assign, readwrite) BOOL rewarded;

@end

NS_ASSUME_NONNULL_END
