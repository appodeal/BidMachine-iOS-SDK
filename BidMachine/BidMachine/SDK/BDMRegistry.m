//
//  BDMRegistry.m
//  BidMachine
//
//  Created by Stas Kochkin on 08/11/2017.
//  Copyright © 2017 Appodeal. All rights reserved.
//

#import "BDMRegistry.h"
#import "BDMSdk.h"

#import <StackFoundation/StackFoundation.h>


@interface BDMRegistry ()

@property (nonatomic, strong) NSMutableSet <Class<BDMNetwork>> *networkClasses;
@property (nonatomic, strong) NSHashTable <id<BDMNetwork>> *networks;

@end

@implementation BDMRegistry

- (NSMutableSet *)networkClasses {
    if (!_networkClasses) {
        _networkClasses = [NSMutableSet new];
    }
    return _networkClasses;
}

- (NSHashTable<id<BDMNetwork>> *)networks {
    if (!_networks) {
        _networks = [[NSHashTable alloc] initWithOptions:NSPointerFunctionsStrongMemory
                                                capacity:self.networkClasses.count];
    }
    return _networks;
}

#pragma mark - Public

- (void)registerNetworkClass:(Class<BDMNetwork>)networkClass {
    [self.networkClasses addObject:networkClass];
}

- (void)initNetworks {
    [self.networkClasses enumerateObjectsUsingBlock:^(Class<BDMNetwork> cls, BOOL *stop) {
        BOOL wasInitialised = ANY(self.networks.allObjects)
        .filter(^(id<BDMNetwork> network) { return [network isKindOfClass:cls]; })
        .array.count > 0;
        if (!wasInitialised) {
            id<BDMNetwork> instance = [cls new];
            [self.networks addObject:instance];
        }
    }];
}

- (id<BDMNetwork>)networkByName:(NSString *)name {
    __block id network;
    if (name) {
        network = ANY(self.networks.allObjects).filter(^BOOL(id<BDMNetwork> network) {
            return [network.name isEqualToString:name];
        }).array.firstObject;
    }
    return network;
}

- (id <BDMBannerAdapter>)bannerAdapterForNetwork:(NSString *)networkName {
    id <BDMNetwork> network = [self networkByName:networkName];
    if ([network respondsToSelector:@selector(bannerAdapterForSdk:)]) {
        return [network bannerAdapterForSdk:BDMSdk.sharedSdk];
    }
    return nil;
}

- (id <BDMFullscreenAdapter>)interstitialAdAdapterForNetwork:(NSString *)networkName {
    id <BDMNetwork> network = [self networkByName:networkName];
    if ([network respondsToSelector:@selector(interstitialAdAdapterForSdk:)]) {
        return [network interstitialAdAdapterForSdk:BDMSdk.sharedSdk];
    }
    return nil;
}

- (id <BDMFullscreenAdapter>)videoAdapterForNetwork:(NSString *)networkName {
    id <BDMNetwork> network = [self networkByName:networkName];
    if ([network respondsToSelector:@selector(videoAdapterForSdk:)]) {
        return [network videoAdapterForSdk:BDMSdk.sharedSdk];
    }
    return nil;
}

- (id <BDMNativeAdServiceAdapter>)nativeAdAdapterForNetwork:(NSString *)networkName {
    id <BDMNetwork> network = [self networkByName:networkName];
    if ([network respondsToSelector:@selector(nativeAdAdapterForSdk:)]) {
        return [network nativeAdAdapterForSdk:BDMSdk.sharedSdk];
    }
    return nil;
}

@end
