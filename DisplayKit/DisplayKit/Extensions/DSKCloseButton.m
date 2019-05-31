//
//  DSKCloseButton.m
//

#import "DSKCloseButton.h"

@interface DSKCloseButton ()

@property (nonatomic, strong) UIGestureRecognizer *tapGesture;

@end

@implementation DSKCloseButton {
    CGSize shadowInsetSize;
    CGFloat shadowRadius;
}

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = UIColor.clearColor;
        [self setContentMode:UIViewContentModeRedraw];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.backgroundColor = UIColor.clearColor;
        [self setContentMode:UIViewContentModeRedraw];
    }
    return self;
}

- (void)addTarget:(id)target action:(SEL)action {
    self.userInteractionEnabled = YES;
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
    [self addGestureRecognizer:self.tapGesture];
}

#pragma mark --- Private

- (void)drawRect:(CGRect)rect {
    CGRect drawRect = CGRectMake(20, 20, rect.size.width - 40, rect.size.height - 40);
    CGFloat interfacePercent = drawRect.size.height / 100;
    
    CGFloat shadowStrong = 5.0f;
    shadowRadius = interfacePercent * shadowStrong;
    shadowInsetSize = CGSizeMake(interfacePercent * shadowStrong, interfacePercent * shadowStrong);
    
    
    CGFloat lineWidth = drawRect.size.height * 4 / 100; // replace 4 if need strong line ...
    drawRect = CGRectInset(drawRect, lineWidth, lineWidth);
    
    CGContextRef clearContent = UIGraphicsGetCurrentContext();
    CGContextClearRect(clearContent,rect);
    
    [self drawRoundWithRect:drawRect lineWidth:lineWidth];
    [self drawCloseWithRect:drawRect lineWidth:lineWidth];
}

- (void) drawRoundWithRect:(CGRect)rect lineWidth:(CGFloat)lineWidth{
    CGFloat radius = CGRectGetHeight(rect) / 2 - lineWidth;
    CGPoint center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    
    UIBezierPath *circle = [UIBezierPath bezierPathWithArcCenter:center
                                                          radius:radius
                                                      startAngle:0
                                                        endAngle:180
                                                       clockwise:YES];
    
    
    [UIColor.whiteColor setStroke];
    [circle setLineWidth:lineWidth];
    [circle stroke];
    
    [self drawShadowWithCurrentPath:circle andLineWidth:lineWidth];
}

- (void)drawCloseWithRect:(CGRect)rect lineWidth:(CGFloat)lineWidth {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIColor.whiteColor setStroke];
    
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
    
    [self drawShadowWithCurrentPath:nil andLineWidth:lineWidth];
    
    CGContextStrokePath(context);
}

- (void)drawShadowWithCurrentPath:(UIBezierPath *)path andLineWidth:(CGFloat)lineWidth {
    CGFloat myColorValues[] = {0, 0, 0, 1.};
    
    CGContextRef myContext = UIGraphicsGetCurrentContext();
    if (path) CGContextAddPath(myContext, path.CGPath);
    CGContextSaveGState(myContext);
    
    CGColorSpaceRef myColorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef myColor = CGColorCreate(myColorSpace, myColorValues);
    
    CGContextSetLineWidth(myContext, lineWidth);
    CGContextSetShadowWithColor (myContext, shadowInsetSize, shadowRadius, myColor);
    
    CGContextStrokePath(myContext);
    
    CGColorRelease(myColor);
    CGColorSpaceRelease(myColorSpace);
    
    CGContextRestoreGState(myContext);
}

@end
