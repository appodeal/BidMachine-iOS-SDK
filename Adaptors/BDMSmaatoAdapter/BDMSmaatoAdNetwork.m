//
//  BDMSmaatoAdNetwork.m
//  BDMSmaatoAdapter
//
//  Created by Ilia Lozhkin on 10/24/19.
//  Copyright © 2019 Stas Kochkin. All rights reserved.
//

#import "BDMSmaatoAdNetwork.h"
#import "BDMSmaatoBannerAdapter.h"
#import "BDMSmaatoFullscreenAdapter.h"
#import "BDMSmaatoStringValueTransformer.h"

@import SmaatoSDKCore;
@import StackFoundation;

@interface BDMSmaatoAdNetwork()

@property (nonatomic, assign) BOOL initialized;

@end

@implementation BDMSmaatoAdNetwork

- (NSString *)name {
    return @"smaato";
}

- (NSString *)sdkVersion {
    return SmaatoSDK.sdkVersion;
}

- (void)initialiseWithParameters:(NSDictionary<NSString *,id> *)parameters
                      completion:(void (^)(BOOL, NSError * _Nullable))completion {
    [self syncMetadata];
    NSString *publisherId = [BDMSmaatoStringValueTransformer.new transformedValue:parameters[@"publisherId"]];
    
    if (self.initialized) {
        STK_RUN_BLOCK(completion, NO, nil);
        return;
    }
    
    if (publisherId) {
        SMAConfiguration *configuration = [[SMAConfiguration alloc] initWithPublisherId:publisherId];
        configuration.logLevel = BDMSdkLoggingEnabled ? kSMALogLevelVerbose : kSMALogLevelError;
        [SmaatoSDK initSDKWithConfig:configuration];
    } else {
        NSError * error = [NSError bdm_errorWithCode:BDMErrorCodeInternal description:@"Smaato app id is not valid string"];
        STK_RUN_BLOCK(completion, YES, error);
    }
}

- (void)collectHeaderBiddingParameters:(NSDictionary<NSString *,id> *)parameters
                            completion:(void (^)(NSDictionary<NSString *,id> * _Nullable, NSError * _Nullable))completion {
    [self syncMetadata];
    NSString *adSpaceId = [BDMSmaatoStringValueTransformer.new transformedValue:parameters[@"adSpaceId"]];
    NSString *publisherId = [BDMSmaatoStringValueTransformer.new transformedValue:parameters[@"publisherId"]];
    if (!adSpaceId || !publisherId) {
        NSError *error = [NSError bdm_errorWithCode:BDMErrorCodeHeaderBiddingNetwork
                                        description:@"FBAudienceNetwork adapter was not receive valid bidding data"];
        STK_RUN_BLOCK(completion, nil, error);
        return;
    }
    
    NSMutableDictionary *bidding = [NSMutableDictionary dictionaryWithCapacity:3];
    bidding[@"adSpaceId"] = adSpaceId;
    bidding[@"publisherId"] = publisherId;
    
    STK_RUN_BLOCK(completion, bidding, nil);
}

- (id<BDMBannerAdapter>)bannerAdapterForSdk:(BDMSdk *)sdk {
    return BDMSmaatoBannerAdapter.new;
}

- (id<BDMFullscreenAdapter>)interstitialAdAdapterForSdk:(BDMSdk *)sdk {
    return BDMSmaatoFullscreenAdapter.new;
}

- (id<BDMFullscreenAdapter>)videoAdapterForSdk:(BDMSdk *)sdk {
    return BDMSmaatoFullscreenAdapter.new;
}

#pragma mark - Private

- (void)syncMetadata {
    if (BDMSdk.sharedSdk.restrictions.allowUserInformation) {
        BDMTargeting *targeting = BDMSdk.sharedSdk.configuration.targeting;
        SmaatoSDK.userAge = targeting.userAge;
        SmaatoSDK.userRegion = targeting.country;
        SmaatoSDK.userZipCode = targeting.zip;

        if (targeting.deviceLocation) {
            SmaatoSDK.userLocation = [[SMALocation alloc] initWithLatitude:targeting.deviceLocation.coordinate.latitude
                                                                 longitude:targeting.deviceLocation.coordinate.longitude
                                                        horizontalAccuracy:targeting.deviceLocation.horizontalAccuracy
                                                                 timestamp:targeting.deviceLocation.timestamp];
            
        }
        
        if ([targeting.gender isEqualToString:kBDMUserGenderMale]) {
            SmaatoSDK.userGender = kSMAGenderMale;
        } else if ([targeting.gender isEqualToString:kBDMUserGenderFemale]) {
            SmaatoSDK.userGender = kSMAGenderFemale;
        }
    }
}

@end
