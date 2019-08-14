//
//  BDMAdColonyFullscreenAdapter.h
//  BDMAdColonyAdapter
//
//  Created by Stas Kochkin on 19/07/2019.
//  Copyright © 2019 Stas Kochkin. All rights reserved.
//

@import Foundation;
@import BidMachine;
@import BidMachine.Adapters;

#import "BDMAdColonyAdNetwork.h"

@interface BDMAdColonyFullscreenAdapter : NSObject <BDMFullscreenAdapter>

@property (nonatomic, weak, nullable) id <BDMFullscreenAdapterDisplayDelegate> displayDelegate;
@property (nonatomic, weak, nullable) id <BDMAdapterLoadingDelegate> loadingDelegate;
@property (nonatomic, assign, readwrite) BOOL rewarded;

- (nonnull instancetype)initWithProvider:(nonnull id<BDMAdColonyAdInterstitialProvider>)provider;

@end

