//
//  BDMRequest.m
//  BidMachine
//
//  Created by Stas Kochkin on 08/11/2017.
//  Copyright © 2017 Appodeal. All rights reserved.
//

#import "BDMRequest.h"
#import "BDMRequest+ParallelBidding.h"
#import "BDMRequest+Private.h"

#import "BDMNetworkItem.h"
#import "BDMServerCommunicator.h"

#import "NSError+BDMSdk.h"
#import "BDMSdk+Project.h"
#import "BDMAuctionInfo+Project.h"
#import "BDMFactory+BDMDisplayAd.h"
#import <ASKExtension/ASKExtension.h>


@interface BDMRequest ()

@property (nonatomic, assign) BDMRequestState state;

@property (copy, nonatomic) NSArray <BDMNetworkItem *> * networks;
@property (copy, nonatomic) NSDictionary <NSString *, id> * customParameters;

@property (copy, nonatomic) NSString * adSpaceId;
@property (copy, nonatomic) NSNumber * activeSegmentIdentifier;
@property (copy, nonatomic) NSNumber * activePlacement;

@property (nonatomic, strong) ASKExpirationTimer * expirationTimer;
@property (nonatomic, assign) BDMPlacementType placementType;

@property (nonatomic, strong) NSHashTable <id<BDMRequestDelegate>> * delegates;
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
              placementType:(BDMPlacementType)placementType
           placementBuilder:(id<BDMPlacementRequestBuilder>)placementBuilder {
    if (!BDMSdk.sharedSdk.sellerID.length) {
        BDMLog(@"You must call BDMSdk.sharedSdk startSessionWithSellerID:YOUR_SELLER_ID completion:...] before!. Sdk not initialized properly, see docs: https://wiki.appodeal.com/display/BID/BidMachine+iOS+SDK+Documentation");
        NSError * error = [NSError bdm_errorWithCode:BDMErrorCodeInternal description:@"No seller ID"];
        [self notifyDelegatesOnFail:error];
        return;
    }
    
    self.placementType = placementType;
    // Populate targeting
    request.targeting = request.targeting ?: BDMSdk.sharedSdk.targeting;
    self.state = BDMRequestStateAuction;
    // Make request by expiration timer
    __weak typeof(self) weakSelf = self;
    
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
        [weakSelf beginExpirationMonitoring];
        [weakSelf notifyDelegatesOnSuccess];
    } failure:^(NSError * error) {
        weakSelf.state = BDMRequestStateFailed;
        [weakSelf notifyDelegatesOnFail:error];
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
    self.expirationTimer = [ASKExpirationTimer expirationTimerWithExpirationTimeinterval:self.response.expirationTime.doubleValue
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
             placementType:(BDMPlacementType)placementType
          placementBuilder:(id<BDMPlacementRequestBuilder>)placementBuilder {
    [self _performWithRequest:request
                placementType:placementType
             placementBuilder:placementBuilder];
}

- (void)invalidate {
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
        ASK_SET_AUTORELASE_VAR(error, [NSError bdm_errorWithCode:BDMErrorCodeInternal description:@"Request not successful and unable to create display ad!"]);
    }
    return [BDMFactory.sharedFactory displayAdWithResponse:self.response
                                             plecementType:self.placementType];
}

@end
