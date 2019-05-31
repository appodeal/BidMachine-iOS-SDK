//
//  DSKVastCompanionModel.h
//  OpenBids
//
//  Created by Lozhkin Ilya on 8/4/17.
//  Copyright © 2017 OpenBids, Inc. All rights reserved.
//

#import "DSKXMLModel.h"
#import "DSKVASTResourceModel.h"


@interface DSKVASTCompanionResource : DSKVASTResourceModel

@property (nonatomic, strong) NSString * type;

@end


@interface DSKVASTCompanionTracking : DSKVASTResourceModel

@property (nonatomic, strong) NSString * event;

@end


@interface DSKVASTCompanionClickThrough : DSKVASTResourceModel

@end


@interface DSKVASTCompanionModel : DSKXMLModel

@property (nonatomic, strong) NSString * width;
@property (nonatomic, strong) NSString * height;

@property (nonatomic, strong) DSKVASTCompanionResource * resource;
@property (nonatomic, strong) DSKVASTCompanionClickThrough * companionClick;

@property (nonatomic, strong) NSArray <DSKVASTCompanionTracking *> * trackings;

@end
