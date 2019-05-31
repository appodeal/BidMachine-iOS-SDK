//
//  CircleTimerButton.h
//
//  Copyright © 2016 OpenBids, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DSKGraphicButton.h"

@interface DSKCircleTimerButton : DSKGraphicButton

+ (instancetype) circleButtonWithSkippInterval:(NSTimeInterval)skippInterval;
+ (instancetype) closeButton;

- (void)start;
- (void)hideCircle;

- (void)startWithSkippInterval:(NSTimeInterval)skippInterval;

@end
