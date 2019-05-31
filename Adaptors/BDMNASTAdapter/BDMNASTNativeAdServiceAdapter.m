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

@import AppodealNASTKit;


@implementation BDMNASTNativeAdServiceAdapter

- (Class)relativeAdNetworkClass {
    return BDMNASTNetwork.class;
}

- (NSString *)adContent {
    return nil;
}

- (void)prepareContent:(NSDictionary *)contentInfo {
    ANKManager * manager = ANKManager.new;
    __weak typeof(self) weakSelf = self;
    [manager parseAdFromJSON:contentInfo completion:^(ANKAd * ad, NSError * error) {
        if (error) {
            [weakSelf.loadingDelegate adapter:weakSelf failedToPrepareContentWithError: [error bdm_wrappedWithCode:BDMErrorCodeNoContent]];
        } else {
            BDMNASTDisplayAdapter * adapter = [BDMNASTDisplayAdapter displayAdapterForAd:ad];
            [weakSelf.loadingDelegate service:weakSelf didLoadNativeAds:@[adapter]];
        }
    }];
}

@end
