//
//  DSKVastExtentionModel.h
//  OpenBids
//
//  Created by Lozhkin Ilya on 8/3/17.
//  Copyright © 2017 OpenBids, Inc. All rights reserved.
//

#import "DSKXMLModel.h"
#import "DSKVASTCompanionModel.h"


@interface DSKVASTExtensionModel : DSKXMLModel

@property (nonatomic, strong) NSString * typeName;

@property (nonatomic, strong) NSString * ctaText;
@property (nonatomic, strong) NSNumber * ctaShow;
@property (nonatomic, strong) NSNumber * muteShow;
@property (nonatomic, strong) NSNumber * progressShow;
@property (nonatomic, strong) NSNumber * companionShow;
@property (nonatomic, strong) NSNumber * videoClickable;

@property (nonatomic, strong) NSString * companionCloseTime;
@property (nonatomic, strong) NSString * assetStrokeColor;
@property (nonatomic, strong) NSString * assetFillColor;

@property (nonatomic, strong) NSString * ctaXPosition;
@property (nonatomic, strong) NSString * ctaYPosition;

@property (nonatomic, strong) NSString * muteXPosition;
@property (nonatomic, strong) NSString * muteYPosition;

@property (nonatomic, strong) NSString * closeXPosition;
@property (nonatomic, strong) NSString * closeYPosition;

@property (nonatomic, strong) DSKVASTCompanionModel * companion;

@end
