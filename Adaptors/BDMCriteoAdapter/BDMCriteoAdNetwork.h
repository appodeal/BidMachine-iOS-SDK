//
//  BDMCriteoAdNetwork.h
//
//  Copyright © 2019 Stas Kochkin. All rights reserved.
//

@import Foundation;
@import BidMachine;
@import BidMachine.Adapters;
@import CriteoPublisherSdk;


@protocol BDMCriteoAdNetworkProvider <NSObject>

- (nullable CRBidToken *)bidTokenForAdUnitId:(nonnull NSString *)adUnitId;

@end

@interface BDMCriteoAdNetwork : NSObject <BDMNetwork, BDMCriteoAdNetworkProvider>

@end
