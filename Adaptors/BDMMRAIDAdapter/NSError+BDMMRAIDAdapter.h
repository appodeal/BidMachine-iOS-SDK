//
//  NSError+BDMMRAIDAdapter.h
//
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (BDMMRAIDAdapter)

+ (NSError *(^)(NSString *))bdm_error;

//+ (NSError *(^)(NSString *))error;
//
//+ (NSError *)bdm_mraid_errorWithReason:(NSString *)reason;

@end
