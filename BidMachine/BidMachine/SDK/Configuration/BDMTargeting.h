//
//  BDMTargeting.h
//  BidMachine
//
//  Created by Stas Kochkin on 03/10/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BidMachine/BDMDefines.h>
#import <BidMachine/BDMUserRestrictions.h>
#import <CoreLocation/CoreLocation.h>


BDM_SUBCLASSING_RESTRICTED
/**
 Targeting model for SDK
 */
@interface BDMTargeting : NSObject <NSCopying, NSSecureCoding>
/**
 Vendor-specific ID for the user
 */
@property (copy, nonatomic, readwrite, nonnull) NSString *userId;
/**
 User gender refer to OpenRTB 2.5 spec
 */
@property (copy, nonatomic, readwrite, nonnull) BDMUserGender *gender;
/**
 User gender yob to OpenRTB 2.5 spec
 */
@property (copy, nonatomic, readwrite, nonnull) NSNumber *yearOfBirth;
/**
 Get user age
 */
@property (copy, nonatomic, readonly, nullable) NSNumber *userAge;
/**
 Comma separated list of keywords about the app
 */
@property (copy, nonatomic, readwrite, nullable) NSString *keywords;
/**
 Blocked advertiser categories using the IAB content categories. Refer to List 5.1
 */
@property (copy, nonatomic, readwrite, nullable) NSArray <NSString *> *blockedCategories;
/**
 Block list of advertisers by their domains (e.g., “ford.com”).
 */
@property (copy, nonatomic, readwrite, nullable) NSArray <NSString *> *blockedAdvertisers;
/**
 Block list of applications by their platform-specific exchange- independent application identifiers. These are numeric IDs.
 */
@property (copy, nonatomic, readwrite, nullable) NSArray <NSString *> *blockedApps;
/**
 Current location of user device. If location services enabled in application, sdk will take location by itself
 */
@property (copy, nonatomic, readwrite, nullable) CLLocation *deviceLocation;
/**
 User country
 */
@property (copy, nonatomic, readwrite, nullable) NSString *country;
/**
 User city
 */
@property (copy, nonatomic, readwrite, nullable) NSString *city;
/**
 User zip code
 */
@property (copy, nonatomic, readwrite, nullable) NSString *zip;
/**
 Store URL
 */
@property (copy, nonatomic, readwrite, nullable) NSURL *storeURL;
/**
 Numeric store id identifier
 */
@property (copy, nonatomic, readwrite, nullable) NSString *storeId;
/**
 Paid version of app
 */
@property (assign, nonatomic, readwrite) BOOL paid;
@end
