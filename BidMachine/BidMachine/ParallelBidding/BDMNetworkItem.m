//
//  BDMNetworkConfiguration.m
//  BidMachine
//
//  Created by Stas Kochkin on 09/11/2017.
//  Copyright © 2017 Appodeal. All rights reserved.
//

#import "BDMNetworkItem.h"

@interface BDMNetworkItem ()

@property (nonatomic, strong, readwrite) NSString * name;
@property (nonatomic, strong, readwrite) NSDictionary * parameters;
@property (nonatomic, strong, readwrite) NSString * identifier;
@property (nonatomic, strong, readwrite) NSDecimalNumber * eCPM;

@end

@implementation BDMNetworkItem

+ (instancetype)networkItemWithName:(NSString *)networkName
                         identifier:(NSString *)appodealIdentifier
                               eCPM:(NSDecimalNumber *)eCPM {
    
    return [self networkItemWithName:networkName
                  identifier:appodealIdentifier
                                eCPM:eCPM
                          parameters:nil];
}

+ (instancetype)networkItemWithName:(NSString *)networkName
                         identifier:(NSString *)appodealIdentifier
                               eCPM:(NSDecimalNumber *)eCPM
                         parameters:(NSDictionary *)parameters {
    BDMNetworkItem * item = [self new];
    item.name = networkName;
    item.identifier = appodealIdentifier;
    item.eCPM = eCPM;
    item.parameters = parameters;
    return item;
}

+ (instancetype)networkItemWithName:(NSString *)networkName
                         parameters:(NSDictionary *)parameters {
    return [self networkItemWithName:networkName
                          identifier:nil
                                eCPM:[NSDecimalNumber decimalNumberWithString:@"0.0"]
                          parameters:parameters];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    BDMNetworkItem * copy = [BDMNetworkItem networkItemWithName:self.name
                                                     identifier:self.identifier
                                                           eCPM:self.eCPM
                                                     parameters:self.parameters];
    return copy;
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.identifier forKey:@"identifier"];
    [aCoder encodeObject:self.parameters forKey:@"parameters"];
    [aCoder encodeObject:self.eCPM forKey:@"eCPM"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.identifier = [aDecoder decodeObjectForKey:@"identifier"];
        self.eCPM = [aDecoder decodeObjectForKey:@"eCPM"];
        self.parameters = [aDecoder decodeObjectForKey:@"parameters"];
    }
    return self;
}

@end
