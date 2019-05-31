//
//  BDMFactory+BDMEventMiddleware.h
//  BidMachine
//
//  Created by Stas Kochkin on 11/01/2019.
//  Copyright © 2019 Appodeal. All rights reserved.
//

#import "BDMFactory.h"
#import "BDMEventMiddleware.h"
#import "BDMRequest.h"


@interface BDMFactory (BDMEventMiddleware)

- (BDMEventMiddleware *)middlewareWithRequest:(BDMRequest *)request eventProducer:(id<BDMAdEventProducer>)eventProducer;

@end

