//
//  BDMTargeting.m
//  BidMachine
//
//  Created by Stas Kochkin on 03/10/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import "BDMTargeting.h"

@interface BDMTargeting ()

@end

@implementation BDMTargeting

- (instancetype)init {
    self = [super init];
    if (self) {
        self.gender = kBDMUserGenderUnknown;
        self.yearOfBirth = @(kBDMUndefinedYearOfBirth);
    }
    return self;
}

- (NSNumber *)userAge {
    NSInteger yob = self.yearOfBirth.unsignedIntegerValue;
    NSInteger age = 0;
    if (yob > 0) {
        NSCalendar *gregorian = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
        NSInteger year = [gregorian component:NSCalendarUnitYear fromDate:NSDate.date];
        age = year - yob;
    }
    return @(age);
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    BDMTargeting * targetingCopy = [BDMTargeting new];
    
    targetingCopy.userId                = self.userId;
    targetingCopy.gender                = self.gender;
    targetingCopy.yearOfBirth           = self.yearOfBirth;
    targetingCopy.keywords              = self.keywords;
    targetingCopy.blockedCategories     = self.blockedCategories;
    targetingCopy.blockedAdvertisers    = self.blockedAdvertisers;
    targetingCopy.blockedApps           = self.blockedApps;
    targetingCopy.deviceLocation              = self.deviceLocation;
    targetingCopy.country               = self.country;
    targetingCopy.city                  = self.city;
    targetingCopy.zip                   = self.zip;
    targetingCopy.paid                  = self.paid;
    targetingCopy.storeURL              = self.storeURL;
    targetingCopy.storeId               = self.storeId;
    
    return targetingCopy;
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.userId forKey:@"userId"];
    [aCoder encodeObject:self.gender forKey:@"gender"];
    [aCoder encodeObject:self.yearOfBirth forKey:@"yearOfBirth"];
    [aCoder encodeObject:self.keywords forKey:@"keywords"];
    [aCoder encodeObject:self.blockedCategories forKey:@"blockedCategories"];
    [aCoder encodeObject:self.blockedAdvertisers forKey:@"blockedAdvertisers"];
    [aCoder encodeObject:self.blockedApps forKey:@"blockedApps"];
    [aCoder encodeObject:self.deviceLocation forKey:@"location"];
    [aCoder encodeObject:self.country forKey:@"country"];
    [aCoder encodeObject:self.city forKey:@"city"];
    [aCoder encodeObject:self.zip forKey:@"zip"];
    [aCoder encodeObject:self.storeURL forKey:@"storeURL"];
    [aCoder encodeInteger:self.paid forKey:@"paid"];
    [aCoder encodeObject:self.storeId forKey:@"storeId"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.userId                = [aDecoder decodeObjectForKey:@"userId"];
        self.gender                = [aDecoder decodeObjectForKey:@"gender"];
        self.yearOfBirth           = [aDecoder decodeObjectForKey:@"yearOfBirth"];
        self.keywords              = [aDecoder decodeObjectForKey:@"keywords"];
        self.blockedCategories     = [aDecoder decodeObjectForKey:@"blockedCategories"];
        self.blockedAdvertisers    = [aDecoder decodeObjectForKey:@"blockedAdvertisers"];
        self.blockedApps           = [aDecoder decodeObjectForKey:@"blockedApps"];
        self.deviceLocation              = [aDecoder decodeObjectForKey:@"location"];
        self.country               = [aDecoder decodeObjectForKey:@"country"];
        self.city                  = [aDecoder decodeObjectForKey:@"city"];
        self.zip                   = [aDecoder decodeObjectForKey:@"zip"];
        self.storeURL              = [aDecoder decodeObjectForKey:@"storeURL"];
        self.paid                  = [aDecoder decodeIntegerForKey:@"paid"];
        self.storeId               = [aDecoder decodeObjectForKey:@"storeId"];
    }
    return self;
}

@end
