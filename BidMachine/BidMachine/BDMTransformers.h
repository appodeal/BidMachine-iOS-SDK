//
//  BDMTransformers.h
//
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <StackFoundation/StackFoundation.h>

#import "BDMProtoAPI-Umbrella.h"
#import "BDMTargeting.h"
#import "BDMEventURL.h"
#import "BDMRequest+Private.h"
#import "BDMAdNetworkConfiguration.h"


@interface BDMTransformers : NSObject

+ (ADCOMDeviceType(^)(STKDeviceType))deviceType;

+ (ADCOMConnectionType(^)(NSString *))connectionType;

+ (ADCOMOS(^)(NSString *))osType;

+ (NSString *(^)(BDMUserGender *))gender;

+ (ADCOMContext_Geo *(^)(CLLocation * userProvidedLocation))geoMessage;

+ (NSArray <BDMEventURL *> *(^)(NSArray <ADCOMAd_Event *> *))eventURLs;

+ (NSDictionary <NSString *, NSString *> *(^)(NSMutableDictionary <NSString *, NSString *> *))jsonObject;

+ (NSMutableDictionary <NSString *, NSString *> *(^)(NSDictionary <NSString *, id> *))protobufMap;

+ (NSArray <BDMAdUnit *> *(^)(BDMAdNetworkConfiguration *, BDMInternalPlacementType))adUnits;

@end
