//
//  BDMAdColonyFullscreenAdapter.m
//  BDMAdColonyAdapter
//
//  Created by Stas Kochkin on 19/07/2019.
//  Copyright © 2019 Stas Kochkin. All rights reserved.
//

@import AdColony;
@import StackFoundation;

#import "BDMAdColonyFullscreenAdapter.h"


@interface BDMAdColonyFullscreenAdapter ()<AdColonyInterstitialDelegate>

@property (nonatomic, strong) AdColonyInterstitial *interstitial;
@property (nonatomic,   weak) id<BDMAdColonyAdInterstitialProvider> provider;

@end

@implementation BDMAdColonyFullscreenAdapter

- (instancetype)initWithProvider:(id<BDMAdColonyAdInterstitialProvider>)provider {
    if (self = [super init]) {
        self.provider = provider;
    }
    return self;
}

- (UIView *)adView {
    return nil;
}

- (void)prepareContent:(NSDictionary<NSString *,NSString *> *)contentInfo {
    NSString *zone = ANY(contentInfo).from(BDMAdColonyZoneIDKey).string;
    if (!zone) {
        NSError *error = [NSError bdm_errorWithCode:BDMErrorCodeNoContent description:@"AdColony zone id wasn't found"];
        [self.loadingDelegate adapter:self failedToPrepareContentWithError:error];
        return;
    }
    self.interstitial = [self.provider interstitialForZone:zone];
    
    if (!self.interstitial) {
        NSError *error = [NSError bdm_errorWithCode:BDMErrorCodeNoContent description:@"AdColony "];
        [self.loadingDelegate adapter:self failedToPrepareContentWithError:error];
        return;
    }
    
    self.interstitial.delegate = self;
    [self.loadingDelegate adapterPreparedContent:self];
}

- (void)present {
    UIViewController *rootViewController = [self.displayDelegate rootViewControllerForAdapter:self];
    if (self.interstitial.expired || !self.interstitial) {
        NSError *error = [NSError bdm_errorWithCode:BDMErrorCodeWasExpired description:@"AdColony interstitial was expired"];
        [self.displayDelegate adapter:self failedToPresentAdWithError:error];
        return;
    }
    [self.interstitial showWithPresentingViewController:rootViewController];
}

#pragma mark - AdColonyInterstitialDelegate

- (void)adColonyInterstitialDidLoad:(AdColonyInterstitial * _Nonnull)interstitial {
    
}

- (void)adColonyInterstitialDidFailToLoad:(AdColonyAdRequestError * _Nonnull)error {
    
}

- (void)adColonyInterstitialWillOpen:(AdColonyInterstitial * _Nonnull)interstitial {
    [self.displayDelegate adapterWillPresent:self];
}

- (void)adColonyInterstitialDidClose:(AdColonyInterstitial * _Nonnull)interstitial {
    if (self.rewarded) {
        [self.displayDelegate adapterFinishRewardAction:self];
    }
    [self.displayDelegate adapterDidDismiss:self];
}

- (void)adColonyInterstitialExpired:(AdColonyInterstitial * _Nonnull)interstitial {
    self.interstitial = nil;
    NSError *error = [NSError bdm_errorWithCode:BDMErrorCodeWasExpired description:@"Interstitial was expired"];
    [self.loadingDelegate adapter:self failedToPrepareContentWithError:error];
}

- (void)adColonyInterstitialDidReceiveClick:(AdColonyInterstitial * _Nonnull)interstitial {
    [self.displayDelegate adapterRegisterUserInteraction:self];
}

@end
