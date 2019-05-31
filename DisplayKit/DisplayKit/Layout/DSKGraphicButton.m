//
//  DSKGraphicButton.m
//  OpenBids
//

//  Copyright © 2016 OpenBids, Inc. All rights reserved.
//

#import "DSKGraphicButton.h"

#import <math.h>

#import <ASKExtension/UIView+ASKExtension.h>
#import <ASKExtension/UIColor+ASKExtension.h>
#import <ASKExtension/NSObject+ASKExtension.h>
#import "UIView+DSKConstraint.h"
#import "DSKConstraintMaker+Private.h"


#define IPHONE                                       [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone
#define DEGREES_TO_RADIANS(degrees)                  ((M_PI * degrees)/180)
#define DEFAULT_INSET(_V)                            UIEdgeInsetsMake(- _V, - _V, - _V, - _V)

#define SHADOW_INSET_SIZE                            CGSizeMake(5.0, 5.0)
#define SHADOW_STRONG                                5
#define TIMER_IN_REVERSE                             NO
#define SHADOW_VISIBLE                               NO


@interface DSKGraphicButton ()

@property (nonatomic, assign, readwrite) DSKGraphicsButtonType type;
@property (nonatomic, strong) NSString * stringContent;

@property (nonatomic, strong) UIColor * fillColor;
@property (nonatomic, strong) UIColor * strokeColor;
@property (nonatomic, strong) UIColor * borderStrokeColor;

@property (nonatomic, assign, getter=isShadow) BOOL shadow;

@property (nonatomic, assign) CGFloat persent;

@property (nonatomic, assign) CGSize shadowInsetSize;
@property (nonatomic, assign) CGFloat shadowRadius;

@property (nonatomic, assign) UIEdgeInsets insets;

@property (nonatomic, assign) BOOL needUpdateConstrain;

@end

@implementation DSKGraphicButton

#pragma mark --- Public

- (instancetype) init {
    self = [super init];
    if (self) {
        self.fillColor = [UIColor ask_defaultFillColor];
        self.strokeColor = [UIColor ask_defaultStrokeColor];
        self.borderStrokeColor = UIColor.clearColor;
        
        self.type = DSKGraphicsButtonNoContent;
        self.persent = 0;
        self.backgroundColor = UIColor.clearColor;
        
        if (IPHONE) {
            self.insets = DEFAULT_INSET(20);
        } else {
            self.insets = DEFAULT_INSET(30);
        }
        
        [self setContentMode:UIViewContentModeRedraw];
    }
    return self;
}

- (void)drawButtonWithType:(DSKGraphicsButtonType)graphicsButtonType{
    self.type = graphicsButtonType;
    [self setNeedsDisplay];
}

- (void)drawTimerWithTime:(NSString *)time persent:(CGFloat)persent {
    self.type = DSKGraphicsButtonTimer;
    self.persent = persent;
    self.stringContent = time;
    [self setNeedsDisplay];
    
}

- (void)drawText:(NSString *)text{
    self.type = DSKGraphicsButtonText;
    self.persent = 100;
    self.stringContent = text;
    
    [self DSK_updateConstraintsIfNeeded];
    [self setNeedsDisplay];
}

- (void)addTarget:(id)target action:(SEL)action {
    self.userInteractionEnabled = YES;
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
    [self addGestureRecognizer:tap];
}

- (NSString *)getCurrentContent {
    return self.stringContent;
}

- (void)apdGraphicsMakeConstraints:(void (^)(DSKConstraintMaker *))block{
    [self apdGraphicsMakeConstraintsOnView:nil withBlock:block];
}

- (void)apdGraphicsMakeConstraintsOnView:(UIView *)view withBlock:(void (^)(DSKConstraintMaker *))block{
    if (!block) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [self DSK_makeConstraintsOnView:view withBlock:^(DSKConstraintMaker *maker) {
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf.translatesAutoresizingMaskIntoConstraints = NO;
        block(maker);
        if (self.type == DSKGraphicsButtonText) {
            CGFloat height = maker.height.floatValue;
            CGSize contentSize = [strongSelf contentSizeWithContentHeight:height];
            CGSize frameSize = [strongSelf frameSizeWithContentSize:contentSize andCurrentHeight:height];
            maker.height = @(frameSize.height);
            maker.width = @(frameSize.width);
        }

        
        [maker updateInsetsWithBorderOffset:5 clickOffset:IPHONE ? 30 : 50];
        self.insets = maker.insets;
    }];
}

