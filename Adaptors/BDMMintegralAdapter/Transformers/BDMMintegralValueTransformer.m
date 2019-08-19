//
//  BDMMintegralValueTransformer.m
//  BDMMintegralAdapter
//
//  Created by Yaroslav Skachkov on 8/16/19.
//  Copyright © 2019 Stas Kochkin. All rights reserved.
//

#import "BDMMintegralValueTransformer.h"

@implementation BDMMintegralValueTransformer

+ (Class)transformedValueClass {
    return [NSArray class];
}

+ (BOOL)allowsReverseTransformation {
    return NO;
}

- (id)transformedValue:(id)value {
    if ([value isKindOfClass:NSString.class]) {
        return value;
    } else if ([value isKindOfClass:NSNumber.class]) {
        return [(NSNumber *)value stringValue];
    }
    return nil;
}

@end
