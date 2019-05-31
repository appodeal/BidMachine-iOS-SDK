 //
//  DSKVASTController.m
//  OpenBids
//

//  Copyright © 2016 OpenBids, Inc. All rights reserved.
//


#import "DSKVASTController.h"
#import "DSKVideoPlayer.h"
#import "DSKVASTVideoModel.h"
#import "DSKVASTCompanionView.h"
#import "NSError+DSKVAST.h"
#import "DSKVASTPostbannerController.h"
#import "DSKThirdPartyEventTracker.h"
#import "DSKCustomScenario.h"
#import "DSKConstraintMaker+Private.h"
#import "UIView+DSKConstraint.h"
#import <NexageSourceKitMRAID/UIView+SKExtension.h>


#define DEFAULT_CONTROL_HEIGTH 25

typedef NS_ENUM(NSUInteger, AVState){
    AVStateLoading = 0,
    AVStatePreLoaded,
    AVStateLoaded,
    AVStateReady,
    AVStateFailValidate,
    AVStateFailPreload,
    AVStateFailLoad,
    
    AVStatePreparePresenting,
    AVStatePrepareDismiss,
    AVStatePresenting,
    AVStatePresented,
    AVStateSkiped,
    AVStateCompleted,
    AVStatePrepareEnd,
    
    AVStatePrepareRepeat
};

typedef NS_OPTIONS(NSUInteger, AVPCondition){
    AVPConditionLoading         = 1 << 0,
    AVPConditionStartPlaying    = 1 << 1,
    AVPConditionStopPlaying     = 1 << 2,
    AVPConditionPause           = 1 << 3,
    AVPConditionResume          = 1 << 4,
    AVPConditionMute            = 1 << 5,
    AVPConditionUnmute          = 1 << 6,
    AVPConditionScreenPlayer    = 1 << 7,
    AVPConditionInvalidate      = 1 << 8
};

@interface DSKVASTController () <DSKVideoPlayerDelegate, DSKVASTCompanionViewDelegate, DSKVASTPostbannerControllerDelegate, DSKCustomControlLayerDelegate, DSKCustomControlLayerDataSource>

@property (nonatomic, strong) DSKVideoPlayer* player;
@property (nonatomic, strong) DSKVASTVideoModel* video;

@property (nonatomic, strong) DSKVASTCompanionView* companionView;
@property (nonatomic, strong) DSKVASTPostbannerController* postbanner;

@property (nonatomic, assign) UIModalPresentationStyle controllerPresentationStyle;
@property (nonatomic, weak) UIViewController * rootViewController;

@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, assign) BOOL wasFullyWatched;
@property (nonatomic, assign) BOOL isSilent;
@property (nonatomic, assign) BOOL isRepeating;

@property (nonatomic, strong) DSKCustomControlLayer * controlLayer;

@property (nonatomic, assign) AVState vastState;
@property (nonatomic, assign) AVPCondition playerCondition;

@property (nonatomic, strong) UIImage * screenshot;

@end

@implementation DSKVASTController

#pragma mark - Lifecycle

- (void)dealloc {
    [self switchPlayerCondition:AVPConditionInvalidate];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.player = [[DSKVideoPlayer alloc] init];
        self.player.delegate = self;
        [self.view addSubview:self.player];
        [self.player sk_makeEdgesEqualToView:self.view];
        self.controlLayer = [[DSKCustomControlLayer alloc] initWithScenario:vastPlayerScenario() delegate:self dataSource:self];
    }
    return self;
}

#pragma mark - Application State

- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appGoToBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appGoToForeground) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)appGoToBackground {
    [self switchPlayerCondition:AVPConditionPause];
}

- (void)appGoToForeground {
    [self switchPlayerCondition:AVPConditionResume];
}

#pragma mark - Public

- (void)loadForVastURL:(NSURL *)vastURL {
    [self switchVastState:AVStateLoading];
    
    __weak typeof(self) weakSelf = self;
    [DSKVASTVideoModel parseVastUrl:vastURL completion:^(DSKVASTVideoModel *video, NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        if (error) {
            [strongSelf switchVastState:AVStateFailValidate error:error vast:video];
        } else {
            [strongSelf switchVastState:AVStatePreLoaded vast:video];
        }
    }];
}

