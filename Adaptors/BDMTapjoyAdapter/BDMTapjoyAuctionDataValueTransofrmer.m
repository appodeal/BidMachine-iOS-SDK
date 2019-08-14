//
//  BDMTapjoyAuctionDataValueTransofrmer.m
//  BDMTapjoyAdapter
//
//  Created by Stas Kochkin on 23/07/2019.
//  Copyright © 2019 Stas Kochkin. All rights reserved.
//

#import "BDMTapjoyAuctionDataValueTransofrmer.h"

@implementation BDMTapjoyAuctionDataValueTransofrmer

+ (Class)transformedValueClass {
    return [NSDictionary class];
}

+ (BOOL)allowsReverseTransformation {
    return NO;
}

- (id)transformedValue:(id)value {
    NSMutableDictionary *auctionData = [value mutableCopy];
    [auctionData removeObjectForKey:@"placement_name"];
    [auctionData removeObjectForKey:@"token"];
    [auctionData removeObjectForKey:@"sdk_key"];
    return auctionData;
}

@end
