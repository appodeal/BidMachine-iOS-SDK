//
//  BDMRequest.m
//  BidMachine
//
//  Created by Stas Kochkin on 08/11/2017.
//  Copyright © 2017 Appodeal. All rights reserved.
//

#import "BDMRequest.h"
#import "BDMRequest+HeaderBidding.h"
#import "BDMRequest+Private.h"

#import "BDMServerCommunicator.h"

#import "NSError+BDMSdk.h"
#import "BDMSdk+Project.h"
#import "BDMAuctionInfo+Project.h"
#import "BDMFactory+BDMDisplayAd.h"

#import <StackFoundation/StackFoundation.h>
#import "BDMFactory+BDMEventMiddleware.h"

@interface BDMRequest ()

@property (nonatomic, assign) BDMRequestState state;

@property (copy, nonatomic) NSDictionary <NSString *, id> *customParameters;

@property (copy, nonatomic) NSString *adSpaceId;
@property (copy, nonatomic) NSNumber *activeSegmentIdentifier;
@property (copy, nonatomic) NSNumber *activePlacement;

@property (nonatomic, strong) STKExpirationTimer *expirationTimer;
@property (nonatomic, strong) BDMEventMiddleware *middleware;
@property (nonatomic, assign) BDMInternalPlacementType placementType;
@property (nonatomic, strong) NSHashTable <id<BDMRequestDelegate>> *delegates;
@property (nonatomic, copy) id <BDMResponse> response;

@end


@implementation BDMRequest

- (instancetype)init {
    if (self = [super init]) {
        self.state = BDMRequestStateIdle;
    }
    return self;
}

- (NSHashTable<id<BDMRequestDelegate>> *)delegates {
    if (!_delegates) {
        _delegates = [NSHashTable weakObjectsHashTable];
    }
    return _delegates;
}

- (void)_performWithRequest:(BDMRequest *)request
              placementType:(BDMInternalPlacementType)placementType
           placementBuilder:(id<BDMPlacementRequestBuilder>)placementBuilder {
    if (!BDMSdk.sharedSdk.sellerID.length) {
        BDMLog(@"You must call BDMSdk.sharedSdk startSessionWithSellerID:YOUR_SELLER_ID completion:...] before!. Sdk not initialized properly, see docs: https://wiki.appodeal.com/display/BID/BidMachine+iOS+SDK+Documentation");
        NSError * error = [NSError bdm_errorWithCode:BDMErrorCodeInternal description:@"No seller ID"];
        [self notifyDelegatesOnFail:error];
        return;
    }
    
    if (self.state == BDMRequestStateAuction) {
        BDMLog(@"Trying to perform non idle request");
        return;
    }
    
    self.placementType = placementType;
    
    __weak typeof(self) weakSelf = self;
    [BDMSdk.sharedSdk collectHeaderBiddingAdUnits:placementType completion:^(NSArray<id<BDMPlacementAdUnit>> *placememntAdUnits) {
        // Append header bidding
        placementBuilder.appendHeaderBidding(placememntAdUnits);
        // Populate targeting
        request.targeting = request.targeting ?: BDMSdk.sharedSdk.targeting;
        weakSelf.state = BDMRequestStateAuction;
        [weakSelf.middleware startEvent:BDMEventAuction];
        // Make request by expiration timer
        [BDMServerCommunicator.sharedCommunicator makeAuctionRequest:^(BDMAuctionBuilder *builder) {
            builder
            .appendPlacementBuilder(placementBuilder)
            .appendRequest(request)
            .appendAuctionSettings(BDMSdk.sharedSdk.auctionSettings)
            .appendSellerID(BDMSdk.sharedSdk.sellerID)
            .appendTestMode(BDMSdk.sharedSdk.testMode)
            .appendRestrictions(BDMSdk.sharedSdk.restrictions);
        } success:^(id<BDMResponse> response) {
            // Save response object
            weakSelf.response = response;
            weakSelf.state = BDMRequestStateSuccessful;
            [weakSelf.middleware fulfillEvent:BDMEventAuction];
            [weakSelf beginExpirationMonitoring];
            [weakSelf notifyDelegatesOnSuccess];
        } failure:^(NSError *error) {
            weakSelf.state = BDMRequestStateFailed;
            [weakSelf.middleware rejectEvent:BDMEventAuction code:error.code];
            [weakSelf notifyDelegatesOnFail:error];
        }];
    }];
}

