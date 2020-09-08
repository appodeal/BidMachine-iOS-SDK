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


@interface BDMFacebookFullscreenAdapter : NSObject <BDMFullscreenAdapter>

@property (nonatomic, assign, readwrite) BOOL rewarded;
@property (nonatomic, weak, nullable) id <BDMAdapterLoadingDelegate> loadingDelegate;
@property (nonatomic, weak, nullable) id <BDMFullscreenAdapterDisplayDelegate> displayDelegate;

@end
