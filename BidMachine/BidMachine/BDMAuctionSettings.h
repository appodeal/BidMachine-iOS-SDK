//
//  BDMDefaultDefines.h
//
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, BDMAuctionType) {
    BDMAuctionTypeFirstPrice = 1,
    BDMAuctionTypeSecondPrice
};

@protocol BDMAuctionSettings <NSObject>

@property (nonatomic, copy, readonly) NSString *domainSpec;
@property (nonatomic, copy, readonly) NSString *domainVersion;
@property (nonatomic, copy, readonly) NSString *protocolVersion;
@property (nonatomic, copy, readonly) NSString *auctionCurrency;

@property (nonatomic, assign, readonly) NSTimeInterval tmax;
@property (nonatomic, assign, readonly) BDMAuctionType auctionType;

@end

@interface BDMOpenRTBAuctionSettings : NSObject <BDMAuctionSettings>

@property (nonatomic, strong) NSString *auctionURL;

+ (BDMOpenRTBAuctionSettings *)defaultAuctionSettings;

@end
