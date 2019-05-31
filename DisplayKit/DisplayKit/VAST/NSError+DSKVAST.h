//
//  NSError+DSKVAST.h
//  OpenBids
//

//  Copyright © 2016 OpenBids, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, DSKVASTErrorCode) {
    DSKVASTNoError = 0,
    DSKVASTParsingError = 100,
    DSKVASTValidationError = 101,
    DSKVASTNoSupportedError = 102,
    DSKVASTTrafficError = 200,
    DSKVASTExpectedDurationError = 202,
    DSKVASTURIConnectionError = 301,
    DSKVASTNoFileError = 401,
    DSKVASTProblemFileError = 405,
    DSKVASTCompanionError = 600,
    DSKVASTUndefinedError = 900
};

@interface NSError (DSKVAST) 

+ (NSError *)DSK_vastErrorWithCode:(DSKVASTErrorCode)errorCode;

@end
