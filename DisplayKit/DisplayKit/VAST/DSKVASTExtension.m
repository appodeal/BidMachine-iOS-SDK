//
//  DSKVASTExtension.m
//  OpenBids

//  Copyright © 2016 OpenBids, Inc. All rights reserved.
//

#import "DSKVASTExtension.h"
#import <ASKExtension/NSObject+ASKExtension.h>
#import "NSString+DSKExtensions.h"
#import <ASKExtension/UIColor+ASKExtension.h>

//`CtaText` - текст CTA, по умолчанию "Learn more"
//`ShowCta` - показывать CTA, по умолчанию true
//`ShowMute` - показывать кнопку mute/unmute, по умолчанию true
//`ShowCompanion`- показывать компанион, по умолчанию true
//`VideoClickable`- все видео кликабельно, по умолчанию false
//`CtaXPosition` - положение CTA по горизонтали, по умолчанию RIGHT (возможные значения left/right/center)
//`CtaYPosition` - положение CTA закрытия по вертикали, по умолчанию BOTTOM (возможные значения top/bottom/center)
//`CloseXPosition` - положение таймера и кнопки закрытия по горизонтали, по умолчанию RIGHT (возможные значения left/right/center)
//`CloseYPosition` - положение таймера и кнопки закрытия по вертикали, по умолчанию TOP (возможные значения top/bottom/center)
//`MuteXPosition`- положение кнопки mute/unmute по горизонтали, по умолчанию LEFT (возможные значения left/right/center)
//`MuteYPosition` - положение кнопки mute/unmute по вертикали, по умолчанию TOP (возможные значения top/bottom/center)
//`AssetsColor` - цвет элементов управления, по умолчанию #C8FFFFFF;
//`AssetsBackgroundColor` - цвет фона элементов управления, Color.TRANSPARENT;
//`Companion` - возможность заменить CTA на VAST companion, спецификация аналогична vast companions.

@interface DSKVASTExtension ()

@property (nonatomic, strong) DSKVASTExtensionModel * extensionModel;

@end

@implementation DSKVASTExtension

+ (DSKVASTExtension *)extensionFromModel:(DSKVASTExtensionModel *)extentionModel {
    if (!extentionModel) {
        return nil;
    }
    
    DSKVASTExtension * _instance = [DSKVASTExtension new];
    _instance.extensionModel = extentionModel;
    
    _instance->_companion = [DSKVASTCompanion companionFromModel:extentionModel.companion];
    
    return _instance;
}

- (NSString *)callToActionText{
    return self.extensionModel.ctaText ? : @"Learn more";
}

- (BOOL)ctaEnabled{
    return self.extensionModel.ctaShow ? [self.extensionModel.ctaShow boolValue] : YES;
}

- (BOOL)muteEnabled{
    return self.extensionModel.muteShow ? [self.extensionModel.muteShow boolValue] : YES;
}

- (BOOL)companionEnabled{
    return self.extensionModel.companionShow ? [self.extensionModel.companionShow boolValue] : YES;
}

- (BOOL)progressBarEnabled{
    return self.extensionModel.progressShow ? [self.extensionModel.progressShow boolValue] : YES;
}

- (BOOL)videoClickable{
    return self.extensionModel.videoClickable ? [self.extensionModel.videoClickable boolValue] : NO;
}

- (NSNumber *)companionCloseTime{
    if (!self.extensionModel.companionCloseTime) {
        return nil;
    }
    return @([self.extensionModel.companionCloseTime DSK_timeInterval]);
}

- (DSKConstraintMaker *)ctaPosition{
    return [DSKConstraintMaker constraintMakerFromString:self.extensionModel.ctaXPosition
                                               yPozition:self.extensionModel.ctaYPosition
                                            xDefPozition:@"right"
                                            yDefPozition:@"bottom"];
}

- (DSKConstraintMaker *)closePosition{
    return [DSKConstraintMaker constraintMakerFromString:self.extensionModel.closeXPosition
                                               yPozition:self.extensionModel.closeYPosition
                                            xDefPozition:@"right"
                                            yDefPozition:@"top"];
}

- (DSKConstraintMaker *)mutePosition{
    return [DSKConstraintMaker constraintMakerFromString:self.extensionModel.muteXPosition
                                               yPozition:self.extensionModel.muteYPosition
                                            xDefPozition:@"left"
                                            yDefPozition:@"top"];
}

- (UIColor *)assetStrokeColor{
    return [UIColor ask_colorFromHex:self.extensionModel.assetStrokeColor] ?: [UIColor ask_defaultStrokeColor];
}

- (UIColor *)assetFillColor{
    return [UIColor ask_colorFromHex:self.extensionModel.assetFillColor] ?: [UIColor ask_defaultFillColor];
}

@end
