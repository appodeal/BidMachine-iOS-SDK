//
//  SKVASTCompanion.h
//  OpenBids
//

//  Copyright © 2016 OpenBids, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DSKSKVASTUrlWithId.h"



@interface DSKSKVASTCompanion : NSObject

@property (nonatomic, strong) NSDictionary * dataByType;
@property (nonatomic, strong, readonly) DSKSKVASTUrlWithId* clickThroughURL;
@property (nonatomic, strong, readonly) NSArray * clickTrackingURL;
@property (nonatomic, strong, readonly) NSDictionary * tracking;

@property (nonatomic, assign) int width;
@property (nonatomic, assign) int height;

- (instancetype)initWithData:(NSDictionary *)data
                       width:(NSString *)width
                      height:(NSString *)height
             clickThroughURL:(DSKSKVASTUrlWithId *)clickThroughURL
              clickTrackings:(NSArray *)clickTrackings
                    tracking:(NSDictionary *)tracking;

@end
