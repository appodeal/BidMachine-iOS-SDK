//
//  BDMSessionBuilder.h
//
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "BDMTargeting.h"


@class GPBMessage;

@interface BDMSessionBuilder : NSObject

@property (nonatomic, readonly) GPBMessage *message;

- (BDMSessionBuilder *(^)(NSString *))appendSellerID;
- (BDMSessionBuilder *(^)(BDMTargeting *))appendTargeting;

@end
