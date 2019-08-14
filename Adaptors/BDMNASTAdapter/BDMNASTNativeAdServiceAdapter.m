//
//  BDMNASTNativeServiceAdapter.m
//  BDMNASTAdapter
//
//  Created by Stas Kochkin on 04/11/2018.
//  Copyright © 2018 Stas Kochkin. All rights reserved.
//

#import "BDMNASTNativeAdServiceAdapter.h"
#import "BDMNASTNetwork.h"
#import "BDMNASTDisplayAdapter.h"
#import <BidMachine/NSError+BDMSdk.h>

@import StackNASTKit;


@implementation BDMNASTNativeAdServiceAdapter

- (void)prepareContent:(NSDictionary<NSString *,NSString *> *)contentInfo {
    STKNASTManager * manager = STKNASTManager.new;
    __weak typeof(self) weakSelf = self;
    [manager parseAdFromJSON:contentInfo completion:^(STKNASTAd * ad, NSError * error) {
        if (error) {
            [weakSelf.loadingDelegate adapter:weakSelf failedToPrepareContentWithError: [error bdm_wrappedWithCode:BDMErrorCodeNoContent]];
        } else {
            BDMNASTDisplayAdapter * adapter = [BDMNASTDisplayAdapter displayAdapterForAd:ad];
            [weakSelf.loadingDelegate service:weakSelf didLoadNativeAds:@[adapter]];
        }
    }];
}

- (UIView *)adView {
    return nil;
}

@end
