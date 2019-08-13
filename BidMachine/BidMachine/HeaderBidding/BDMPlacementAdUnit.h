//
//  BDMPlacementAdUnit.h
//  BidMachine
//
//  Created by Stas Kochkin on 17/07/2019.
//  Copyright © 2019 Appodeal. All rights reserved.
//

#import "BDMDefines.h"

@class BDMAdUnit;

NS_ASSUME_NONNULL_BEGIN

@protocol BDMPlacementAdUnit <NSObject>

@property (nonatomic, copy, readonly) NSString *bidder;
@property (nonatomic, copy, readonly, nullable) NSString *bidderSdkVersion;
@property (nonatomic, copy, readonly) NSDictionary <NSString *, id> *clientParams;
@property (nonatomic, assign, readonly) BDMAdUnitFormat format;

@end


@interface BDMPlacementAdUnitBuilder: NSObject

@property (nonatomic, readonly) BDMPlacementAdUnitBuilder *(^appendAdUnit)(BDMAdUnit *);
@property (nonatomic, readonly) BDMPlacementAdUnitBuilder *(^appendSdkVersion)(NSString *);
@property (nonatomic, readonly) BDMPlacementAdUnitBuilder *(^appendBidder)(NSString *);
@property (nonatomic, readonly) BDMPlacementAdUnitBuilder *(^appendClientParamters)(NSDictionary <NSString *, id> *);

+ (id<BDMPlacementAdUnit>)placementAdUnitWithBuild:(void(^)(BDMPlacementAdUnitBuilder *))build;

@end

NS_ASSUME_NONNULL_END
