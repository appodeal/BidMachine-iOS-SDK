//
//  BDMRequestBuilder.m
//
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import "BDMAuctionBuilder.h"
#import "BDMTransformers.h"
#import "BDMSdk+Project.h"

#import "BDMProtoAPI-Umbrella.h"
#import <ASKExtension/ASKExtension.h>


@interface BDMAuctionBuilder ()

@property (nonatomic, strong) BDMRequest * request;
@property (nonatomic, strong) id<BDMAuctionSettings> auctionSettings;
@property (nonatomic, assign) BOOL testMode;
@property (nonatomic, copy) NSString * sellerID;
@property (nonatomic, strong) id<BDMPlacementRequestBuilder> placementBuilder;
@property (nonatomic, strong) BDMUserRestrictions *restrictions;

@end

@implementation BDMAuctionBuilder

- (BDMAuctionBuilder *(^)(BDMRequest *))appendRequest {
    return ^id(BDMRequest *request) {
        self.request = request;
        return self;
    };
}

- (BDMAuctionBuilder *(^)(NSString *))appendSellerID {
    return ^id(NSString * sellerID) {
        self.sellerID = sellerID;
        return self;
    };
}

- (BDMAuctionBuilder *(^)(id<BDMAuctionSettings>))appendAuctionSettings {
    return ^id(id<BDMAuctionSettings> auctionSettings) {
        self.auctionSettings = auctionSettings;
        return self;
    };
}

- (BDMAuctionBuilder *(^)(id<BDMPlacementRequestBuilder>))appendPlacementBuilder {
    return ^id(id<BDMPlacementRequestBuilder> plcBuilder) {
        self.placementBuilder = plcBuilder;
        return self;
    };
}

- (BDMAuctionBuilder *(^)(BOOL))appendTestMode {
    return ^id(BOOL testMode) {
        self.testMode = testMode;
        return self;
    };
}

- (BDMAuctionBuilder *(^)(BDMUserRestrictions *))appendRestrictions {
    return ^id(BDMUserRestrictions * restrictions) {
        self.restrictions = restrictions;
        return self;
    };
}

- (GPBMessage *)message {
    ORTBOpenrtb *openRtbMessage = [ORTBOpenrtb message];
    openRtbMessage.ver         = self.auctionSettings.protocolVersion;
    openRtbMessage.domainspec  = self.auctionSettings.domainSpec;
    openRtbMessage.domainver   = self.auctionSettings.domainVersion;
    openRtbMessage.request     = ({
        ORTBRequest *requestMessage    = [ORTBRequest message];
        requestMessage.test            = self.testMode;
        requestMessage.tmax            = self.auctionSettings.tmax;
        requestMessage.at              = self.auctionSettings.auctionType;
        requestMessage.curArray        = [NSMutableArray arrayWithObject:self.auctionSettings.auctionCurrency];
        // Setup context
        requestMessage.context         = self.adcomContextMessage;
        // Setup items
        requestMessage.itemArray       = self.requestItemsMessage;
        // Setup extensions
        requestMessage.extArray        = self.requestExtensionsMessage;
        requestMessage;
    });
    
    BOOL isGDPRRestricted = self.restrictions.subjectToGDPR && !self.restrictions.hasConsent;
    BOOL isCoppa = self.restrictions.coppa;
    
    if (isGDPRRestricted || isCoppa) {
         openRtbMessage = [self restrictOpenRtbMessage:openRtbMessage gdpr:isGDPRRestricted coppa:isCoppa];
    }
    
    return openRtbMessage;
}

#pragma mark - Private

