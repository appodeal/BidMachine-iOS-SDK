//
//  DSKSpinnerView.m
//
//  Copyright © 2018 Stas Kochkin. All rights reserved.
//

#import "DSKSpinnerView.h"
#import <ASKExtension/ASKExtension.h>

@interface DSKSpinnerView ()

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@end

@implementation DSKSpinnerView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        CGFloat scale = CGRectGetHeight(self.frame) / 20;
        CGAffineTransform transform = CGAffineTransformMakeScale(scale, scale);
        
        self.indicatorView.transform = transform;
        [self addSubview:self.indicatorView];
        self.indicatorView.layer.position = self.center;
    }
    return self;
}

- (UIActivityIndicatorView *)indicatorView {
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:self.frame];
        _indicatorView.color = UIColor.ask_mainColor;
    }
    return _indicatorView;
}

- (void)startAnimating {
    [self.indicatorView startAnimating];
}

- (void)stopAnimating {
    [self.indicatorView stopAnimating];
}

- (void)appendToView:(UIView *)view {
    if (!self.superview && view) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        [view addSubview:self];
        
        [[self.centerXAnchor constraintEqualToAnchor:view.centerXAnchor] setActive:YES];
        [[self.centerYAnchor constraintEqualToAnchor:view.centerYAnchor] setActive:YES];
        [[self.widthAnchor constraintEqualToConstant:CGRectGetWidth(self.frame)] setActive:YES];
        [[self.heightAnchor constraintEqualToConstant:CGRectGetHeight(self.frame)] setActive:YES];
    };
}

- (void)removeFromSuperview {
    [super removeFromSuperview];
    [self stopAnimating];
}

@end
