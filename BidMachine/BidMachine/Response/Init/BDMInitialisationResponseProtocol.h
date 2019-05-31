//
//  BDMInitialisationResponseProtocol.h
//  BidMachine
//
//  Created by Stas Kochkin on 05/12/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BDMInitialisationResponse <NSObject>

@property (nonatomic, copy, readonly) NSURL * auctionURL;

@end

