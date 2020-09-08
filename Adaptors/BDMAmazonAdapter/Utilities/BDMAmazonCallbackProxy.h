//
//  BDMAmazonCallbackProxy.h
//  BDMAmazonAdapter
//
//  Created by Stas Kochkin on 08.09.2020.
//  Copyright © 2020 Stas Kochkin. All rights reserved.
//

#import <Foundation/Foundation.h>

@import DTBiOSSDK;


NS_ASSUME_NONNULL_BEGIN

@interface BDMAmazonCallbackProxy : NSObject <DTBAdCallback>

@property (nonatomic, weak) id<DTBAdCallback> delegate;

@end

NS_ASSUME_NONNULL_END
