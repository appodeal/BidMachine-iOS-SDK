//
//  DSKVastCompanionModel.m
//  OpenBids
//
//  Created by Lozhkin Ilya on 8/4/17.
//  Copyright © 2017 OpenBids, Inc. All rights reserved.
//

#import "DSKVASTCompanionModel.h"

@interface DSKVASTCompanionResource ()

@property (nonatomic, strong) NSString * staticResource;
@property (nonatomic, strong) NSString * iframeResource;
@property (nonatomic, strong) NSString * htmlResource;

@end

@implementation DSKVASTCompanionResource

+ (NSDictionary *)DSK_xmlModel{
    return @{@"type"                :   @"attr_creativeType",
             @"staticResource"      :   @"StaticResource",
             @"iframeResource"      :   @"IFrameResource",
             @"htmlResource"        :   @"HTMLResource"};
}

- (NSString *)type{
    if (_htmlResource) {
        return @"HTMLResource";
    }
    
    if (_iframeResource) {
        return @"IFrameResource";
    }
    
    if (_staticResource) {
        return @"StaticResource";
    }
    
    return @"";
}

- (NSString *)resource{
    if (_htmlResource) {
        return _htmlResource;
    }
    
    if (_iframeResource) {
        return _iframeResource;
    }
    
    if (_staticResource) {
        return _staticResource;
    }
    
    return nil;
}

+ (DSKXMLValueTransformer *)htmlResourceValueTransformer{
    return [self transformerStringAsStringOrURLString];
}

+ (DSKXMLValueTransformer *)iframeResourceValueTransformer{
    return [self transformerStringAsStringOrURLString];
}

+ (DSKXMLValueTransformer *)staticResourceValueTransformer{
    return [self transformerStringAsStringOrURLString];
}

@end

@implementation DSKVASTCompanionTracking

+ (NSDictionary *)DSK_xmlModel{
    return @{@"event"               : @"attr_event",
             @"resource"            : @"Tracking"};
}

@end

@implementation DSKVASTCompanionClickThrough : DSKVASTResourceModel

+ (NSDictionary *)DSK_xmlModel{
    return @{@"resource"            : @"CompanionClickThrough"};
}

@end

@implementation DSKVASTCompanionModel

+ (NSDictionary *)DSK_xmlModel{
    return @{@"width"               : @"attr_height",
             @"height"              : @"attr_height",
             @"resource"            : @"StaticResource",
             @"companionClick"      : @"CompanionClickThrough",
             @"trackings"           : @"TrackingEvents"};
}

+ (DSKXMLNodeTransformer *)trackingJSONTransformer{
    return [self transformerArrayOfObjects:DSKVASTCompanionTracking.class];
}

@end
