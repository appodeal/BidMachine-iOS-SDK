//
//  BDMMediaViewController.m
//
//  Copyright © 2016 Appodeal, Inc. All rights reserved.
//

#import "BDMMediaViewController.h"
#import <DisplayKit/DisplayKit.h>
#import <ASKExtension/ASKExtension.h>

#define BDM_CONTROLLER_CONTROL_SIZE 70

@interface BDMMediaViewController ()

@property (nonatomic,   copy) void(^completion)(BOOL);
@property (nonatomic, assign) UIModalPresentationStyle controllerPresentationStyle;

@property (nonatomic,   weak) DSKVideoPlayer * player;
@property (nonatomic, strong) DSKCircleTimerButton * closeButton;
@property (nonatomic, strong) DSKGraphicButton * muteButton;

@end

@implementation BDMMediaViewController

- (instancetype)initWithPlayer:(DSKVideoPlayer *)player {
    self = [super init];
    if (self) {
        self.player = player;
    }
    return self;
}

- (void)presentFromController:(UIViewController *)controller
                   completion:(void (^)(BOOL))completion
{
    self.completion = completion;
    
    self.controllerPresentationStyle = controller.modalPresentationStyle;
    controller.modalPresentationStyle = UIModalPresentationFullScreen;
    [controller presentViewController:self animated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setPlayerConstraint];
    [self setCloseConstraint];
    [self setMuteConstraint];
    
    [self updateMuteButton];
}

- (void)dismissViewControllerAnimated:(BOOL)flag
                           completion:(void (^)(void))completion {
    [self.player removeFromSuperview];
    [self.closeButton removeFromSuperview];
    [self.muteButton removeFromSuperview];
    
    if (self.presentingViewController) {
        self.presentingViewController.modalPresentationStyle = self.controllerPresentationStyle;
    }
    self.completion ? self.completion(self.player.mute) : nil;
    [super dismissViewControllerAnimated:flag completion:completion];
}

- (void)updateMuteButton {
    DSKGraphicsButtonType type = self.player.mute ? DSKGraphicsButtonMuteOn : DSKGraphicsButtonMuteOff;
    [self.muteButton drawButtonWithType:type];
}

#pragma mark - Action

- (void)skippButtonPressed {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)muteButtonPressed {
    [self.player setMute:!self.player.mute];
    [self updateMuteButton];
}

#pragma mark - Lazy

- (DSKCircleTimerButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [DSKCircleTimerButton closeButton];
        [_closeButton addTarget:self action:@selector(skippButtonPressed)];
    }
    return _closeButton;
}


- (DSKGraphicButton *)muteButton {
    if (!_muteButton) {
        _muteButton = [DSKGraphicButton new];
        [_muteButton addTarget:self action:@selector(muteButtonPressed)];
    }
    return _muteButton;
}

#pragma mark - Constraint

- (void)setPlayerConstraint {
    if (!self.player) {
        return;
    }
    [self.player removeFromSuperview];
    [self.player ask_constraint_edgesEqualToEdgesOfView:self.view];
}

- (void)setCloseConstraint {
    [self.view addSubview:self.closeButton];
    self.closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    if (@available(iOS 11.0, *)) {
        [[self.closeButton.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor] setActive:YES];
        [[self.closeButton.rightAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.rightAnchor] setActive:YES];
    } else {
        [[self.closeButton.topAnchor constraintEqualToAnchor:self.view.topAnchor] setActive:YES];
        [[self.closeButton.rightAnchor constraintEqualToAnchor:self.view.rightAnchor] setActive:YES];
    }
    
    
    [[self.closeButton.widthAnchor constraintEqualToConstant:BDM_CONTROLLER_CONTROL_SIZE] setActive:YES];
    [[self.closeButton.heightAnchor constraintEqualToConstant:BDM_CONTROLLER_CONTROL_SIZE] setActive:YES];
}

- (void)setMuteConstraint {
    [self.view addSubview:self.muteButton];
    self.muteButton.translatesAutoresizingMaskIntoConstraints = NO;
    if (@available(iOS 11.0, *)) {
        [[self.muteButton.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor] setActive:YES];
        [[self.muteButton.leftAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leftAnchor] setActive:YES];
    } else {
        [[self.muteButton.topAnchor constraintEqualToAnchor:self.view.topAnchor] setActive:YES];
        [[self.muteButton.leftAnchor constraintEqualToAnchor:self.view.leftAnchor] setActive:YES];
    }
    [[self.muteButton.widthAnchor constraintEqualToConstant:BDM_CONTROLLER_CONTROL_SIZE] setActive:YES];
    [[self.muteButton.heightAnchor constraintEqualToConstant:BDM_CONTROLLER_CONTROL_SIZE] setActive:YES];
}


@end