- (void)loadForVastXML:(NSData *)XML {
    [self switchVastState:AVStateLoading];
    
    __weak typeof(self) weakSelf = self;
    [DSKVASTVideoModel parseVastData:XML completion:^(DSKVASTVideoModel *vast, NSError *vastParsingError) {
        __strong typeof(self) strongSelf = weakSelf;
        if (vastParsingError) {
            [strongSelf switchVastState:AVStateFailValidate error:vastParsingError vast:vast];
        } else {
            [strongSelf switchVastState:AVStatePreLoaded vast:vast];
        }
    }];
}

- (void) presentFromViewController:(UIViewController *)viewController {
    self.rootViewController = viewController;
    
    [self switchVastState:AVStatePreparePresenting];
}

- (void)pause{
    [self switchPlayerCondition:AVPConditionPause];
}

- (void)resume {
    [self switchPlayerCondition:AVPConditionResume];
}

- (NSString *)adCreative {
    return self.video.rawData;
}

#pragma mark - State Machine

- (void)switchVastState:(AVState)state {
    [self switchVastState:state error:nil vast:nil];
}

- (void)switchVastState:(AVState)state
                  error:(NSError *)error {
    [self switchVastState:state error:error vast:nil];
}

- (void)switchVastState:(AVState)state
                   vast:(DSKVASTVideoModel *)vast {
    [self switchVastState:state error:nil vast:vast];
}

- (void)switchVastState:(AVState)state
                  error:(NSError *)error
                   vast:(DSKVASTVideoModel *)vast{
    self.vastState = state;
    switch (state) {
            
        case AVStateLoading:  break;
        case AVStatePreLoaded:          [self applyVastUpdatePreloadedVast:vast];                           break;
        case AVStateLoaded:             [self applyVastUpdateLoadedVast:vast];                              break;
        case AVStateReady:              [self applyVastUpdateReadyVast];                                    break;
        case AVStateFailValidate:       [self applyVastUpdateFailToValidateVideo:vast withError:error];     break;
        case AVStateFailPreload:        [self applyVastUpdateFailToPreloadVideo:vast withError:error];      break;
        case AVStateFailLoad:           [self applyVastUpdateFailToLoadVideoWithError:error];               break;
        case AVStatePreparePresenting:  [self applyVastUpdatePreparePresenting];                            break;
        case AVStatePrepareDismiss:     [self applyVastUpdatePrepareDismiss:error];                         break;
        case AVStatePresenting:         [self applyVastUpdatePesenting];                                    break;
        case AVStatePresented:          [self applyVastUpdatePresented];                                    break;
        case AVStateSkiped:             [self applyVastUpdateSkiped];                                       break;
        case AVStateCompleted:          [self applyVastUpdateCompleted];                                    break;
        case AVStatePrepareEnd:         [self applyVastUpdatePrepareEnd];                                   break;
        case AVStatePrepareRepeat:      [self applyVastUpdatePrepareRepeat];                                break;
            
        default:  break;
    }
}

#pragma mark - Player state

- (void)switchPlayerCondition:(AVPCondition)condition{
    self.playerCondition = condition;
    if (condition & AVPConditionLoading) {
        [self applyPlayerChangeEventLoading];
    }
    
    if (condition & AVPConditionScreenPlayer) {
        [self applyPlayerChangeEventMakeScreen];
    }
    
    if (condition & AVPConditionStartPlaying) {
        [self applyPlayerChangeEventStartPlaying];
    }
    
    if (condition & AVPConditionStopPlaying) {
        [self applyPlayerChangeEventStopPlaying];
    }
    
    if (condition & AVPConditionPause) {
        [self applyPlayerChangeEventPause];
    }
    
    if (condition & AVPConditionResume) {
        [self applyPlayerChangeEventResume];
    }
    
    if (condition & AVPConditionMute) {
        [self applyPlayerChangeEventMute];
    }
    
    if (condition & AVPConditionUnmute) {
        [self applyPlayerChangeEventUnmute];
    }
    
    if (condition & AVPConditionInvalidate) {
        [self applyPlayerChangeEventInvalidate];
    }
}

