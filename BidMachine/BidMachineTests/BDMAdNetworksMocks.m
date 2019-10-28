//
//  BDMAdNetworksMocks.m
//  BidMachineTests
//
//  Created by Stas Kochkin on 08/08/2019.
//  Copyright © 2019 Appodeal. All rights reserved.
//

#import "BDMAdNetworksMocks.h"
#import <Kiwi/Kiwi.h>


@implementation BDMMRAIDNetwork

- (NSString *)name {
    return @"mraid";
}

- (id<BDMBannerAdapter>)bannerAdapterForSdk:(BDMSdk *)sdk {
    return [KWMock nullMockForProtocol:@protocol(BDMBannerAdapter)];
}

@end


@implementation BDMVASTNetwork

- (NSString *)name {
    return @"vast";
}

@end


@implementation BDMNASTNetwork

- (NSString *)name {
    return @"nast";
}

@end


@implementation BDMHeaderBiddingNetwork

- (NSString *)name {
    return @"headerbidding";
}

- (void)initialiseWithParameters:(NSDictionary<NSString *,id> *)parameters
                      completion:(void (^)(BOOL, NSError *))completion {}

- (void)collectHeaderBiddingParameters:(NSDictionary<NSString *,id> *)parameters
                          adUnitFormat:(BDMAdUnitFormat)adUnitFormat
                            completion:(void (^)(NSDictionary<NSString *,id> *, NSError *))completion {}

@end
