//
//  BDMAuctionInfo+Project.h
//  BidMachine
//
//  Created by Stas Kochkin on 21/11/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import <BidMachine/BidMachine.h>
#import "BDMResponseProtocol.h"

@interface BDMAuctionInfo (Private)

- (instancetype)initWithResponse:(id<BDMResponse>)response;

@end
