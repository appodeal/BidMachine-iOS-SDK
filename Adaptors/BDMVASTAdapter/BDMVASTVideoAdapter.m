//
//  BDMVASTVideoAdapter.m
//  BDMVASTVideoAdapter
//
//  Created by Pavel Dunyashev on 24/09/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#define DEFAULT_SKIP_INTERVAL 5
#define DEFAULT_REWARD_INTERVAL 30

#import "BDMVASTVideoAdapter.h"
#import "BDMVASTNetwork.h"
#import <BidMachine/NSError+BDMSdk.h>

@import DisplayKit;
@import ASKExtension;
@import ASKProductPresentation;
@import ASKSpinner;

@interface BDMVASTVideoAdapter () <DSKVASTControllerDelegate>

@property (nonatomic, strong) DSKVASTController * videoController;

@end

@implementation BDMVASTVideoAdapter

- (Class)relativeAdNetworkClass {
    return BDMVASTNetwork.class;
}

- (UIView *)adView {
    return self.videoController.view;
}

- (void)prepareContent:(NSDictionary *)contentInfo {
    NSString * rawXML = contentInfo[@"creative"];
    NSData * xmlData = [rawXML dataUsingEncoding:NSUTF8StringEncoding];
    
    self.videoController = [DSKVASTController new];
    self.videoController.delegate = self;
    [self.videoController loadForVastXML:xmlData];
}

- (NSString *)adContent {
    return self.videoController.adCreative;
}


- (void)present {
    [self.videoController presentFromViewController:self.rootViewController];
}

#pragma mark - Private

- (NSNumber *)closeTime {
    return self.rewarded ? @DEFAULT_REWARD_INTERVAL : @DEFAULT_SKIP_INTERVAL;
}

- (BOOL)isAutoclose {
    return NO;
}

- (BOOL)isRewarded {
    return self.rewarded;
}

- (UIViewController *)rootViewController {
    return [self.displayDelegate rootViewControllerForAdapter:self] ?: UIViewController.ask_topPresentedViewController;
}

#pragma mark - DSKVASTControllerDelegate

- (void)vastControllerReady:(DSKVASTController *)controller {
    [self.loadingDelegate adapterPreparedContent:self];
}

- (void)vastController:(DSKVASTController *)controller didFailToLoad:(NSError *)error {
    [self.loadingDelegate adapter:self failedToPrepareContentWithError: [error bdm_wrappedWithCode:BDMErrorCodeNoContent]];
}

- (void)vastController:(DSKVASTController *)controller didFailWhileShow:(NSError *)error {
    [self.displayDelegate adapter:self failedToPresentAdWithError: [error bdm_wrappedWithCode:BDMErrorCodeBadContent]];
}

- (void)vastControllerDidClick:(DSKVASTController *)controller clickURL:(NSString *)clickURL {
    [self.displayDelegate adapterRegisterUserInteraction:self];
    
    if (clickURL) {
        [controller pause];
        [ASKSpinnerScreen show];
        __weak typeof(controller)weakController = controller;
        [ASKProductPresentation openURL:[NSURL URLWithString:clickURL]
                                success:^(NSURL *url) {
                                    [ASKSpinnerScreen hide];
                                } failure:^(NSError *error) {
                                    [ASKSpinnerScreen hide];
                                } completion:^{
                                    [weakController resume];
                                }];
    }
}

- (void)vastControllerDidDismiss:(DSKVASTController *)controller {
    [self.displayDelegate adapterDidDismiss:self];
}

- (void)vastControllerDidFinish:(DSKVASTController *)controller {
    [self.displayDelegate adapterFinishRewardAction:self];
}

- (void)vastControllerDidPresent:(DSKVASTController *)controller {
    [self.displayDelegate adapterWillPresent:self];
}

/// Noop
- (void)vastControllerDidSkip:(DSKVASTController *)controller {}

@end
