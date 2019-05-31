//
//  BDMPriceFloor.h
//  BidMachine
//
//  Created by Stas Kochkin on 05/10/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import "BDMPriceFloor.h"

@implementation BDMPriceFloor

- (instancetype)init {
    self = [super init];
    if (self) {
        self.ID = NSUUID.UUID.UUIDString;
        self.value = [NSDecimalNumber decimalNumberWithDecimal:[@0.01f decimalValue]];
    }
    return self;
}

@end
