//
//  DSKSplashScreenView.m
//
//  Copyright © 2018 Stas Kochkin. All rights reserved.
//

#import "DSKSplashScreenView.h"
#import "DSKCloseButton.h"
#import "DSKSpinnerView.h"

#import <ASKExtension/ASKExtension.h>

@interface DSKSplashScreenView ()

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) DSKCloseButton *closeButton; // without close button

@end

@implementation DSKSplashScreenView

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.7];
    }
    return self;
}

- (void)presentViewFrom:(UIView *)view withInterval:(NSTimeInterval)interval {
    [self ask_constraint_edgesEqualToEdgesOfView:view];
    
    [self activateIndicator];
    [self startTimerWithInterval:interval];
}

- (void)dismiss:(dispatch_block_t)completion {
    [self invalidateTimer];
    
    [UIView animateWithDuration:0.9 animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        completion ? completion() : nil;
    }];
}

- (void)addTarget:(id)target action:(SEL)action {
    if (!self.closeButton) {
        self.closeButton = DSKCloseButton.new;
        [self.closeButton addTarget:target action:action];
    }
}

#pragma mark - Private

- (void)activateIndicator {
    DSKSpinnerView *indicator = [[DSKSpinnerView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [indicator appendToView:self];
    [indicator startAnimating];
}

- (void)startTimerWithInterval:(NSTimeInterval)interval {
    if (interval > 0.5) {
        [self invalidateTimer];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:interval
                                                      target:self
                                                    selector:@selector(timerTick)
                                                    userInfo:nil
                                                     repeats:NO];
    } else {
        [self timerTick];
    }
    
}

- (void)invalidateTimer {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)timerTick {
    [self invalidateTimer];
//    [self addTarget:self action:@selector(dismiss:)];
//    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
//    [self updateCloseConstraint]; // now without this button
}

- (void)updateCloseConstraint {
    if (!self.closeButton) {
        return;
    }
    self.closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.closeButton];
    
    [[self.closeButton.topAnchor constraintEqualToAnchor:self.topAnchor] setActive:YES];
    [[self.closeButton.rightAnchor constraintEqualToAnchor:self.rightAnchor] setActive:YES];
    [[self.closeButton.widthAnchor constraintEqualToConstant:60] setActive:YES];
    [[self.closeButton.heightAnchor constraintEqualToConstant:60] setActive:YES];
}

@end
