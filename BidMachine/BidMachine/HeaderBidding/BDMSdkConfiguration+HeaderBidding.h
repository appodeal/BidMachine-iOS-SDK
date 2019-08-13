//
//  BDMSdk+HeaderBidding.h
//  BidMachine
//
//  Created by Stas Kochkin on 01/10/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//


#import <BidMachine/BDMSdk.h>
#import <BidMachine/BDMAdNetworkConfiguration.h>

@interface BDMSdk (HeaderBidding)
/**
 Configuration
 */
@property (copy, nonatomic, readonly, nonnull) BDMSdkConfiguration *configuration;
@end

@interface BDMSdkConfiguration (HeaderBidding)
/**
 Any extensions
 */
@property (copy, nonatomic, readwrite, nullable) NSArray <BDMAdNetworkConfiguration *> *networkConfigurations;
@property (copy, nonatomic, readwrite, nonnull) NSString *ssp;

@end