#pragma mark - Player behaviour

- (void)applyPlayerChangeEventLoading {
    self.controlLayer.extention = self.video.extension;
    
    BOOL progressBarEnabled =   (self.video.extension && self.video.extension.progressBarEnabled) ||
                                !self.video.extension;
    
    [self.player setProgressBarHidden:!progressBarEnabled];
    [self.player loadWithURL:self.video.videoURL];
}

- (void)applyPlayerChangeEventStartPlaying {
    self.isPlaying = YES;
    
    [self.player play];
}

- (void)applyPlayerChangeEventStopPlaying {
    self.isPlaying = NO;
    
    [self.player stop];
}

- (void)applyPlayerChangeEventPause {
    if (self.isPlaying) {
        [self.player pause];
    }
}

- (void)applyPlayerChangeEventResume {
    if (self.isPlaying)
        [self.player resume];
}

- (void)applyPlayerChangeEventMute {
    self.isSilent = YES;

    [self.player setMute:YES];
    
    if (self.isPlaying) {
        [self trackEvents:self.video.tracking.muteURL];
    }
}

- (void)applyPlayerChangeEventUnmute {
    self.isSilent = NO;
    
    [self.player setMute:NO];
    
    if (self.isPlaying){
        [self trackEvents:self.video.tracking.unmuteURL];
    }
}

- (void)applyPlayerChangeEventInvalidate{
    [self.player invalidate];
}

- (void)applyPlayerChangeEventMakeScreen{
    self.screenshot = [self.player takeScreenshot];
}

#pragma mark - VAST behaviour

- (void)applyVastUpdateFailToValidateVideo:(DSKVASTVideoModel *)video
                                 withError:(NSError *)error {
    [DSKThirdPartyEventTracker sendError:error.code
                           trackingEvent:video.errorNoticeUrl];
    
    [self notifyDelegate:@selector(vastController:didFailToLoad:)
              withObject:self withObject:error];
}

- (void)applyVastUpdateFailToPreloadVideo:(DSKVASTVideoModel *)video
                                withError:(NSError *)error {
    [DSKThirdPartyEventTracker sendError:DSKVASTExpectedDurationError
                           trackingEvent:video.errorNoticeUrl];
    
    [self notifyDelegate:@selector(vastController:didFailToLoad:)
              withObject:self withObject:error];
}

- (void)applyVastUpdateFailToLoadVideoWithError:(NSError *)error {
    
    [DSKThirdPartyEventTracker sendError:DSKVASTProblemFileError
                           trackingEvent:self.video.errorNoticeUrl];
    
    if (self.isPlaying) {
        [self switchVastState:AVStatePrepareDismiss
                        error:error];
    }
    
    [self notifyDelegate:@selector(vastController:didFailToLoad:)
              withObject:self withObject:error];
}


- (void)applyVastUpdatePreloadedVast:(DSKVASTVideoModel *)vast {
//    if ([[self.delegate maxDuration] floatValue] < vast.duration) {
//        NSError * durationError = [NSError DSK_vastErrorWithCode:DSKVASTExpectedDurationError];
//        [self switchVastState:AVStateFailPreload
//                        error:durationError
//                         vast:vast];
//    } else {
        [self switchVastState:AVStateLoaded
                         vast:vast];
//    }
}

- (void)applyVastUpdateLoadedVast:(DSKVASTVideoModel *)vast {
    self.video = vast;
    
    [self switchPlayerCondition:AVPConditionLoading];
}

- (void)applyVastUpdateReadyVast {
    [self notifyDelegate:@selector(vastControllerReady:)
              withObject:self];
}

- (void)applyVastUpdatePrepareRepeat {
    [self.controlLayer setNewScenario:vastPlayerRepeatScenario()];
    [self.controlLayer processEvent:CCEventApplyScenario];
    
    self.isRepeating = YES;
    
    [self switchPlayerCondition:AVPConditionUnmute];
    [self switchVastState:AVStatePresented];
}

- (void)applyVastUpdatePreparePresenting {
    [self createCompBanner];
    [self createPostbanner];
    
    [self switchVastState:AVStatePresenting];
}

