//
//  UIView+DSKConstraint.h
//
//  Created by Lozhkin Ilya on 4/4/17.
//  Copyright © 2017 OpenBids, Inc. All rights reserved.
//

#import "DSKConstraintMaker.h"

@interface UIView (DSKConstraint)

- (void)DSK_makeConstraintsOnView:(UIView *)view
                        withBlock:(void(^)(DSKConstraintMaker * maker))block;

- (void)DSK_makeConstraints:(void(^)(DSKConstraintMaker * maker))block;

- (void)DSK_updateConstraintsIfNeeded;
- (void)removeAllConstraints;
@end
