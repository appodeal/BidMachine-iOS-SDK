//
//  DSKVastExtentionModel.m
//  OpenBids
//
//  Created by Lozhkin Ilya on 8/3/17.
//  Copyright © 2017 OpenBids, Inc. All rights reserved.
//

#import "DSKVASTExtensionModel.h"

@implementation DSKVASTExtensionModel

+ (NSDictionary *)DSK_xmlModel{
    return @{@"typeName"            : @"attr_type",
             @"ctaText"             : @"CtaText",
             @"ctaShow"             : @"ShowCta",
             @"muteShow"            : @"ShowMute",
             @"progressShow"        : @"ShowProgress",
             @"videoClickable"      : @"VideoClickable",
             @"companionShow"       : @"ShowCompanion",
             @"companionCloseTime"  : @"CompanionCloseTime",
             @"assetStrokeColor"    : @"AssetsColor",
             @"assetFillColor"      : @"AssetsBackgroundColor",
             @"ctaXPosition"        : @"CtaXPosition",
             @"ctaYPosition"        : @"CtaYPosition",
             @"muteXPosition"       : @"MuteXPosition",
             @"muteYPosition"       : @"MuteYPosition",
             @"closeXPosition"      : @"CloseXPosition",
             @"closeYPosition"      : @"CloseYPosition",
             @"companion"           : @"Companion"};
}

@end
