//
//  DSKConstraint.h
//  OpenBids
//
//  Created by Lozhkin Ilya on 4/4/17.
//  Copyright © 2017 OpenBids, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DSKConstraint <NSObject>

@property (nonatomic, strong, readonly) NSNumber * width;
@property (nonatomic, strong, readonly) NSNumber * height;

@property (nonatomic, strong, readonly) NSNumber * top;
@property (nonatomic, strong, readonly) NSNumber * left;
@property (nonatomic, strong, readonly) NSNumber * bottom;
@property (nonatomic, strong, readonly) NSNumber * right;

@property (nonatomic, assign, readonly) BOOL centerX;
@property (nonatomic, assign, readonly) BOOL centerY;

@end
