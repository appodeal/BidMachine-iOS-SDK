//
//  DSKConstraintMaker+Private.h
//  OpenBids
//
//  Created by Lozhkin Ilya on 10/11/17.
//  Copyright © 2017 OpenBids, Inc. All rights reserved.
//

#import "DSKConstraintMaker.h"

@interface DSKConstraintMaker (Private)

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

+ (instancetype)defaultMaker;

@end
