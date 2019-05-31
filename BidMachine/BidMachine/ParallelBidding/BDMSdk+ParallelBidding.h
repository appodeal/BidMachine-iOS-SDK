//
//  BDMSdk+ParallelBidding.h
//  BidMachine
//
//  Created by Stas Kochkin on 01/10/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//


#import <BidMachine/BDMSdk.h>
#import <BidMachine/BDMInterstitial.h>
#import <BidMachine/BDMRewarded.h>
#import <BidMachine/BDMNativeAd.h>
#import <BidMachine/BDMBannerView.h>


FOUNDATION_EXPORT NSString * _Nonnull const BDMParallelBiddingNetworksExtensionKey;
FOUNDATION_EXPORT NSString * _Nonnull const BDMSSPExtensionKey;
FOUNDATION_EXPORT NSString * _Nonnull const BDMParallelBiddingInitialisatationItemsExtensionKey;


FOUNDATION_EXPORT NSString * _Nonnull const BDMRequestAppodealSegmentIdentifier;

/// Integration with parallel bidding mode sample
/*
BDMSdkConfiguration * configuration = [BDMSdkConfiguration new];
NSString * sellerID = @"seller id";
NSDecimalNumber * eCPM = [NSDecimalNumber decimalNumberWithDecimal:[@2.75f decimalValue]];
NSDictionary * parameters = @{ @"network_key" : @"value" };
BDMNetworkItem * item = [BDMNetworkItem networkItemWithName:@"Network"
                                                 identifier:@"Some uniq id"
                                                       eCPM:eCPM
                                                 parameters:parameters];
configuration.extensions = @{
                             BDMSSPExtensionKey : @"Your SSP name",
                             BDMParallelBiddingInitialisatationItemsExtensionKey : @[ item ],
                             BDMParallelBiddingNetworksExtensionKey : @[ NSStringFromClass(MyNetworkClass) ]
                             };
[BDMSdk.sharedSdk startSessionWithSellerID:sellerID
                             configuration:configuration
                                completion:^{
                                    // Network was started
                                }];
 */


@interface BDMSdkConfiguration (ParallelBidding)
/**
 Any extensions
 */
@property (copy, nonatomic, readwrite, nullable) NSDictionary <NSString *, id> * extensions;

@end


@interface BDMInterstitial (ParallelBidding)
/**
 Begin presentation of ad if it's available
 
 @param placement Current active placement
 @param rootViewController view controller for presentation
 */
- (void)presentWithPlacement:(nullable NSNumber *)placement
      fromRootViewController:(nonnull UIViewController *)rootViewController;

@end


@interface BDMRewarded (ParallelBidding)
/**
 Begin presentation of ad if it's available
 
 @param placement Current active placement
 @param rootViewController view controller for presentation
 */
- (void)presentWithPlacement:(nullable NSNumber *)placement
      fromRootViewController:(nonnull UIViewController *)rootViewController;

@end


@interface BDMNativeAd (ParallelBidding)
/**
 Current placement
 */
@property (nonatomic, copy, nullable, readwrite) NSNumber * placement;

@end


@interface BDMBannerView (ParallelBidding)
/**
 Current placement
 */
@property (nonatomic, copy, nullable, readwrite) NSNumber * placement;

@end
