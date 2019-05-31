//
//  SKVASTMediaFile.m
//  VAST
//
//  Created by Jay Tucker on 10/15/13.
//  Copyright (c) 2013 Nexage. All rights reserved.
//

#import "DSKSKVASTMediaFile.h"
#import "NSString+DSKExtensions.h"


@implementation DSKSKVASTMediaFile

- (id)initWithId:(NSString *)id_
        delivery:(NSString *)delivery
            type:(NSString *)type
         bitrate:(NSString *)bitrate
           width:(NSString *)width
          height:(NSString *)height
        duration:(NSString *)duration
        scalable:(NSString *)scalable
maintainAspectRatio:(NSString *)maintainAspectRatio
    apiFramework:(NSString *)apiFramework
             url:(NSString *)url

{
    self = [super init];
    if (self) {
        _id_ = id_;
        _delivery = delivery;
        _type = type;
        _bitrate = bitrate ? [bitrate intValue] : 0;
        _width = width ? [width intValue] : 0;
        _height = height ? [height intValue] : 0;
        _scalable = scalable == nil || [scalable boolValue];
        _duration = duration ? [duration DSK_timeInterval] : 0;
        _maintainAspectRatio = maintainAspectRatio != nil && [maintainAspectRatio boolValue];
        _apiFramework = apiFramework;
        _url = [NSURL URLWithString:url];
    }
    return self;
}


@end