#pragma mark --- Service Text

- (CGSize)frameSizeWithContentSize:(CGSize)contentSize andCurrentHeight:(CGFloat)currentHeight{
    return CGSizeMake(contentSize.width + currentHeight, currentHeight);
}

- (CGSize)contentSizeWithContentHeight:(CGFloat)contentHeight{
    NSAttributedString *attributedText = [self attributedStringWithCurrentContent:self.stringContent contentSize:CGSizeMake(0, contentHeight)];
    if (attributedText) {
        return [attributedText size];
    } else {
        return CGSizeZero;
    }
}

- (NSAttributedString *) attributedStringWithCurrentContent:(NSString *)contentString contentSize:(CGSize)contentSize{
    if (contentString && ![contentString isEqualToString:@""]) {
        
        UIFont *font = [UIFont systemFontOfSize:contentSize.height * 0.6];
        
        NSShadow *shadow = [[NSShadow alloc] init];
        shadow.shadowColor = [UIColor blackColor];
        shadow.shadowBlurRadius = self.shadowRadius;
        shadow.shadowOffset = self.shadowInsetSize;
        
        NSMutableParagraphStyle* paragraph = [[NSMutableParagraphStyle alloc] init];
        [paragraph setAlignment:NSTextAlignmentCenter];
        [paragraph setLineBreakMode:NSLineBreakByClipping];
        
        NSDictionary *attributes;
        if (self.type == DSKGraphicsButtonText && self.isShadow) {
            attributes = @{NSShadowAttributeName          : shadow,
                           NSForegroundColorAttributeName : self.strokeColor,
                           NSFontAttributeName            : font,
                           NSParagraphStyleAttributeName  : paragraph};
        } else {
            attributes = @{NSForegroundColorAttributeName : self.strokeColor,
                           NSFontAttributeName            : font,
                           NSParagraphStyleAttributeName  : paragraph};
        }
        
        NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:contentString attributes:attributes];
        
//        CGSize textSize = [attributedText size];
//        
//        [attributedText drawInRect:CGRectInset(rect, 0, (CGRectGetHeight(rect) - textSize.height) / 2)];
        return attributedText;
    }
    return nil;
}

#pragma mark - override propery

- (BOOL)isShadow {
    return SHADOW_VISIBLE && _shadow;
}

#pragma mark --- Private

- (void)drawRect:(CGRect)rect{
    CGRect drawRect = CGRectMake(- self.insets.left, - self.insets.top, rect.size.width + self.insets.left + self.insets.right, rect.size.height + self.insets.top + self.insets.bottom);
    
    CGFloat interfacePercent = drawRect.size.height / 100;
    self.shadowRadius = interfacePercent * SHADOW_STRONG;
    self.shadowInsetSize = CGSizeMake(interfacePercent * SHADOW_INSET_SIZE.width, interfacePercent * SHADOW_INSET_SIZE.height);
    
    
    CGFloat lineWidth = drawRect.size.height * 4 / 100; // replace 4 if need strong line ...
    drawRect = CGRectInset(drawRect, lineWidth, lineWidth);
    
    [self drawRoundWithRect:drawRect lineWidth:lineWidth];
    
    switch (self.type) {
        case DSKGraphicsButtonNoContent:
        {
            CGContextRef clearContent = UIGraphicsGetCurrentContext();
            CGContextClearRect(clearContent,rect);
        } break;
        case DSKGraphicsButtonClose:
        {
            CGContextRef clearContent = UIGraphicsGetCurrentContext();
            CGContextClearRect(clearContent,rect);
            
            self.shadow = YES;
            
            [self drawRoundWithRect:drawRect lineWidth:lineWidth];
            [self drawCloseWithRect:drawRect lineWidth:lineWidth];
            
        } break;
        case DSKGraphicsButtonRepeat:
        {
            CGContextRef clearContent = UIGraphicsGetCurrentContext();
            CGContextClearRect(clearContent,rect);
            
            self.shadow = YES;
            
            [self drawRoundWithRect:drawRect lineWidth:lineWidth];
            [self drawRepeatWithRect:drawRect lineWidth:lineWidth];
            
        } break;
        case DSKGraphicsButtonTimer:
        {
            CGContextRef clearContent = UIGraphicsGetCurrentContext();
            CGContextClearRect(clearContent,rect);
            
            self.shadow = YES;
            
            [self drawRoundWithRect:drawRect lineWidth:lineWidth];
            [self drawRoundWithRect:drawRect lineWidth:lineWidth stringContent:self.stringContent andPercent:self.persent];
            
        } break;
        case DSKGraphicsButtonText:
        {
            CGContextRef clearContent = UIGraphicsGetCurrentContext();
            CGContextClearRect(clearContent,rect);
            
            self.shadow = YES;
            
            [self drawTextWithRect:drawRect lineWidth:lineWidth stringContent:self.stringContent];
            
        } break;
        case DSKGraphicsButtonMuteOn:
        {
            CGContextRef clearContent = UIGraphicsGetCurrentContext();
            CGContextClearRect(clearContent,rect);
            
            self.shadow = YES;
            
            [self drawRoundWithRect:drawRect lineWidth:lineWidth];
            [self drawMuteIsOn:YES withRect:drawRect lineWidth:lineWidth];
            
        } break;
        case DSKGraphicsButtonMuteOff:
        {
            CGContextRef clearContent = UIGraphicsGetCurrentContext();
            CGContextClearRect(clearContent,rect);
            
            self.shadow = YES;
            
            [self drawRoundWithRect:drawRect lineWidth:lineWidth];
            [self drawMuteIsOn:NO withRect:drawRect lineWidth:lineWidth];
            
        } break;
        case DSKGraphicsButtonPlay: {
            CGContextRef clearContent = UIGraphicsGetCurrentContext();
            CGContextClearRect(clearContent,rect);
            self.shadow = NO;
            [self drawPlayButton];
            break;}
    }
    
    
//    [self drawRoundWithRect:drawRect lineWidth:lineWidth strokeColor:UIColor.whiteColor andFillColor:fillColor];
//    [self drawCloseWithRect:rect lineWidth:lineWidth andStrokeColor:UIColor.whiteColor];
//    [self drawRoundWithRect:drawRect lineWidth:lineWidth strokeColor:UIColor.whiteColor andPercent:25];
//    [self drawRepeatWithRect:drawRect lineWidth:lineWidth andStrokeColor:UIColor.whiteColor];
    
}

