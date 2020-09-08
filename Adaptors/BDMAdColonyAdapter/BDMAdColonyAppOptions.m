//
//  BDMAdColonyAppOptions.m
//  BDMAdColonyAdapter
//
//  Created by Stas Kochkin on 23/07/2019.
//  Copyright © 2019 Stas Kochkin. All rights reserved.
//

#import "BDMAdColonyAppOptions.h"

@implementation BDMAdColonyAppOptions

- (instancetype)init {
    if (self = [super init]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.disableLogging = !BDMSdkLoggingEnabled;
    
    if (BDMSdk.sharedSdk.restrictions.subjectToGDPR) {
        [self setPrivacyFrameworkOfType:ADC_GDPR isRequired:YES];
        NSString *consent = BDMSdk.sharedSdk.restrictions.consentString ?: BDMSdk.sharedSdk.restrictions.hasConsent ? @"1" : @"0";
        [self setPrivacyConsentString:consent forType:ADC_GDPR];
    }
    
    if (BDMSdk.sharedSdk.restrictions.subjectToCCPA) {
        [self setPrivacyFrameworkOfType:ADC_CCPA isRequired:YES];
        NSString *consent = BDMSdk.sharedSdk.restrictions.USPrivacyString ?: BDMSdk.sharedSdk.restrictions.hasCCPAConsent ? @"1" : @"0";
        [self setPrivacyConsentString:consent forType:ADC_CCPA];
    }
    
    if (BDMSdk.sharedSdk.restrictions.coppa) {
        [self setPrivacyFrameworkOfType:ADC_COPPA isRequired:YES];
    }
    
    if (!BDMSdk.sharedSdk.restrictions.allowUserInformation) {
        return;
    }
    
    AdColonyUserMetadata *userMetadata  = [AdColonyUserMetadata new];
    userMetadata.userAge                = [BDMSdk.sharedSdk.configuration.targeting.userAge integerValue];
    userMetadata.userLatitude           = @(BDMSdk.sharedSdk.configuration.targeting.deviceLocation.coordinate.latitude);
    userMetadata.userLongitude          = @(BDMSdk.sharedSdk.configuration.targeting.deviceLocation.coordinate.longitude);
    
    if ([BDMSdk.sharedSdk.configuration.targeting.gender isEqualToString:kBDMUserGenderMale]) {
        userMetadata.userGender = ADCUserMale;
    } else if ([BDMSdk.sharedSdk.configuration.targeting.gender isEqualToString:kBDMUserGenderFemale]) {
        userMetadata.userGender = ADCUserFemale;
    }
    
    userMetadata.userZipCode = BDMSdk.sharedSdk.configuration.targeting.zip;
}

@end
