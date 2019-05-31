//
//  BDMSessionBuilder.m
//
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import "BDMSessionBuilder.h"
#import "BDMProtoAPI-Umbrella.h"
#import "BDMTransformers.h"
#import "BDMSdk+Project.h"
#import <ASKExtension/ASKExtension.h>


@interface BDMSessionBuilder ()

@property (nonatomic, copy) NSString * sellerID;
@property (nonatomic, copy) BDMTargeting * targeting;

@end

@implementation BDMSessionBuilder

- (BDMSessionBuilder *(^)(NSString *))appendSellerID {
    return ^id(NSString * sellerID) {
        self.sellerID = sellerID;
        return self;
    };
}

- (BDMSessionBuilder *(^)(BDMTargeting *))appendTargeting {
    return ^id(BDMTargeting * targeting) {
        self.targeting = targeting;
        return self;
    };
}

- (GPBMessage *)message {
    BDMInitRequest * requestMessage = BDMInitRequest.message;
    requestMessage.sellerId = self.sellerID;
    requestMessage.bundle = ask_bundle();
    requestMessage.os = BDMTransformers.osType(ask_deviceOs());
    requestMessage.osv = ask_deviceOsVersion();
    requestMessage.sdk = @"BidMachine";
    requestMessage.sdkver = kBDMVersion;
    requestMessage.geo = self.geoMessage;
    return requestMessage;
}

- (ADCOMContext_Geo *)geoMessage {
    ADCOMContext_Geo * geoMessage;
    BOOL isGDPRRestricted = BDMSdk.sharedSdk.restrictions.subjectToGDPR && !BDMSdk.sharedSdk.restrictions.hasConsent;
    BOOL isCoppa = BDMSdk.sharedSdk.restrictions.coppa;
    BOOL shouldRestictGeoData = isGDPRRestricted || isCoppa;
    
    if (shouldRestictGeoData) {
        geoMessage = ADCOMContext_Geo.message;
    } else {
        geoMessage = BDMTransformers.geoMessage(self.targeting.deviceLocation);
        geoMessage.country = self.targeting.country;
        geoMessage.city    = self.targeting.city;
        geoMessage.zip     = self.targeting.zip;
    }
    
    geoMessage.utcoffset = ask_utc();
    
    return geoMessage;
}

@end
