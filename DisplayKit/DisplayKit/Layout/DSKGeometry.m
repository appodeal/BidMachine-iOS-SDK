//
//  DSKGeometry.m
//  OpenBids
//
//  Created by Lozhkin Ilya on 8/5/17.
//  Copyright © 2017 OpenBids, Inc. All rights reserved.
//

#import "DSKGeometry.h"

#import <sys/utsname.h>

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

const DSKRect DSKRectZero = {.size = {.width = 0, .height = 0}, .origin = {.x = 0, .y = 0}, .cX = NO, .cY = NO};

#pragma mark - Interface orientation

UIInterfaceOrientation DSKCurrentInterfaceOrientation(){
    return [[UIApplication sharedApplication] statusBarOrientation];
}

NSString * DSKSystemDeviceName() {
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}

bool DSKIsSafeAreaLayoutGuideUntrasted(void) {
    BOOL potrait = UIInterfaceOrientationIsPortrait(UIApplication.sharedApplication.statusBarOrientation);
    BOOL aspectRatioIncorrect = NO;
    if (potrait) {
        aspectRatioIncorrect = (int)(UIScreen.mainScreen.bounds.size.height / 16) == (int)(UIScreen.mainScreen.bounds.size.width / 9);
    } else {
        aspectRatioIncorrect = (int)(UIScreen.mainScreen.bounds.size.height / 9) == (int)(UIScreen.mainScreen.bounds.size.width / 16);
    }
    
    return DSKCurrentDeviceIsiPhoneX() && aspectRatioIncorrect;
}

bool DSKCurrentDeviceIsiPhoneX() {
#if TARGET_IPHONE_SIMULATOR
    NSString * device = NSProcessInfo.processInfo.environment[@"SIMULATOR_MODEL_IDENTIFIER"];
#else
    NSString * device = DSKSystemDeviceName();
#endif
    return  [device isEqualToString:@"iPhone10,3"] ||
            [device isEqualToString:@"iPhone10,6"];
}

UIEdgeInsets DSKSafeArea() {
    UIEdgeInsets edgeInsets = UIEdgeInsetsZero;
#ifdef __IPHONE_11_0
    if (@available(iOS 11.0, *)) {
        UIWindow * keyWindow = [[UIApplication sharedApplication] keyWindow];
        edgeInsets = keyWindow.safeAreaInsets;
    }
#endif
    return edgeInsets;
}

bool DSKStatusBarUnhidden(){
    BOOL canBeHidden = NO;

    BOOL statusBarHidden = [[UIApplication sharedApplication] isStatusBarHidden];
    
    if (statusBarHidden) {
        canBeHidden = YES;
    } else {
        canBeHidden = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"UIViewControllerBasedStatusBarAppearance"] boolValue];
        
        if (SYSTEM_VERSION_LESS_THAN(@"9.0")) {
            canBeHidden = YES;
        }
    }
    
    return canBeHidden;
}

bool DSKSystemVersionIsiOS11(){
    return SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"11.0");
}
