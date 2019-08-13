//
//  BDMTapjoyFullscreenAdapter.m
//  BDMTapjoyAdapter
//
//  Created by Stas Kochkin on 22/07/2019.
//  Copyright © 2019 Stas Kochkin. All rights reserved.
//

#import "BDMTapjoyFullscreenAdapter.h"
#import "BDMTapjoyValueTransformer.h"
#import "BDMTapjoyAuctionDataValueTransofrmer.h"

#import <Tapjoy/Tapjoy.h>


@interface BDMTapjoyFullscreenAdapter () <TJPlacementDelegate, TJPlacementVideoDelegate>

@property (nonatomic, strong) TJPlacement *placement;

@end


@implementation BDMTapjoyFullscreenAdapter

- (UIView *)adView {
    return nil;
}

- (void)prepareContent:(NSDictionary<NSString *,NSString *> *)contentInfo {
    NSString *plcName = [BDMTapjoyValueTransformer.new transformedValue:contentInfo[@"placement_name"]];
    if (!plcName) {
        NSError *error = [NSError bdm_errorWithCode:BDMErrorCodeBadContent
                                        description:@"Tapjoy placement wasn't found"];
        [self.loadingDelegate adapter:self failedToPrepareContentWithError:error];
        return;
    }
    
    self.placement = [TJPlacement limitedPlacementWithName:plcName mediationAgent:@"bidmachine" delegate:self];
    self.placement.adapterVersion = kBDMVersion;
    self.placement.videoDelegate = self;
    self.placement.auctionData = [BDMTapjoyAuctionDataValueTransofrmer.new transformedValue:contentInfo];
    
    if (self.placement.isContentReady) {
        [self.loadingDelegate adapterPreparedContent:self];
    } else {
        [self.placement requestContent];
    }
}

- (void)present {
    UIViewController *rootViewController = [self.displayDelegate rootViewControllerForAdapter:self];
    if (!self.placement.isContentReady || !rootViewController) {
        NSError *error = [NSError bdm_errorWithCode:BDMErrorCodeBadContent
                                        description:@"Can't present Tapjoy placement"];
        [self.loadingDelegate adapter:self failedToPrepareContentWithError:error];
        return;
    }
    
    [self.placement showContentWithViewController:rootViewController];
}

#pragma mark - TJPlacementDelegate

- (void)requestDidSucceed:(TJPlacement *)placement {}

- (void)requestDidFail:(TJPlacement *)placement error:(NSError *)error {
    NSError *wrapper = [error bdm_wrappedWithCode:BDMErrorCodeBadContent];
    [self.loadingDelegate adapter:self failedToPrepareContentWithError:wrapper];
}

- (void)contentIsReady:(TJPlacement *)placement {
    [self.loadingDelegate adapterPreparedContent:self];
}

- (void)contentDidAppear:(TJPlacement *)placement {
    [self.displayDelegate adapterWillPresent:self];
}

- (void)contentDidDisappear:(TJPlacement *)placement {
    [self.displayDelegate adapterDidDismiss:self];
}

#pragma mark - TJPlacementVideoDelegate

- (void)videoDidComplete:(TJPlacement *)placement {
    [self.displayDelegate adapterFinishRewardAction:self];
}

- (void)videoDidFail:(TJPlacement *)placement error:(NSString *)errorMsg {
    NSError *error = [NSError bdm_errorWithCode:BDMErrorCodeUnknown description:errorMsg];
    [self.displayDelegate adapter:self failedToPresentAdWithError:error];
}

@end
