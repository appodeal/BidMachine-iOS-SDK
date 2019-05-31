//
//  DSKGraphicButton.h
//  OpenBids
//

//  Copyright © 2016 OpenBids, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DSKConstraintMaker.h"

typedef NS_ENUM(NSUInteger, DSKGraphicsButtonType) {
    DSKGraphicsButtonNoContent = 0,
    DSKGraphicsButtonClose,
    DSKGraphicsButtonRepeat,
    DSKGraphicsButtonTimer,
    DSKGraphicsButtonText,
    DSKGraphicsButtonMuteOn,
    DSKGraphicsButtonMuteOff,
    DSKGraphicsButtonPlay
};

@interface DSKGraphicButton : UIView

@property (nonatomic, assign, readonly) DSKGraphicsButtonType type;

- (void)drawButtonWithType:(DSKGraphicsButtonType)graphicsButtonType;

- (void)drawTimerWithTime:(NSString *)time persent:(CGFloat)persent;

- (void)drawText:(NSString *)text;


- (void)setFillColor:(UIColor *)fillColor;

- (void)setStrokeColor:(UIColor *)strokeColor;

- (void)addTarget:(id)target action:(SEL)action;


- (NSString *)getCurrentContent;

- (void)apdGraphicsMakeConstraints:(void(^)(DSKConstraintMaker * maker))block;

- (void)apdGraphicsMakeConstraintsOnView:(UIView *)view withBlock:(void(^)(DSKConstraintMaker * maker))block;

@end