- (void)applyVastUpdatePrepareDismiss:(NSError *)error {
    [self switchPlayerCondition:AVPConditionInvalidate];
    
    [self trackEvents:self.video.tracking.closeURL];
    
    self.rootViewController.modalPresentationStyle = self.controllerPresentationStyle;
    
    if (self.wasFullyWatched) {
        [self notifyDelegate:@selector(vastControllerDidFinish:)
                  withObject:self];
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.isPlaying) {
            [self notifyDelegate:@selector(vastController:didFailWhileShow:)
                      withObject:self withObject:error];
        } else {
            [self notifyDelegate:@selector(vastControllerDidDismiss:)
                      withObject:self];
        }
    }];
}

- (void)applyVastUpdatePesenting {
    [self showCompbannerIfPossible];
    [self.controlLayer addOnView:self.view];
    
    self.controllerPresentationStyle = self.rootViewController.modalPresentationStyle;
    self.rootViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    
    [self.rootViewController presentViewController:self animated:NO completion:^{
        [self switchVastState:AVStatePresented];
    }];
}

- (void)applyVastUpdatePresented {
    [self addObservers];
    
    [self.controlLayer processEvent:CCEventStartScenario];
    [self switchPlayerCondition:AVPConditionStartPlaying];
    
    if (!self.isRewarded) {
        [self.controlLayer processEvent:CCEventExternalEmptySV];
    }
    
    if (!self.isLearnMoreButtonRequired) {
        [self.controlLayer processEvent:CCEventExternalEmptyMore];
    }
    
    if (!self.isRepeating) {
        [self trackEvents:self.video.tracking.creativeView];
        [self trackEvents:self.video.tracking.impressions];
        [self trackEvents:self.video.tracking.startURL];
        [self trackEvents:self.video.tracking.fullScreenURL];
        
        [self notifyDelegate:@selector(vastControllerDidPresent:) withObject:self];
    }
}

- (void)applyVastUpdateSkiped {
    //TODO: UPDATE
//    [self notifyDelegate:@selector(vastControllerDidSkip:) withObject:self];
//    if (self.video.extension.skippTracker) {
//        [self trackEvents:@[self.video.extension.skippTracker]];
//    }
    
    [self switchVastState:AVStatePrepareEnd];
}

- (void)applyVastUpdateCompleted {
    [self.controlLayer processEvent:CCEventExternalEmptyRV];
    
    if (!self.wasFullyWatched) {
        [self trackEvents:self.video.tracking.finishURL];
    }
    
    self.wasFullyWatched = YES;

    [self switchVastState:AVStatePrepareEnd];
}

- (void)applyVastUpdatePrepareEnd {
    [self removeObservers];
    
    [self.controlLayer processEvent:CCEventExternalEmptyCompletly];
    [self switchPlayerCondition:AVPConditionStopPlaying | AVPConditionScreenPlayer];

    if (self.isAutoclose){
        [self switchVastState:AVStatePrepareDismiss];
    } else {
        [self showPostbannerIfPossible];
    }
}

#pragma mark - Notifying

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

- (void)notifyDelegate:(SEL)selector withObject:(id)object{
    if ([self.delegate respondsToSelector:selector]) {
        [self.delegate performSelector:selector withObject:object];
    }
}

- (void)notifyDelegate:(SEL)selector withObject:(id)object1 withObject:(id)object2{
    if ([self.delegate respondsToSelector:selector]) {
        [self.delegate performSelector:selector withObject:object1 withObject:object2];
    }
}

#pragma clang diagnostic pop

- (void)trackEvents:(NSArray *)events {
    [DSKThirdPartyEventTracker sendTrackingEvents:events];
}

#pragma mark - Postbanner & Companion view

- (void)createPostbanner {
    self.postbanner = [DSKVASTPostbannerController controllerFromCompanions:self.video.companionsArray
                                                         rootViewController:self
                                                                aspectRatio:self.video.aspectRatio];
    self.postbanner.delegate = self;
}

- (void)createScreenPostbanner {
    self.postbanner = [DSKVASTPostbannerController controllerFromScreen:self.screenshot
                                                     rootViewController:self
                                                            aspectRatio:self.video.aspectRatio];
    self.postbanner.delegate = self;
}

