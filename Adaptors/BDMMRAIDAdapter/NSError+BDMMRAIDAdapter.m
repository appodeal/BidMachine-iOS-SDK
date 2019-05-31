//
//  NSError+BDMMRAIDAdapter.m
//
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import "NSError+BDMMRAIDAdapter.h"

@implementation NSError (BDMMRAIDAdapter)

+ (NSError *(^)(NSString *))bdm_error {
    return ^NSError *(NSString *description){
        description = description ?: @"unknown";
        return [NSError errorWithDomain:@"com.bdm.mraid.error"
                                   code:0
                               userInfo:@{ NSLocalizedFailureReasonErrorKey : description }];
    };
}

@end
