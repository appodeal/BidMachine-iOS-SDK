//
//  BDMMyTargetBannerAdapter.h
//  BDMMyTargetAdapter
//
//  Created by Stas Kochkin on 19/07/2019.
//  Copyright © 2019 Stas Kochkin. All rights reserved.
//

@import Foundation;
@import BidMachine;
@import BidMachine.Adapters;


NS_ASSUME_NONNULL_BEGIN

@interface BDMMyTargetBannerAdapter : NSObject <BDMBannerAdapter>

@property (nonatomic, weak, nullable) id<BDMAdapterLoadingDelegate> loadingDelegate;
@property (nonatomic, weak, nullable) id <BDMBannerAdapterDisplayDelegate> displayDelegate;

@end

NS_ASSUME_NONNULL_END
