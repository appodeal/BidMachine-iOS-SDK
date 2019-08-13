//
//  BDMAdColonyAdapter.h
//  BDMAdColonyAdapter
//
//  Created by Stas Kochkin on 19/07/2019.
//  Copyright © 2019 Stas Kochkin. All rights reserved.
//

@import Foundation;
@import BidMachine;
@import BidMachine.Adapters;
@import AdColony;


@protocol BDMAdColonyAdInterstitialProvider <NSObject>

- (nullable AdColonyInterstitial *)interstitialForZone:(nonnull NSString *)zone;

@end


@interface BDMAdColonyAdNetwork : NSObject <BDMNetwork, BDMAdColonyAdInterstitialProvider>

@end
