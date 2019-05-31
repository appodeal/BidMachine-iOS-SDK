//
//  BDMSdk-Private.h
//  BidMachine
//
//  Created by Stas Kochkin on 07/11/2017.
//  Copyright © 2017 Appodeal. All rights reserved.
//

#import <BidMachine/BidMachine.h>
#import "BDMSdk.h"
#import "BDMRequest.h"
#import "BDMRegistry.h"
#import "BDMAuctionSettings.h"

@interface BDMSdk (Project)

@property (nonatomic, copy, readonly) NSString * sellerID;
@property (nonatomic, copy, readonly) BDMTargeting * targeting;
@property (nonatomic, assign, readonly) BOOL testMode;
@property (nonatomic, strong, readonly) BDMOpenRTBAuctionSettings *auctionSettings;

@property (nonatomic, assign, readonly) BOOL isDeviceReachable;

@property (nonatomic, copy, readonly) BDMUserRestrictions * restrictions;

- (id <BDMBannerAdapter>)bannerAdapterForNetwork:(NSString *)networkName;
- (id <BDMFullscreenAdapter>)interstitialAdAdapterForNetwork:(NSString *)networkName;
- (id <BDMFullscreenAdapter>)videoAdapterForNetwork:(NSString *)networkName;
- (id <BDMNativeAdServiceAdapter>)nativeAdAdapterForNetwork:(NSString *)networkName;

- (NSSet *)exchangeRequestBodyFromSdkRequest:(BDMRequest *)request
                                interstitial:(BOOL)intserstitial;

@end
