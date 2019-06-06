//
//  BDMTransformers.h
//
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "BDMProtoAPI-Umbrella.h"
#import "BDMTargeting.h"
#import "BDMEventURL.h"


@interface BDMTransformers : NSObject

+ (ADCOMDeviceType(^)(UIUserInterfaceIdiom))deviceType;

+ (ADCOMConnectionType(^)(NSString *))connectionType;

+ (ADCOMOS(^)(NSString *))osType;

+ (NSString *(^)(BDMUserGender *))gender;

+ (ADCOMContext_Geo *(^)(CLLocation * userProvidedLocation))geoMessage;

+ (NSArray <BDMEventURL *> *(^)(NSArray <ADCOMAd_Event *> *))eventURLs;

@end
