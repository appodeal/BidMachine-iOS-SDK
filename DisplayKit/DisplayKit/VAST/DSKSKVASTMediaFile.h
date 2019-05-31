//
//  SKVASTMediaFile.h
//  VAST
//
//  Created by Jay Tucker on 10/15/13.
//  Copyright (c) 2013 Nexage. All rights reserved.
//
//  VASTMediaFile is a data structure that contains parameters for the VAST video itself.
//  The parameters are available from VASTModel, derived from the VAST XML document using the VAS2Parser.  There may be multiple mediaFiles in each VAST document.

#import <Foundation/Foundation.h>

@interface DSKSKVASTMediaFile : NSObject

@property (nonatomic, copy, readonly) NSString *id_;  // add trailing underscore to id_ to avoid conflict with reserved keyword "id".
@property (nonatomic, copy, readonly) NSString *delivery;
@property (nonatomic, copy, readonly) NSString *type;
@property (nonatomic, assign, readonly) int bitrate;
@property (nonatomic, assign, readonly) int width;
@property (nonatomic, assign, readonly) int height;
@property (nonatomic, assign, readonly) float duration;
@property (nonatomic, assign, readonly) BOOL scalable;
@property (nonatomic, assign, readonly) BOOL maintainAspectRatio;
@property (nonatomic, copy, readonly) NSString *apiFramework;
@property (nonatomic, strong, readonly) NSURL *url;

- (id)initWithId:(NSString *)id_ // add trailing underscore
        delivery:(NSString *)delivery
            type:(NSString *)type
         bitrate:(NSString *)bitrate
           width:(NSString *)width
          height:(NSString *)height
        duration:(NSString *)duration
        scalable:(NSString *)scalable
maintainAspectRatio:(NSString *)maintainAspectRatio
    apiFramework:(NSString *)apiFramework
             url:(NSString *)url;

@end
