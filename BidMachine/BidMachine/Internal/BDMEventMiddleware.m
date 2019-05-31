//
//  BDMEventMidleware.m
//  BidMachine
//
//  Created by Stas Kochkin on 28/11/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//


#import "BDMEventMiddleware.h"
#import "NSArray+BDMEventURL.h"
#import "BDMServerCommunicator.h"

#import <ASKExtension/ASKExtension.h>


static NSInteger const BDMEventError = 1000;
static NSInteger const BDMEventTrackingError = 1001;


NSString * NSStringFromBDMEvent(BDMEvent event) {
    switch (event) {
        case BDMEventLoaded: return @"Loading"; break;
        case BDMEventClick: return @"User interaction"; break;
        case BDMEventClosed: return @"Closing"; break;
        case BDMEventViewable: return @"Viewable"; break;
        case BDMEventDestroyed: return @"Destroying"; break;
        case BDMEventImpression: return @"Impression"; break;
    }
}


NSString * NSStringFromBDMErrorCode(BDMErrorCode code) {
    switch (code) {
        case BDMErrorCodeInternal: return @"Internal"; break;
        case BDMErrorCodeTimeout: return @"Timeout"; break;
        case BDMErrorCodeException: return @"Exception"; break;
        case BDMErrorCodeNoContent: return @"No content"; break;
        case BDMErrorCodeWasClosed: return @"Was closed"; break;
        case BDMErrorCodeUnknown: return @"Unknown"; break;
        case BDMErrorCodeBadContent: return @"Bad content"; break;
        case BDMErrorCodeWasExpired: return @"Was expired"; break;
        case BDMErrorCodeNoConnection: return @"No internet connection"; break;
        case BDMErrorCodeWasDestroyed: return @"Was destroyed"; break;
        case BDMErrorCodeHTTPBadRequest: return @"Bad request"; break;
        case BDMErrorCodeHTTPServerError: return @"Internal server error"; break;
    }
}


@interface BDMEventMiddlewareBuilder ()

@property (nonatomic, copy) NSNumber *(^updatePlacement)(void);
@property (nonatomic, copy) NSNumber *(^updateSegment)(void);
@property (nonatomic, copy) NSArray<BDMEventURL *> *(^updateEvents)(void);
@property (nonatomic, copy) id<BDMAdEventProducer> (^updateProducer)(void);

@end

@implementation BDMEventMiddlewareBuilder

- (BDMEventMiddlewareBuilder *(^)(NSNumber *(^)(void)))segment {
    return ^id(NSNumber *(^updateSegment)(void)) {
        self.updateSegment = [updateSegment copy];
        return self;
    };
}

- (BDMEventMiddlewareBuilder *(^)(NSNumber *(^)(void)))placement {
    return ^id(NSNumber *(^updatePlacement)(void)) {
        self.updatePlacement = [updatePlacement copy];
        return self;
    };
}

- (BDMEventMiddlewareBuilder *(^)(NSArray<BDMEventURL *> *(^)(void)))events {
    return ^id(NSArray<BDMEventURL *> *(^updateEvents)(void)) {
        self.updateEvents = [updateEvents copy];
        return self;
    };
}

- (BDMEventMiddlewareBuilder *(^)(id<BDMAdEventProducer> (^)(void)))producer {
    return ^id(id<BDMAdEventProducer>(^updateProducer)(void)) {
        self.updateProducer = [updateProducer copy];
        return self;
    };
}

@end


@interface BDMEventMiddleware ()

@property (nonatomic, copy) NSNumber *(^updatePlacement)(void);
@property (nonatomic, copy) NSNumber *(^updateSegment)(void);
@property (nonatomic, copy) NSArray<BDMEventURL *> *(^updateEvents)(void);
@property (nonatomic, copy) id<BDMAdEventProducer> (^updateProducer)(void);

@end

@implementation BDMEventMiddleware

+ (instancetype)buildMidleware:(void(^)(BDMEventMiddlewareBuilder *))build {
    BDMEventMiddlewareBuilder * builder = BDMEventMiddlewareBuilder.new;
    build(builder);
    return [[self alloc] initWithBuilder:builder];
}

- (void)registerError:(BDMEvent)event code:(BDMErrorCode)code {
    BDMLog(@"Handling lifecycle error: %@ for %@ event", NSStringFromBDMErrorCode(code), NSStringFromBDMEvent(event));

    NSArray <BDMEventURL *> * trackers = ASK_RUN_BLOCK(self.updateEvents);
    BDMEventURL * URL = [trackers bdm_searchTrackerOfType:BDMEventError];
    if (!URL) {
        return;
    }
    
    URL = URL
    .extendedByAction(event)
    .extendedByErrorCode(code)
    .extendedBySegment(ASK_RUN_BLOCK(self.updateSegment))
    .extendedByPlacement(ASK_RUN_BLOCK(self.updatePlacement));
    
    [BDMServerCommunicator.sharedCommunicator trackEvent:URL];
}

- (void)registerEvent:(BDMEvent)type {
    BDMLog(@"Handling %@ event", NSStringFromBDMEvent(type));
    [self notifyProducerDelegateIfNeeded:type];
    NSArray <BDMEventURL *> * trackers = ASK_RUN_BLOCK(self.updateEvents);
    BDMEventURL * URL = [trackers bdm_searchTrackerOfType:type];
    if (!URL) {
        return;
    }
    
    BDMEventURL * fallbackURL = [trackers bdm_searchTrackerOfType:BDMEventTrackingError];

    URL = URL
    .extendedBySegment(ASK_RUN_BLOCK(self.updateSegment))
    .extendedByPlacement(ASK_RUN_BLOCK(self.updatePlacement));
    __weak typeof(self) weakSelf = self;
    [BDMServerCommunicator.sharedCommunicator trackEvent:URL success:nil failure:^(NSError * error) {
        [weakSelf fallback:type url:fallbackURL code:error.code];
    }];
}

#pragma mark - Private

- (instancetype)initWithBuilder:(BDMEventMiddlewareBuilder *)builder {
    if (self = [super init]) {
        self.updateEvents = [builder.updateEvents copy];
        self.updatePlacement = [builder.updatePlacement copy];
        self.updateSegment = [builder.updateSegment copy];
        self.updateProducer = [builder.updateProducer copy];
    }
    return self;
}

- (void)fallback:(BDMEvent)event url:(BDMEventURL *)url code:(BDMErrorCode)code {
    if (!url) {
        return;
    }
    
    BDMLog(@"Handling tracking error: %@ for %@ event", NSStringFromBDMErrorCode(code), NSStringFromBDMEvent(event));
    url = url
    .extendedByEvent(event)
    .extendedByErrorCode(code)
    .extendedBySegment(ASK_RUN_BLOCK(self.updateSegment))
    .extendedByPlacement(ASK_RUN_BLOCK(self.updatePlacement));
    
    [BDMServerCommunicator.sharedCommunicator trackEvent:url];
}

- (void)notifyProducerDelegateIfNeeded:(BDMEvent)event {
    switch (event) {
        case BDMEventViewable: {
            [[ASK_RUN_BLOCK(self.updateProducer) producerDelegate] didProduceImpression:ASK_RUN_BLOCK(self.updateProducer)];
            break; }
        case BDMEventClick: {
            [[ASK_RUN_BLOCK(self.updateProducer) producerDelegate] didProduceUserAction:ASK_RUN_BLOCK(self.updateProducer)];
            break; }
        default: break;
    }
}

@end