- (ORTBOpenrtb *)restrictOpenRtbMessage:(ORTBOpenrtb *)message
                                   gdpr:(BOOL)gdp
                                  coppa:(BOOL)coppa
{
    NSDictionary *baseRestrictedPath = @{@"gender"      : @"user.gender",
                                         @"yob"         : @"user.yob",
                                         @"keywords"    : @"user.keywords",
                                         @"userId"      : @"user.id_p",
                                         @"country"     : @"user.geo",
                                         @"city"        : @"user.geo",
                                         @"zip"         : @"user.geo",
                                         
                                         @"lat"         : @"device.geo.lat",
                                         @"lon"         : @"device.geo.lon",
                                         @"accur"       : @"device.geo.accur",
                                         @"lastfix"     : @"device.geo.lastfix",
                                         @"type"        : @"device.geo.type"
                                         };
    
    NSDictionary *coppaAdditionalRestrictedPath = @{@"contype"     : @"device.contype",
                                                    @"mccmnc"      : @"device.mccmnc",
                                                    @"carrier"     : @"device.carrier",
                                                    @"hwv"         : @"device.hwv",
                                                    @"make"        : @"device.make",
                                                    @"model"       : @"device.model",
                                                    @"lang"        : @"device.lang",
                                                    };
   
    
    NSMutableDictionary *restrictedPath = [NSMutableDictionary dictionary];
    if (gdp || coppa) {
        [restrictedPath addEntriesFromDictionary:baseRestrictedPath];
    }
    
    if (coppa) {
        [restrictedPath addEntriesFromDictionary:coppaAdditionalRestrictedPath];
    }
    
    NSError *error = nil;
    ADCOMContext *context = [[ADCOMContext alloc] initWithData:message.request.context.value error:&error];
    
    if (!error) {
        [restrictedPath enumerateKeysAndObjectsUsingBlock:^(NSString  *key, NSString *path, BOOL * _Nonnull stop) {
            id message = [context ask_valueForKeyPath:path];
            if (GPBMessage.ask_isValid(message)) {
                [message clear];
            }
            else if (NSString.ask_isValid(message)) {
                [context setValue:nil forKeyPath:path];
            }
            else if (NSNumber.ask_isValid(message)) {
                [context setValue:@0 forKeyPath:path];
            }
        }];
        message.request.context = [GPBAny anyWithMessage:context error:nil];
    }
    
    return message;
}

- (NSMutableArray <GPBAny *> *)requestExtensionsMessage {
    NSMutableArray <GPBAny *> * extensions = [NSMutableArray arrayWithCapacity:1];
    BDMRequestExtension * ext = [BDMRequestExtension message];
    ext.sellerId = self.sellerID;
    GPBAny * extAny = [[GPBAny alloc] initWithMessage:ext error:nil];
    extAny ? [extensions addObject:extAny] : nil;
    return extensions;
}

#pragma mark - Item

- (NSMutableArray <ORTBRequest_Item *> *)requestItemsMessage {
    NSArray <BDMPriceFloor *> * pricefloors = self.request.priceFloors.count ? self.request.priceFloors : @[BDMPriceFloor.new]; // Use default pricfloor
    ORTBRequest_Item *itemMessage   = [ORTBRequest_Item message];
    itemMessage.qty                 = 1;
    itemMessage.id_p                = NSUUID.UUID.UUIDString; // For Parallel Bidding it should be ad unit id
    itemMessage.spec                = self.adcomPlacementMessage;
    itemMessage.dealArray           = pricefloors.ask_transform(^ORTBRequest_Item_Deal *(BDMPriceFloor * floor, NSUInteger idx) {
        ORTBRequest_Item_Deal * deal = ORTBRequest_Item_Deal.message;
        deal.id_p   = floor.ID;
        deal.flr    = floor.value.doubleValue;
        deal.flrcur = self.auctionSettings.auctionCurrency;
        return deal;
    }).mutableCopy;
    return [NSMutableArray arrayWithObject:itemMessage];
}

#pragma mark - ADCOM Placements

- (GPBAny *)adcomPlacementMessage {
    ADCOMPlacement * placement = (ADCOMPlacement *)self.placementBuilder.placement;
    GPBAny *placementMessageAny = [GPBAny anyWithMessage:placement error:nil];
    return placementMessageAny;
}

