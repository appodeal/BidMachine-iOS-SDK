//
//  DSKConstraintMaker.m
//  OpenBids
//
//  Created by Lozhkin Ilya on 10/11/17.
//  Copyright © 2017 OpenBids, Inc. All rights reserved.
//

#import "DSKConstraintMaker.h"

#import "DSKGeometry.h"

#define k_sH             20.f

static inline NSDictionary * support_pozition(){
    return @{@"top"     : @0,
             @"left"    : @0,
             @"bottom"  : @0,
             @"right"   : @0,
             @"center"  : @1,
             @"width"   : @30,
             @"height"  : @30
             };
}

#define X_SUPPORT_X @[@"left",@"center",@"right"]
#define Y_SUPPORT_Y @[@"top",@"center",@"bottom"]

#define V_UDF(_V,_E) support_pozition()[[_V isEqualToString:_E] ? _V : @"UNDEFINED"]

@interface DSKConstraintMaker ()

@property (nonatomic, strong, readwrite) NSNumber * width;
@property (nonatomic, strong, readwrite) NSNumber * height;

@property (nonatomic, strong, readwrite) NSNumber * top;
@property (nonatomic, strong, readwrite) NSNumber * left;
@property (nonatomic, strong, readwrite) NSNumber * bottom;
@property (nonatomic, strong, readwrite) NSNumber * right;

@property (nonatomic, assign, readwrite) BOOL centerX;
@property (nonatomic, assign, readwrite) BOOL centerY;

@property (nonatomic, assign, readwrite) DSKInterfaceOrientation interfaceOrientation;

@property (nonatomic, assign, readwrite) UIEdgeInsets insets;

@end

@implementation DSKConstraintMaker

+ (instancetype)defaultMaker{
    return [self constraintMakerFromString:@"left" yPozition:@"top"];
}

+ (instancetype)constraintMakerFromString:(NSString *)xPozition
                                yPozition:(NSString *)yPozition
{
    return [self constraintMakerFromString:xPozition
                                 yPozition:yPozition
                              xDefPozition:nil
                              yDefPozition:nil];
}

+ (instancetype)constraintMakerFromString:(NSString *)xPozition
                                yPozition:(NSString *)yPozition
                             xDefPozition:(NSString *)xDefPozition
                             yDefPozition:(NSString *)yDefPozition
{
    xPozition = [self supportPosition:xPozition default:xDefPozition from:X_SUPPORT_X];
    yPozition = [self supportPosition:yPozition default:yDefPozition from:Y_SUPPORT_Y];
    
    return [[self alloc] initConstraintMakerFromString:xPozition yPozition:yPozition];
}

- (instancetype)initConstraintMakerFromString:(NSString *)xPozition
                                    yPozition:(NSString *)yPozition
{
    self = [super init];
    if (self) {
        self.centerX    = [V_UDF(xPozition, @"center") boolValue];
        self.centerY    = [V_UDF(yPozition, @"center") boolValue];
        
        self.top        = V_UDF(yPozition, @"top");
        self.left       = V_UDF(xPozition, @"left");
        self.bottom     = V_UDF(yPozition, @"bottom");
        self.right      = V_UDF(xPozition, @"right");
        
        self.width      = support_pozition()[@"width"];
        self.height     = support_pozition()[@"height"];
    }
    return self;
}

