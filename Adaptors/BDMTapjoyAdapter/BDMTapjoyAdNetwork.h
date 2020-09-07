//
//  BDMTapjoyAdapter.h
//  BDMTapjoyAdapter
//
//  Created by Stas Kochkin on 22/07/2019.
//  Copyright © 2019 Stas Kochkin. All rights reserved.
//

@import Foundation;
@import BidMachine;
@import BidMachine.Adapters;

#import <Tapjoy/Tapjoy.h>


NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const BDMTapjoySDKKey;
FOUNDATION_EXPORT NSString *const BDMTapjoyTokenKey;
FOUNDATION_EXPORT NSString *const BDMTapjoyPlacementKey;

@interface BDMTapjoyAdNetwork : NSObject <BDMNetwork>

@end

NS_ASSUME_NONNULL_END
