//
//  BDMHeaderBiddingOperationProtocol.h
//  BidMachine
//
//  Created by Stas Kochkin on 17/07/2019.
//  Copyright © 2019 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BDMNetworkProtocol.h"


NS_ASSUME_NONNULL_BEGIN

@protocol BDMHeaderBiddingOperation <NSObject>

@property (nonatomic, assign, readonly) NSTimeInterval executionTime;
@property (nonatomic, copy, readonly, nullable) NSError *error;

@end

NS_ASSUME_NONNULL_END
