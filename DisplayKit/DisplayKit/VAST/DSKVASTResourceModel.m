//
//  DSKVastResourceModel.m
//  OpenBids
//
//  Created by Lozhkin Ilya on 8/4/17.
//  Copyright © 2017 OpenBids, Inc. All rights reserved.
//

#import "DSKVASTResourceModel.h"

@implementation DSKVASTResourceModel

+ (NSDictionary *)DSK_xmlModel{
    return nil;
}

+ (DSKXMLValueTransformer *)resourceValueTransformer{
    return [self transformerStringAsStringOrURLString];
}

@end
