//
//  BDMVungleFullscreenAdapter.m
//  BDMVungleAdapter
//
//  Created by Stas Kochkin on 22/07/2019.
//  Copyright © 2019 Stas Kochkin. All rights reserved.
//

#import "BDMVungleFullscreenAdapter.h"
#import "BDMVungleValueTransformer.h"

@interface BDMVungleFullscreenAdapter ()

@property (nonatomic, copy) NSString *placement;

@end

@implementation BDMVungleFullscreenAdapter

- (UIView *)adView {
    return nil;
}

- (void)prepareContent:(NSDictionary<NSString *,NSString *> *)contentInfo {
    self.placement = [BDMVungleValueTransformer.new transformedValue:contentInfo[@"placement_id"]];
    if (self.placement && [VungleSDK.sharedSDK isAdCachedForPlacementID:self.placement]) {
        [self.loadingDelegate adapterPreparedContent:self];
    } else {
        NSString *description = [NSString stringWithFormat:@"Vungle has not content for placement %@", self.placement ?: @"unknown"];
        NSError *error = [NSError bdm_errorWithCode:BDMErrorCodeNoContent description:description];
        [self.loadingDelegate adapter:self failedToPrepareContentWithError:error];
    }
}

- (void)present {
    UIViewController *rootViewController = [self.displayDelegate rootViewControllerForAdapter:self];
    if (!rootViewController) {
        NSError *error = [NSError bdm_errorWithCode:BDMErrorCodeUnknown description:@"Root view controller cannot be nil"];
        [self.displayDelegate adapter:self failedToPresentAdWithError:error];
        return;
    }
    NSError *error = nil;
    [VungleSDK.sharedSDK playAd:rootViewController options:nil placementID:self.placement error:&error];
    if (error) {
        NSError *wrapper = [error bdm_wrappedWithCode:BDMErrorCodeUnknown];
        [self.displayDelegate adapter:self failedToPresentAdWithError:wrapper];
    }
}

#pragma mark VungleSDKDelegate

- (void)vungleAdPlayabilityUpdate:(BOOL)isAdPlayable placementID:(NSString *)placementID error:(NSError *)error {
    if (![placementID isEqualToString:self.placement]) {
        return;
    }
    
    if (error) {
        NSError *wrapped = [error bdm_wrappedWithCode:BDMErrorCodeNoContent];
        [self.loadingDelegate adapter:self failedToPrepareContentWithError:wrapped];
    }
}

- (void)vungleWillShowAdForPlacementID:(NSString *)placementID {
    if (![placementID isEqualToString:self.placement]) {
        return;
    }
    
    [self.displayDelegate adapterWillPresent:self];
}

- (void)vungleWillCloseAdWithViewInfo:(VungleViewInfo *)info placementID:(NSString *)placementID {
    if (![placementID isEqualToString:self.placement]) {
        return;
    }
    
    if (info.didDownload.boolValue) {
        [self.displayDelegate adapterRegisterUserInteraction:self];
    }
    
    if (info.completedView.boolValue && self.rewarded) {
        [self.displayDelegate adapterFinishRewardAction:self];
    }
    
    [self.displayDelegate adapterDidDismiss:self];
}

@end
