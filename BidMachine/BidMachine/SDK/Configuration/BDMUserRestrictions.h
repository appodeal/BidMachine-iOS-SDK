//
//  BDMUserRestrictions.h
//  BidMachine
//
//  Created by Stas Kochkin on 08/11/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BidMachine/BDMDefines.h>


BDM_SUBCLASSING_RESTRICTED
/**
 User restrictions objects
 */
@interface BDMUserRestrictions : NSObject <NSCopying, NSSecureCoding>
/**
 Coppa parameter
 */
@property (assign, nonatomic, readwrite) BOOL coppa;
/**
 Setup that user is under GDPR
 */
@property (assign, nonatomic, readwrite) BOOL subjectToGDPR;
/**
 Setup that user give consent
 */
@property (assign, nonatomic, readwrite) BOOL hasConsent;
/**
 * The consent string for sending the GDPR consent
 */
@property (copy, nonatomic, readwrite, nullable) NSString * consentString;

@end

