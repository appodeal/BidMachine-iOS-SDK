//
//  BDMMyTargetCustomParams.h
//  BDMMyTargetAdapter
//
//  Created by Stas Kochkin on 19/07/2019.
//  Copyright © 2019 Stas Kochkin. All rights reserved.
//

@import MyTargetSDK;
@import BidMachine.HeaderBidding;

NS_ASSUME_NONNULL_BEGIN

@interface BDMMyTargetCustomParams : NSObject

+ (void)populate:(MTRGCustomParams *)params;

@end

NS_ASSUME_NONNULL_END
