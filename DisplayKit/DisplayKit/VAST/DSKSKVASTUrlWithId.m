//
//  SKVASTUrlWithId.m
//  VAST
//
//  Created by Jay Tucker on 10/15/13.
//  Copyright (c) 2013 Nexage. All rights reserved.
//

#import "DSKSKVASTUrlWithId.h"

@implementation DSKSKVASTUrlWithId

- (id)initWithID:(NSString *)id_ url:(NSURL *)url
{
    self = [super init];
    if (self) {
        _id_ = id_;
        _url = url;;
    }
    return self;
}

@end
