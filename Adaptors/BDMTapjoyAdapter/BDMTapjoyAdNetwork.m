//
//  BDMTapjoyAdapter.m
//  BDMTapjoyAdapter
//
//  Created by Stas Kochkin on 22/07/2019.
//  Copyright © 2019 Stas Kochkin. All rights reserved.
//

#import "BDMTapjoyAdNetwork.h"
#import "BDMTapjoyValueTransformer.h"
#import "BDMTapjoyFullscreenAdapter.h"

#import <Tapjoy/Tapjoy.h>
#import <StackFoundation/StackFoundation.h>


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
    NSString *sdkKey = [BDMTapjoyValueTransformer.new transformedValue:parameters[@"sdk_key"]];
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
                            completion:(void (^)(NSDictionary<NSString *,id> *, NSError *))completion {
    [self syncMetadata];
    NSString *sdkKey = [Tapjoy.sharedTapjoyConnect limitedSdkKey];
    NSString *token = Tapjoy.getUserToken ?: @"1";
    NSString *placement = [BDMTapjoyValueTransformer.new transformedValue:parameters[@"placement_name"]];
    if (!sdkKey || !placement) {
        NSError *error = [NSError bdm_errorWithCode:BDMErrorCodeHeaderBiddingNetwork
                                        description:@"Tapjoy adapter was not receive valid bidding data"];
        STK_RUN_BLOCK(completion, nil, error);
    } else {
        NSMutableDictionary *bidding = [NSMutableDictionary dictionaryWithCapacity:3];
        bidding[@"sdk_key"] = sdkKey;
        bidding[@"placement_name"] = placement;
        bidding[@"token"] = token;
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
    [Tapjoy belowConsentAge:BDMSdk.sharedSdk.restrictions.coppa];
    [Tapjoy subjectToGDPR:BDMSdk.sharedSdk.restrictions.subjectToGDPR];
    [Tapjoy setUserConsent:BDMSdk.sharedSdk.restrictions.hasConsent ? @"1" : @"0"];
}

@end
