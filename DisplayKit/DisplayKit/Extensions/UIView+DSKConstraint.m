//
//  UIView+DSKConstraint.m
//  OpenBids
//
//  Created by Lozhkin Ilya on 4/4/17.
//  Copyright © 2017 OpenBids, Inc. All rights reserved.
//

#import "UIView+DSKConstraint.h"
#import "DSKConstraint.h"
#import "DSKConstraintMaker+Private.h"

#import <objc/runtime.h>
#import <ASKExtension/NSObject+ASKExtension.h>


static NSString * const kDSKConstraint             = @"apdConstrain";
static NSString * const kDSKConstraintMakerBlock   = @"apdConstraintMakerBlock";


@implementation UIView (DSKConstraint)

- (id<DSKConstraint>)DSK_constraint {
    return objc_getAssociatedObject(self, &kDSKConstraint);
}

- (void)setApd_constraint:(id<DSKConstraint>)DSK_constraint {
    objc_setAssociatedObject(self, &kDSKConstraint, DSK_constraint, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void (^)(DSKConstraintMaker *))DSK_constraintMakerBlock {
    return objc_getAssociatedObject(self, &kDSKConstraintMakerBlock);
}

- (void)setDSK_constraintMakerBlock:(void (^)(DSKConstraintMaker *))DSK_constraintMakerBlock {
    objc_setAssociatedObject(self, &kDSKConstraintMakerBlock, DSK_constraintMakerBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

#pragma mark - Public

- (void)DSK_makeConstraints:(void (^)(DSKConstraintMaker *))block{
    [self DSK_makeConstraintsOnView:nil withBlock:block];
}

- (void)DSK_makeConstraintsOnView:(UIView *)view withBlock:(void (^)(DSKConstraintMaker *))block{
    if (![self superview]) {
        if (!view) {
            return;
        }
        [view addSubview:self];
    }

    self.DSK_constraintMakerBlock = block;
    [self DSK_updateConstraintsIfNeeded];
}

- (void)DSK_updateConstraintsIfNeeded{
    __weak typeof(self) weakSelf = self;
    if ([self superview] && self.DSK_constraintMakerBlock) {
        [self DSK_updateConstraints:^DSKConstraintMaker *{
            __strong typeof(self) strongSelf = weakSelf;
            DSKConstraintMaker * maker = [DSKConstraintMaker defaultMaker];
            
            strongSelf.DSK_constraintMakerBlock(maker);
            
            return [strongSelf updateMakerOffset:maker];
        }];
    }
}

#pragma mark - Private

- (DSKConstraintMaker *)updateMakerOffset:(DSKConstraintMaker *)maker{
    DSKConstraintMaker * makerCopy = [maker copy];
    makerCopy.width = @(makerCopy.width.floatValue - maker.insets.left - makerCopy.insets.right);
    makerCopy.height = @(makerCopy.height.floatValue - maker.insets.top - makerCopy.insets.bottom);
    
    return makerCopy;
}

- (void)removeAllConstraints
{
    UIView *superview = self.superview;
    while (superview != nil) {
        for (NSLayoutConstraint *c in superview.constraints) {
            if (c.firstItem == self || c.secondItem == self) {
                [superview removeConstraint:c];
            }
        }
        superview = superview.superview;
    }
    
    [self removeConstraints:self.constraints];
    //self.translatesAutoresizingMaskIntoConstraints = YES;
}

- (void)DSK_updateConstraints:(DSKConstraintMaker * (^)(void))block{
    
    UIView * parentView = [self superview];
    [self removeAllConstraints];
    
    DSKConstraintMaker * maker = block();
    [self setApd_constraint:maker];
    id <DSKConstraint> constraint = maker;
    BOOL centerX = constraint.centerX;
    BOOL centerY = constraint.centerY;
    
    if (!(constraint.top && constraint.left && constraint.bottom && constraint.right)) {
        CGSize renderingSize = CGSizeMake(constraint.width.floatValue, constraint.height.floatValue);
        [self.widthAnchor constraintEqualToConstant:renderingSize.width].active = YES;
        [self.heightAnchor constraintEqualToConstant:renderingSize.height].active = YES;
    }
    
    if (centerY) {
        [self.centerYAnchor constraintEqualToAnchor:parentView.centerYAnchor].active = YES;
    } else {
        if (constraint.top) {
            //[self.topAnchor constraintEqualToAnchor:parentView.topAnchor constant:[constraint.top floatValue]].active = YES;
            [parentView addConstraint: [NSLayoutConstraint constraintWithItem:self
                                                              attribute:NSLayoutAttributeTop
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:parentView
                                                              attribute:NSLayoutAttributeTop
                                                             multiplier:1.0
                                                               constant:[constraint.top floatValue]]];
            
        }
        if (constraint.bottom) {
            [self.bottomAnchor constraintEqualToAnchor:parentView.bottomAnchor constant:[constraint.bottom floatValue]].active = YES;
        }
    }
    
    if (centerX) {
        [self.centerXAnchor constraintEqualToAnchor:parentView.centerXAnchor].active = YES;
    } else {
        if (constraint.left) {
            [self.leftAnchor constraintEqualToAnchor:parentView.leftAnchor constant:[constraint.left floatValue]].active = YES;
        }
        if (constraint.right) {
            //[self.rightAnchor constraintEqualToAnchor:parentView.rightAnchor constant:[constraint.right floatValue]].active = YES;
            [parentView addConstraint: [NSLayoutConstraint constraintWithItem:self
                                                                    attribute:NSLayoutAttributeRight
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:parentView
                                                                    attribute:NSLayoutAttributeRight
                                                                   multiplier:1.0
                                                                     constant:[constraint.top floatValue]]];
        }
    }
    
//
//    [self mas_remakeConstraints:^(MASConstraintMaker *make) {
//        __strong typeof(self) strongSelf = weakSelf;
//
//        DSKConstraintMaker * maker = block();
//        [strongSelf setApd_constraint:maker];
//
//        id <DSKConstraint> constraint = maker;
//
//        BOOL centerX = constraint.centerX;
//        BOOL centerY = constraint.centerY;
//
//        if (!(constraint.top && constraint.left && constraint.bottom && constraint.right)) {
//            CGSize renderingSize = CGSizeMake(constraint.width.floatValue, constraint.height.floatValue);
//            make.size.mas_equalTo(renderingSize);
//        }
//
//        if (centerY) {
//            make.centerY.equalTo(parrentView);
//        } else {
//            if (constraint.top) {
//                make.top.equalTo(parrentView).with.mas_offset(constraint.top);
//            }
//            if (constraint.bottom) {
//                make.bottom.equalTo(parrentView).with.mas_offset(constraint.bottom);
//            }
//        }
//
//        if (centerX) {
//            make.centerX.equalTo(parrentView);
//        } else {
//            if (constraint.left) {
//                make.left.equalTo(parrentView).with.mas_offset(constraint.left);
//            }
//            if (constraint.right) {
//                make.right.equalTo(parrentView).with.mas_offset(constraint.right);
//            }
//        }
//    }];
}

@end
