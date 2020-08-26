//
//  BDMPlacementAdUnit.m
//  BidMachine
//
//  Created by Stas Kochkin on 17/07/2019.
//  Copyright © 2019 Appodeal. All rights reserved.
//

#import "BDMPlacementAdUnit.h"
#import "BDMAdUnit.h"

#import <StackFoundation/StackFoundation.h>


@interface BDMAdUnitExtended : BDMAdUnit <BDMPlacementAdUnit>

@property (nonatomic, copy, readwrite) NSString *bidderSdkVersion;
@property (nonatomic, copy, readwrite) NSString *bidder;
@property (nonatomic, copy, readwrite) NSDictionary <NSString *, id> *clientParams;

@end


@implementation BDMAdUnitExtended

- (id)copyWithZone:(NSZone *)zone {
    BDMAdUnitExtended *copy = [super copyWithZone:zone];
    copy.bidderSdkVersion = self.bidderSdkVersion;
    copy.clientParams = self.clientParams;
    copy.bidder = self.bidder;
    return copy;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.bidderSdkVersion = [coder decodeObjectForKey:@"bidder_sdk_ver"];
        self.clientParams = [coder decodeObjectForKey:@"client_params"];
        self.bidder = [coder decodeObjectForKey:@"bidder"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.bidderSdkVersion forKey:@"bidder_sdk_ver"];
    [aCoder encodeObject:self.clientParams forKey:@"client_params"];
    [aCoder encodeObject:self.bidder forKey:@"bidder"];
}

@end


@interface BDMPlacementAdUnitBuilder ()

@property (nonatomic, copy) BDMAdUnit *adUnit;
@property (nonatomic, copy) NSString *sdkVer;
@property (nonatomic, copy) NSString *bidder;
@property (nonatomic, copy) NSDictionary <NSString *, id> *clientParams;

@end


@implementation BDMPlacementAdUnitBuilder

+ (id<BDMPlacementAdUnit>)placementAdUnitWithBuild:(void (^)(BDMPlacementAdUnitBuilder *))build {
    BDMPlacementAdUnitBuilder *builder = [BDMPlacementAdUnitBuilder new];
    build(builder);
    BDMAdUnitExtended *placementAdUnit = [[BDMAdUnitExtended alloc] initWithFormat:builder.adUnit.format
                                                                      customParams:builder.adUnit.customParams
                                                                            extras:builder.adUnit.extras];
    placementAdUnit.bidder = builder.bidder;
    placementAdUnit.bidderSdkVersion = builder.sdkVer;
    placementAdUnit.clientParams = [builder clientParamsWithExtras:builder.adUnit.extras];

    return placementAdUnit;
}

- (BDMPlacementAdUnitBuilder *(^)(BDMAdUnit *))appendAdUnit {
    return ^id(BDMAdUnit *unit) {
        self.adUnit = unit;
        return self;
    };
}

- (BDMPlacementAdUnitBuilder *(^)(NSString *))appendBidder {
    return ^id(NSString *bidder) {
        self.bidder = bidder;
        return self;
    };
}

- (BDMPlacementAdUnitBuilder *(^)(NSString *))appendSdkVersion {
    return ^id(NSString *sdkVersion) {
        self.sdkVer = sdkVersion;
        return self;
    };
}

- (BDMPlacementAdUnitBuilder *(^)(NSDictionary<NSString *,id> *))appendClientParamters {
    return ^id(NSDictionary<NSString *,id> *clientParams) {
        self.clientParams = clientParams;
        return self;
    };
}

- (NSDictionary *)clientParamsWithExtras:(NSDictionary <NSString *, id> *)extras {
    NSMutableDictionary *params = self.clientParams.mutableCopy;
    if (extras.count) {
        NSData *data = [STKJSONSerialization dataWithJSONObject:extras options:NSJSONWritingFragmentsAllowed error:nil];
        NSString * extString = [data base64EncodedStringWithOptions: 0];
        params[@"bdm_ext"] = extString;
    }
    return params;
}

@end
