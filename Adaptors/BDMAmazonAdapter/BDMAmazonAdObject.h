//
//  BDMAmazonAdObject.h
//  BDMAmazonAdapter
//
//  Created by Ilia Lozhkin on 07.09.2020.
//  Copyright © 2020 Stas Kochkin. All rights reserved.
//

@import Foundation;
@import BidMachine;
@import BidMachine.Adapters;

NS_ASSUME_NONNULL_BEGIN

@interface BDMAmazonBannerAdapter : NSObject <BDMBannerAdapter>

@property (nonatomic, weak, nullable) id <BDMAdapterLoadingDelegate> loadingDelegate;
@property (nonatomic, weak, nullable) id <BDMBannerAdapterDisplayDelegate> displayDelegate;

@end

@interface BDMAmazonInterstitialAdapter : NSObject <BDMFullscreenAdapter>

@property (nonatomic, weak, nullable) id <BDMAdapterLoadingDelegate> loadingDelegate;
@property (nonatomic, weak, nullable) id <BDMFullscreenAdapterDisplayDelegate> displayDelegate;

@end

NS_ASSUME_NONNULL_END
