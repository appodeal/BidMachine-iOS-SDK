//
//  BDMNativeAdProtocol.m
//  BidMachine
//
//  Created by Stas Kochkin on 28/08/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BDMNativeAdProtocol.h"
#import "BDMFactory+BDMServerCommunicator.h"
#import "BDMRuntimeExtensions.h"
#import "BDMResponse.h"
#import <objc/runtime.h>


static char kBDMNAtiveAdPlacementKey;
static char kBDMNAtiveAdPlacemExchangeResponseKey;
static char kBDMNAtiveAdSereverCommunicatorKey;

@interface BDMNativeAdContainer : NSObject <BDMNativeAd>

@end

@implementation BDMNativeAdContainer

+ (void)load {
    adx_addConcreteProtocol(@protocol(BDMNativeAd), self);
}

__attribute__((constructor))
static void adx_injectBDMNativeAd (void) {
    adx_loadConcreteProtocol(@protocol(BDMNativeAd));
}

#pragma mark - Public

- (void)setPlacementId:(NSNumber *)placementId {
    objc_setAssociatedObject(self, &kBDMNAtiveAdPlacementKey, placementId, OBJC_ASSOCIATION_COPY);
}

- (NSNumber *)placementId {
    return objc_getAssociatedObject(self, &kBDMNAtiveAdPlacementKey);
}

- (void)setExchangeResponse:(BDMResponse *)exchangeResponse {
    objc_setAssociatedObject(self, &kBDMNAtiveAdPlacemExchangeResponseKey, exchangeResponse, OBJC_ASSOCIATION_RETAIN);

}

- (BDMResponse *)exchangeResponse {
    return objc_getAssociatedObject(self, &kBDMNAtiveAdPlacemExchangeResponseKey);
}

- (void)trackExchangeImpression {
//    [self.exchangeCommunicator trackEvent:[(id<BDMResponse>)self.exchangeResponse impressionURL]
//                            errorPassback:[(id<BDMResponse>)self.exchangeResponse errorURL]];
}

- (void)trackExchangeInteraction {
//    [self.exchangeCommunicator trackEvent:[(id<BDMResponse>)self.exchangeResponse clickURL]
//                            errorPassback:[(id<BDMResponse>)self.exchangeResponse errorURL]];
}

- (void)trackExchangeFinish {
//    [self.exchangeCommunicator trackEvent:[(id<BDMResponse>)self.exchangeResponse finishURL]
//                            errorPassback:[(id<BDMResponse>)self.exchangeResponse errorURL]];
}

#pragma mark - Private

- (BDMServerCommunicator *)exchangeCommunicator {
    BDMServerCommunicator * communicator = objc_getAssociatedObject(self, &kBDMNAtiveAdSereverCommunicatorKey);
    if (!communicator) {
        communicator = [BDMFactory.sharedFactory serverCommunicator];
//        communicator.delegate = self;
        objc_setAssociatedObject(self, &kBDMNAtiveAdSereverCommunicatorKey, communicator, OBJC_ASSOCIATION_RETAIN);
    }
    return communicator;
}

#pragma mark - BDMServerCommunicatorDelegate

- (void)communicator:(BDMServerCommunicator *)communicator connectionSuccessfulWithResponse:(id<BDMResponse>)response {
    // no-op
}

- (void)communicator:(BDMServerCommunicator *)communicator connectionFailedWithError:(NSError *)error {
    // no-op
}

- (NSNumber *)activeSegmentForCommunicator:(BDMServerCommunicator *)communicator {
    return nil;
}

- (NSNumber *)activePlacementForComminicator:(BDMServerCommunicator *)communicator {
    return self.placementId;
}

@end
