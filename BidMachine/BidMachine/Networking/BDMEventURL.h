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
 Replace BM_ACTION_START in URL
 */
@property (nonatomic, readonly, copy) BDMEventURL *(^extendedByStartTime)(NSDate *);
/**
 Replace BM_ACTION_FINISH in URL
 */
@property (nonatomic, readonly, copy) BDMEventURL *(^extendedByFinishTime)(NSDate *);
/**
 Replace macros 
 */
@property (nonatomic, readonly, copy) BDMEventURL *(^extendedByAction)(NSInteger);
/**
 Replace event macros
 */
@property (nonatomic, readonly, copy) BDMEventURL *(^extendedByEvent)(NSInteger);
/**
 Replace error codes
 */
@property (nonatomic, readonly, copy) BDMEventURL *(^extendedByErrorCode)(BDMErrorCode);
/**
 Replace type
 */
@property (nonatomic, readonly, copy) BDMEventURL *(^extendedByType)(NSString *);
/**
 Replace network name
 */
@property (nonatomic, readonly, copy) BDMEventURL *(^extendedByAdNetwork)(NSString *);
/**
 Instantiate event

 @param stringURL Destination URL string
 @param type Type of event
 @return Event URL
 */
+ (BDMEventURL *)trackerWithStringURL:(NSString *)stringURL type:(NSInteger)type;

@end


