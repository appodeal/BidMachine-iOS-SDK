//
//  BDMNativeService.m
//  BidMachine
//
//  Created by Lozhkin Ilya on 5/31/18.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import "BDMNativeAdService.h"
#import "BDMFactory+BDMServerCommunicator.h"
#import "BDMSdk+Project.h"
#import "BDMNativeAdProtocol.h"
#import "BDMRequest+ParallelBidding.h"


@interface BDMNativeAdService ()

@property (nonatomic, strong, readwrite) id <BDMNativeAdServiceAdapter> adapter;

@property (nonatomic, strong) BDMServerCommunicator * serverCommunicator;
@property (nonatomic, strong, readwrite) id <BDMResponse> response;

@property (nonatomic, strong, readwrite) NSNumber * segment;
@property (nonatomic, strong, readonly) BDMSdk * sdk;

@end

@implementation BDMNativeAdService

- (void)makeRequest:(BDMRequest *)request {
    self.segment = request.activeSegmentIdentifier;
//    [self.serverCommunicator makeRequest:request.destinationURL
//                          clientBodyData:[self.sdk exchangeRequestBodyFromSdkRequest:request interstitial:NO]];
}

#pragma nark - Accessing

- (BDMSdk *)sdk {
    return BDMFactory.sharedFactory.sharedSdk;
}

- (BDMServerCommunicator *)serverCommunicator {
    if (!_serverCommunicator) {
        _serverCommunicator = BDMFactory.sharedFactory.serverCommunicator;
//        _serverCommunicator.delegate = self;
    }
    return _serverCommunicator;
}

#pragma mark - BDMServerCommunicatorDelegate


- (void)communicator:(BDMServerCommunicator *)communicator
connectionSuccessfulWithResponse:(id<BDMResponse>)response {
//    BDMAdType adType = BDMAdTypeFromString(response.adType, nil, nil);
//    if (adType == BDMAdTypeNative) {
//        self.adapter = [self.sdk nativeAdAdapterForNetwork:response.displaymanager];
//    }
//
////    self.adapter.delegate = self;
//    self.response = response;
//
//    if (self.adapter) {
//        [self.adapter prepareContent:response.renderingInfo];
//    } else {
//        NSError * error = [NSError errorWithDomain:kBDMErrorDomain
//                                              code:0
//                                          userInfo:@{ NSLocalizedFailureReasonErrorKey : @"Adapter not found error" }];
////        [communicator trackError:self.response.errorURL
////                            code:BDMUnknownNetworkError];
//        [self.delegate service:self failedToLoadWithError:error];
//    }
}

- (void)communicator:(BDMServerCommunicator *)communicator
connectionFailedWithError:(NSError *)error {
    [self.delegate service:self failedToLoadWithError:error];
}

- (NSNumber *)activeSegmentForCommunicator:(BDMServerCommunicator *)communicator {
    return self.segment;
}

- (NSNumber *)activePlacementForComminicator:(BDMServerCommunicator *)communicator {
    return nil;
}

#pragma mark - BDMAdapterDelegate

- (void)adapterPreparedContent:(id<BDMAdapter>)adapter {
    //unused
}

- (void)adapter:(id<BDMAdapter>)adapter failedToPresentAdWithError:(NSError *)error {
    //unused
}

- (void)adapter:(id<BDMAdapter>)adapter failedToPrepareContentWithError:(NSError *)error {
//    [self.serverCommunicator trackError:self.response.errorURL
//                                   code:BDMFillError];
    [self.delegate service:self failedToLoadWithError:error];
}

#pragma mark BDMNativeAdServiceAdapterDelegate

- (void)service:(id<BDMNativeAdServiceAdapter>)service
didLoadNativeAds:(NSArray<id<BDMNativeAd>> *)nativeAds
{
//    [self.serverCommunicator trackEvent:self.response.fillURL
//                          errorPassback:self.response.errorURL];
    
    [nativeAds enumerateObjectsUsingBlock:^(id<BDMNativeAd> nativeAd, NSUInteger idx, BOOL * stop) {
        [nativeAd setExchangeResponse:self.response];
    }];
    [self.delegate service:self didLoadNativeAds:nativeAds];
}

@end
