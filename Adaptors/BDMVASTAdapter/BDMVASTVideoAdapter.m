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

@import BidMachine.Adapters;
@import AppodealVASTKit;
@import ASKExtension;
@import ASKProductPresentation;
@import ASKSpinner;


@interface BDMVASTVideoAdapter () <AVKControllerDelegate>

@property (nonatomic, strong) AVKController *videoController;
@property (nonatomic, copy) NSNumber *maxDuration;

@end

@implementation BDMVASTVideoAdapter

- (Class)relativeAdNetworkClass {
    return BDMVASTNetwork.class;
}

- (instancetype)init {
    if (self = [super init]) {
        _maxDuration = @(180);
    }
    return self;
}

- (UIView *)adView {
    return self.videoController.view;
}

- (void)prepareContent:(NSDictionary *)contentInfo {
    NSString * rawXML = contentInfo[@"creative"];
    self.maxDuration = [contentInfo[@"max_duration"] isKindOfClass:NSNumber.self] ? contentInfo[@"max_duration"] : self.maxDuration;
    NSData * xmlData = [rawXML dataUsingEncoding:NSUTF8StringEncoding];
    
    self.videoController = [AVKController new];
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

#pragma mark - AVKControllerDelegate

- (void)vastControllerReady:(AVKController *)controller {
    [self.loadingDelegate adapterPreparedContent:self];
}

- (void)vastController:(AVKController *)controller didFailToLoad:(NSError *)error {
    [self.loadingDelegate adapter:self failedToPrepareContentWithError: [error bdm_wrappedWithCode:BDMErrorCodeNoContent]];
}

- (void)vastController:(AVKController *)controller didFailWhileShow:(NSError *)error {
    [self.displayDelegate adapter:self failedToPresentAdWithError: [error bdm_wrappedWithCode:BDMErrorCodeBadContent]];
}

- (void)vastControllerDidClick:(AVKController *)controller clickURL:(NSString *)clickURL {
    [self.displayDelegate adapterRegisterUserInteraction:self];
    NSURL *productLink = clickURL ? [NSURL URLWithString:clickURL] : nil;
    if (productLink) {
        [controller pause];
        [ASKSpinnerScreen show];
        __weak typeof(controller) weakController = controller;
        [ASKProductPresentation openURLs:@[productLink] success:^(NSURL *link) {
            [ASKSpinnerScreen hide];
        } failure:^(NSError *error) {
            [ASKSpinnerScreen hide];
        } completion:^{
            [weakController resume];
        }];
    }
}

- (void)vastControllerDidDismiss:(AVKController *)controller {
    [self.displayDelegate adapterDidDismiss:self];
}

- (void)vastControllerDidFinish:(AVKController *)controller {
    [self.displayDelegate adapterFinishRewardAction:self];
}

- (void)vastControllerDidPresent:(AVKController *)controller {
    [self.displayDelegate adapterWillPresent:self];
}

/// Noop
- (void)vastControllerDidSkip:(AVKController *)controller {}

@end
