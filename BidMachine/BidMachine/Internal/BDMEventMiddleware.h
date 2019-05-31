//
//  BDMEventMidleware.h
//  BidMachine
//
//  Created by Stas Kochkin on 28/11/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BDMAdEventProducerProtocol.h"
#import "BDMDefines.h"

@class BDMEventURL;

typedef NS_ENUM(NSInteger, BDMEvent) {
    BDMEventLoaded = 500,
    BDMEventImpression = 501,
    BDMEventViewable = 502,
    BDMEventClick = 503,
    BDMEventClosed = 504,
    BDMEventDestroyed = 505,
};

@interface BDMEventMiddlewareBuilder : NSObject

@property (nonatomic, copy, readonly) BDMEventMiddlewareBuilder *(^events)(NSArray <BDMEventURL *>*(^)(void));
@property (nonatomic, copy, readonly) BDMEventMiddlewareBuilder *(^placement)(NSNumber *(^)(void));
@property (nonatomic, copy, readonly) BDMEventMiddlewareBuilder *(^segment)(NSNumber *(^)(void));
@property (nonatomic, copy, readonly) BDMEventMiddlewareBuilder *(^producer)(id<BDMAdEventProducer>(^)(void));

@end

@interface BDMEventMiddleware : NSObject

+ (instancetype)buildMidleware:(void(^)(BDMEventMiddlewareBuilder *))build;

- (void)registerEvent:(BDMEvent)type;
- (void)registerError:(BDMEvent)event code:(BDMErrorCode)code;

@end

