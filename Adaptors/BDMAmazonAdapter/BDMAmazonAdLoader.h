//
//  BDMAmazonAdLoader.h
//  BDMAmazonAdapter
//
//  Created by Stas Kochkin on 31.08.2020.
//  Copyright © 2020 Stas Kochkin. All rights reserved.
//


#import "BDMAmazonNetwork.h"


@class BDMAmazonAdLoader;

typedef void(^BDMAmazonAdLoaderCompletion)(BDMAmazonAdLoader *_Nonnull loader,
                                           NSDictionary <NSString *, id> *_Nullable biddingParameters,
                                           NSError *_Nullable error);


NS_ASSUME_NONNULL_BEGIN

@interface BDMAmazonAdLoader : NSObject

- (instancetype)initWithFormat:(BDMAdUnitFormat)format;

- (void)prepareWithParameters:(NSDictionary <NSString *, id> *)parameters completion:(BDMAmazonAdLoaderCompletion)completion;

@end

NS_ASSUME_NONNULL_END
