//
//  SKVASTUrlWithId.h
//  VAST
//
//  Created by Jay Tucker on 10/15/13.
//  Copyright (c) 2013 Nexage. All rights reserved.
//
//  VASTUrlWithId is a simple data structure to handle VAST URL elements which may be impresssions or clickthroughs.

#import <Foundation/Foundation.h>

@interface DSKSKVASTUrlWithId : NSObject

@property (nonatomic, copy, readonly) NSString *id_; // add trailing underscore to id_ to avoid conflict with reserved keyword "id".
@property (nonatomic, strong, readonly) NSURL *url;

- (id)initWithID:(NSString *)id_ url:(NSURL *)url;

@end
