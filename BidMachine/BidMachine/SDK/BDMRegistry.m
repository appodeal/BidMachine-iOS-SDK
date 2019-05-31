//
//  BDMRegistry.m
//  BidMachine
//
//  Created by Stas Kochkin on 08/11/2017.
//  Copyright © 2017 Appodeal. All rights reserved.
//

#import "BDMRegistry.h"
#import <objc/runtime.h>
#import "BDMSdk.h"


@interface BDMRegistry ()

@property (nonatomic, strong) NSMutableSet * networkClasses;

@end

@implementation BDMRegistry

- (NSMutableSet *)networkClasses {
    if (!_networkClasses) {
        _networkClasses = [NSMutableSet new];
    }
    return _networkClasses;
}

#pragma mark - Public

- (void)registerNetworkClass:(NSString *)networkClassString {
    [self.networkClasses addObject:networkClassString];
}

- (Class <BDMNetwork>)networkClassByName:(NSString *)name {
    __block Class cls;
    if (name) {
        [self.networkClasses enumerateObjectsUsingBlock:^(NSString * clsString, BOOL * stop) {
            Class clsCandidate = NSClassFromString(clsString);
            if ([clsCandidate respondsToSelector:@selector(name)] &&
                [[clsCandidate name] isEqualToString:name]) {
                cls = clsCandidate;
                *stop = YES;
            }
        }];
    }
    return  cls;
}

- (id <BDMBannerAdapter>)bannerAdapterForNetwork:(NSString *)networkName {
    Class network = [self networkClassByName:networkName];
    if ([network respondsToSelector:@selector(bannerAdapterClassForSdk:)]) {
        return [[[network bannerAdapterClassForSdk:BDMSdk.sharedSdk] class] new];
    }
    return nil;
}

- (id <BDMFullscreenAdapter>)interstitialAdAdapterForNetwork:(NSString *)networkName {
    Class network = [self networkClassByName:networkName];
    if ([network respondsToSelector:@selector(interstitialAdAdapterClassForSdk:)]) {
        return [[[network interstitialAdAdapterClassForSdk:BDMSdk.sharedSdk] class] new];
    }
    return nil;
}

- (id <BDMFullscreenAdapter>)videoAdapterForNetwork:(NSString *)networkName {
    Class network = [self networkClassByName:networkName];
    if ([network respondsToSelector:@selector(videoAdapterClassForSdk:)]) {
        return [[[network videoAdapterClassForSdk:BDMSdk.sharedSdk] class] new];
    }
    return nil;
}

- (id <BDMNativeAdServiceAdapter>)nativeAdAdapterForNetwork:(NSString *)networkName {
    Class network = [self networkClassByName:networkName];
    if ([network respondsToSelector:@selector(nativeAdAdapterClassForSdk:)]) {
        return [[[network nativeAdAdapterClassForSdk:BDMSdk.sharedSdk] class] new];
    }
    return nil;
}

@end
