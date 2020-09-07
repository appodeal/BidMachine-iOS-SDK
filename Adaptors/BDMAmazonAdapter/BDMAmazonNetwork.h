//
//  BDMAmazonNetwork.h
//  BDMAmazonNetwork
//
//  Created by Yaroslav Skachkov on 9/10/19.
//  Copyright © 2019 Stas Kochkin. All rights reserved.
//

@import Foundation;
@import BidMachine;
@import BidMachine.Adapters;


NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const BDMAmazonAppIDKey;
FOUNDATION_EXPORT NSString *const BDMAmazonSlotIdKey;

@interface BDMAmazonNetwork : NSObject <BDMNetwork>

@end

NS_ASSUME_NONNULL_END
