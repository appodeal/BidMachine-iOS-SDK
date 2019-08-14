//
//  BDMRegistry.h
//  BidMachine
//
//  Created by Stas Kochkin on 08/11/2017.
//  Copyright © 2017 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BDMNetworkProtocol.h"
#import "BDMDefines.h"


@interface BDMRegistry : NSObject

- (void)registerNetworkClass:(Class<BDMNetwork>)networkClass;
- (void)initNetworks;
- (id<BDMNetwork>)networkByName:(NSString *)name;

- (id <BDMBannerAdapter>)bannerAdapterForNetwork:(NSString *)networkName;
- (id <BDMFullscreenAdapter>)interstitialAdAdapterForNetwork:(NSString *)networkName;
- (id <BDMFullscreenAdapter>)videoAdapterForNetwork:(NSString *)networkName;
- (id <BDMNativeAdServiceAdapter>)nativeAdAdapterForNetwork:(NSString *)networkName;

@end
