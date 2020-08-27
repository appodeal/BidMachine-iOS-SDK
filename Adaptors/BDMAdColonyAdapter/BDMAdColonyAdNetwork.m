//
//  BDMAdColonyAdapter.m
//  BDMAdColonyAdapter
//
//  Created by Stas Kochkin on 19/07/2019.
//  Copyright © 2019 Stas Kochkin. All rights reserved.
//

#import <AdColony/AdColony.h>
#import <StackFoundation/StackFoundation.h>

#import "BDMAdColonyAdNetwork.h"
#import "BDMAdColonyStringTransformer.h"
#import "BDMAdColonyFullscreenAdapter.h"
#import "BDMAdColonyAppOptions.h"


@interface BDMAdColonyAdNetwork ()<AdColonyInterstitialDelegate>

@property (nonatomic, strong) NSMutableArray <AdColonyZone *> *zones;
@property (nonatomic, strong) NSPointerArray *interstitials;
@property (nonnull, copy) NSString *appId;
@property (nonatomic, copy) void(^interstitialCompletion)(AdColonyInterstitial *, NSError *);

@end

@implementation BDMAdColonyAdNetwork

- (instancetype)init {
    if (self = [super init]) {
        self.zones = [NSMutableArray arrayWithCapacity:1];
        self.interstitials = [NSPointerArray weakObjectsPointerArray];
    }
    return self;
}

- (NSString *)name {
    return @"adcolony";
}

- (NSString *)sdkVersion {
    return AdColony.getSDKVersion;
}

- (void)initialiseWithParameters:(NSDictionary<NSString *,id> *)parameters
                      completion:(void (^)(BOOL, NSError *))completion {
    if (self.zones.count) {
        STK_RUN_BLOCK(completion, NO, nil);
        return;
    }
    
    BDMAdColonyStringTransformer *transformer = [BDMAdColonyStringTransformer new];
    NSString *appId = [transformer transformedValue:parameters[@"app_id"]];
    NSArray <NSString *> *zones = ANY(parameters[@"zones"])
    .flatMap(^id(id val) { return [transformer transformedValue:val]; })
    .array;
    
    if (!appId || !zones.count) {
        NSError *error = [NSError bdm_errorWithCode:BDMErrorCodeHeaderBiddingNetwork
                                        description:@"AdColony app id or zones not valid!"];
        STK_RUN_BLOCK(completion, YES, error);
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    self.appId = appId;
    AdColonyAppOptions *options = [BDMAdColonyAppOptions new];
    [AdColony configureWithAppID:appId
                         zoneIDs:zones
                         options:options
                      completion:^(NSArray<AdColonyZone *> *zones) {
                          [weakSelf.zones addObjectsFromArray:zones];
                          STK_RUN_BLOCK(completion, YES, nil);
    }];
}

- (void)collectHeaderBiddingParameters:(NSDictionary<NSString *,id> *)parameters
                          adUnitFormat:(BDMAdUnitFormat)adUnitFormat
                            completion:(void (^)(NSDictionary<NSString *,id> *, NSError *))completion {
    BDMAdColonyStringTransformer *transformer = [BDMAdColonyStringTransformer new];
    NSString *zoneId = [transformer transformedValue:parameters[@"zone_id"]];
    NSString *appId = self.appId;
    // Check that we have zone id
    if (!zoneId || !self.appId) {
        NSError *error = [NSError bdm_errorWithCode:BDMErrorCodeHeaderBiddingNetwork
                                        description:@"AdColony zone_id wasn't found"];
        STK_RUN_BLOCK(completion, nil, error);
        return;
    }
    // Check that we have zone for id
    AdColonyZone *zone = ANY(self.zones).filter(^BOOL(AdColonyZone *zone) {
        return [zone.identifier isEqualToString:zoneId];
    }).array.firstObject;
    
    if (!zone) {
        NSString *reason = [NSString stringWithFormat:@"AdColony zone for id: %@ not found", zoneId];
        NSError *error = [NSError bdm_errorWithCode:BDMErrorCodeHeaderBiddingNetwork
                                        description:reason];
        STK_RUN_BLOCK(completion, nil, error);
        return;
    }
    
    AdColonyInterstitial *interstitial = [self interstitialForZone:zoneId];
    if (interstitial != nil) {
        NSDictionary *clientParams = @{ @"app_id": appId, @"zone_id" : zoneId };
        STK_RUN_BLOCK(completion, clientParams, nil);
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    self.interstitialCompletion = ^(AdColonyInterstitial *ad, NSError *error) {
        if (ad) {
            @synchronized (weakSelf) {
                [weakSelf.interstitials addPointer:(__bridge void *)(ad)];
            }
            NSDictionary *clientParams = @{ @"app_id": appId, @"zone_id" : zoneId };
            STK_RUN_BLOCK(completion, clientParams, nil);
        } else {
            NSError *wrapper = [error bdm_wrappedWithCode:BDMErrorCodeHeaderBiddingNetwork];
            STK_RUN_BLOCK(completion, nil, wrapper);
        }
    };
    [AdColony requestInterstitialInZone:zone.identifier options:nil andDelegate:self];
}

- (id<BDMFullscreenAdapter>)videoAdapterForSdk:(BDMSdk *)sdk {
    return [[BDMAdColonyFullscreenAdapter alloc] initWithProvider:self];
}

- (void)adColonyInterstitialDidLoad:(AdColonyInterstitial * _Nonnull)interstitial {
    STK_RUN_BLOCK(self.interstitialCompletion, interstitial, nil);
}

- (void)adColonyInterstitialDidFailToLoad:(AdColonyAdRequestError * _Nonnull)error {
    STK_RUN_BLOCK(self.interstitialCompletion, nil, error);
}

#pragma mark - BDMAdColonyAdInterstitialProvider

- (AdColonyInterstitial *)interstitialForZone:(NSString *)zone {
    AdColonyInterstitial *interstitial;
    NSUInteger interstitialIdx = 0;
    for (NSUInteger idx = 0; idx < self.interstitials.count; ++idx) {
        if ([[(AdColonyInterstitial *)[self.interstitials pointerAtIndex:idx] zoneID] isEqualToString:zone]) {
            interstitial = [self.interstitials pointerAtIndex:idx];
            interstitialIdx = idx;
            break;
        }
    }
    
    if (interstitial.expired) {
        [self.interstitials removePointerAtIndex:interstitialIdx];
        return nil;
    }
    
    return interstitial;
}

@end
