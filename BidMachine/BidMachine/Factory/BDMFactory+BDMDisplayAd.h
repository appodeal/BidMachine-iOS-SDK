//
//  BDMFactory+BDMDisplayAd.h
//  BidMachine
//
//  Created by Stas Kochkin on 01/11/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import "BDMFactory.h"
#import "BDMDisplayAdProtocol.h"
#import "BDMRequest+Private.h"

@interface BDMFactory (BDMDisplayAd)

- (id<BDMDisplayAd>)displayAdWithResponse:(id<BDMResponse>)response plecementType:(BDMPlacementType)placementType;
- (id<BDMDisplayAd>)displayAdWithRequest:(BDMRequest *)request error:(NSError **)error;

@end

