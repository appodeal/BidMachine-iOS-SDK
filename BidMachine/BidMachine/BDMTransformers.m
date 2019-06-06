//
//  BDMTransformers.m
//
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import "BDMTransformers.h"
#import <ASKExtension/ASKExtension.h>

@implementation BDMTransformers

+ (ADCOMDeviceType (^)(UIUserInterfaceIdiom))deviceType {
    return ^ADCOMDeviceType (UIUserInterfaceIdiom type){
        return type == UIUserInterfaceIdiomPad ? ADCOMDeviceType_DeviceTypeTablet : ADCOMDeviceType_DeviceTypePhoneDevice;
    };
}

+ (ADCOMConnectionType (^)(NSString *))connectionType {
    return ^ADCOMConnectionType (NSString *connectionType){
        return ASKObj(@{@"other"  : @(ADCOMConnectionType_ConnectionTypeInvalid),
                        @"wifi"   : @(ADCOMConnectionType_ConnectionTypeWifi),
                        @"mobile" : @(ADCOMConnectionType_ConnectionTypeCellularNetworkUnknown)
                        })
        .from(connectionType)
        .number
        .unsignedIntValue;
    };
}

+ (ADCOMOS (^)(NSString *))osType {
    return ^ADCOMOS (NSString *type){
        return ADCOMOS_OsIos;
    };
}

+ (NSString *(^)(BDMUserGender *))gender {
    return ^NSString *(BDMUserGender * gender){
        return ASKObj(@{kBDMUserGenderMale     : @"M",
                        kBDMUserGenderFemale   : @"F",
                        kBDMUserGenderUnknown  : @"O"
                        })
        .from(gender)
        .string;
    };
}

+ (ADCOMContext_Geo *(^)(CLLocation *))geoMessage {
    return ^ADCOMContext_Geo *(CLLocation * userProvidedLocation) {
        ADCOMContext_Geo *geo = [ADCOMContext_Geo message];
        
        geo.utcoffset = ask_utc();
        ADCOMLocationType type = ADCOMLocationType_LocationTypeInvalid;
        
        CLLocation * deviceLocation = ask_currentLocation();
        CLLocation * desiredLocation;
        
        if (userProvidedLocation && deviceLocation) {
            NSComparisonResult comrasionResult = [userProvidedLocation.timestamp compare:deviceLocation.timestamp];
            if (comrasionResult == NSOrderedAscending) {
                type = ADCOMLocationType_LocationTypeUser;
                desiredLocation = userProvidedLocation;
            } else {
                type = ADCOMLocationType_LocationTypeGps;
                desiredLocation = deviceLocation;
            }
        } else if (deviceLocation) {
            type = ADCOMLocationType_LocationTypeGps;
            desiredLocation = deviceLocation;
        } else {
            type = ADCOMLocationType_LocationTypeUser;
            desiredLocation = userProvidedLocation;
        }
        
        if (desiredLocation) {
            geo.type = type;
            geo.lastfix = desiredLocation.timestamp.timeIntervalSince1970;
            geo.accur = desiredLocation.horizontalAccuracy;
            geo.lat = desiredLocation.coordinate.latitude;
            geo.lon = desiredLocation.coordinate.longitude;
        }
        return geo;
    };
}

+ (NSArray <BDMEventURL *> *(^)(NSArray <ADCOMAd_Event *> *))eventURLs {
    return ^id(NSArray <ADCOMAd_Event *> *events) {
        if (!events.count) {
            return @[];
        }
        
        NSArray <BDMEventURL *> *trackers = events.ask_transform(^id(ADCOMAd_Event * event, NSUInteger idx){
            if (!event.URL.length) {
                return nil;
            }
            
            int32_t rawType = ADCOMAd_Event_Type_RawValue(event);
            if (!BDMEventTypeExtended_IsValidValue(rawType)) {
                return nil;
            }
            
            BDMEventURL * tracker = [BDMEventURL trackerWithStringURL:event.URL type:rawType];
            return tracker;
        });
        return trackers;
    };
}

@end
