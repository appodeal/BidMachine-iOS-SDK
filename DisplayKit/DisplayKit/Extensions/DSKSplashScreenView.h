//
//  DSKSplashScreenView.h
//
//  Copyright © 2018 Stas Kochkin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DSKSplashScreenView : UIView

- (void)addTarget:(id)target action:(SEL)action;

- (void)presentViewFrom:(UIView *)view
           withInterval:(NSTimeInterval)interval;

- (void)dismiss:(dispatch_block_t)completion;

@end
