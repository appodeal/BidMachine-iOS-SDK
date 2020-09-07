//
//  BDMCriteoInterstitialAdapter.h
//
//  Copyright © 2020 Stas Kochkin. All rights reserved.
//

#import "BDMCriteoAdNetwork.h"


NS_ASSUME_NONNULL_BEGIN

@interface BDMCriteoInterstitialAdapter : NSObject <BDMFullscreenAdapter>

- (instancetype)initWithProvider:(id<BDMCriteoAdNetworkProvider>)provider;

@property (nonatomic, assign, readwrite) BOOL rewarded;
@property (nonatomic, weak, nullable) id <BDMAdapterLoadingDelegate> loadingDelegate;
@property (nonatomic, weak, nullable) id <BDMFullscreenAdapterDisplayDelegate> displayDelegate;

@end

NS_ASSUME_NONNULL_END
