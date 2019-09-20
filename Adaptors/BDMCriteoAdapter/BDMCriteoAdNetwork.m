//
//  BDMCriteoAdNetwork.m
//  BDMCriteoAdapter
//
//  Created by Stas Kochkin on 11/09/2019.
//  Copyright © 2019 Stas Kochkin. All rights reserved.
//

#import "BDMCriteoAdNetwork.h"
#import <AdSupport/AdSupport.h>
#import <StackFoundation/StackFoundation.h>


static NSString const *kBDMCriteoHost = @"gum.criteo.com";
static NSString const *kBDMCriteoLaunchAppEvent = @"Launch";
static NSString const *kBDMCriteoActiveAppEvent = @"Active";
static NSString const *kBDMCriteoInactiveAppEvent = @"Inactive";
static NSString const *kBDMCriteoZeroUUID = @"00000000-0000-0000-0000-000000000000";


@interface BDMCriteoAdNetwork ()

@property (nonatomic, copy) NSString *senderID;
@property (nonatomic, assign) NSTimeInterval throttlingTimestamp;
@property (nonatomic, assign) BOOL wasInitialised;

@end


@implementation BDMCriteoAdNetwork

- (NSString *)name {
    return @"criteo";
}

- (NSString *)sdkVersion {
    return @"1.0.0";
}

- (void)initialiseWithParameters:(NSDictionary<NSString *,id> *)parameters
                      completion:(void (^)(BOOL, NSError *))completion {
    NSString *senderID = parameters[@"sender_id"];
    if (!NSString.stk_isValid(senderID)) {
        NSError *error = [NSError bdm_errorWithCode:BDMErrorCodeHeaderBiddingNetwork
                                        description:@"Criteo adapter was not receive valid sender id"];
        STK_RUN_BLOCK(completion, NO, error);
        return;
    }
    self.senderID = senderID;
    if (!self.wasInitialised) {
        self.wasInitialised = YES;
        [self beginObserving];
        [self sendLaunchEvent];
    }
    STK_RUN_BLOCK(completion, NO, nil);
}

#pragma mark - Notifications

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)beginObserving {
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(appBecomeActive)
                                               name:UIApplicationDidBecomeActiveNotification
                                             object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(appBecomeInactive)
                                               name:UIApplicationWillResignActiveNotification
                                             object:nil];
}

- (void)appBecomeActive {
    [self sendEvent:kBDMCriteoActiveAppEvent.copy];
}

- (void)appBecomeInactive {
    [self sendEvent:kBDMCriteoInactiveAppEvent.copy];
}

- (void)sendLaunchEvent {
    [self sendEvent:kBDMCriteoLaunchAppEvent.copy];
}

#pragma mark - Networking

- (void)sendEvent:(NSString *)event {
    // Throttling
    if (self.throttlingTimestamp - NSDate.stk_currentTimeInSeconds > 0) {
        return;
    }
    
    NSURLRequest *request = [self trackerForEvent:event];
    __weak typeof(self) weakSelf = self;
    NSURLSessionDataTask *task = [NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:^(NSData * data, NSURLResponse * response, NSError * error) {
        NSDictionary * responseObject = [STKJSONSerialization JSONObjectWithData:data
                                                                         options:0
                                                                           error:nil];
        weakSelf.throttlingTimestamp = NSDate.stk_currentTimeInSeconds + [responseObject[@"throttleSec"] unsignedIntegerValue];
    }];
    [task resume];
}

- (NSURLRequest *)trackerForEvent:(NSString *)event {
    // https://appodeal.slack.com/archives/C9PMC2S2X/p1531315599000408
    // Get necessary data from source
    BOOL shouldRestrictParameters = BDMSdk.sharedSdk.restrictions.coppa || (BDMSdk.sharedSdk.restrictions.subjectToGDPR && !BDMSdk.sharedSdk.restrictions.hasConsent);
    
    NSString *idfa = shouldRestrictParameters ? kBDMCriteoZeroUUID : ASIdentifierManager.sharedManager.advertisingIdentifier.UUIDString;
    NSString *appId = STKBundle.ID;
    NSString *limitAdTracking = @(!ASIdentifierManager.sharedManager.isAdvertisingTrackingEnabled).stringValue;
    // Create query item
    NSURLQueryItem *idfaItem = [NSURLQueryItem queryItemWithName:@"idfa" value:idfa];
    NSURLQueryItem *appIdItem = [NSURLQueryItem queryItemWithName:@"appId" value:appId];
    NSURLQueryItem *eventTypeItem = [NSURLQueryItem queryItemWithName:@"eventType" value:event];
    NSURLQueryItem *limitAdTrackingItem = [NSURLQueryItem queryItemWithName:@"limitedAdTracking" value:limitAdTracking];
    // Build URL from components
    NSURLComponents *components = [NSURLComponents new];
    components.scheme = @"https";
    components.host = kBDMCriteoHost.copy;
    components.path = [NSString stringWithFormat:@"/appevent/v1/%@", self.senderID];
    components.queryItems = @[ idfaItem, appIdItem, eventTypeItem, limitAdTrackingItem ];
    NSURL * url = components.URL;
    // Build request with URL
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
    NSString *userAgent = STKDevice.userAgent;
    [request setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    [request setHTTPMethod:@"GET"];
    
    return request;
}

@end