- (void)createCompBanner{
    self.companionView = nil;
    
    if (self.isExtentionCompanion) {
        self.companionView = [DSKVASTCompanionView extentionCompanionFromCompanion:self.video.extension.companion rootViewController:self];
    } else {
        self.companionView = [DSKVASTCompanionView bannerCompanionFromArray:self.video.companionsArray rootViewController:self];
    }
    
    self.companionView.delegate = self;
}

- (BOOL)showPostbannerIfPossible {
    if (!self.postbanner) {
        [self createScreenPostbanner];
    }
    
    [self.postbanner show];
    return YES;
}

- (BOOL)showCompbannerIfPossible {
    BOOL canShow = NO;
    
    BOOL canShowAsPostbanner = self.companionView != nil;
    BOOL canShowAsCta = self.companionView != nil && self.isExtentionCompanion;
    canShow = canShowAsCta || canShowAsPostbanner;
    
    if (canShow) {
         [self.view addSubview:self.companionView];
    }
    
    if (canShowAsCta) {
        [self.companionView DSK_makeConstraints:^(DSKConstraintMaker * make) {
            [make copyPozition:self.video.extension.ctaPosition];
            make.width = @(self.video.extension.companion.width);
            make.height = @(self.video.extension.companion.heigth);
        }];
    } else if (canShowAsPostbanner) {
        CGFloat heigth = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 90 : 50;
        [[self.companionView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor] setActive:YES];
        [[self.companionView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor] setActive:YES];
        [[self.companionView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor] setActive:YES];
        [[self.companionView.heightAnchor constraintEqualToConstant:heigth] setActive:YES];
    }
    return canShow;
}

#pragma mark - Actions

- (void)moreButtonClick {
    [self trackEvents:self.video.tracking.clickTrackingUrl];
    [self notifyDelegate:@selector(vastControllerDidClick:clickURL:) withObject:self withObject:[self.video.clickThroughURL absoluteString]];
}

- (void)muteButtonPressed {
    if (self.isSilent) {
        [self switchPlayerCondition:AVPConditionUnmute];
    } else {
         [self switchPlayerCondition:AVPConditionMute];
    }
    [self.controlLayer processEvent:CCEventExternalEmptyMut];
}

- (void)skipButtonPressed {
    if (self.isPlaying) {
        [self switchVastState:AVStateSkiped];
    } else {
        [self switchVastState:AVStatePrepareDismiss];
    }
}

- (void)repeatButtonClick {
    [self switchVastState:AVStatePrepareRepeat];
}

#pragma mark - Accessors

- (BOOL)isEstimatedInterfaceOritentationInLandscape {
    switch (self.video.aspectRatio) {
        case DSKVASTAspectRatioPortrait:    return NO;                                                  break;
        case DSKVASTAspectRatioLandscape:   return YES;                                                 break;
        default:                            return [super isEstimatedInterfaceOritentationInLandscape]; break;
    }
}

- (BOOL)isExtentionCompanion{
    return self.video.extension.companion != nil && self.video.extension.ctaEnabled;
}

- (BOOL)isLearnMoreButtonRequired {
    if (self.companionView) {
        return NO;
    }
    
    return (self.video.clickThroughURL != nil && self.video.extension && self.video.extension.ctaEnabled)  || (self.video.clickThroughURL && !self.video.extension);
}

- (BOOL)isRewarded {
    if ([self.delegate respondsToSelector:@selector(isRewarded)]){
        return [self.delegate isRewarded];
    }
    else return NO;
}

- (BOOL)isAutoclose {
    if (self.video.extension && ![self.video.extension companionEnabled]) return YES;
    
    if ([self.delegate respondsToSelector:@selector(isAutoclose)]){
        return [self.delegate isAutoclose];
    } else {
        return NO;
    }
}

#pragma mark - DSKVASTPostbannerControllerDelegate

- (void)postbannerDidReciveTap:(DSKVASTPostbannerController *)postbanner destanationURL:(NSURL *)URL {
    if ([self.delegate respondsToSelector:@selector(vastControllerDidClick:clickURL:)]){
        [self.delegate vastControllerDidClick:self clickURL:[URL absoluteString]];
    }
}

