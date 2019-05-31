//
//  BDMAuctionSettingsSpec.m
//  BidMachineKiwiTests
//
//  Created by Yaroslav Skachkov on 11/26/18.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <Foundation/Foundation.h>

#import "BDMAuctionSettings.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <AdSupport/AdSupport.h>
#import <ASKExtension/ASKExtension.h>

SPEC_BEGIN(BDMAuctionSettingsSpec)

describe(@"BDMAuctionSettingsSpec", ^{
    
    __block BDMOpenRTBAuctionSettings <BDMAuctionSettings> * openRTBAuctionSettings;
    
    beforeEach(^{
        openRTBAuctionSettings = BDMOpenRTBAuctionSettings.new;
    });
    
    it(@"should return constants", ^{
        [[[openRTBAuctionSettings domainSpec] should] equal:@"adcom"];
        [[[openRTBAuctionSettings domainVersion] should] equal:@"1.0"];
        [[[openRTBAuctionSettings protocolVersion] should] equal:@"3.0"];
        [[[openRTBAuctionSettings auctionCurrency] should] equal:@"USD"];
        [[theValue([openRTBAuctionSettings tmax]) should] equal:theValue(10000)];
        [[theValue([openRTBAuctionSettings auctionType]) should] equal:theValue(BDMAuctionTypeSecondPrice)];
    });
});

SPEC_END
