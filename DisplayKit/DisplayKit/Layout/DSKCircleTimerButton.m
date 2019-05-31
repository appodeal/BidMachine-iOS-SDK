//
//  CircleTimerButton.m
//
//  Copyright © 2016 OpenBids, Inc. All rights reserved. 0.01666667
//

#import "DSKCircleTimerButton.h"

#import <ASKExtension/ASKTimer.h>
#import <ASKExtension/UIButton+ASKExtension.h>

#define SKIP_TEXT(INTERVAL) [NSString stringWithFormat:@"%d", (int) INTERVAL]
#define DEFAULT_TIMER_TICK                          0.25


@interface DSKCircleTimerButton ()

@property (nonatomic, assign) NSTimeInterval skipInterval;
@property (nonatomic, assign) NSTimeInterval currentTime;

@property (nonatomic, strong) ASKTimer* skipTimer;

@property (nonatomic, assign) float percentageCompleted;
@property (nonatomic, assign) BOOL hideWithTime;

@end

@implementation DSKCircleTimerButton

#pragma mark - Public

- (void)dealloc {
    [self.skipTimer cancel];
}

+ (instancetype) circleButtonWithSkippInterval:(NSTimeInterval)skippInterval {
    
    DSKCircleTimerButton* circleTimerContentView = [DSKCircleTimerButton new];
    
    {
        circleTimerContentView.currentTime = 0.0f;
        circleTimerContentView.skipInterval = skippInterval ?: -1;
    }
    
    [circleTimerContentView isReadyAndShowSkipButton];
    
    return circleTimerContentView;
}

+ (instancetype) closeButton{
    return [[self class] circleButtonWithSkippInterval:0];
}

- (void)startWithSkippInterval:(NSTimeInterval)skippInterval{
    self.currentTime = 0.0f;
    self.skipInterval = skippInterval ?: -1;
    
    [self start];
}

- (void) start {
    if ([self isReadyAndShowSkipButton]) {
        return;
    }
    self.userInteractionEnabled = NO;
    [self startSkipTimerWithTimerTick:DEFAULT_TIMER_TICK];
}

- (void) hideCircle {
    self.hideWithTime = YES;
}

#pragma mark --- Private methods

- (void) setCloseButtonOnView{
    self.userInteractionEnabled = YES;
    [self drawButtonWithType:DSKGraphicsButtonClose];
}

- (BOOL) isReadyAndShowSkipButton {
    if (self.skipInterval < self.currentTime) {
        [self setCloseButtonOnView];
        [self.skipTimer cancel];
        return YES;
    }
    return NO;
}

#pragma mark --- Timer start - work - stop

- (void) startSkipTimerWithTimerTick:(NSTimeInterval)timerTick {
    __weak typeof(self) weakSelf = self;
    self.skipTimer = [ASKTimer timerWithInterval:timerTick periodic:YES block:^{
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf timerTick:timerTick];
    }];
}

#pragma mark --- Tick

- (void) timerTick:(CGFloat)timerTick {
    
    if (![self isReadyAndShowSkipButton]) {
        if (!self.hideWithTime) {
            self.percentageCompleted = self.currentTime * 100 / self.skipInterval;
            NSTimeInterval time = self.skipInterval-self.currentTime;
            if (self.type == DSKGraphicsButtonClose) {
            } else {
                [self drawTimerWithTime:SKIP_TEXT(roundf(time)) persent:self.percentageCompleted];
            }
        } else {
            if (self.type != DSKGraphicsButtonNoContent) {
                [self drawButtonWithType:DSKGraphicsButtonNoContent];
            }
        }
    }
    self.currentTime += timerTick;
}

@end
