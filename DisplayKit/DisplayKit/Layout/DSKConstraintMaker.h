//
//  DSKConstraintMaker.h
//  OpenBids
//
//  Created by Lozhkin Ilya on 10/11/17.
//  Copyright © 2017 OpenBids, Inc. All rights reserved.
//

#import "DSKConstraint.h"

typedef NS_ENUM(NSUInteger, DSKInterfaceOrientation) {
    DSKInterfaceOrientationUnknown,
    DSKInterfaceOrientationPortrait,
    DSKInterfaceOrientationLandscape
};

@interface DSKConstraintMaker : NSObject <DSKConstraint, NSCopying>

@property (nonatomic, assign, readonly) DSKInterfaceOrientation interfaceOrientation;

@property (nonatomic, assign, readonly) UIEdgeInsets insets;

@end

@interface DSKConstraintMaker (DSKStringTranslate)

+ (instancetype)constraintMakerFromString:(NSString *)xPozition
                                yPozition:(NSString *)yPozition;

+ (instancetype)constraintMakerFromString:(NSString *)xPozition
                                yPozition:(NSString *)yPozition
                             xDefPozition:(NSString *)xDefPozition
                             yDefPozition:(NSString *)yDefPozition;

@end

@interface DSKConstraintMaker (DSKInsets)

- (void)updateInsets;

- (void)updateInsetsWithBorderOffset:(CGFloat)borderOffset clickOffset:(CGFloat)clickOffset;

- (UIEdgeInsets)systemInsets;

- (UIEdgeInsets)systemInsetsWithBorderOffset:(CGFloat)borderOffset clickOffset:(CGFloat)clickOffset;

@end

@interface DSKConstraintMaker (DSKFullscreenInset)

- (UIEdgeInsets)fullscreenInsets;

@end

@interface DSKConstraintMaker (DSKCopying)

- (void)copyPozition:(DSKConstraintMaker *)maker;

@end
