//
//  DSKVASTCompanion.h
//  OpenBids
//

//  Copyright © 2016 OpenBids, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DSKVASTExtensionModel.h"

typedef NS_ENUM(NSInteger, DSKVASTAspectRatio) {
    DSKVASTAspectRatioUnknown = 0,
    DSKVASTAspectRatioBanner,
    DSKVASTAspectRatioLandscape,
    DSKVASTAspectRatioPortrait
};

typedef NS_ENUM(NSInteger, DSKVASTCompanionType) {
    DSKVASTCompanionTypeStatic = 0,
    DSKVASTCompanionTypeHTML,
    DSKVASTCompanionTypeIFrame,
    DSKVASTCompanionTypeUndefined = NSNotFound
};

DSKVASTCompanionType DSK_companionTypeFromString(NSString * typeString);

@interface DSKVASTCompanion : NSObject

//data set NSURL?
@property (nonatomic, strong, readonly) NSString * data;
@property (nonatomic, strong, readonly) NSURL * clickThroughURL;
@property (nonatomic, strong, readonly) NSArray * clickTrackingURLs;
@property (nonatomic, strong, readonly) NSArray * creativeViewTrackingURLs;
//@property (nonatomic, strong, readonly) NSURL* impressionURL;

@property (nonatomic, assign) int width;
@property (nonatomic, assign) int heigth;

@property (nonatomic, assign, readonly) DSKVASTAspectRatio aspectRatio;
@property (nonatomic, assign, readonly) DSKVASTCompanionType type;


+ (NSArray <DSKVASTCompanion *> *)companionFromModels:(NSArray <DSKVASTCompanionModel *> *)extentionModels;

+ (instancetype)companionFromModel:(DSKVASTCompanionModel *)extentionModel;

@end
