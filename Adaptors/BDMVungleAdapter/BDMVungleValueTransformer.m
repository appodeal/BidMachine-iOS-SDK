//
//  BDMVungleValueTransformer.m
//  BDMVungleAdapter
//
//  Created by Stas Kochkin on 22/07/2019.
//  Copyright © 2019 Stas Kochkin. All rights reserved.
//

#import "BDMVungleValueTransformer.h"

@implementation BDMVungleValueTransformer

+ (Class)transformedValueClass {
    return [NSString class];
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
