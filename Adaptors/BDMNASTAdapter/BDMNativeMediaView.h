//
//  BDMInternalMediaView.h
//
//  Copyright © 2016 Appodeal, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BDMNativeMediaView : UIView

@property (nonatomic, strong) NSURL *videoUrl;
@property (nonatomic, strong) NSURL *placeholderURL;
@property (nonatomic,   weak) UIViewController *controller;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (void)render;

@end
