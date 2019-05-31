//
//  VASTSettings.m
//  VAST
//
//  Created by Muthu on 6/26/14.
//  Copyright (c) 2014 Nexage, Inc. All rights reserved.
//

#import "DSKVASTSettings.h"

NSString * const kDSKVASTKitVersion     = @"1.1.0";
NSInteger const kDSKMaxRecursiveDepth = 5;
NSTimeInterval const kDSKVideoLoadTimeoutInterval = 10.0;

///Real appodeal vast ads can be parsed by with parser, but they are not valid 
BOOL const kDSKValidateWithSchema = NO;

@implementation DSKVASTSettings

static NSTimeInterval vastVideoLoadTimeout= kDSKVideoLoadTimeoutInterval;

+ (NSTimeInterval)vastVideoLoadTimeout
{
    return vastVideoLoadTimeout?vastVideoLoadTimeout:kDSKVideoLoadTimeoutInterval;
}

+ (void)setVastVideoLoadTimeout:(NSTimeInterval)newValue
{
    if (newValue!=vastVideoLoadTimeout) {
        vastVideoLoadTimeout = newValue>=kDSKVideoLoadTimeoutInterval?newValue:kDSKVideoLoadTimeoutInterval;  // force minimum to default value
    }
}

@end
