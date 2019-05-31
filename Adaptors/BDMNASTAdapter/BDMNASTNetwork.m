//
//  BDMNASTNetwork.m
//  BDMNASTAdapter
//
//  Created by Stas Kochkin on 04/11/2018.
//  Copyright © 2018 Stas Kochkin. All rights reserved.
//

#import "BDMNASTNetwork.h"
#import "BDMNASTNativeAdServiceAdapter.h"


@implementation BDMNASTNetwork

#pragma mark - BDMNetwork

+ (NSString *)name {
    return @"nast";
}

+ (NSString *)sdkVersion {
    return @"2.0";
}

+ (Class<BDMNativeAdServiceAdapter>)nativeAdAdapterClassForSdk:(BDMSdk *)sdk {
    return BDMNASTNativeAdServiceAdapter.class;
}

@end
