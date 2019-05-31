//
//  NSError+DSKVAST.m
//  OpenBids
//

//  Copyright © 2016 OpenBids, Inc. All rights reserved.
//

#import "NSError+DSKVAST.h"
#import <ASKExtension/NSError+ASKExtension.h>


@implementation NSError (DSKVAST)

+ (NSError *)DSK_vastErrorWithCode:(DSKVASTErrorCode)errorCode {
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"For more info visit https://support.google.com/dfp_premium/answer/4442429?hl=en", NSUnderlyingErrorKey: self};
    NSError * error = [NSError errorWithDomain:@"com.apdvast.error" code:errorCode userInfo: userInfo];
    return error;
}

@end
