//
//  BDMInterstitial.m
//  BidMachine
//
//  Created by Stas Kochkin on 07/11/2017.
//  Copyright © 2017 Appodeal. All rights reserved.
//

#import "BDMInterstitial.h"
#import "BDMRequest+ParallelBidding.h"
#import "BDMRequest+Private.h"
#import "BDMFactory+BDMEventMiddleware.h"
#import "BDMFactory+BDMDisplayAd.h"
#import "BDMSdk+ParallelBidding.h"
#import "BDMSdk+Project.h"
#import "NSError+BDMSdk.h"

#import <ASKExtension/ASKExtension.h>


@interface BDMInterstitial () <BDMRequestDelegate, BDMDisplayAdDelegate>

@property (nonatomic, strong) BDMEventMiddleware * middleware;
@property (nonatomic, strong) id <BDMDisplayAd> displayAd;

@property (nonatomic, strong) BDMInterstitialRequest * currentRequest;

@end

@implementation BDMInterstitial

#pragma mark - Public

- (void)makeRequest:(BDMRequest *)request {
    [self populateWithRequest:(BDMInterstitialRequest *)request];
}

- (void)populateWithRequest:(BDMInterstitialRequest *)request {
    NSAssert(BDMInterstitialRequest.ask_isValid(request), @"BDMInterstitial request should be kind of class BDMInterstitialRequest");
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
            [self.delegate interstitial:self failedWithError:error];
            break; }
        case BDMRequestStateAuction: {
            [self.currentRequest registerDelegate:self];
            break; }
        case BDMRequestStateExpired: {
            NSError * error = [NSError bdm_errorWithCode:BDMErrorCodeNoContent description:@"Auction response was expired"];
            [self.delegate interstitial:self failedWithError:error];
            break; }
    }
}

- (BOOL)isLoaded {
    return self.displayAd.hasLoadedCreative;
}

- (BOOL)canShow {
    return self.displayAd.availableToPresent;
}

- (UIView *)adView {
    return self.displayAd.adView;
}

- (BDMAuctionInfo *)auctionInfo {
    return self.currentRequest.info;
}

- (void)prepareDisplayAd {
    NSError * error;
    self.displayAd = [BDMFactory.sharedFactory displayAdWithRequest:self.currentRequest error:&error];
    if (error) {
        [self.delegate interstitial:self failedWithError:error];
        return;
    }
    self.displayAd.delegate = self;
    [self.displayAd prepare];
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    [self presentWithPlacement:nil fromRootViewController:rootViewController];
}

- (void)dealloc {
    [self invalidate];
}

#pragma mark - Private

- (void)invalidate {
    [self.currentRequest invalidate];
    [self.displayAd invalidate];
    self.currentRequest = nil;
    self.displayAd = nil;
}

- (void)presentWithPlacement:(NSNumber *)placement fromRootViewController:(UIViewController *)rootViewController {
    if (!self.displayAd.hasLoadedCreative) {
        NSError * error = [NSError bdm_errorWithCode:BDMErrorCodeNoContent
                                         description:@"Display ad not ready to present any ad!"];
        [self.delegate interstitial:self failedToPresentWithError:error];
        return;
    }
    // Try to present
    self.displayAd.delegate = self;
    [self.displayAd presentAd:rootViewController container:nil];
}

#pragma mark - BDMRequestDelegate

- (void)request:(BDMRequest *)request completeWithInfo:(BDMAuctionInfo *)info {
    [self prepareDisplayAd];
}

- (void)request:(BDMRequest *)request failedWithError:(NSError *)error {
    [self.middleware registerError:BDMEventLoaded code:error.code];
    [self.delegate interstitial:self failedWithError:error];
}

- (void)requestDidExpire:(BDMRequest *)request {
    [self.middleware registerError:BDMEventImpression code:BDMErrorCodeWasExpired];
    if ([self.delegate respondsToSelector:@selector(interstitialDidExpire:)]) {
        [self.delegate interstitialDidExpire:self];
    }
}

#pragma mark - BDMDisplayAdDelegate

- (void)displayAdReady:(id<BDMDisplayAd>)displayAd {
    [self.middleware registerEvent:BDMEventLoaded];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
    if ([self.delegate respondsToSelector:@selector(interstitial:readyToPresentAd:)]) {
        [self.delegate interstitial:self readyToPresentAd:self.auctionInfo];
    }
#pragma clang diagnostic pop
    [self.delegate interstitialReadyToPresent:self];
}

- (void)displayAd:(id<BDMDisplayAd>)displayAd failedWithError:(NSError *)error {
    [self.middleware registerError:BDMEventLoaded code:error.code];
    [self.delegate interstitial:self failedWithError:error];
}

- (void)displayAdLogStartView:(id<BDMDisplayAd>)displayAd {
    [self.middleware registerEvent:BDMEventImpression];
    [self.delegate interstitialWillPresent:self];
}

- (void)displayAdLogFinishView:(id<BDMDisplayAd>)displayAd {
    [self.middleware registerEvent:BDMEventClosed];
    [self.delegate interstitialDidDismiss:self];
    [self invalidate];
}

- (void)displayAdLogImpression:(id<BDMDisplayAd>)displayAd {
    [self.middleware registerEvent:BDMEventViewable];
}

- (void)displayAdLogUserInteraction:(id<BDMDisplayAd>)displayAd {
    [self.middleware registerEvent:BDMEventClick];
    [self.delegate interstitialRecieveUserInteraction:self];
}

- (void)displayAd:(id<BDMDisplayAd>)displayAd failedToPresent:(NSError *)error {
    [self.middleware registerError:BDMEventImpression code:error.code];
    [self.delegate interstitial:self failedToPresentWithError:error];
    if (error.code != BDMErrorCodeNoConnection) {
        [self invalidate];
    }
}

@end
