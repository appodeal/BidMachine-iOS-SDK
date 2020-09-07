//
//  BDMSmaatoAdNetwork.h
//  BDMSmaatoAdapter
//
//  Created by Ilia Lozhkin on 10/24/19.
//  Copyright © 2019 Stas Kochkin. All rights reserved.
//

@import Foundation;
@import BidMachine;
@import BidMachine.Adapters;
@import BidMachine.HeaderBidding;


NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const BDMSmaatoIDKey;
FOUNDATION_EXPORT NSString *const BDMSmaatoPriceKey;
FOUNDATION_EXPORT NSString *const BDMSmaatoSpaceIDKey;

@interface BDMSmaatoAdNetwork : NSObject <BDMNetwork>

@end

NS_ASSUME_NONNULL_END
