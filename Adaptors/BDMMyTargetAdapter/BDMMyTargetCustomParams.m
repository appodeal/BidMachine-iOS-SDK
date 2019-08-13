//
//  BDMMyTargetCustomParams.m
//  BDMMyTargetAdapter
//
//  Created by Stas Kochkin on 19/07/2019.
//  Copyright © 2019 Stas Kochkin. All rights reserved.
//

#import "BDMMyTargetCustomParams.h"

@implementation BDMMyTargetCustomParams

+ (void)populate:(MTRGCustomParams *)params {
    if (BDMSdk.sharedSdk.restrictions.allowUserInformation) {
        BDMTargeting *targeting = BDMSdk.sharedSdk.configuration.targeting;
        if ([targeting.gender isEqualToString:kBDMUserGenderMale]) {
            [params setGender:MTRGGenderMale];
        } else if ([targeting.gender isEqualToString:kBDMUserGenderFemale]) {
            [params setGender:MTRGGenderFemale];
        }
    }
}

@end
