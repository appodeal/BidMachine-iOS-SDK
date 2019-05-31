//
//  BDMRequest+ParallelBidding.h
//  BidMachine
//
//  Created by Stas Kochkin on 01/10/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import <BidMachine/BDMRequest.h>
#import <BidMachine/BDMNetworkItem.h>

@interface BDMRequest (ParallelBidding)
/**
 Identifier of current segment identifier
*/
@property (nonatomic, readwrite, copy, nullable) NSNumber * activeSegmentIdentifier;
/**
 Identifier of current segment identifier
 */
@property (nonatomic, readwrite, copy, nullable) NSNumber * activePlacement;
/**
 Networks config
 */
@property (nonatomic, readwrite, copy, nullable) NSArray <BDMNetworkItem *> * networks;
/**
 Custom parameters fot request
 */
@property (copy, nonatomic, readwrite, nullable) NSDictionary <NSString *, id> * customParameters;

@end