- (void) drawTextWithRect:(CGRect)rect lineWidth:(CGFloat)lineWidth stringContent:(NSString *)stringContent{
    
    UIBezierPath * cornerRect = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(rect, lineWidth, lineWidth) cornerRadius:rect.size.height / 2];
    
    [self.borderStrokeColor setStroke];
    [self.fillColor setFill];
    cornerRect.lineWidth = lineWidth;
    
    if (self.fillColor) {
        [cornerRect fill];
    }
    
    [cornerRect stroke];
    
    if (self.shadow) {
        [self drawShadowWithCurrentPath:cornerRect andLineWidth:lineWidth];
    }
    
    NSAttributedString * attributedText = [self attributedStringWithCurrentContent:stringContent contentSize:rect.size];
    if (attributedText) {
        
        
        CGSize textSize = [attributedText size];
        
        [attributedText drawInRect:CGRectInset(rect, 0, (CGRectGetHeight(rect) - textSize.height) / 2)];
    }
}

- (void)drawMuteIsOn:(BOOL)isOn withRect:(CGRect)rect lineWidth:(CGFloat)lineWidth{
    
    CGRect drawRect = CGRectInset(rect, CGRectGetWidth(rect) / 4, CGRectGetHeight(rect) / 4);

    CGFloat triangleSideLength = drawRect.size.height * 5 / 7;
    CGFloat triangleHeigth = triangleSideLength / 2;
    
    CGFloat centerX = drawRect.origin.x + drawRect.size.width / 2;
    CGFloat centerY = drawRect.origin.y + drawRect.size.height / 2;
    
    CGFloat leftX = centerX - triangleHeigth;
    CGFloat middleLeftX = centerX - triangleHeigth * 3 / 4;
    
    CGFloat middleTopY = centerY + triangleSideLength / 5;
    CGFloat middleLowY = centerY - triangleSideLength / 5;
    
    CGFloat topY = centerY + triangleSideLength / 2;
    CGFloat lowY = centerY - triangleSideLength / 2;
    
    CGPoint aPoint = CGPointMake(leftX, middleTopY);
    CGPoint bPoint = CGPointMake(middleLeftX, middleTopY);
    CGPoint cPoint = CGPointMake(centerX, topY);
    CGPoint dPoint = CGPointMake(centerX, lowY);
    CGPoint ePoint = CGPointMake(middleLeftX, middleLowY);
    CGPoint fPoint = CGPointMake(leftX, middleLowY);

    UIBezierPath * rectPath = [UIBezierPath bezierPath];

    [rectPath moveToPoint:aPoint];
    [rectPath addLineToPoint:bPoint];
    [rectPath addLineToPoint:cPoint];
    [rectPath addLineToPoint:dPoint];
    [rectPath addLineToPoint:ePoint];
    [rectPath addLineToPoint:fPoint];
    [rectPath closePath];
    
    UIBezierPath * firstArc;
    UIBezierPath * secondArc;
    if (!isOn) {
        CGPoint center = CGPointMake(centerX + triangleSideLength / 6, centerY);
        firstArc = [UIBezierPath bezierPathWithArcCenter:center
                                                  radius:triangleSideLength / 2
                                              startAngle:DEGREES_TO_RADIANS(90)
                                                endAngle:DEGREES_TO_RADIANS(270)
                                               clockwise:NO];
        
        
        secondArc = [UIBezierPath bezierPathWithArcCenter:center
                                                   radius:triangleSideLength / 4
                                               startAngle:DEGREES_TO_RADIANS(90)
                                                 endAngle:DEGREES_TO_RADIANS(270)
                                                clockwise:NO];
        firstArc.lineWidth = lineWidth;
        secondArc.lineWidth = lineWidth;
        
        [firstArc stroke];
        [secondArc stroke];
        
       
    } else {
        CGFloat length = triangleSideLength / 2;
        CGPoint startPoint = CGPointMake(centerX + triangleSideLength / 6, centerY - length / 2);

        [rectPath moveToPoint:startPoint];
        [rectPath addLineToPoint:CGPointMake(startPoint.x + length,startPoint.y + length)];
        [rectPath moveToPoint:CGPointMake(startPoint.x, startPoint.y + length)];
        [rectPath addLineToPoint:CGPointMake(startPoint.x + length, startPoint.y)];
    }
    
    [self.strokeColor setStroke];
    [self.fillColor setFill];
    
    rectPath.lineWidth = lineWidth;
    [rectPath stroke];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextAddPath(context, rectPath.CGPath);
    if (firstArc && secondArc) {
        CGContextAddPath(context, firstArc.CGPath);
        CGContextAddPath(context, secondArc.CGPath);
    }
    
    if (self.isShadow) {
        [self drawShadowWithCurrentPath:nil andLineWidth:lineWidth];
    } else {
        CGContextStrokePath(context);
    }
}

