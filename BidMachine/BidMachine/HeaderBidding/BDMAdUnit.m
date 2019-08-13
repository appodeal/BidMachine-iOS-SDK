//
//  BDMAdUnit.m
//  BidMachine
//
//  Created by Stas Kochkin on 18/07/2019.
//  Copyright © 2019 Appodeal. All rights reserved.
//

#import "BDMAdUnit.h"


@interface BDMAdUnit ()

@property (nonatomic, assign, readwrite) BDMAdUnitFormat format;
@property (nonatomic, copy,   readwrite) NSDictionary <NSString *, id> *customParams;

@end


@implementation BDMAdUnit

- (instancetype)initWithFormat:(BDMAdUnitFormat)format
                  customParams:(NSDictionary<NSString *,id> *)customParams {
    if (self = [super init]) {
        self.format = format;
        self.customParams = customParams;
    }
    return self;
}

+ (instancetype)adUnitWithFormat:(BDMAdUnitFormat)type customParams:(NSDictionary<NSString *,id> *)customParams {
    return [[self alloc] initWithFormat:type customParams:customParams];
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInteger:self.format forKey:@"format"];
    [aCoder encodeObject:self.customParams forKey:@"params"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    BDMAdUnitFormat format = [aDecoder decodeIntegerForKey:@"format"];
    NSDictionary *params = [aDecoder decodeObjectForKey:@"params"];
    
    return [self initWithFormat:format customParams:params];
}

- (id)copyWithZone:(nullable NSZone *)zone {
    return [[self.class alloc] initWithFormat:self.format customParams:self.customParams];;
}

- (BOOL)isEqual:(id)object {
    return [object isKindOfClass:BDMAdUnit.class] &&
    [(BDMAdUnit *)object format] == self.format &&
    [[(BDMAdUnit *)object customParams] isEqual:self.customParams];
}

@end

