//
//  BDMNetworkProtocol.h
//  BidMachine
//
//  Created by Stas Kochkin on 07/11/2017.
//  Copyright © 2017 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BidMachine/BDMAdapterProtocol.h>

@class BDMSdk;
@protocol BDMNetwork;


@protocol BDMNetwork <NSObject>

+ (NSString *)name;

@optional

+ (NSString *)sdkVersion;
+ (void)startThirdPartySdkSession:(NSDictionary *)parameters
                       completion:(dispatch_block_t)completion;

+ (Class<BDMBannerAdapter>)bannerAdapterClassForSdk:(BDMSdk *)sdk;
+ (Class<BDMFullscreenAdapter>)interstitialAdAdapterClassForSdk:(BDMSdk *)sdk;
+ (Class<BDMFullscreenAdapter>)videoAdapterClassForSdk:(BDMSdk *)sdk;
+ (Class<BDMNativeAdServiceAdapter>)nativeAdAdapterClassForSdk:(BDMSdk *)sdk;

@end
