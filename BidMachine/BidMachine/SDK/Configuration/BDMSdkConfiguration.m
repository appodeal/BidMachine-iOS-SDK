//
//  BDMSdkConfiguration.m
//  BidMachine
//
//  Created by Stas Kochkin on 03/10/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import "BDMSdkConfiguration.h"
#import "BDMSdkConfiguration+HeaderBidding.h"

#define BDM_INIT_REQUEST_ENDPOINT   @"https://api.appodealx.com"

@interface BDMSdkConfiguration ()

@property (copy, nonatomic, readwrite, nullable) NSArray <BDMAdNetworkConfiguration *> *networkConfigurations;
@property (copy, nonatomic, readwrite, nonnull) NSString *ssp;

@end

@implementation BDMSdkConfiguration

- (instancetype)init {
    if (self = [super init]) {
        self.ssp = @"appodeal";
    }
    return self;
}

- (NSURL *)baseURL {
    return _baseURL ?: [NSURL URLWithString:BDM_INIT_REQUEST_ENDPOINT];
}

- (id)copyWithZone:(NSZone *)zone {
    BDMSdkConfiguration * configurationCopy = [BDMSdkConfiguration new];
    
    configurationCopy.targeting             = self.targeting;
    configurationCopy.networkConfigurations = self.networkConfigurations;
    configurationCopy.testMode              = self.testMode;
    configurationCopy.ssp                   = self.ssp;
    configurationCopy.baseURL               = self.baseURL;
    
    return configurationCopy;
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.targeting forKey:@"targeting"];
    [aCoder encodeObject:self.networkConfigurations forKey:@"network_configurations"];
    [aCoder encodeBool:self.testMode forKey:@"test_mode"];
    [aCoder encodeObject:self.baseURL forKey:@"base_url"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.targeting             = [aDecoder decodeObjectForKey:@"targeting"];
        self.networkConfigurations = [aDecoder decodeObjectForKey:@"network_configurations"];
        self.testMode              = [aDecoder decodeBoolForKey:@"test_mode"];
        self.baseURL               = [aDecoder decodeObjectForKey:@"base_url"];
    }
    return self;
}

@end
