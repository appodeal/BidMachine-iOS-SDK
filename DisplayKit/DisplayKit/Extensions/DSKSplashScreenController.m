//
//  DSKSplashScreenController.m
//

#import "DSKSplashScreenController.h"
#import "DSKCloseButton.h"
#import "DSKSpinnerView.h"

#import <ASKExtension/ASKExtension.h>

@interface DSKSplashScreenController ()

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) DSKCloseButton *closeButton;
@property (nonatomic, strong) UIVisualEffectView * effectView;

@end

@implementation DSKSplashScreenController

- (instancetype)init {
    if (self = [super init]) {
        self.modalPresentationStyle = UIModalPresentationOverFullScreen;
        
        BOOL blured = YES;
        if (blured) {
            self.effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
            self.effectView.alpha = 0.5f;
            
            [self.effectView ask_constraint_edgesEqualToEdgesOfView:self.view];
        } else {
            self.view.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.4];
        }
    }
    return self;
}

- (void)presentFromViewController:(UIViewController *)controller
                     withInterval:(NSTimeInterval)interval {
    [controller presentViewController:self animated:NO completion:nil];
    
    [self activateIndicator];
    [self startTimerWithInterval:interval];
}

- (void)dismiss {
    [self invalidateTimer];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addTarget:(id)target action:(SEL)action {
    if (!self.closeButton) {
        self.closeButton = DSKCloseButton.new;
        [self.closeButton addTarget:target action:action];
    }
}

#pragma mark - Private

- (void)activateIndicator {
    DSKSpinnerView *indicator = [[DSKSpinnerView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [indicator appendToView:self.effectView.contentView];
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
    
//    [self addTarget:self action:@selector(dismiss)];
//    Removing spinner view
//    [[self.effectView.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self updateCloseConstraint];
}

- (void)updateCloseConstraint {
    if (!self.closeButton) {
        return;
    }
    self.closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.effectView.contentView addSubview:self.closeButton];
    
    if (@available(iOS 11.0, *)) {
        [[self.closeButton.topAnchor constraintEqualToAnchor:self.effectView.contentView.safeAreaLayoutGuide.topAnchor] setActive:YES];
        [[self.closeButton.rightAnchor constraintEqualToAnchor:self.effectView.contentView.safeAreaLayoutGuide.rightAnchor] setActive:YES];
    } else {
        [[self.closeButton.topAnchor constraintEqualToAnchor:self.effectView.contentView.topAnchor] setActive:YES];
        [[self.closeButton.rightAnchor constraintEqualToAnchor:self.effectView.contentView.rightAnchor] setActive:YES];
    }
    
    [[self.closeButton.widthAnchor constraintEqualToConstant:60] setActive:YES];
    [[self.closeButton.heightAnchor constraintEqualToConstant:60] setActive:YES];
}

@end
