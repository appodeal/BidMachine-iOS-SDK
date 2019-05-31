//
//  DSKVideoEventTracker.h
//  OpenBids
//

//  Copyright © 2016 OpenBids, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DSKThirdPartyEventTracker : NSObject

+ (void)sendTrackingEvents:(NSArray *)trackingEvents;
+ (void)sendTrackingEvent:(NSString *)trackingEvent;

+ (void)sendError:(NSUInteger)errorCode trackingEvent:(NSString *)trackingEvent;

@end
