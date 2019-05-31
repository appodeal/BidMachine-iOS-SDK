//
//  BDMRetryTimer.h
//
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BDMRetryTimer;

typedef void(^BDMActionBlock)(BDMRetryTimer *);

@interface BDMRetryTimer : NSObject

+ (BDMRetryTimer *(^)(BDMActionBlock))timer;

- (void(^)(void))start;

- (void(^)(void))stop;

- (void(^)(void))repeat;

@end
