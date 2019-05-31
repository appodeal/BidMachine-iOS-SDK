//
//  BDMNetworkConfigurator.m
//  BidMachine
//
//  Created by Stas Kochkin on 12/02/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import "BDMNetworkConfigurator.h"
#import "BDMRequest+ParallelBidding.h"

@interface BDMNetworkConfigurator ()

@property (nonatomic, copy) BDMNetworkConfiguratorCompletionBlock completion;
@property (nonatomic, strong) dispatch_group_t initializationGroup;

@end

@implementation BDMNetworkConfigurator

- (dispatch_group_t)initializationGroup {
    if (!_initializationGroup) {
        _initializationGroup = dispatch_group_create();
    }
    return _initializationGroup;
}

- (void)initialize:(nonnull NSArray <BDMNetworkItem *> *)networks
        completion:(nonnull BDMNetworkConfiguratorCompletionBlock)completion {
    // Copy completon block
    self.completion = completion;
    // Enumerate networks
    [networks enumerateObjectsUsingBlock:^(BDMNetworkItem * item, NSUInteger idx, BOOL * stop) {
        // Get network
        Class <BDMNetwork> network = [self.dataSource networkClassWithName:item.name
                                                           forConfigurator:self];
        NSString * networkName = [network name];
        BDMLog(@"Prepare network %@", networkName);
        if ([network respondsToSelector:@selector(startThirdPartySdkSession:completion:)]) {
            dispatch_group_enter(self.initializationGroup);
            __weak typeof(self) weakSelf = self;
            [network startThirdPartySdkSession:item.parameters completion:^{
                BDMLog(@"Complete network processing %@", networkName);
                dispatch_group_leave(weakSelf.initializationGroup);
            }];
        }
    }];
    
    dispatch_group_notify(self.initializationGroup,
                          dispatch_get_main_queue(),
                          ^{
                              self.completion ? self.completion() : nil;
                          });
    
}

- (nonnull NSSet <NSDictionary *> *)exchangeRequestBodyFromSdkRequest:(nonnull BDMRequest *)request
                                                         interstitial:(BOOL)intserstitial
                                                                  ssp:(nonnull NSString *)ssp {
    // Prepare networks config for auction on server
    NSMutableSet * requestBody = [NSMutableSet new];
    // Enumerate all passed configs
    [request.networks enumerateObjectsUsingBlock:^(BDMNetworkItem * network, NSUInteger idx, BOOL * stop) {
        // Enumerate wanted ad types
        /*
        [request.supportedTypes enumerateObjectsUsingBlock:^(NSNumber * typeNum, NSUInteger idx, BOOL * stop) {
            id<BDMAdapter> adapter;
            BDMAdType adType = typeNum.integerValue;
            adapter = [self.dataSource adapterWithName:network.name
                                                adType:adType
                                          interstitial:intserstitial];
            if (adapter) {
                // Get native info
                NSError * error;
                NSMutableDictionary * biddingInformation = [NSMutableDictionary new];
                biddingInformation[@"displaymanager"] = [adapter.relativeAdNetworkClass name];
                if ([adapter.relativeAdNetworkClass respondsToSelector:@selector(sdkVersion)]) {
                    biddingInformation[@"displaymanager_ver"] = [adapter.relativeAdNetworkClass sdkVersion];
                }
                // ext
                if ([adapter respondsToSelector:@selector(externalBiddingInformationForLoadingParamters:error:)]) {
                    biddingInformation[@"ext"] = [adapter externalBiddingInformationForLoadingParamters:network.parameters
                                                                                                  error:&error];
                }
                // SSP object
                if (network.identifier) {
                    NSMutableDictionary * sspInfo = [NSMutableDictionary new];
                    sspInfo[@"id"] = network.identifier;
                    sspInfo[@"ecpm"] = network.eCPM;
                    biddingInformation[ssp] = sspInfo;
                }
                // Error indicates that network not ready for auction
                if (!error) {
                    // If everything fine add config
                    [requestBody addObject:biddingInformation];
                }
            }
        }];*/
    }];
    
    return requestBody;
}

@end
