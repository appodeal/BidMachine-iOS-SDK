//
//  DSKVASTExtension.h
//  OpenBids

//  Copyright © 2016 OpenBids, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DSKVASTExtensionModel.h"
#import "DSKVASTCompanion.h"
#import "DSKConstraintMaker.h"


@protocol DSKVASTExtention <NSObject>

@property (nonatomic, assign, readonly) BOOL progressBarEnabled;
@property (nonatomic, assign, readonly) BOOL videoClickable;

@end


@protocol DSKCompanionExtention <NSObject>

@property (nonatomic, assign, readonly) BOOL companionEnabled;

@property (nonatomic, strong, readonly) NSNumber * companionCloseTime;

@end


@protocol DSKControllExtension <NSObject>

@property (nonatomic, strong, readonly) NSString * callToActionText;

@property (nonatomic, assign, readonly) BOOL ctaEnabled;
@property (nonatomic, assign, readonly) BOOL muteEnabled;

@property (nonatomic, strong, readonly) DSKConstraintMaker *ctaPosition;
@property (nonatomic, strong, readonly) DSKConstraintMaker *closePosition;
@property (nonatomic, strong, readonly) DSKConstraintMaker *mutePosition;

@property (nonatomic, strong, readonly) UIColor * assetStrokeColor;
@property (nonatomic, strong, readonly) UIColor * assetFillColor;

@end


@interface DSKVASTExtension : NSObject <DSKControllExtension, DSKCompanionExtention, DSKVASTExtention>

@property (nonatomic, strong, readonly) DSKVASTCompanion * companion;

+ (DSKVASTExtension *)extensionFromModel:(DSKVASTExtensionModel *)extentionModel;

@end
