//
//  BDMAdColonyFullscreenAdapter.m
//  BDMAdColonyAdapter
//
//  Created by Stas Kochkin on 19/07/2019.
//  Copyright © 2019 Stas Kochkin. All rights reserved.
//

#import "BDMAdColonyFullscreenAdapter.h"
#import "BDMAdColonyStringTransformer.h"

#import <AdColony/AdColony.h>


@interface BDMAdColonyFullscreenAdapter ()

@property (nonatomic, weak) id<BDMAdColonyAdInterstitialProvider> provider;
@property (nonatomic, strong) AdColonyInterstitial *interstitial;

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
    NSString *zone = [BDMAdColonyStringTransformer.new transformedValue:contentInfo[@"zone_id"]];
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
    
    [self subscribe];
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

- (void)subscribe {
    __weak typeof(self) weakSelf = self;
    [self.interstitial setExpire:^{
        weakSelf.interstitial = nil;
        NSError *error = [NSError bdm_errorWithCode:BDMErrorCodeWasExpired description:@"Interstitial was expired"];
        [weakSelf.loadingDelegate adapter:weakSelf failedToPrepareContentWithError:error];
    }];
    
    [self.interstitial setOpen:^{
        [weakSelf.displayDelegate adapterWillPresent:weakSelf];
    }];
    
    [self.interstitial setClick:^{
        [weakSelf.displayDelegate adapterRegisterUserInteraction:weakSelf];
    }];
    
    [self.interstitial setClose:^{
        if (weakSelf.rewarded) {
            [weakSelf.displayDelegate adapterFinishRewardAction:weakSelf];
        }
        [weakSelf.displayDelegate adapterDidDismiss:weakSelf];
    }];
}

@end
