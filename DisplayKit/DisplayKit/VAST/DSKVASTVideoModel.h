//
//  DSKVASTVideoModel.h
//  OpenBids
//

//  Copyright © 2016 OpenBids, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DSKVASTCompanion.h"
#import "DSKVASTTrackingModel.h"
#import "DSKVASTExtension.h"


@interface DSKVASTVideoModel : NSObject

@property (nonatomic, strong, readonly) NSURL* videoURL;
@property (nonatomic, strong, readonly) NSURL* clickThroughURL;

@property (nonatomic, copy) NSString * errorNoticeUrl;

@property (nonatomic, assign, readonly) NSInteger width;
@property (nonatomic, assign, readonly) NSInteger heigth;
@property (nonatomic, assign) DSKVASTAspectRatio aspectRatio;

@property (nonatomic, assign, readonly) float skippOffset;
@property (nonatomic, assign, readonly) float duration;

@property (nonatomic, strong, readonly) DSKVASTTrackingModel* tracking;

@property (nonatomic, strong, readonly) NSString * rawData;

@property (nonatomic, strong) NSArray <__kindof DSKVASTCompanion *> *companionsArray;

@property (nonatomic, strong, readonly) DSKVASTExtension * extension;

+ (void)parseVastData:(NSData*)XMLData completion:(void(^)(DSKVASTVideoModel *vast, NSError *vastParsingError))completion;
+ (void)parseVastUrl:(NSURL *)Url completion:(void (^)(DSKVASTVideoModel *, NSError *))completion;

@end
