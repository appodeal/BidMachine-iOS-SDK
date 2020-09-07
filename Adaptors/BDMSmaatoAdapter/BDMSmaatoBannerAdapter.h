//
//  BDMSmaatoBannerAdapter.h
//  BDMSmaatoAdapter
//
//  Created by Ilia Lozhkin on 10/24/19.
//  Copyright © 2019 Stas Kochkin. All rights reserved.
//

@import Foundation;
@import BidMachine;
@import BidMachine.Adapters;


NS_ASSUME_NONNULL_BEGIN

@interface BDMSmaatoBannerAdapter : NSObject <BDMBannerAdapter>

@property (nonatomic, weak, nullable) id<BDMAdapterLoadingDelegate> loadingDelegate;
@property (nonatomic, weak, nullable) id <BDMBannerAdapterDisplayDelegate> displayDelegate;

@end

NS_ASSUME_NONNULL_END
