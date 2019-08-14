//
//  BDMInitializationOperation.h
//  BidMachine
//
//  Created by Stas Kochkin on 19/02/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import "BDMAsyncOperation.h"
#import "BDMAdNetworkConfiguration.h"
#import "BDMNetworkProtocol.h"
#import "BDMHeaderBiddingOperationProtocol.h"
#import "BDMHeaderBiddingController.h"


NS_ASSUME_NONNULL_BEGIN

@interface BDMHeaderBiddingInitialisationOperation : BDMAsyncOperation <BDMHeaderBiddingOperation>

+ (instancetype)initialisationOperationForNetworks:(NSArray <BDMAdNetworkConfiguration *> *)networks
                                        controller:(BDMHeaderBiddingController *)controller
                                 waitUntilFinished:(BOOL)waitUntilFinished;

@end

NS_ASSUME_NONNULL_END
