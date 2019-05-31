//
//  BDMAuctionInfo.h
//  BidMachine
//
//  Created by Stas Kochkin on 22/10/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BidMachine/BDMDefines.h>

BDM_SUBCLASSING_RESTRICTED
/**
 Information of performed auction
 */
@interface BDMAuctionInfo : NSObject <NSCopying>
/**
 Identifier of win ad
 */
@property (nonatomic, copy, readonly, nullable) NSString * bidID;
/**
 Creative ID
 */
@property (nonatomic, copy, readonly, nullable) NSString * creativeID;
/**
 Creative cid
 */
@property (nonatomic, copy, readonly, nullable) NSString * cID;
/**
 Ad domains array
 */
@property (nonatomic, copy, readonly, nullable) NSArray <NSString *> * adDomains;
/**
 Demand name
 */
@property (nonatomic, copy, readonly, nullable) NSString * demandSource;
/**
 Auction price
 */
@property (nonatomic, copy, readonly, nullable) NSNumber * price;
@end

