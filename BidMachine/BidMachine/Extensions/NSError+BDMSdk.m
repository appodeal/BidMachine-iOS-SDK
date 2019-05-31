//
//  NSError+BDMSdk.m
//  BidMachine
//
//  Created by Stas Kochkin on 29/11/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import "NSError+BDMSdk.h"


@implementation NSError (BDMSdk)

- (NSError *)bdm_wrappedWithCode:(BDMErrorCode)code {
    return [NSError errorWithDomain:kBDMErrorDomain
                               code:code
                           userInfo:self.userInfo.copy];
}

+ (NSError *)bdm_errorWithCode:(BDMErrorCode)code description:(NSString *)description {
    
    return [NSError errorWithDomain:kBDMErrorDomain
                               code:code
                           userInfo:@{ NSLocalizedDescriptionKey: @"BidMachine sdk was unsuccessful",
                                       NSLocalizedFailureReasonErrorKey : description ?: @"No description" }];
}

- (BDMErrorCode)bdm_transformedFromNSURLErrorDomain {
    switch (self.code) {
        case NSURLErrorBadURL: return BDMErrorCodeBadContent; break;
        case NSURLErrorTimedOut: return BDMErrorCodeTimeout; break;
        case NSURLErrorNotConnectedToInternet: return BDMErrorCodeNoConnection; break;
            
        default: return BDMErrorCodeUnknown; break;
    }
}

@end

@implementation NSURLResponse (BDMSdk)

- (BDMErrorCode)bdm_errorCode {
    if ([self isKindOfClass:NSHTTPURLResponse.class]) {
        BOOL badRequest = [(NSHTTPURLResponse *)self statusCode] >= 400 && [(NSHTTPURLResponse *)self statusCode] < 500;
        BOOL internalServerError = [(NSHTTPURLResponse *)self statusCode] > 500;
        if (badRequest) {
            return BDMErrorCodeHTTPBadRequest;
        } else if (internalServerError) {
            return BDMErrorCodeHTTPServerError;
        }
    }
    return BDMErrorCodeUnknown;
}

@end

@implementation NSException (BDMSdk)

- (NSError *)bdm_wrappedError {
    return [NSError bdm_errorWithCode:BDMErrorCodeException description:self.userInfo[NSLocalizedDescriptionKey]];
}

@end
