//
//  BDMFacebookFullscreenAdapter.h
//  BDMFacebookAdapter
//
//  Created by Stas Kochkin on 23/07/2019.
//  Copyright © 2019 Stas Kochkin. All rights reserved.
//

@import Foundation;
@import BidMachine;
@import BidMachine.Adapters;

NS_ASSUME_NONNULL_BEGIN

@interface BDMFacebookFullscreenAdapter : NSObject <BDMFullscreenAdapter>

@property (nonatomic, weak, nullable) id <BDMFullscreenAdapterDisplayDelegate> displayDelegate;
@property (nonatomic, weak, nullable) id <BDMAdapterLoadingDelegate> loadingDelegate;
@property (nonatomic, assign, readwrite) BOOL rewarded;

@end

NS_ASSUME_NONNULL_END
