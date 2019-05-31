//
//  BDMSdkConfiguration.m
//  BidMachine
//
//  Created by Stas Kochkin on 03/10/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import "BDMSdkConfiguration.h"

@interface BDMSdkConfiguration ()

@property (copy, nonatomic, readwrite, nullable) NSDictionary <NSString *, id> * extensions;

@end

@implementation BDMSdkConfiguration

- (id)copyWithZone:(NSZone *)zone {
    BDMSdkConfiguration * configurationCopy = [BDMSdkConfiguration new];
    
    configurationCopy.targeting           = self.targeting;
    configurationCopy.extensions          = self.extensions;
    configurationCopy.testMode            = self.testMode;
    
    return configurationCopy;
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.targeting forKey:@"targeting"];
    [aCoder encodeObject:self.extensions forKey:@"extensions"];
    [aCoder encodeBool:self.testMode forKey:@"testMode"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.targeting      = [aDecoder decodeObjectForKey:@"targeting"];
        self.extensions     = [aDecoder decodeObjectForKey:@"extensions"];
        self.testMode       = [aDecoder decodeBoolForKey:@"testMode"];
    }
    return self;
}

@end
