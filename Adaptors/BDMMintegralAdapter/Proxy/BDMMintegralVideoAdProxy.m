//
//  BDMMintegralVideoAdProxy.m
//  BDMMintegralAdapter
//
//  Created by Yaroslav Skachkov on 9/5/19.
//  Copyright © 2019 Stas Kochkin. All rights reserved.
//

#import "BDMMintegralVideoAdProxy.h"

@interface BDMMintegralVideoAdProxy()

@property (nonatomic, assign) BOOL adIsLoading;

@end

@implementation BDMMintegralVideoAdProxy

+ (instancetype)sharedInstance {
    static BDMMintegralVideoAdProxy * _sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = BDMMintegralVideoAdProxy.new;
    });
    return _sharedInstance;
}

- (MTGBidRewardAdManager *)manager {
    return [MTGBidRewardAdManager sharedInstance];
}

- (UIViewController *)rootViewController {
    return [self.adapter.displayDelegate rootViewControllerForAdapter:self.adapter];
}

- (void)loadVideoWithBidToken:(NSString *)bidToken
                  placementId:(NSString *)placementId
                       unitId:(NSString *)unitId
                      adapter:(id<BDMFullscreenAdapter>)adapter {
    if (!self.adIsLoading) {
        self.adIsLoading = YES;
        self.adapter = adapter;
        [self.manager loadVideoWithBidToken:bidToken
                                placementId:placementId
                                     unitId:unitId
                                   delegate:self];
    }
}

- (void)showVideoWithPlacementId:(NSString *)placementId
                          unitId:(NSString *)unitId
                    withRewardId:(NSString *)rewardId
                          userId:(NSString *)userId
                         adapter:(id<BDMFullscreenAdapter>)adapter {
    if ([self rootViewController]) {
        [self.manager showVideoWithPlacementId:placementId
                         unitId:unitId
                   withRewardId:rewardId
                         userId:userId
                       delegate:self
                 viewController:[self rootViewController]];
    }
}

#pragma mark - MTGRewardAdShowDelegate

- (void)onVideoAdShowFailed:(NSString *)unitId
                  withError:(NSError *)error {
    [self.adapter.displayDelegate adapter:self.adapter failedToPresentAdWithError:error];
}

- (void)onVideoAdClicked:(NSString *)unitId {
    [self.adapter.displayDelegate adapterRegisterUserInteraction:self.adapter];
}

- (void)onVideoAdDismissed:(NSString *)unitId
             withConverted:(BOOL)converted
            withRewardInfo:(MTGRewardAdInfo *)rewardInfo {
    [self.adapter.displayDelegate adapterFinishRewardAction:self.adapter];
}

- (void)onVideoAdDidClosed:(NSString *)unitId {
    [self.adapter.displayDelegate adapterDidDismiss:self.adapter];
}

// No-op
- (void)onVideoAdShowSuccess:(NSString *)unitId {}
- (void)onVideoPlayCompleted:(NSString *)unitId {}
- (void)onVideoEndCardShowSuccess:(NSString *)unitId {}

#pragma mark - MTGRewardAdLoadDelegate

- (void)onVideoAdLoadSuccess:(NSString *)unitId {
    self.adIsLoading = NO;
    [self.adapter.loadingDelegate adapterPreparedContent:self.adapter];
}

- (void)onVideoAdLoadFailed:(NSString *)unitId
                      error:(NSError *)error {
    self.adIsLoading = NO;
    [self.adapter.loadingDelegate adapter:self.adapter failedToPrepareContentWithError:error];
}

// No-op
- (void)onAdLoadSuccess:(NSString *)unitId {}
@end
