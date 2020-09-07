//
//  BDMTapjoyAdapter.m
//  BDMTapjoyAdapter
//
//  Created by Stas Kochkin on 22/07/2019.
//  Copyright © 2019 Stas Kochkin. All rights reserved.
//

@import StackFoundation;

#import "BDMTapjoyAdNetwork.h"
#import "BDMTapjoyFullscreenAdapter.h"


NSString *const BDMTapjoySDKKey           = @"sdk_key";
NSString *const BDMTapjoyTokenKey         = @"token";
NSString *const BDMTapjoyPlacementKey     = @"placement_name";

@interface BDMTapjoyAdNetwork ()

@property (nonatomic, copy) void(^completion)(BOOL, NSError *);

@end


@implementation BDMTapjoyAdNetwork

- (instancetype)init {
    if (self = [super init]) {
        [self subscribe];
    }
    return self;
}

- (void)dealloc {
    [self unsubscribe];
}

- (NSString *)name {
    return @"tapjoy";
}

- (NSString *)sdkVersion {
    return Tapjoy.getVersion;
}

- (void)initialiseWithParameters:(NSDictionary<NSString *,id> *)parameters
                      completion:(void (^)(BOOL, NSError *))completion {
    [self syncMetadata];
    if (Tapjoy.isLimitedConnected) {
        STK_RUN_BLOCK(completion, NO, nil);
        return;
    }
    NSString *sdkKey = ANY(parameters).from(BDMTapjoySDKKey).string;
    if (sdkKey) {
        self.completion = completion;
        [Tapjoy limitedConnect:sdkKey];
    } else {
        NSError *error = [NSError bdm_errorWithCode:BDMErrorCodeHeaderBiddingNetwork
                                        description:@"Tapjoy sdk key is not valid string"];
        STK_RUN_BLOCK(completion, YES, error);
    }
}

- (void)collectHeaderBiddingParameters:(NSDictionary<NSString *,id> *)parameters
                          adUnitFormat:(BDMAdUnitFormat)adUnitFormat
                            completion:(void (^)(NSDictionary<NSString *,id> *, NSError *))completion {
    [self syncMetadata];
    NSString *sdkKey = [Tapjoy.sharedTapjoyConnect limitedSdkKey];
    NSString *token = Tapjoy.getUserToken ?: @"1";
    NSString *placement = ANY(parameters).from(BDMTapjoyPlacementKey).string;
    if (!sdkKey || !placement) {
        NSError *error = [NSError bdm_errorWithCode:BDMErrorCodeHeaderBiddingNetwork
                                        description:@"Tapjoy adapter was not receive valid bidding data"];
        STK_RUN_BLOCK(completion, nil, error);
    } else {
        NSMutableDictionary *bidding = [NSMutableDictionary dictionaryWithCapacity:3];
        bidding[BDMTapjoySDKKey]            = sdkKey;
        bidding[BDMTapjoyTokenKey]          = token;
        bidding[BDMTapjoyPlacementKey]      = placement;
        STK_RUN_BLOCK(completion, bidding, nil);
    }
}

- (id<BDMFullscreenAdapter>)videoAdapterForSdk:(BDMSdk *)sdk {
    return [BDMTapjoyFullscreenAdapter new];
}

#pragma mark - Observing

- (void)subscribe {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(tapjoyConnectionSuccess:)
                                                 name:TJC_LIMITED_CONNECT_SUCCESS
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(tapjoyConnectionFailed:)
                                                 name:TJC_LIMITED_CONNECT_FAILED
                                               object:nil];
}

- (void)unsubscribe {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)tapjoyConnectionSuccess:(NSNotification *)notification {
    STK_RUN_BLOCK(self.completion, YES, nil);
    self.completion = nil;
}

- (void)tapjoyConnectionFailed:(NSNotification *)notification {
    NSError *error = [NSError bdm_errorWithCode:BDMErrorCodeHeaderBiddingNetwork
                                    description:@"Tapjoy sdk key is not valid string"];
    STK_RUN_BLOCK(self.completion, YES, error);
    self.completion = nil;
}

#pragma mark - Private

- (void)syncMetadata {
    [Tapjoy setDebugEnabled:NO];
    [[TJPrivacyPolicy sharedInstance] setBelowConsentAge:BDMSdk.sharedSdk.restrictions.coppa];
    
    if (BDMSdk.sharedSdk.restrictions.subjectToGDPR) {
        [[TJPrivacyPolicy sharedInstance] setUserConsent:BDMSdk.sharedSdk.restrictions.hasConsent ? @"1" : @"0"];
        [[TJPrivacyPolicy sharedInstance] setSubjectToGDPR:BDMSdk.sharedSdk.restrictions.subjectToGDPR];
    }
    
    if (BDMSdk.sharedSdk.restrictions.subjectToCCPA) {
        [[TJPrivacyPolicy sharedInstance] setUSPrivacy:BDMSdk.sharedSdk.restrictions.USPrivacyString];
    }
    
}

@end
