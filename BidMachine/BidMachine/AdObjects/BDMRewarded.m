//
//  BDMRewarded.m
//  BidMachine
//
//  Created by Stas Kochkin on 16/11/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import "BDMRewarded.h"
#import "BDMRequest+ParallelBidding.h"
#import "BDMRequest+Private.h"
#import "BDMFactory+BDMEventMiddleware.h"
#import "BDMFactory+BDMDisplayAd.h"
#import "BDMSdk+ParallelBidding.h"
#import "BDMSdk+Project.h"
#import "NSError+BDMSdk.h"

#import <ASKExtension/ASKExtension.h>


@interface BDMRewarded () <BDMRequestDelegate, BDMDisplayAdDelegate>

@property (nonatomic, strong) BDMEventMiddleware * middleware;
@property (nonatomic, strong) id <BDMDisplayAd> displayAd;

@property (nonatomic, strong) BDMRewardedRequest * currentRequest;

@end

@implementation BDMRewarded

#pragma mark - Public

- (void)makeRequest:(BDMRequest *)request {
    [self populateWithRequest:(BDMRewardedRequest *)request];
}

- (void)populateWithRequest:(BDMRewardedRequest *)request {
    NSAssert(BDMRewardedRequest.ask_isValid(request), @"BDMRewarded request should be kind of class BDMRewardedRequest");
    self.currentRequest = request;
    self.middleware = [BDMFactory.sharedFactory middlewareWithRequest:self.currentRequest eventProducer:self];
    switch (self.currentRequest.state) {
        case BDMRequestStateIdle: {
            [self.currentRequest performWithDelegate:self];
            break; }
        case BDMRequestStateSuccessful: {
            [self prepareDisplayAd];
            break; }
        case BDMRequestStateFailed: {
            NSError * error = [NSError bdm_errorWithCode:BDMErrorCodeNoContent description:@"No auction response to load!"];
            [self.delegate rewarded:self failedWithError:error];
            break; }
        case BDMRequestStateAuction: {
            [self.currentRequest registerDelegate:self];
            break; }
        case BDMRequestStateExpired: {
            NSError * error = [NSError bdm_errorWithCode:BDMErrorCodeNoContent description:@"Auction response was expired"];
            [self.delegate rewarded:self failedWithError:error];
            break; }
    }
}

- (BOOL)isLoaded {
    return self.displayAd.hasLoadedCreative;
}

- (BOOL)canShow {
    return self.displayAd.availableToPresent;
}

- (BDMAuctionInfo *)auctionInfo {
    return self.currentRequest.info;
}

- (UIView *)adView {
    return self.displayAd.adView;
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    [self presentWithPlacement:nil fromRootViewController:rootViewController];
}

#pragma mark - Private

- (void)presentWithPlacement:(NSNumber *)placement fromRootViewController:(UIViewController *)rootViewController {
    if (!self.displayAd.hasLoadedCreative) {
        NSError * error = [NSError bdm_errorWithCode:BDMErrorCodeNoContent
                                         description:@"Display ad not ready to present any ad!"];
        [self.delegate rewarded:self failedToPresentWithError:error];
        return;
    }
    [self.currentRequest cancelExpirationTimer];
    [self.displayAd presentAd:rootViewController container:nil];
}

- (void)prepareDisplayAd {
    NSError * error;
    self.displayAd = [BDMFactory.sharedFactory displayAdWithRequest:self.currentRequest error:&error];
    if (error) {
        [self.delegate rewarded:self failedWithError:error];
        return;
    }
    self.displayAd.delegate = self;
    [self.displayAd prepare];
}

- (void)invalidate {
    [self.currentRequest invalidate];
    [self.displayAd invalidate];
    self.currentRequest = nil;
    self.displayAd = nil;
}

#pragma mark - BDMRequestDelegate

- (void)request:(BDMRequest *)request completeWithInfo:(BDMAuctionInfo *)info {
    [self prepareDisplayAd];
}

- (void)request:(BDMRequest *)request failedWithError:(NSError *)error {
    [self.middleware registerError:BDMEventLoaded code:error.code];
    [self.delegate rewarded:self failedWithError:error];
}

- (void)requestDidExpire:(BDMRequest *)request {
    [self.middleware registerError:BDMEventImpression code:BDMErrorCodeWasExpired];
    if ([self.delegate respondsToSelector:@selector(rewardedDidExpire:)]) {
        [self.delegate rewardedDidExpire:self];
    }
}

#pragma mark - BDMDisplayAdDelegate

- (void)displayAdReady:(id<BDMDisplayAd>)displayAd {
    [self.middleware registerEvent:BDMEventLoaded];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
    if ([self.delegate respondsToSelector:@selector(rewarded:readyToPresentAd:)]) {
        [self.delegate rewarded:self readyToPresentAd:self.auctionInfo];
    }
#pragma clang diagnostic pop
    [self.delegate rewardedReadyToPresent:self];
}

- (void)displayAd:(id<BDMDisplayAd>)displayAd failedWithError:(NSError *)error {
    [self.middleware registerError:BDMEventLoaded code:error.code];
    [self.delegate rewarded:self failedWithError:error];
}

- (void)displayAdLogImpression:(id<BDMDisplayAd>)displayAd {}

- (void)displayAdLogUserInteraction:(id<BDMDisplayAd>)displayAd {
    [self.middleware registerEvent:BDMEventClick];
    [self.delegate rewardedRecieveUserInteraction:self];
}

- (void)displayAdLogStartView:(id<BDMDisplayAd>)displayAd {
    [self.middleware registerEvent:BDMEventImpression];
    [self.delegate rewardedWillPresent:self];
}

- (void)displayAdLogFinishView:(id<BDMDisplayAd>)displayAd {
    [self.middleware registerEvent:BDMEventClosed];
    [self.delegate rewardedDidDismiss:self];
    [self invalidate];
}

- (void)displayAd:(id<BDMDisplayAd>)displayAd failedToPresent:(NSError *)error {
    [self.middleware registerError:BDMEventImpression code:error.code];
    [self.delegate rewarded:self failedToPresentWithError:error];
    if (error.code != BDMErrorCodeNoConnection) {
        [self invalidate];
    }
}

- (void)displayAdCompleteRewardAction:(id<BDMDisplayAd>)displayAd {
    [self.middleware registerEvent:BDMEventViewable];
    [self.delegate rewardedFinishRewardAction:self];
}

@end
