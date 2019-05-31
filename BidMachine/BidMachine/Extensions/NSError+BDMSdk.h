//
//  NSError+BDMSdk.h
//  BidMachine
//
//  Created by Stas Kochkin on 29/11/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BidMachine/BDMDefines.h>


@interface NSError (BDMSdk)

- (NSError *)bdm_wrappedWithCode:(BDMErrorCode)code;
+ (NSError *)bdm_errorWithCode:(BDMErrorCode)code description:(NSString *)description;

- (BDMErrorCode)bdm_transformedFromNSURLErrorDomain;

@end

@interface NSURLResponse (BDMSdk)

- (BDMErrorCode)bdm_errorCode;

@end


@interface NSException (BDMSdk)

- (NSError *)bdm_wrappedError;

@end
