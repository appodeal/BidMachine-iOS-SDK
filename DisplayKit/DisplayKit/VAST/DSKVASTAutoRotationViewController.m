//
//  DSKVASTAutoRotationViewController.m
//  OpenBids

//  Copyright © 2017 OpenBids, Inc. All rights reserved.
//

#import "DSKVASTAutoRotationViewController.h"

#import "DSKGeometry.h"

@interface DSKVASTAutoRotationViewController ()

//@property (nonatomic, assign) float rotationAngle;
@property (nonatomic, assign) BOOL statusBarHiddenByDefault;

@end

@implementation DSKVASTAutoRotationViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self hideStatusBarIfNeeded];
    [self rotate:self.rotationAngle];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self showStatusBarIfNeeded];
    [self rotate:self.inversionRotationAngle];
}

- (BOOL)shouldAutorotate {
    return NO;
}

#pragma mark - Protected

- (float)inversionRotationAngle {
    return 360.0 - self.rotationAngle;
}

- (float)rotationAngle {
    float rotationAngle = 0.0;
    if ((self.currentDeviceOrientation == UIInterfaceOrientationLandscapeRight && !self.isEstimatedInterfaceOritentationInLandscape) ||
        (self.currentDeviceOrientation == UIInterfaceOrientationPortraitUpsideDown && self.isEstimatedInterfaceOritentationInLandscape)) {
        rotationAngle = 270.0;
    } else if ((self.currentDeviceOrientation == UIInterfaceOrientationLandscapeLeft && !self.isEstimatedInterfaceOritentationInLandscape) ||
               (self.currentDeviceOrientation == UIInterfaceOrientationPortrait && self.isEstimatedInterfaceOritentationInLandscape)){
        rotationAngle = 90.0;
    }
    return rotationAngle;
}

#pragma mark - Status Bar 

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)hideStatusBarIfNeeded {
    if (DSKStatusBarUnhidden()) {
        self.statusBarHiddenByDefault = [[UIApplication sharedApplication] isStatusBarHidden];
        if (!self.statusBarHiddenByDefault) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
#pragma clang diagnostic pop
        }
    }
}

- (void)showStatusBarIfNeeded {
    if (DSKStatusBarUnhidden()) {
        if (!self.statusBarHiddenByDefault) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
            [[UIApplication sharedApplication] setStatusBarHidden:NO];
#pragma clang diagnostic pop
        }
    }
}

#pragma mark - Orientation

- (void)rotate:(float)degree {
    self.view.transform = CGAffineTransformMakeRotation(degree/180*M_PI);
}

- (UIInterfaceOrientation)currentDeviceOrientation {
//    return (UIInterfaceOrientation)[[UIDevice currentDevice] orientation];
    return [[UIApplication sharedApplication] statusBarOrientation];
}

- (UIInterfaceOrientation)estimatedInterfaceOritentation {
    if (self.supportedInterfaceOrientations & UIInterfaceOrientationMaskPortrait ||
        self.supportedInterfaceOrientations & UIInterfaceOrientationMaskPortraitUpsideDown) {
        return UIInterfaceOrientationPortrait;
    }
    
    if (self.supportedInterfaceOrientations & UIInterfaceOrientationMaskLandscapeLeft ||
        self.supportedInterfaceOrientations & UIInterfaceOrientationMaskLandscapeRight) {
        return UIInterfaceOrientationLandscapeLeft;
    }
    
    return self.currentDeviceOrientation;
}

- (BOOL)isDeviceInLandscape {
    return self.currentDeviceOrientation == UIInterfaceOrientationLandscapeLeft || self.currentDeviceOrientation == UIInterfaceOrientationLandscapeRight;
}

- (BOOL)isEstimatedInterfaceOritentationInLandscape {
    return self.isDeviceInLandscape;
}


@end