+ (NSString *)supportPosition:(NSString *)pozition default:(NSString *)defaultPozition from:(NSArray *)supportedArray{
    NSString * supportPozition = pozition;
    
    supportPozition = [supportedArray containsObject:defaultPozition] ? defaultPozition : @"UNDEFINED";
    supportPozition = [supportedArray containsObject:pozition] ? pozition : supportPozition;
    
    return supportPozition;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone{
    DSKConstraintMaker *_instanceCopy = [DSKConstraintMaker new];
    
    if (_instanceCopy) {
        _instanceCopy.width     = [self.width copyWithZone:zone];
        _instanceCopy.height    = [self.height copyWithZone:zone];
        _instanceCopy.top       = [self.top copyWithZone:zone];
        _instanceCopy.left      = [self.left copyWithZone:zone];
        _instanceCopy.bottom    = [self.bottom copyWithZone:zone];
        _instanceCopy.right     = [self.right copyWithZone:zone];
        
        _instanceCopy.centerY   = self.centerY;
        _instanceCopy.centerX   = self.centerX;
        
        _instanceCopy.insets    = self.insets;
        
        _instanceCopy.interfaceOrientation = self.interfaceOrientation;
    }
    
    return _instanceCopy;
}

- (void)copyPozition:(DSKConstraintMaker *)maker{
    if (!maker) {
        return;
    }
    
    self.top        = maker.top;
    self.left       = maker.left;
    self.bottom     = maker.bottom;
    self.right      = maker.right;
    self.centerX    = maker.centerX;
    self.centerY    = maker.centerX;
}

#pragma mark - DSKInsets

- (void)updateInsets{
    self.insets = [self systemInsets];
}

- (void)updateInsetsWithBorderOffset:(CGFloat)borderOffset clickOffset:(CGFloat)clickOffset{
    self.insets = [self systemInsetsWithBorderOffset:borderOffset clickOffset:clickOffset];
}

- (UIEdgeInsets)systemInsets{
    return [self systemInsetsWithBorderOffset:0 clickOffset:0];
}

- (UIEdgeInsets)systemInsetsWithBorderOffset:(CGFloat)borderOffset clickOffset:(CGFloat)clickOffset{
    UIEdgeInsets offset = [self systemOffsetWithBorderOffset:borderOffset clickOffset:clickOffset fullscreen:NO];
    return UIEdgeInsetsMake(-offset.top, -offset.left, -offset.bottom, -offset.right);
}

- (UIEdgeInsets)fullscreenInsets{
    UIEdgeInsets offset = [self systemOffsetWithBorderOffset:0 clickOffset:0 fullscreen:YES];
    return UIEdgeInsetsMake(-offset.top, -offset.left, -offset.bottom, -offset.right);
}

- (UIEdgeInsets)systemOffsetWithBorderOffset:(CGFloat)borderOffset clickOffset:(CGFloat)clickOffset fullscreen:(BOOL)fullscreen{
    
    NSNumber * top;
    NSNumber * left;
    NSNumber * bottom;
    NSNumber * right;

    CGFloat bH = fullscreen ? 0 : k_sH;
    
    if (DSKCurrentInterfaceOrientation() == UIInterfaceOrientationPortrait) {
        if (self.interfaceOrientation == DSKInterfaceOrientationLandscape) {
            if (self.centerX) {
                left = right = @(MAX(borderOffset, clickOffset));
            } else {
                if (self.left) {
                    left = @(MAX(DSKSafeArea().top, DSKStatusBarUnhidden() ? borderOffset : bH + borderOffset));
                } else if (self.right) {
                    right = @(MAX(DSKSafeArea().bottom, borderOffset));
                }
            }
            
            
            if (self.centerY) {
                top = bottom = @(MAX(borderOffset, clickOffset));
            } else {
                if (self.top) {
                    top = @(MAX(DSKSafeArea().right, borderOffset));
                    top = DSKSystemVersionIsiOS11() && fullscreen ? @(- k_sH) : top; // WKWebView offset 
                } else if (self.bottom) {
                    bottom = @(MAX(DSKSafeArea().left, borderOffset));
                }
            }
        } else {
            if (self.centerX) {
                left = right = @(MAX(borderOffset, clickOffset));
            } else {
                if (self.left) {
                    left = @(MAX(DSKSafeArea().left, borderOffset));
                } else if (self.right) {
                    right = @(MAX(DSKSafeArea().right, borderOffset));
                }
            }
            
            
            if (self.centerY) {
                top = bottom = @(MAX(borderOffset, clickOffset));
            } else {
                if (self.top) {
                    top = @(MAX(DSKSafeArea().top, DSKStatusBarUnhidden() ? borderOffset : bH + borderOffset));
                } else if (self.bottom) {
                    bottom = @(MAX(DSKSafeArea().bottom, borderOffset));
                }
            }
        }
    } else if (DSKCurrentInterfaceOrientation() == UIInterfaceOrientationPortraitUpsideDown){
        if (self.interfaceOrientation == DSKInterfaceOrientationLandscape) {
            if (self.centerX) {
                left = right = @(MAX(borderOffset, clickOffset));
            } else {
                if (self.left) {
                    left = @(MAX(DSKSafeArea().bottom, borderOffset));
                } else if (self.right) {
                    right = @(MAX(DSKSafeArea().top, DSKStatusBarUnhidden() ? borderOffset : bH + borderOffset));
                }
            }
            
            
            if (self.centerY) {
                top = bottom = @(MAX(borderOffset, clickOffset));
            } else {
                if (self.top) {
                    top = @(MAX(DSKSafeArea().left, borderOffset));
                } else if (self.bottom) {
                    bottom = @(MAX(DSKSafeArea().right, borderOffset));
                    bottom = DSKSystemVersionIsiOS11() && fullscreen ? @(- k_sH) : bottom; // WKWebView offset
                }
            }
        } else {
            if (self.centerX) {
                left = right = @(MAX(borderOffset, clickOffset));
            } else {
                if (self.left) {
                    left = @(MAX(DSKSafeArea().left, borderOffset));
                } else if (self.right) {
                    right = @(MAX(DSKSafeArea().right, borderOffset));
                }
            }
            
            
            if (self.centerY) {
                top = bottom = @(MAX(borderOffset, clickOffset));
            } else {
                if (self.top) {
                    top = @(MAX(DSKSafeArea().top, DSKStatusBarUnhidden() ? borderOffset : bH + borderOffset));
                } else if (self.bottom) {
                    bottom = @(MAX(DSKSafeArea().bottom, borderOffset));
                }
            }
        }
    } else if (DSKCurrentInterfaceOrientation() == UIInterfaceOrientationLandscapeLeft){
        if (self.interfaceOrientation == DSKInterfaceOrientationLandscape || self.interfaceOrientation == DSKInterfaceOrientationUnknown) {
            if (self.centerX) {
                left = right = @(MAX(borderOffset, clickOffset));
            } else {
                if (self.left) {
                    left = @(MAX(DSKSafeArea().left, borderOffset));
                } else if (self.right) {
                    right = @(MAX(DSKSafeArea().right, borderOffset));
                }
            }
            
            
            if (self.centerY) {
                top = bottom = @(MAX(borderOffset, clickOffset));
            } else {
                if (self.top) {
                    top = @(MAX(DSKSafeArea().top, borderOffset));
                } else if (self.bottom) {
                    bottom = @(MAX(DSKSafeArea().bottom, borderOffset));
                }
            }
        } else {
            if (self.centerX) {
                left = right = @(MAX(borderOffset, clickOffset));
            } else {
                if (self.left) {
                    left = @(MAX(DSKSafeArea().bottom, borderOffset));
                } else if (self.right) {
                    right = @(MAX(DSKSafeArea().top, borderOffset));
                }
            }
            
            
            if (self.centerY) {
                top = bottom = @(MAX(borderOffset, clickOffset));
            } else {
                if (self.top) {
                    top = @(MAX(DSKSafeArea().left, borderOffset));
                } else if (self.bottom) {
                    bottom = @(MAX(DSKSafeArea().right, borderOffset));
                }
            }
        }
    } else if (DSKCurrentInterfaceOrientation() == UIInterfaceOrientationLandscapeRight){
        if (self.interfaceOrientation == DSKInterfaceOrientationLandscape || self.interfaceOrientation == DSKInterfaceOrientationUnknown) {
            if (self.centerX) {
                left = right = @(MAX(borderOffset, clickOffset));
            } else {
                if (self.left) {
                    left = @(MAX(DSKSafeArea().left, borderOffset));
                } else if (self.right) {
                    right = @(MAX(DSKSafeArea().right, borderOffset));
                }
            }
            
            
            if (self.centerY) {
                top = bottom = @(MAX(borderOffset, clickOffset));
            } else {
                if (self.top) {
                    top = @(MAX(DSKSafeArea().top, borderOffset));
                } else if (self.bottom) {
                    bottom = @(MAX(DSKSafeArea().bottom, borderOffset));
                }
            }
        } else {
            if (self.centerX) {
                left = right = @(MAX(borderOffset, clickOffset));
            } else {
                if (self.left) {
                    left = @(MAX(DSKSafeArea().top, borderOffset));
                } else if (self.right) {
                    right = @(MAX(DSKSafeArea().bottom, borderOffset));
                }
            }
            
            
            if (self.centerY) {
                top = bottom = @(MAX(borderOffset, clickOffset));
            } else {
                if (self.top) {
                    top = @(MAX(DSKSafeArea().right, borderOffset));
                } else if (self.bottom) {
                    bottom = @(MAX(DSKSafeArea().left, borderOffset));
                }
            }
        }
    }
    
    top     = top ?: @(MAX(borderOffset, clickOffset));
    left    = left ?: @(MAX(borderOffset, clickOffset));
    bottom  = bottom ?: @(MAX(borderOffset, clickOffset));
    right   = right ?: @(MAX(borderOffset, clickOffset));

    UIEdgeInsets offset = UIEdgeInsetsMake(top.floatValue, left.floatValue, bottom.floatValue, right.floatValue);
    
    return offset;
}

@end
