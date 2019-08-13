//
//  NSArray+BDMEventTarcker.m
//  BidMachine
//
//  Created by Stas Kochkin on 28/11/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import "NSArray+BDMEventURL.h"
#import <StackFoundation/StackFoundation.h>


@implementation NSArray (BDMEventURL)

- (BDMEventURL *)bdm_searchTrackerOfType:(NSInteger)type {
    return [self stk_filter:^BOOL(BDMEventURL * tracker) {
        if (!BDMEventURL.stk_isValid(tracker)) {
            return false;
        }
        return tracker.type == type;
    }].firstObject;
}

@end
