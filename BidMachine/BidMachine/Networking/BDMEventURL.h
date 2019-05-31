//
//  BDMEventTracker.h
//  BidMachine
//
//  Created by Stas Kochkin on 24/10/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BDMDefines.h"
#import "BDMProtoAPI-Umbrella.h"
#import "BDMEventMiddleware.h"


/**
 Wrapper for event for mapping to BDMEventTypeExtended from Extension of proto models
 @param event Event (or extended errors)
 @return Raw value of BDMEventTypeExtended
 */
NSInteger BDMEventTrackerTypeFromBDMEvent(BDMEvent event);
/**
 Wrapper for event for mapping to BDMActionType from Extension of proto models

 @param event Event, exteneded errors not supports here!
 @return Raw value of BDMActionType
 */
NSInteger BDMActionTypeFromBDMEvent(BDMEvent event);


@interface BDMEventURL : NSURL

@property (nonatomic, readonly, assign) NSInteger type;
/**
 Replace macros PLACEMENT in URL
 */
@property (nonatomic, readonly, copy) BDMEventURL *(^extendedByPlacement)(NSNumber *);
/**
 Replace macros SEGMENT in URL
 */
@property (nonatomic, readonly, copy) BDMEventURL *(^extendedBySegment)(NSNumber *);
/**
 Replace macros 
 */
@property (nonatomic, readonly, copy) BDMEventURL *(^extendedByAction)(NSInteger);
@property (nonatomic, readonly, copy) BDMEventURL *(^extendedByEvent)(NSInteger);

@property (nonatomic, readonly, copy) BDMEventURL *(^extendedByErrorCode)(BDMErrorCode);

+ (BDMEventURL *)trackerWithStringURL:(NSString *)stringURL type:(NSInteger)type;

@end


