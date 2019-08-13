//
//  BDMHeaderBiddingController.h
//  BidMachine
//
//  Created by Stas Kochkin on 24/07/2019.
//  Copyright © 2019 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BDMAdNetworkConfiguration.h"
#import "BDMEventMiddleware.h"
#import "BDMPlacementAdUnit.h"
#import "BDMRequest+Private.h"


@class BDMHeaderBiddingController;

NS_ASSUME_NONNULL_BEGIN

@protocol BDMHeaderBiddingControllerDelegate  <NSObject>

- (nullable id<BDMNetwork>)networkWithName:(NSString *)name
                                controller:(BDMHeaderBiddingController *)controller;

@end

@interface BDMHeaderBiddingController : NSObject

typedef void(^BDMHeaderBiddingInitializationCompletion)(void);
typedef void(^BDMHeaderBiddingPreparationCompletion)(_Nullable id<BDMPlacementAdUnit>);

@property (nonatomic, weak, nullable) BDMEventMiddleware *middleware;
@property (nonatomic, weak, nullable) id <BDMHeaderBiddingControllerDelegate> delegate;

- (void)initializeNetwork:(BDMAdNetworkConfiguration *)config
               completion:(BDMHeaderBiddingInitializationCompletion)completion;

- (void)prepareAdUnit:(BDMAdUnit *)adUnit
            placement:(BDMInternalPlacementType)placement
              network:(NSString *)network
           completion:(BDMHeaderBiddingPreparationCompletion)completion;

- (void)invalidateAdUnit:(BDMAdUnit *)adUnit
               placement:(BDMInternalPlacementType)placement
                 network:(NSString *)network;

@end

NS_ASSUME_NONNULL_END
