//
//  BDMFaceebookPlacementsTransformer.m
//  BDMFacebookAdapter
//
//  Created by Stas Kochkin on 23/07/2019.
//  Copyright © 2019 Stas Kochkin. All rights reserved.
//

#import "BDMFaceebookPlacementsTransformer.h"

#import <StackFoundation/StackFoundation.h>


@implementation BDMFaceebookPlacementsTransformer

+ (Class)transformedValueClass {
    return [NSArray class];
}

+ (BOOL)allowsReverseTransformation {
    return NO;
}

- (id)transformedValue:(id)value {
    return ANY(value).flatMap(^NSString *(id plc) {
        return NSString.stk_isValid(plc) ? plc : nil;
    }).array;
}


@end