#pragma mark - ADCOM Context

- (GPBAny *)adcomContextMessage {
    ADCOMContext *contextMessage   = [ADCOMContext message];
    
    contextMessage.restrictions = ({
        ADCOMContext_Restrictions *restrictions = [ADCOMContext_Restrictions message];
        restrictions.bcatArray = self.request.targeting.blockedCategories.mutableCopy;
        restrictions.badvArray = self.request.targeting.blockedAdvertisers.mutableCopy;
        restrictions.bappArray = self.request.targeting.blockedApps.mutableCopy;
        restrictions;
    });
    
    contextMessage.app             = self.adcomContextAppMessage;
    contextMessage.device          = self.adcomContextDeviceMessage;
    contextMessage.user            = self.adcomContextUserMessage;
    contextMessage.regs            = self.adcomContextRegsMessage;
    
    GPBAny * contextMessageAny = [GPBAny anyWithMessage:contextMessage error:nil];
    return contextMessageAny;
}

- (ADCOMContext_App *)adcomContextAppMessage {
    ADCOMContext_App *app = [ADCOMContext_App message];
    app.storeid     = self.request.targeting.storeId;
    app.storeurl    = self.request.targeting.storeURL.absoluteString;
    app.paid        = self.request.targeting.paid;
    app.bundle      = ask_bundle();
    app.ver         = ask_appVersion();
    app.name        = [NSBundle.mainBundle objectForInfoDictionaryKey:(NSString *)kCFBundleNameKey];
    return app;
}

- (ADCOMContext_Device *)adcomContextDeviceMessage {
    ADCOMContext_Device *device = [ADCOMContext_Device message];
    device.type     = BDMTransformers.deviceType(ask_deviceType());
    device.ua       = ask_userAgent();
    device.lmt      = !ask_advertisingTrackingEnabled();
    device.contype  = BDMTransformers.connectionType(ask_connectionTypeString());
    device.mccmnc   = ask_mccmnc();
    device.carrier  = ask_carrierName();
    device.w        = ask_screenWidth() * ask_screenRatio();
    device.h        = ask_screenHeight() * ask_screenRatio();
    device.ppi      = ask_screenPpi();
    device.pxratio  = ask_screenRatio();
    device.os       = BDMTransformers.osType(ask_deviceOs());
    device.osv      = ask_deviceOsVersion();
    device.hwv      = ask_hardwareVersion();
    device.make     = ask_deviceMaker();
    device.model    = ask_deviceName();
    device.lang     = ask_deviceLanguage();
    device.geo      = BDMTransformers.geoMessage(self.request.targeting.deviceLocation);
    
    if (self.restrictions.subjectToGDPR && !self.restrictions.hasConsent) {
        device.ifa = @"00000000-0000-0000-0000-000000000000";
    } else {
        device.ifa = ask_advertisingID();
    }
    
    return device;
}

- (ADCOMContext_User *)adcomContextUserMessage {
    ADCOMContext_User *user = [ADCOMContext_User message];
    user.gender     = BDMTransformers.gender(self.request.targeting.gender);
    user.yob        = self.request.targeting.yearOfBirth.unsignedIntValue;
    user.keywords   = self.request.targeting.keywords;
    user.id_p       = self.request.targeting.userId;
    user.consent    = self.restrictions.consentString;
    user.geo = ({
        ADCOMContext_Geo *geo = [ADCOMContext_Geo message];
        geo.country = self.request.targeting.country;
        geo.city    = self.request.targeting.city;
        geo.zip     = self.request.targeting.zip;
        geo;
    });
    return user;
}

- (ADCOMContext_Regs *)adcomContextRegsMessage {
    ADCOMContext_Regs *regs = [ADCOMContext_Regs message];
    
    regs.coppa = self.restrictions.coppa;
    regs.gdpr = self.restrictions.subjectToGDPR;
    
    return regs;
}

@end
