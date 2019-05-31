//
//  SKVASTCompanion.m
//  OpenBids
//

//  Copyright © 2016 OpenBids, Inc. All rights reserved.
//

#import "DSKSKVASTCompanion.h"

@implementation DSKSKVASTCompanion

- (instancetype)initWithData:(NSDictionary *)data
                       width:(NSString *)width
                      height:(NSString *)height
             clickThroughURL:(DSKSKVASTUrlWithId *)clickThroughURL
              clickTrackings:(NSArray *)clickTrackings
                    tracking:(NSDictionary *)tracking; {
    
    self = [super init];
    if (self) {
        _dataByType = data;
        _width = width ? [width intValue] : 0;
        _height = height ? [height intValue] : 0;
        _clickThroughURL = clickThroughURL;
        _clickTrackingURL = clickTrackings;
        _tracking = tracking;
    }
    return self;
}

@end
