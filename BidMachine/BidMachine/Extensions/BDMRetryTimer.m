//
//  BDMRetryTimer.m
//
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import "BDMRetryTimer.h"
#import <ASKExtension/ASKExtension.h>

static NSInteger const kBDMRetryTimerIntervalDegreeThreshold = 7;

@interface BDMRetryTimer ()

@property (nonatomic,   copy) BDMActionBlock actionBlock;
@property (nonatomic, strong) ASKTimer *timer;
@property (nonatomic, assign) int repeatCount;

@end

@implementation BDMRetryTimer

+ (BDMRetryTimer *(^)(BDMActionBlock))timer {
    return ^BDMRetryTimer *(BDMActionBlock block){
        BDMRetryTimer *timer = [BDMRetryTimer new];
        timer.actionBlock = block;
        return timer;
    };
}

- (void (^)(void))start {
    return ^{
        ASK_RUN_BLOCK(self.actionBlock, self);
    };
}

- (void (^)(void))stop {
    return ^{
        if (self.timer) {
            [self.timer cancel];
            
            self.timer          = nil;
            self.repeatCount    = 0;
        }
    };
}

- (void (^)(void))repeat {
    return ^{
        __weak typeof(self) weakSelf = self;
        self.timer = [ASKTimer timerWithInterval:self.repeatInterval periodic:NO block:^{
            ASK_RUN_BLOCK(weakSelf.actionBlock, weakSelf);
        }];
    };
}

#pragma mark - Private

- (float)repeatInterval {
    if (self.repeatCount < kBDMRetryTimerIntervalDegreeThreshold) {
        ++self.repeatCount;
    }
    return 1 << self.repeatCount;
}

@end
