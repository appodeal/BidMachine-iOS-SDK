//
//  BDMNetworkConfigurator.h
//  BidMachine
//
//  Created by Stas Kochkin on 12/02/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BDMNetworkProtocol.h"
#import "BDMRequest.h"
#import "BDMNetworkItem.h"


@class BDMNetworkConfigurator;
typedef dispatch_block_t BDMNetworkConfiguratorCompletionBlock;

@protocol BDMNetworkConfiguratorDataSource <NSObject>

- (nullable Class <BDMNetwork>)networkClassWithName:(nonnull NSString *)name
                                    forConfigurator:(nonnull BDMNetworkConfigurator *)congigurator;
- (nullable id<BDMAdapter>)adapterWithName:(nonnull NSString *)name
                                    adType:(BDMFullscreenAdType)type
                              interstitial:(BOOL)interstitial;

@end

@interface BDMNetworkConfigurator : NSObject

@property (nonatomic, weak, nullable) id <BDMNetworkConfiguratorDataSource> dataSource;

- (void)initialize:(nonnull NSArray <BDMNetworkItem *> *)networks
        completion:(nonnull BDMNetworkConfiguratorCompletionBlock)completion;

- (nonnull NSSet <NSDictionary *> *)exchangeRequestBodyFromSdkRequest:(nonnull BDMRequest *)request
                                                         interstitial:(BOOL)intserstitial
                                                                  ssp:(nonnull NSString *)ssp;

@end