- (void) drawRoundWithRect:(CGRect)rect lineWidth:(CGFloat)lineWidth stringContent:(NSString *)stringContent andPercent:(CGFloat)percent {
    
    //TODO: remove if line can be normal size
    lineWidth = lineWidth * 1.5;
    
    if (TIMER_IN_REVERSE) {
        percent = 1 - percent;
    }
    
//    TODO: 
//    CGFloat radius = CGRectGetHeight(rect) / 2 - lineWidth;
    CGFloat radius = CGRectGetHeight(rect) / 2 - lineWidth * 0.5;
    CGPoint center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    
    float endAngle = 270.0f;
    float degrees = 360.0f;
    
    float tempDegrees = percent * 360.0 / 100.f;
    degrees = tempDegrees == 0 ? endAngle + 1 : (tempDegrees < 90) ? 270 + tempDegrees : tempDegrees - 90;
    
    if (TIMER_IN_REVERSE) {
        float temp = endAngle;
        endAngle = degrees;
        degrees = temp;
    }
    
    UIBezierPath *circle = [UIBezierPath bezierPathWithArcCenter:center
                                                          radius:radius
                                                      startAngle:DEGREES_TO_RADIANS(degrees)
                                                        endAngle:DEGREES_TO_RADIANS(endAngle)
                                                       clockwise:YES];
    
    [self.strokeColor setStroke];
    circle.lineWidth = lineWidth;
    [circle stroke];
    
    if (self.isShadow) {
        [self drawShadowWithCurrentPath:circle andLineWidth:lineWidth];
    }
    
    if (stringContent && ![stringContent isEqualToString:@""]) {
        
        UIFont *font = [UIFont systemFontOfSize:rect.size.height * 0.4];
        
        NSShadow *shadow = [[NSShadow alloc] init];
        shadow.shadowColor = [UIColor blackColor];
        shadow.shadowBlurRadius = self.shadowRadius;
        shadow.shadowOffset = self.shadowInsetSize;
        
        NSMutableParagraphStyle* paragraph = [[NSMutableParagraphStyle alloc] init];
        [paragraph setAlignment:NSTextAlignmentCenter];
        [paragraph setLineBreakMode:NSLineBreakByClipping];
        
        NSDictionary *attributes;
        if (self.isShadow) {
            attributes = @{NSShadowAttributeName                        : shadow,
                                         NSForegroundColorAttributeName : self.strokeColor,
                                         NSFontAttributeName            : font,
                                         NSParagraphStyleAttributeName  : paragraph};
        } else {
            attributes = @{NSForegroundColorAttributeName               : self.strokeColor,
                                         NSFontAttributeName            : font,
                                         NSParagraphStyleAttributeName  : paragraph};
        }
        
        NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:stringContent attributes:attributes];
        
        CGSize textSize = [attributedText size];
        
        [attributedText drawInRect:CGRectInset(rect, 0, (CGRectGetHeight(rect) - textSize.height) / 2)];
    }
}

