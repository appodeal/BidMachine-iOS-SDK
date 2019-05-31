//
//  BDMNativeService.h
//  BidMachine
//
//  Created by Lozhkin Ilya on 5/31/18.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BidMachine/BDMRequest.h>
#import <BidMachine/BDMNativeAdProtocol.h>


@class BDMNativeAdService;

/**
 Native ad service callback handler
 */
@protocol BDMNativeAdServiceDelegate <NSObject>
/**
 Called if any error occure due to auction

 @param service Failed service
 @param error Error object
 */
- (void)service:(nonnull BDMNativeAdService *)service failedToLoadWithError:(nonnull NSError *)error;
/**
 Called auction finish with valid bid

 @param service Succesful service
 @param nativeAds Array of ready to present native ads
 */
- (void)service:(nonnull BDMNativeAdService *)service didLoadNativeAds:(nonnull NSArray <id<BDMNativeAd>> *)nativeAds;
@end

/**
 Native service that provide auctions and validate win bids.
 */
@interface BDMNativeAdService : NSObject
/**
 Callback handler
 */
@property (nonatomic, weak, nullable) id<BDMNativeAdServiceDelegate> delegate;
/**
 Demand name
 */
@property (nonatomic, readonly, nullable) NSString * demandSource;
/**
 Auction price
 */
@property (nonatomic, readonly, nullable) NSNumber * price;
/**
 Make request to exchange backend. Provide bidding information from
 sdk networks and embedded display manager (NAST)

 @param request Request object
 */
- (void)makeRequest:(nonnull BDMRequest *)request;
@end
