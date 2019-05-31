//
//  BDMNetworkConfiguration.h
//  BidMachine
//
//  Created by Stas Kochkin on 09/11/2017.
//  Copyright © 2017 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Object needed for intilize third party networks
 and making request for necessary ad units
 */
@interface BDMNetworkItem : NSObject <NSCopying, NSSecureCoding>
/**
 Registered network name
 */
@property (nonatomic, strong, readonly) NSString * name;
/**
 Custom parameters dictionary. Format of keys/values should be defined in any network adapter
 */
@property (nonatomic, strong, readonly) NSDictionary * parameters;
/**
 Internal appodeal ID for stats
 */
@property (nonatomic, strong, readonly) NSString * identifier;
/**
 Historical or pricfeloor eCPM
 */
@property (nonatomic, strong, readonly) NSDecimalNumber * eCPM;
/**
 Designated initializer

 @param networkName Ready for bidding network
 @param identifier Uniq appodeal id
 @param eCPM Historical or pricfeloor eCPM
 @return Instance of configuration
 */
+ (instancetype)networkItemWithName:(NSString *)networkName
                         identifier:(NSString *)identifier
                               eCPM:(NSDecimalNumber *)eCPM;
/**
 Designated initializer
 
 @param networkName Ready for bidding network
 @param identifier Uniq appodeal id
 @param eCPM Historical or pricfeloor eCPM
 @param parameters Additional network depended parameters
 @return Instance of configuration
 */
+ (instancetype)networkItemWithName:(NSString *)networkName
                         identifier:(NSString *)identifier
                               eCPM:(NSDecimalNumber *)eCPM
                         parameters:(NSDictionary *)parameters;
/**
 Designated initializer for networks that not
 have any additional information firm SSP

 @param networkName Network name
 @param parameters P
 @return Additional network depended parameters
 */
+ (instancetype)networkItemWithName:(NSString *)networkName
                         parameters:(NSDictionary *)parameters;

@end
