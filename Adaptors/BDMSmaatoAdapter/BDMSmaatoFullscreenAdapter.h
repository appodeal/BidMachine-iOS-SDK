//
//  BDMSmaatoFullscreenAdapter.h
//  BDMSmaatoAdapter
//
//  Created by Ilia Lozhkin on 10/24/19.
//  Copyright © 2019 Stas Kochkin. All rights reserved.
//

@import Foundation;
@import BidMachine;
@import BidMachine.Adapters;


@interface BDMSmaatoFullscreenAdapter : NSObject <BDMFullscreenAdapter>

@property (nonatomic, weak, nullable) id <BDMFullscreenAdapterDisplayDelegate> displayDelegate;
@property (nonatomic, weak, nullable) id <BDMAdapterLoadingDelegate> loadingDelegate;
@property (nonatomic, assign, readwrite) BOOL rewarded;

@end
