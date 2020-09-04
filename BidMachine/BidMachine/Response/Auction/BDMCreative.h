//
//  BDMCreative.h
//  BidMachine
//
//  Created by Stas Kochkin on 21/11/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BDMResponseProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface BDMCreative : NSObject <BDMCreative>

+ (instancetype)parseFromBid:(ORTBResponse_Seatbid_Bid *)bid;

@end

NS_ASSUME_NONNULL_END
