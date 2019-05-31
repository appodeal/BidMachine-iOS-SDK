//
//  BDMDefaultDefines.m
//
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import "BDMAuctionSettings.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <AdSupport/AdSupport.h>
#import <ASKExtension/ASKExtension.h>

#define BDM_AUCTION_URL_KEY   "kBDMAuctonUrl"
#define BDM_AUCTION_URL       "https://api.appodealx.com/openrtb3/auction"

static NSString *carrierCode = nil;

@implementation BDMOpenRTBAuctionSettings

+ (BDMOpenRTBAuctionSettings *)defaultAuctionSettings {
    BDMOpenRTBAuctionSettings *settings = BDMOpenRTBAuctionSettings.new;
    
    settings.auctionURL = self.defaultAuctionURL;
    return settings;
}

- (NSString *)domainSpec {
    return @"adcom";
}

- (NSString *)domainVersion {
    return @"1.0";
}

- (NSString *)protocolVersion {
    return @"3.0";
}

- (NSString *)auctionCurrency {
    return @"USD";
}

- (NSTimeInterval)tmax {
    return 10000;
}

- (BDMAuctionType)auctionType {
    return BDMAuctionTypeSecondPrice;
}

- (void)setAuctionURL:(NSString *)auctionURL {
    if (auctionURL) {
        _auctionURL = auctionURL;
        [[NSUserDefaults standardUserDefaults] setObject:auctionURL forKey:@BDM_AUCTION_URL_KEY];
    }
}

#pragma mark - Private

+ (NSString *)defaultAuctionURL {
    NSString *cachedUrl = [[NSUserDefaults standardUserDefaults] stringForKey:@BDM_AUCTION_URL_KEY];
    return NSString.ask_isValid(cachedUrl) && cachedUrl.length ? cachedUrl : @BDM_AUCTION_URL;
}

@end
