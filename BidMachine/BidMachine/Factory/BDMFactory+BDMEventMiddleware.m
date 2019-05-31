//
//  BDMFactory+BDMEventMiddleware.m
//  BidMachine
//
//  Created by Stas Kochkin on 11/01/2019.
//  Copyright © 2019 Appodeal. All rights reserved.
//

#import "BDMFactory+BDMEventMiddleware.h"
#import "BDMRequest+Private.h"
#import "BDMRequest+ParallelBidding.h"


@implementation BDMFactory (BDMEventMiddleware)

- (BDMEventMiddleware *)middlewareWithRequest:(BDMRequest *)request eventProducer:(id<BDMAdEventProducer>)eventProducer {
    __weak typeof(eventProducer) weakProducer = eventProducer;
    __weak typeof(request) weakRequest = request;
    return [BDMEventMiddleware buildMidleware:^(BDMEventMiddlewareBuilder * builder) {
        builder.segment(^NSNumber *{
            return weakRequest.activeSegmentIdentifier;
        });
        builder.placement(^NSNumber *{
            return weakRequest.activePlacement;
        });
        builder.events(^NSArray<BDMEventURL *> *{
            return weakRequest.eventTrackers;
        });
        builder.producer(^id<BDMAdEventProducer>{
            return weakProducer;
        });
    }];
}

@end
