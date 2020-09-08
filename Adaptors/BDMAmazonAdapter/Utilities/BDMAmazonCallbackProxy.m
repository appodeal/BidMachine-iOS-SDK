//
//  BDMAmazonCallbackProxy.m
//  BDMAmazonAdapter
//
//  Created by Stas Kochkin on 08.09.2020.
//  Copyright © 2020 Stas Kochkin. All rights reserved.
//

#import "BDMAmazonCallbackProxy.h"

@implementation BDMAmazonCallbackProxy

- (void)onSuccess:(DTBAdResponse *)adResponse {
    [self.delegate onSuccess:adResponse];
}

- (void)onFailure:(DTBAdError)error {
    [self.delegate onFailure:error];
}

@end
