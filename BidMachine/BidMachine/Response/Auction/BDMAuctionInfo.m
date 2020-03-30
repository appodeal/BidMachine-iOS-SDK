//
//  BDMAuctionInfo.m
//  BidMachine
//
//  Created by Stas Kochkin on 22/10/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import "BDMAuctionInfo.h"
#import "BDMAuctionInfo+Project.h"


@interface BDMAuctionInfo ()

@property (nonatomic, copy, readwrite, nullable) NSString * bidID;
@property (nonatomic, copy, readwrite, nullable) NSString * creativeID;
@property (nonatomic, copy, readwrite, nullable) NSString * cID;
@property (nonatomic, copy, readwrite, nullable) NSString * dealID;
@property (nonatomic, copy, readwrite, nullable) NSArray <NSString *> * adDomains;
@property (nonatomic, copy, readwrite, nullable) NSString * demandSource;
@property (nonatomic, copy, readwrite, nullable) NSNumber * price;
@property (nonatomic, assign, readwrite) BDMCreativeFormat format;

@end

@implementation BDMAuctionInfo

- (instancetype)initWithResponse:(id<BDMResponse>)response {
    if (self = [super init]) {
        self.bidID          = response.identifier;
        self.demandSource   = response.demandSource;
        self.price          = response.price;
        self.cID            = response.cid;
        self.dealID         = response.deal;
        self.creativeID     = response.creative.ID;
        self.adDomains      = response.creative.adDomains;
        self.format         = response.creative.format;
    }
    return self;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    BDMAuctionInfo * copy = [BDMAuctionInfo new];
    copy.bidID          = self.bidID;
    copy.creativeID     = self.creativeID;
    copy.demandSource   = self.demandSource;
    copy.price          = self.price;
    copy.cID            = self.cID;
    copy.dealID         = self.dealID;
    copy.adDomains      = self.adDomains;
    copy.format         = self.format;
    return copy;
}

@end