- (BDMAuctionInfo *)info {
    return self.response ? [[BDMAuctionInfo alloc] initWithResponse:self.response] : nil;
}

- (void)_invalidate {
    BDMLog(@"Auction invalidating: %@", self);
    self.expirationTimer = nil;
    self.response = nil;
}

- (void)beginExpirationMonitoring {
    __weak typeof (self) weakSelf = self;
    BDMLog(@"Start expiration monitoring for response: %@ of time: %1.2f s", self.response.identifier, self.response.expirationTime.doubleValue);
    self.expirationTimer = [STKExpirationTimer expirationTimerWithExpirationTimeinterval:self.response.expirationTime.doubleValue
                                                                          observableItem:self.response
                                                                                  expire:^(id<BDMResponse> response) {
                                                                                      [weakSelf expire];
                                                                                  }];
    [self.expirationTimer fire];
}

- (void)expire {
    self.state = BDMRequestStateExpired;
    [self invalidate];
    [self notifyDelegatesOnExpire];
}

- (BDMEventMiddleware *)middleware {
    if (!_middleware) {
        _middleware = [BDMFactory.sharedFactory middlewareWithRequest:self
                                                        eventProducer:nil];
    }
    return _middleware;
}

#pragma mark - Delegate

- (void)notifyDelegatesOnFail:(NSError *)error {
    for (id<BDMRequestDelegate> delegate in self.delegates.allObjects.reverseObjectEnumerator) {
        [delegate request:self failedWithError:error];
    }
}

- (void)notifyDelegatesOnExpire {
    for (id<BDMRequestDelegate> delegate in self.delegates.allObjects.reverseObjectEnumerator) {
        [delegate requestDidExpire:self];
    }
}

- (void)notifyDelegatesOnSuccess {
    for (id<BDMRequestDelegate> delegate in self.delegates.allObjects.reverseObjectEnumerator) {
        [delegate request:self completeWithInfo:self.info];
    }
}

@end

@implementation BDMRequest (Private)

- (NSArray<BDMEventURL *> *)eventTrackers {
    return self.response.creative.trackers;
}

- (void)registerDelegate:(id<BDMRequestDelegate>)delegate {
    [self.delegates addObject:delegate];
}

- (void)performWithRequest:(BDMRequest *)request
             placementType:(BDMInternalPlacementType)placementType
          placementBuilder:(id<BDMPlacementRequestBuilder>)placementBuilder {
    [self _performWithRequest:request
                placementType:placementType
             placementBuilder:placementBuilder];
}

- (void)invalidate {
    [self.middleware rejectAll:BDMErrorCodeWasDestroyed];
    self.state = BDMRequestStateIdle;
    [self _invalidate];
}

- (void)cancelExpirationTimer {
    BDMLog(@"Cancel expiration timer for response: %@", self.response.identifier);
    self.expirationTimer = nil;
}

@end


@implementation BDMRequest (DisplayAd)

- (id<BDMDisplayAd>)displayAdWithError:(NSError *__autoreleasing *)error {
    if (self.state != BDMRequestStateSuccessful) {
        STK_SET_AUTORELASE_VAR(error, [NSError bdm_errorWithCode:BDMErrorCodeInternal description:@"Request not successful and unable to create display ad!"]);
    }
    return [BDMFactory.sharedFactory displayAdWithResponse:self.response
                                             plecementType:self.placementType];
}

@end
