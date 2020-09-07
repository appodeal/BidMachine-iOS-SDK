//
//  BDMFacebookAdapter.h
//  BDMFacebookAdapter
//
//  Created by Stas Kochkin on 23/07/2019.
//  Copyright © 2019 Stas Kochkin. All rights reserved.
//

@import Foundation;
@import BidMachine;
@import BidMachine.Adapters;


NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const BDMFacebookAppIDKey;
FOUNDATION_EXPORT NSString *const BDMFacebookTokenKey;
FOUNDATION_EXPORT NSString *const BDMFacebookPlacementIDKey;
FOUNDATION_EXPORT NSString *const BDMFacebookPlacementIDsKey;
FOUNDATION_EXPORT NSString *const BDMFacebookBidPayloadIDKey;

@interface BDMFacebookAdNetwork : NSObject <BDMNetwork>

@end

NS_ASSUME_NONNULL_END
