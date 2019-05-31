//
//  BDMUserRestrictions.m
//  BidMachine
//
//  Created by Stas Kochkin on 08/11/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import "BDMUserRestrictions.h"

@implementation BDMUserRestrictions

- (instancetype)init {
    self = [super init];
    if (self) {
        self.coppa = NO;
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (id)copyWithZone:(NSZone *)zone {
    BDMUserRestrictions * restrictionsCopy = [BDMUserRestrictions new];
    
    restrictionsCopy.consentString  = self.consentString;
    restrictionsCopy.subjectToGDPR  = self.subjectToGDPR;
    restrictionsCopy.coppa          = self.coppa;
    restrictionsCopy.hasConsent     = self.hasConsent;
    
    return restrictionsCopy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.consentString forKey:@"consentString"];
    [aCoder encodeBool:self.subjectToGDPR forKey:@"subjectToGDPR"];
    [aCoder encodeBool:self.coppa forKey:@"coppa"];
    [aCoder encodeBool:self.hasConsent forKey:@"hasConsent"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.consentString   = [aDecoder decodeObjectForKey:@"consentString"];
        self.subjectToGDPR   = [aDecoder decodeBoolForKey:@"subjectToGDPR"];
        self.coppa           = [aDecoder decodeBoolForKey:@"coppa"];
        self.hasConsent      = [aDecoder decodeBoolForKey:@"hasConsent"];
    }
    return self;
}

@end
