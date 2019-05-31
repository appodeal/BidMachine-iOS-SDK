//
//  BDMSpecUtils.m
//
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import "BDMSpecUtils.h"

@implementation BDMSpecUtils

+ (NSDictionary *(^)(NSString *))specFixtures {
    return ^NSDictionary *(NSString *name){
        NSBundle * bundle =  [NSBundle bundleForClass:self];
        NSString * fixturePath = [bundle pathForResource:[name componentsSeparatedByString:@"."].firstObject ofType:[name componentsSeparatedByString:@"."].lastObject];
        NSData * fixtureData = [NSData dataWithContentsOfFile:fixturePath];
        id jsonObject = [NSJSONSerialization JSONObjectWithData:fixtureData options:0 error:nil];
        return jsonObject;
    };
}

@end
