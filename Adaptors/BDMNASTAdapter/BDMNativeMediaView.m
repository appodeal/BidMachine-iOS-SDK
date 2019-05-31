//
//  BDMInternalMediaView.m
//
//  Copyright © 2016 Appodeal, Inc. All rights reserved.
//

#import "BDMNativeMediaView.h"
#import "BDMMediaViewController.h"

#import <ASKExtension/ASKExtension.h>
#import <DisplayKit/DisplayKit.h>
#import <ASKDiskUtils/ASKDiskUtils.h>
#import <ASKViewabilityTracker/ASKViewabilityTracker.h>
#import <ASKViewabilityTracker/UIView+ASKViewability.h>

typedef NS_ENUM(NSInteger, BDMMediaViewState) {
    BDMStateNoVideo = 0,
    BDMStateLoading,
    BDMStateReadyToPlay,
    BDMStatePlaying
};


#define BDM_MEDIA_VIEW_VISABILITY_PERCENTAGE    85
#define BDM_DEFAULT_MIN_WIDTH                   100.0f
#define BDM_DEFAULT_ASPECT_RATIO                1.778f // aka 16:9
#define BDM_CONTROLS_DEFAULT_OPACITY            0.6f


@interface BDMNativeMediaView () <DSKVideoPlayerDelegate>

@property (nonatomic, assign) BDMMediaViewState state;

@property (nonatomic, strong) DSKVideoPlayer *player;
@property (nonatomic, strong) UIImageView * placeholder;
@property (nonatomic, strong) ASKTimer * visabilityTimer;
@property (nonatomic, strong) DSKGraphicButton * playButton;
@property (nonatomic, strong) DSKGraphicButton * muteButton;
@property (nonatomic, strong) BDMMediaViewController * playerController;

@end

@implementation BDMNativeMediaView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.state = BDMStateNoVideo;
        self.layer.masksToBounds = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(appGoingBackground)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(appGoingForeground)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
        
    }
    return self;
}

- (void)render {
    if (!self.videoUrl && !self.placeholderURL) {
        // nothink presentation
        return;
    }
    
    [self renderPlaceholderIfNeeded];
    [self renderVideoIfNeeded];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removePlayer];
}

#pragma mark - private

- (void)renderPlaceholderIfNeeded {
    if (!self.placeholder) {
        self.placeholder = UIImageView.askFastImageCache(self.placeholderURL);
        [self.placeholder ask_constraint_edgesEqualToEdgesOfView:self];
    }
}

- (void)renderVideoIfNeeded {
    __weak __typeof__(self)_weakSelf = self;
    self.state = BDMStateLoading;
    ASKDataCacher.cacheURL(self.videoUrl, ^(ASKFile *file) {
        [_weakSelf createPlayer];
    }, ^(NSError *error) {
        self.state = BDMStateNoVideo;
        // should be fail to present
    });
}

- (void)createPlayer {
    [self removePlayer];
    
    self.player = [[DSKVideoPlayer alloc] initWithFrame:self.frame];
    self.player.backgroundColor = UIColor.blackColor;
    self.player.delegate = self;
    
    [self.player loadWithURL:self.videoUrl];
}

- (void)removePlayer {
    [self stopVisabilityDetection];
    
    if (self.state == BDMStateNoVideo) return;
    
    self.state = BDMStateNoVideo;
    [self.player invalidate];
    if ([self.player superview])
        [self.player removeFromSuperview];
    self.player = nil;
}

- (void)updateMuteButton {
    DSKGraphicsButtonType type = self.player.mute ? DSKGraphicsButtonMuteOn : DSKGraphicsButtonMuteOff;
    [self.muteButton drawButtonWithType:type];
}

- (void)showFullscreen {
    if (!self.controller) {
        // warning
        return;
    }
    self.playerController = [[BDMMediaViewController alloc] initWithPlayer:self.player];
    [self.playerController presentFromController:self.controller completion:^(BOOL muted) {
        [self setPlayerConstraint];
        [self updateMuteButton];
        self.playerController = nil;
    }];
    [self.player play];
}

- (void)hideFullscreen {
    [self.playerController dismissViewControllerAnimated:NO completion:nil];
}

- (void)startPlaying {
    if (self.state != BDMStateReadyToPlay) {
        //warning
        return;
    }
    
    self.state = BDMStatePlaying;
    [UIView animateWithDuration:0.2 animations:^{
        [self setPlayerConstraint];
    }];
    [self.player play];
    [self setMuteConstraint];
    [self updateMuteButton];
}

#pragma mark - DSKVideoPlayerDelegate

- (void)videoPlayerReady:(DSKVideoPlayer *)videoPlayer {
    self.state = BDMStateReadyToPlay;
    [self startVisabilityDetection];
}

- (void)videoPlayer:(DSKVideoPlayer *)videoPlayer didFailWithError:(NSError *)error {
    [self.player invalidate];
}