- (void) drawRoundWithRect:(CGRect)rect lineWidth:(CGFloat)lineWidth{
    
    CGFloat radius = CGRectGetHeight(rect) / 2 - lineWidth;
    CGPoint center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    
    UIBezierPath *circle = [UIBezierPath bezierPathWithArcCenter:center
                                                          radius:radius
                                                      startAngle:0
                                                        endAngle:180
                                                       clockwise:YES];
    
    
    [self.borderStrokeColor setStroke];
    [self.fillColor setFill];
    
    circle.lineWidth = lineWidth;
    
    if (self.fillColor) {
        [circle fill];
    }
    
    [circle stroke];
    
    [self drawShadowWithCurrentPath:circle andLineWidth:lineWidth];
}

- (void) drawRepeatWithRect:(CGRect)rect lineWidth:(CGFloat)lineWidth{
    
    CGFloat radius = CGRectGetHeight(rect) / 2 - lineWidth;
    CGPoint center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    
    UIBezierPath *circle = [UIBezierPath bezierPathWithArcCenter:center
                                                          radius:radius / 2
                                                      startAngle:DEGREES_TO_RADIANS(0)
                                                        endAngle:DEGREES_TO_RADIANS(270)
                                                       clockwise:YES];
    
    [self.strokeColor setStroke];
    [self.strokeColor setFill];
    circle.lineWidth = lineWidth;
    [circle stroke];
    
    UIBezierPath *triangle = [UIBezierPath bezierPath];
    { // repeat draw triangle
//        CGFloat tail = (radius - (lineWidth + radius / 2)) / 2;
        CGFloat tail = lineWidth * 1.5;
        CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect) - (radius / 2  + tail)); //  (radius / 2 + lineWidth + tail)
        CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect) - (radius / 2 - tail));
        
        CGFloat angle = M_PI/3; // 60 degrees in radians
        // v1 = vector from startPoint to endPoint:
        CGPoint v1 = CGPointMake(endPoint.x - startPoint.x, endPoint.y - startPoint.y);
        // v2 = v1 rotated by 60 degrees:
        CGPoint v2 = CGPointMake(cosf(angle) * v1.x - sinf(angle) * v1.y,
                                 sinf(angle) * v1.x + cosf(angle) * v1.y);
        // thirdPoint = startPoint + v2:
        CGPoint thirdPoint = CGPointMake(startPoint.x + v2.x, startPoint.y + v2.y);
        
        
        [triangle moveToPoint:startPoint];
        [triangle addLineToPoint:endPoint];
        [triangle addLineToPoint:thirdPoint];
        [triangle closePath];
        
        triangle.lineWidth = lineWidth;
        [triangle stroke];
        
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextAddPath(context, circle.CGPath);
    CGContextAddPath(context, triangle.CGPath);
    
    if (self.isShadow) {
        [self drawShadowWithCurrentPath:nil andLineWidth:lineWidth];
    } else {
        CGContextStrokePath(context);
    }
    
    [triangle fill];
}