- (void)postbannerDidMoreAction:(DSKVASTPostbannerController *)postbanner{
    [self moreButtonClick];
}

- (void)postbannerDidLoad:(DSKVASTPostbannerController *)postbanner {}


- (void)postbanner:(DSKVASTPostbannerController *)postbanner didFailToLoadWithError:(NSError *)error {
    self.postbanner = nil;
}

- (void)postbannerDidHide:(DSKVASTPostbannerController *)postbanner {
    [self switchVastState:AVStatePrepareDismiss];
}

- (void)postbannerDidRepeatAction:(DSKVASTPostbannerController *)postbanner {
    [self repeatButtonClick];
}

- (NSNumber *)postbannerCloseTime{
    if (self.video.extension.companionCloseTime) {
        return self.video.extension.companionCloseTime;
    }
    
    if ([self.delegate respondsToSelector:@selector(closeTime)]) {
        return [self.delegate closeTime];
    }
    return nil;
}

#pragma mark - DSKVASTCompanionViewDelegate

- (void)companionViewDidReciveTap:(DSKVASTCompanionView *)companionView destanationURL:(NSURL *)URL {
    [self notifyDelegate:@selector(vastControllerDidClick:clickURL:) withObject:self withObject:[URL absoluteString]];
}

#pragma mark - DSKVideoPlayerDelegate

- (void)videoPlayerReady:(DSKVideoPlayer*)videoPlayer {
    [self switchVastState:AVStateReady];
}

- (void)videoPlayer:(DSKVideoPlayer*)videoPlayer didFailWithError:(NSError*)error {
    [self switchVastState:AVStateFailLoad error:error];
}

- (void)videoPlayer:(DSKVideoPlayer*)videoPlayer
          sendEvent:(DSKVideoEvent)event {
    switch (event) {
        case DSKVideoEventFinish:       [self switchVastState:AVStateCompleted];                break;
        case DSKVideoEventFirstQurtile: [self trackEvents:self.video.tracking.firstQurtileURL]; break;
        case DSKVideoEventMidpoint:     [self trackEvents:self.video.tracking.midpointURL];     break;
        case DSKVideoEventThirdQurtile: [self trackEvents:self.video.tracking.thirdQurtileURL]; break;
        case DSKVideoEventClick:        [self videoPlayerDidReciveTap:videoPlayer];             break;
        case DSKVideoEventResume:       [self trackEvents:self.video.tracking.resumeURL];       break;
        case DSKVideoEventPause:        [self trackEvents:self.video.tracking.pauseURL];        break;
        default: break;
    }
}

- (void)videoPlayerDidReciveTap:(DSKVideoPlayer*)videoPlayer{
    if (self.video.extension && self.video.extension.videoClickable) {
        [self moreButtonClick];
    }
}

#pragma mark - DSKCustomControlLayerDelegate, DSKCustomControlLayerDataSource

- (void)DSK_clickOnButtonType:(CCType)type{
    switch (type) {
        case CCTypeClose:       [self skipButtonPressed];   break;
        case CCTypeTimerClose:  [self skipButtonPressed];   break;
        case CCTypeUnMute:      [self muteButtonPressed];   break;
        case CCTypeMore:        [self moreButtonClick];     break;
        case CCTypeRepeat:      [self repeatButtonClick];   break;
        default: break;
    }
}

- (NSNumber *)DSK_closeTime{
    NSNumber * closeTime = nil;
    if (![self isRewarded]){
        NSTimeInterval skipInterval = [self.video skippOffset];
        closeTime = @(skipInterval);
    }
    return closeTime;
}

- (BOOL)DSK_isEstimatedInterfaceOritentationInLandscape{
    return self.isEstimatedInterfaceOritentationInLandscape;
}

- (BOOL)DSK_isAutoHideControlls {
    return !(self.video.extension && self.video.extension.videoClickable);
}

- (void)DSK_hidden:(BOOL)hidden alpha:(CGFloat)alpha{
    self.player.progressView.alpha = alpha;
}

@end
