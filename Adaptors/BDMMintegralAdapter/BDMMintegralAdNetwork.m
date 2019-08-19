//
//  BDMMintegralAdNetwork.m
//  BDMMintegralAdNetwork
//
//  Created by Yaroslav Skachkov on 8/16/19.
//  Copyright © 2019 Stas Kochkin. All rights reserved.
//

@import StackFoundation;

#import "BDMMintegralAdNetwork.h"
#import "BDMMintegralValueTransformer.h"
#import "BDMMintegralFullscreenAdapter.h"
#import <MTGSDK/MTGSDK.h>
#import <MTGSDKBidding/MTGBiddingSDK.h>

@implementation BDMMintegralAdNetwork

- (NSString *)name {
    return @"mintegral";
}

- (NSString *)sdkVersion {
    return MTGSDKVersion;
}

- (void)initialiseWithParameters:(NSDictionary<NSString *,id> *)parameters
                      completion:(void (^)(BOOL, NSError * _Nullable))completion {
    [self syncMetadata];
    STK_RUN_BLOCK(completion, NO, nil);
}

- (void)collectHeaderBiddingParameters:(NSDictionary<NSString *,id> *)parameters
                            completion:(void (^)(NSDictionary<NSString *,id> * _Nullable, NSError * _Nullable))completion {
    [self syncMetadata];
    NSString *appId = [BDMMintegralValueTransformer.new transformedValue:parameters[@"app_id"]];
    NSString *buyeruid = [MTGBiddingSDK buyerUID];
    NSString *unitId = [BDMMintegralValueTransformer.new transformedValue:parameters[@"unit_id"]];
    if (!appId || !buyeruid || !unitId) {
        NSError *error = [NSError bdm_errorWithCode:BDMErrorCodeHeaderBiddingNetwork
                                        description:@"FBAudienceNetwork adapter was not receive valid bidding data"];
        STK_RUN_BLOCK(completion, nil, error);
        return;
    }
    
    NSMutableDictionary *bidding = [NSMutableDictionary dictionaryWithCapacity:3];
    bidding[@"app_id"] = appId;
    bidding[@"buyeruid"] = buyeruid;
    bidding[@"unit_id"] = unitId;
    
    STK_RUN_BLOCK(completion, bidding, nil);
}

- (id<BDMFullscreenAdapter>)videoAdapterForSdk:(BDMSdk *)sdk {
    return [BDMMintegralFullscreenAdapter new];
}

#pragma mark - Private

- (void)syncMetadata {
    [[MTGSDK sharedInstance] setConsentStatus:BDMSdk.sharedSdk.restrictions.hasConsent];
}

@end
