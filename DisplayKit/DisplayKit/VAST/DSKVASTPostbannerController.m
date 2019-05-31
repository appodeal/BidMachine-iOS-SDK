//
//  DSKVASTPostbannerController.m
//  OpenBids

//  Copyright © 2017 OpenBids, Inc. All rights reserved.
//

#import "DSKVASTPostbannerController.h"


#import "DSKGeometry.h"
#import "NSError+DSKVAST.h"
#import "DSKGraphicButton.h"
#import "DSKCustomScenario.h"
#import "DSKVASTCompanionView.h"
#import "DSKConstraintMaker+Private.h"
#import "UIView+DSKConstraint.h"
#import <NexageSourceKitMRAID/UIView+SKExtension.h>


#define INTERFACE_ORIENTATION_KEY @"orientation"

@interface DSKVASTPostbannerController () <DSKVASTCompanionViewDelegate, DSKCustomControlLayerDelegate, DSKCustomControlLayerDataSource>

@property (nonatomic, strong) DSKVASTCompanionView * posbannerView;

@property (nonatomic, weak) UIViewController * rootViewController;

@property (nonatomic, strong) DSKCustomControlLayer * customLayer;

@end

@implementation DSKVASTPostbannerController

#pragma mark - Life cicle

- (void)loadView {
    [super loadView];
    
    [self.view addSubview:self.posbannerView];
    [self.customLayer addOnView:self.view];
    
    //TODO CONSTRAINTS
    [self.posbannerView DSK_makeConstraints:^(DSKConstraintMaker *make) {
        make.interfaceOrientation = self.isEstimatedInterfaceOritentationInLandscape ? DSKInterfaceOrientationLandscape : DSKInterfaceOrientationPortrait;
        UIEdgeInsets inset = [make fullscreenInsets];
        make.top = @(- inset.top);
        make.bottom = @(-inset.bottom);
        make.left = @(-inset.left);
        make.right = @(-inset.right);
    }];
    
    [self.posbannerView sk_makeEdgesEqualToView:self.view];
}

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController{
    self = [super init];
    if (self) {
        self.rootViewController = rootViewController;
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    }
    return self;
}

#pragma mark - Public

+ (DSKVASTPostbannerController *)controllerFromCompanions:(NSArray *)companions
                                       rootViewController:(UIViewController *)controller
                                              aspectRatio:(DSKVASTAspectRatio)aspectRatio {
    
    return [self controllerFromCompanions:companions screen:nil rootViewController:controller aspectRatio:aspectRatio];
}

+ (DSKVASTPostbannerController *)controllerFromScreen:(UIImage *)screen
                                   rootViewController:(UIViewController *)controller
                                          aspectRatio:(DSKVASTAspectRatio)aspectRatio{
    
    return [self controllerFromCompanions:nil screen:screen rootViewController:controller aspectRatio:aspectRatio];
}

+ (DSKVASTPostbannerController *)controllerFromCompanions:(NSArray *)companions
                                                   screen:(UIImage *)screen
                                   rootViewController:(UIViewController *)controller
                                          aspectRatio:(DSKVASTAspectRatio)aspectRatio{
    
    DSKVASTPostbannerController * postBannerController = [[DSKVASTPostbannerController alloc] initWithRootViewController:controller];
    DSKVASTCompanionView * companionView = nil;
    BOOL staticImage = YES;
    
    if (companions) {
        staticImage = NO;
        companionView = [DSKVASTCompanionView companionViewFromArray:companions
                                                  rootViewController:postBannerController
                                                         aspectRatio:aspectRatio];
    } else if (screen) {
        companionView = [DSKVASTCompanionView companionViewFromImage:screen
                                                  rootViewController:postBannerController
                                                         aspectRatio:aspectRatio];
    } else {
        
    }
    
    NSDictionary * scenario = staticImage ? vastPostbannerScreenScenario() : vastPostbannerScenario();
    if (companionView) {
        companionView.delegate = postBannerController;
        [postBannerController setPosbannerView:companionView];
        
        postBannerController.customLayer = [[DSKCustomControlLayer alloc] initWithScenario:scenario
                                                                                  delegate:postBannerController
                                                                                dataSource:postBannerController];
        
        [companionView load];
    } else {
        postBannerController = nil;
    }
    
    return postBannerController;
}

- (void)show {
    [self.posbannerView show];
    [self.customLayer processEvent:CCEventStartScenario];
    [self.rootViewController presentViewController:self animated:YES completion:nil];
}

#pragma mark - Action

- (void)closeButtonPressed {
    [self.posbannerView hide];
    [self dismissViewControllerAnimated:NO completion:^{
        [self.delegate postbannerDidHide:self];
    }];
}

- (void)repeatButtonPressed {
    [self.posbannerView hide];
    [self dismissViewControllerAnimated:NO completion:^{
        [self.delegate postbannerDidRepeatAction:self];
    }];
}

- (void)learnMoreButtonPressed {
    if ([self.delegate respondsToSelector:@selector(postbannerDidMoreAction:)]) {
        [self.delegate postbannerDidMoreAction:self];
    }
}

#pragma mark - Orientation

- (BOOL)isEstimatedInterfaceOritentationInLandscape {
    switch (self.posbannerView.aspectRatio) {
        case DSKVASTAspectRatioPortrait:    return NO;                                                  break;
        case DSKVASTAspectRatioLandscape:   return YES;                                                 break;
        default:                            return [super isEstimatedInterfaceOritentationInLandscape]; break;
    }
}

#pragma mark - DSKVASTCompanionViewDelegate

- (void)staticCompanionViewDidReciveTap:(DSKVASTCompanionView *)companionView{
    [self learnMoreButtonPressed];
}

- (void)mraidCompanionViewDidLoad:(DSKVASTCompanionView *) companionView {
    [self.delegate postbannerDidLoad:self];
}

- (void)companionViewDidReciveTap:(DSKVASTCompanionView *)companionView destanationURL:(NSURL *)URL {
    [self.delegate postbannerDidReciveTap:self destanationURL:URL];
}

- (void)mraidCompanionViewDidDismiss:(DSKVASTCompanionView *)companionView {
    [self closeButtonPressed];
}

- (void)mraidCompanionDidFailToLoad:(DSKVASTCompanionView *)companionView {
    NSError * error = [NSError DSK_vastErrorWithCode:DSKVASTCompanionError];
    [self.delegate postbanner:self didFailToLoadWithError:error];
}

- (void)mraidCompanion:(DSKVASTCompanionView *)companionView useCustomClose:(BOOL)useCustomClose{
    if (useCustomClose) {
        [self.customLayer processEvent:CCEventUseCustomCloseTrue];
    } else {
        [self.customLayer processEvent:CCEventUseCustomCloseFalse];
    }
}

#pragma mark - DSKCustomControlLayerDelegate, DSKCustomControlLayerDataSource

- (void)DSK_clickOnButtonType:(CCType)type{
    switch (type) {
        case CCTypeRepeat:      [self repeatButtonPressed];     break;
        case CCTypeClose:       [self closeButtonPressed];      break;
        case CCTypeTimerClose:  [self closeButtonPressed];      break;
        case CCTypeMore:        [self learnMoreButtonPressed];  break;
        default: break;
    }
}

- (NSNumber *)DSK_closeTime{
    if ([self.delegate respondsToSelector:@selector(postbannerCloseTime)]) {
        return [self.delegate postbannerCloseTime];
    }
    return nil;
}

- (BOOL)DSK_isEstimatedInterfaceOritentationInLandscape{
    return [self isEstimatedInterfaceOritentationInLandscape];
}

@end
