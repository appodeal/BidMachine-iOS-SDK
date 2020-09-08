//
//  BDMAdColonyAdapter.h
//  BDMAdColonyAdapter
//
//  Created by Stas Kochkin on 19/07/2019.
//  Copyright © 2019 Stas Kochkin. All rights reserved.
//

@import AdColony;
@import Foundation;
@import BidMachine;
@import BidMachine.Adapters;

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const BDMAdColonyAppIDKey;
FOUNDATION_EXPORT NSString *const BDMAdColonyZoneIDKey;
FOUNDATION_EXPORT NSString *const BDMAdColonyZonesKey;

@protocol BDMAdColonyAdInterstitialProvider <NSObject>

- (nullable AdColonyInterstitial *)interstitialForZone:(NSString *)zone;

@end

@interface BDMAdColonyAdNetwork : NSObject <BDMNetwork, BDMAdColonyAdInterstitialProvider>

@end

NS_ASSUME_NONNULL_END
