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


NSString *NSStringFromBDMEvent(BDMEvent event) {
    switch (event) {
        case BDMEventCreativeLoading: return @"Creative loading"; break;
        case BDMEventClick: return @"User interaction"; break;
        case BDMEventClosed: return @"Closing"; break;
        case BDMEventViewable: return @"Viewable"; break;
        case BDMEventDestroyed: return @"Destroying"; break;
        case BDMEventImpression: return @"Impression"; break;
        case BDMEventAuction: return @"Auction"; break;
        case BDMEventInitialisation: return @"Initialisation"; break;
    }
}


BDMEvent BDMEventFromNSString(NSString *event) {
    if ([event isEqualToString:@"Creative loading"]) {
        return BDMEventCreativeLoading;
    } else if ([event isEqualToString:@"User interaction"]) {
        return BDMEventClick;
    } else if ([event isEqualToString:@"Closing"]) {
        return BDMEventClosed;
    } else if ([event isEqualToString:@"Viewable"]) {
        return BDMEventViewable;
    } else if ([event isEqualToString:@"Destroying"]) {
        return BDMEventDestroyed;
    } else if ([event isEqualToString:@"Impression"]) {
        return BDMEventImpression;
    } else if ([event isEqualToString:@"Auction"]) {
        return BDMEventAuction;
    } else if ([event isEqualToString:@"Initialisation"]) {
        return BDMEventInitialisation;
    }
    return 0;
}


NSString *NSStringFromBDMErrorCode(BDMErrorCode code) {
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

@property (nonatomic, strong) NSMutableDictionary <NSString *, NSDate *> *startTimeByEventType;
@property (nonatomic, copy) NSNumber *(^updatePlacement)(void);
@property (nonatomic, copy) NSNumber *(^updateSegment)(void);
@property (nonatomic, copy) NSArray<BDMEventURL *> *(^updateEvents)(void);
@property (nonatomic, copy) id<BDMAdEventProducer> (^updateProducer)(void);

@end

@implementation BDMEventMiddleware

+ (instancetype)buildMiddleware:(void(^)(BDMEventMiddlewareBuilder *))build {
    BDMEventMiddlewareBuilder * builder = BDMEventMiddlewareBuilder.new;
    build(builder);
    return [[self alloc] initWithBuilder:builder];
}

- (void)rejectAll:(BDMErrorCode)code {
    NSArray <NSString *> *enumerator = [[self.startTimeByEventType copy] allKeys];
    [enumerator enumerateObjectsUsingBlock:^(NSString *eventString, NSUInteger idx, BOOL *stop) {
        BDMEvent event = BDMEventFromNSString(eventString);
        // Send trackers for requiered events
        if (event != BDMEventViewable &&
            event != BDMEventClosed &&
            event != BDMEventImpression &&
            event != BDMEventClick) {
            [self rejectEvent:event code:code];
        // Just remove non required
        } else {
            [self.startTimeByEventType removeObjectForKey:eventString];
        }
    }];
}

- (void)rejectEvent:(BDMEvent)type
               code:(BDMErrorCode)code {
    NSString *eventString = NSStringFromBDMEvent(type);
    NSDate *startTime = self.startTimeByEventType[eventString];
    NSDate *finishTime = [NSDate date];
    [self.startTimeByEventType removeObjectForKey:eventString];
    
    BDMLog(@"Handling lifecycle error: %@ for %@ event, timing: %1.2f sec",
           NSStringFromBDMErrorCode(code),
           eventString,
           finishTime.timeIntervalSince1970 - startTime.timeIntervalSince1970);
    
    NSArray <BDMEventURL *> *trackers = ASK_RUN_BLOCK(self.updateEvents);
    BDMEventURL *URL = [trackers bdm_searchTrackerOfType:BDMEventError];
    if (!URL) {
        return;
    }
    
    URL = URL
    .extendedByStartTime(startTime)
    .extendedByFinishTime(finishTime)
    .extendedByAction(type)
    .extendedByErrorCode(code)
    .extendedBySegment(ASK_RUN_BLOCK(self.updateSegment))
    .extendedByPlacement(ASK_RUN_BLOCK(self.updatePlacement));
    
    [BDMServerCommunicator.sharedCommunicator trackEvent:URL];
}

- (void)startEvent:(BDMEvent)type {
    NSString *eventString = NSStringFromBDMEvent(type);
    NSDate *startTime = [NSDate date];
    self.startTimeByEventType[eventString] = startTime;
}

- (void)fulfillEvent:(BDMEvent)type {
    NSString *eventString = NSStringFromBDMEvent(type);
    NSDate *startTime = self.startTimeByEventType[eventString];
    NSDate *finishTime = [NSDate date];
    [self.startTimeByEventType removeObjectForKey:eventString];
    
    BDMLog(@"Handling %@ event, timing: %1.2f sec", eventString, finishTime.timeIntervalSince1970 - startTime.timeIntervalSince1970);
    [self notifyProducerDelegateIfNeeded:type];
    
    NSArray <BDMEventURL *> * trackers = ASK_RUN_BLOCK(self.updateEvents);
    BDMEventURL *URL = [trackers bdm_searchTrackerOfType:type];
    if (!URL) {
        return;
    }
    
    BDMEventURL *fallbackURL = [trackers bdm_searchTrackerOfType:BDMEventTrackingError];
    
    URL = URL
    .extendedByStartTime(startTime)
    .extendedByFinishTime(finishTime)
    .extendedBySegment(ASK_RUN_BLOCK(self.updateSegment))
    .extendedByPlacement(ASK_RUN_BLOCK(self.updatePlacement));
    
    __weak typeof(self) weakSelf = self;
    [BDMServerCommunicator.sharedCommunicator trackEvent:URL
                                                 success:nil
                                                 failure:^(NSError * error) {
                                                     [weakSelf fallback:type
                                                                    url:fallbackURL
                                                                   code:error.code
                                                              startTime:startTime
                                                             finishTime:finishTime];
                                                 }];
}

#pragma mark - Private

- (instancetype)initWithBuilder:(BDMEventMiddlewareBuilder *)builder {
    if (self = [super init]) {
        self.updateEvents           = [builder.updateEvents copy];
        self.updatePlacement        = [builder.updatePlacement copy];
        self.updateSegment          = [builder.updateSegment copy];
        self.updateProducer         = [builder.updateProducer copy];
        self.startTimeByEventType   = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)fallback:(BDMEvent)event
             url:(BDMEventURL *)url
            code:(BDMErrorCode)code
       startTime:(NSDate *)startTime
      finishTime:(NSDate *)finishTime {
    
    if (!url) {
        return;
    }
    
    BDMLog(@"Handling tracking error: %@ for event %@, timing: %1.2f sec",
           NSStringFromBDMErrorCode(code),
           NSStringFromBDMEvent(event),
           finishTime.timeIntervalSince1970 - startTime.timeIntervalSince1970);
    
    url = url
    .extendedByStartTime(startTime)
    .extendedByFinishTime(finishTime)
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
