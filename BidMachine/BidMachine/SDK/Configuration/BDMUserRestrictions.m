//
//  BDMUserRestrictions.m
//  BidMachine
//
//  Created by Stas Kochkin on 08/11/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import "BDMUserRestrictions.h"


@interface BDMUserRestrictions ()

@property (nonatomic, copy) NSString *userDefaultsConsentString;
@property (nonatomic, copy) NSString *publisherDefinedConsentString;
@property (nonatomic, assign) BOOL userDefaultsSubjectToGDPR;
@property (nonatomic, assign) BOOL publisherDefinedSubjectToGDPR;

@end

@implementation BDMUserRestrictions

- (instancetype)init {
    self = [super init];
    if (self) {
        self.userDefaultsSubjectToGDPR = [NSUserDefaults.standardUserDefaults boolForKey:@"IABConsent_SubjectToGDPR"];
        self.userDefaultsConsentString = [NSUserDefaults.standardUserDefaults objectForKey:@"IABConsent_ConsentString"];
        self.coppa = NO;
        [self observeUserDefaults];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)observeUserDefaults {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDefaultsDidChangeNotification:)
                                                 name:NSUserDefaultsDidChangeNotification
                                               object:nil];
}

- (void)userDefaultsDidChangeNotification:(NSNotification *)notification {
    NSUserDefaults *defaults = (NSUserDefaults *)[notification object];
    self.userDefaultsSubjectToGDPR = [defaults boolForKey:@"IABConsent_SubjectToGDPR"];
    self.userDefaultsConsentString = [defaults objectForKey:@"IABConsent_ConsentString"];
}

- (void)setConsentString:(NSString *)consentString {
    self.publisherDefinedConsentString = consentString;
}

- (void)setSubjectToGDPR:(BOOL)subjectToGDPR {
    self.publisherDefinedSubjectToGDPR = subjectToGDPR;
}

- (NSString *)consentString {
    return self.publisherDefinedConsentString ?: self.userDefaultsConsentString;
}

- (BOOL)subjectToGDPR {
    return self.publisherDefinedSubjectToGDPR || self.userDefaultsSubjectToGDPR;
}

- (BOOL)allowUserInformation {
    return !self.coppa && (!self.subjectToGDPR || self.hasConsent);
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (id)copyWithZone:(NSZone *)zone {
    BDMUserRestrictions *restrictionsCopy = [BDMUserRestrictions new];
    
    restrictionsCopy.publisherDefinedConsentString  = self.publisherDefinedConsentString;
    restrictionsCopy.publisherDefinedSubjectToGDPR  = self.publisherDefinedSubjectToGDPR;
    restrictionsCopy.coppa                          = self.coppa;
    restrictionsCopy.hasConsent                     = self.hasConsent;
    
    return restrictionsCopy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.publisherDefinedConsentString forKey:@"consentString"];
    [aCoder encodeBool:self.publisherDefinedSubjectToGDPR forKey:@"subjectToGDPR"];
    [aCoder encodeBool:self.coppa forKey:@"coppa"];
    [aCoder encodeBool:self.hasConsent forKey:@"hasConsent"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.publisherDefinedConsentString   = [aDecoder decodeObjectForKey:@"consentString"];
        self.publisherDefinedSubjectToGDPR   = [aDecoder decodeBoolForKey:@"subjectToGDPR"];
        self.coppa                           = [aDecoder decodeBoolForKey:@"coppa"];
        self.hasConsent                      = [aDecoder decodeBoolForKey:@"hasConsent"];
    }
    return self;
}

@end
