//
//  BDMMRAIDClosableView.h
//  BDMMRAIDAdapter
//
//  Created by Stas Kochkin on 03/06/2019.
//  Copyright © 2019 Stas Kochkin. All rights reserved.
//

#import <Foundation/Foundation.h>
@import StackUIKit;

@interface BDMMRAIDClosableView : STKInteractionView

+ (instancetype)closableView:(NSTimeInterval)timeout action:(void (^)(BDMMRAIDClosableView *))action;
- (void)render:(UIView *)superview;

@end

