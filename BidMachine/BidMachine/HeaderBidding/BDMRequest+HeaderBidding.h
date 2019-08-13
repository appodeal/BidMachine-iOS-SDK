//
//  BDMRequest+HeaderBidding.h
//  BidMachine
//
//  Created by Stas Kochkin on 01/10/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import <BidMachine/BDMRequest.h>

@interface BDMRequest (HeaderBidding)
/**
 Custom parameters fot request
 */
@property (copy, nonatomic, readwrite, nullable) NSDictionary <NSString *, id> *customParameters;

@end
