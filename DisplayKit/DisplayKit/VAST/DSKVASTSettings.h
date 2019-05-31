//
//  VASTSettings.h
//  VAST
//
//  Created by Muthu on 6/12/14.
//  Copyright (c) 2014 Nexage. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString * const kDSKVASTKitVersion;
FOUNDATION_EXPORT NSInteger const kDSKMaxRecursiveDepth;
FOUNDATION_EXPORT BOOL const kDSKValidateWithSchema;

@interface DSKVASTSettings : NSObject

+ (NSTimeInterval)vastVideoLoadTimeout;

+ (void)setVastVideoLoadTimeout:(NSTimeInterval)newValue;

@end

