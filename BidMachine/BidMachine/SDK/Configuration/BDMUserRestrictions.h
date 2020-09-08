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

/// User restrictions object
@interface BDMUserRestrictions : NSObject <NSCopying, NSSecureCoding>
/// Indicates that SDK allows to pass user information to networks
@property (assign, nonatomic, readonly) BOOL allowUserInformation;
/// Coppa parameter
@property (assign, nonatomic, readwrite) BOOL coppa;
/// Indicates that user has given consent
@property (assign, nonatomic, readwrite) BOOL hasConsent;
/// Indicates that user is under GDPR policy
@property (assign, nonatomic, readwrite) BOOL subjectToGDPR;
/// The consent string to send GDPR consent
@property (copy, nonatomic, readwrite, nullable) NSString *consentString;
/// Indicates that user has given consent
@property (assign, nonatomic, readonly) BOOL hasCCPAConsent;
/// Indicates that user is under CCPA policy
@property (assign, nonatomic, readonly) BOOL subjectToCCPA;
///  IAB CCPA String
@property (copy, nonatomic, readwrite, nullable) NSString *USPrivacyString;
@end