- (void) drawCloseWithRect:(CGRect)rect lineWidth:(CGFloat)lineWidth{
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.strokeColor setStroke];
    
    CGContextSetLineWidth(context, lineWidth);
    
    CGFloat tail = (rect.size.height / 4);
    
    CGFloat x1 = tail + rect.origin.x + lineWidth * 1.2;
    CGFloat x2 = tail * 3 + rect.origin.x - lineWidth * 1.2;
    
    CGFloat y1 = tail + rect.origin.y + lineWidth * 1.2;
    CGFloat y2 = tail * 3 + rect.origin.y - lineWidth * 1.2;
    
    CGPoint array[] = {
        CGPointMake(x1, y1),
        CGPointMake(x2, y2),
        CGPointMake(x1, y2),
        CGPointMake(x2, y1)
    };
    
    CGContextBeginPath(context);
    for (int k = 0; k < 4; k += 2) {
        CGContextMoveToPoint(context, array[k].x, array[k].y);
        CGContextAddLineToPoint(context, array[k+1].x, array[k+1].y);
    }
    
    if (self.isShadow) {
        [self drawShadowWithCurrentPath:nil andLineWidth:lineWidth];
    }
    
    CGContextStrokePath(context);
    
    
}

- (void) drawShadowWithCurrentPath:(UIBezierPath *) path andLineWidth:(CGFloat)lineWidth{
    
    CGSize myShadowOffset = self.shadowInsetSize;
    CGFloat myColorValues[] = {0, 0, 0, 1.};
    
    CGContextRef myContext = UIGraphicsGetCurrentContext();
    if (path) CGContextAddPath(myContext, path.CGPath);
    CGContextSaveGState(myContext);
    
    CGColorSpaceRef myColorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef myColor = CGColorCreate(myColorSpace, myColorValues);
    
    CGContextSetLineWidth(myContext, lineWidth);
    CGContextSetShadowWithColor (myContext, myShadowOffset, self.shadowRadius, myColor);

    CGContextStrokePath(myContext);
    
    CGColorRelease(myColor);
    CGColorSpaceRelease(myColorSpace);
    
    CGContextRestoreGState(myContext);
}

- (void)drawPlayButton{
    self.layer.cornerRadius = self.frame.size.width / 2.0f;
    self.layer.masksToBounds = YES;
    self.backgroundColor = [UIColor clearColor];
    CGRect bounds = self.bounds;
    
    //TODO: draw pretty background image, but get so much freak warnings
    //    if (self.placeholder.image) {
    //        UIImage * defaultImage = self.placeholder.image;
    //        double refWidth = CGImageGetWidth(defaultImage.CGImage);
    //        double refHeight = CGImageGetHeight(defaultImage.CGImage);
    //        double x = (refWidth - bounds.size.width) / 2.0;
    //        double y = (refHeight - bounds.size.height) / 2.0;
    //        CGRect cropRect = CGRectMake(x, y, bounds.size.width,  bounds.size.height);
    //        CGImageRef imageRef = CGImageCreateWithImageInRect([defaultImage CGImage], cropRect);
    //        CIFilter *gaussianBlurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
    //        [gaussianBlurFilter setDefaults];
    //        CIImage *inputImage = [CIImage imageWithCGImage:imageRef];
    //        [gaussianBlurFilter setValue:inputImage forKey:kCIInputImageKey];
    //        [gaussianBlurFilter setValue:@8.0 forKey:kCIInputRadiusKey];
    //        CIImage *outputImage = [gaussianBlurFilter outputImage];
    //        CIContext *context   = [CIContext contextWithOptions:nil];
    //        CGImageRef cgimg     = [context createCGImage:outputImage fromRect:[inputImage extent]];
    //        UIImage *otputBackgroung       = [UIImage imageWithCGImage:cgimg];
    //        CGImageRelease(cgimg);
    //        CGImageRelease(imageRef);
    //        [button setBackgroundImage:otputBackgroung forState:UIControlStateNormal];
    //    }
    
    //Just draw triangle in circle
    self.layer.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.6f].CGColor;
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    CGPoint centerPoint = CGPointMake(bounds.size.width / 2, bounds.size.height / 2);
    
    CGPoint a = CGPointMake(centerPoint.x - centerPoint.x / 3, centerPoint.y + centerPoint.y / 2);
    CGPoint b = CGPointMake(a.x, centerPoint.y - centerPoint.y / 2);
    CGPoint c = CGPointMake(centerPoint.x + centerPoint.x / 3 * 2, centerPoint.y);
    
    [path moveToPoint:a];
    [path addLineToPoint:b];
    [path addLineToPoint:c];
    [path closePath];
    
    shapeLayer.path = path.CGPath;
    shapeLayer.fillColor = [UIColor colorWithWhite:0.0f alpha:0.8f].CGColor;
    [self.layer addSublayer:shapeLayer];
}

@end