- (void)videoPlayer:(DSKVideoPlayer *)videoPlayer sendEvent:(DSKVideoEvent)event {
    if (event == DSKVideoEventClick) {
        if (!self.playerController) {
            [self showFullscreen];
        }
        return;
    }
    
    if (event == DSKVideoEventFinish) {
        [self.playerController dismissViewControllerAnimated:NO completion:nil];
        [self.player repeat];
    }
}

#pragma mark - Visability detection

- (void)startVisabilityDetection {
    __weak __typeof__(self) _weakSelf = self;
    self.visabilityTimer = [ASKTimer timerWithInterval:0.5f periodic:YES block:^{
        BOOL isVisible = [_weakSelf ask_isVisibleOnScreenWithPercentage:BDM_MEDIA_VIEW_VISABILITY_PERCENTAGE overlayDetection:NO];
        BOOL isFullscreen = _weakSelf.playerController != nil;
        BOOL isPlaying = self.state == BDMStatePlaying;
        BOOL isReadyToPlay = self.state == BDMStateReadyToPlay;
        
        if (!isVisible && !isFullscreen && isPlaying) {
            [_weakSelf.player pause];
        }
        
        if (isVisible && isReadyToPlay) {
            [_weakSelf startPlaying];
        } else if (!isPlaying) {
            [_weakSelf.player play];
        }
    }];
}

- (void)stopVisabilityDetection {
    [self.visabilityTimer cancel];
}

#pragma mark - Notifications

- (void)appGoingBackground {
    if (self.state == BDMStatePlaying) {
        [self.player pause];
    }
}

- (void)appGoingForeground {
    if (self.state == BDMStatePlaying) {
        [self.player resume];
    }
}

#pragma mark - Controls

- (void)createMuteButton {
    self.muteButton = [DSKGraphicButton new];
    [self.muteButton addTarget:self action:@selector(muteButtonPressed)];
    self.muteButton.alpha = BDM_CONTROLS_DEFAULT_OPACITY;
}

- (void)removeButtons {
    for (UIView * view in self.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            [view removeFromSuperview];
//            _playButton = nil;
        }
    }
}

#pragma mark - Action

- (void)muteButtonPressed {
    [self.player setMute:!self.player.mute];
    [self updateMuteButton];
}

- (void)playButtonPressed {
    [self.playButton removeFromSuperview];
    self.playButton = nil;
    
    [self startPlaying];
}

#pragma mark - Lazy

- (DSKGraphicButton *)muteButton {
    if (!_muteButton) {
        _muteButton = [DSKGraphicButton new];
        [_muteButton addTarget:self action:@selector(muteButtonPressed)];
    }
    return _muteButton;
}

- (DSKGraphicButton *)playButton {
    if (!_playButton) {
        _playButton = [DSKGraphicButton new];
        [_playButton drawButtonWithType:DSKGraphicsButtonPlay];
        [_playButton addTarget:self action:@selector(playButtonPressed)];
    }
    return _playButton;
}

#pragma mark - Constraint

- (void)setPlaceheolderConstraint {
    [self.placeholder ask_constraint_edgesEqualToEdgesOfView:self];
}

- (void)setPlayerConstraint {
    [self.player removeFromSuperview];
    [self addSubview:self.player];
    if (self.placeholder.superview) {
        [self insertSubview:self.player aboveSubview:self.placeholder];
    } else {
        [self insertSubview:self.player atIndex:0];
    }
    [self.player ask_constraint_edgesEqualToEdgesOfView:self];
}

- (void)setMuteConstraint {
    [self.muteButton removeFromSuperview];
    [self addSubview:self.muteButton];
    self.muteButton.translatesAutoresizingMaskIntoConstraints = NO;
    if (@available(iOS 11.0, *)) {
        [[self.muteButton.topAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.topAnchor] setActive:YES];
        [[self.muteButton.leftAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.leftAnchor] setActive:YES];
    } else {
        [[self.muteButton.topAnchor constraintEqualToAnchor:self.topAnchor] setActive:YES];
        [[self.muteButton.leftAnchor constraintEqualToAnchor:self.leftAnchor] setActive:YES];
    }
    [[self.muteButton.widthAnchor constraintEqualToConstant:20] setActive:YES];
    [[self.muteButton.heightAnchor constraintEqualToConstant:20] setActive:YES];
}

- (void)setPlayButtonConstraint {
    [self.playButton removeFromSuperview];
    [self addSubview:self.playButton];
    float size = self.frame.size.width > 60 ? 60 : 35;
    self.playButton.translatesAutoresizingMaskIntoConstraints = YES;
    [[self.playButton.centerXAnchor constraintEqualToAnchor:self.centerXAnchor] setActive:YES];
    [[self.playButton.centerYAnchor constraintEqualToAnchor:self.centerYAnchor] setActive:YES];
    [[self.playButton.widthAnchor constraintEqualToConstant:size] setActive:YES];
    [[self.playButton.heightAnchor constraintEqualToConstant:size] setActive:YES];
}

@end
