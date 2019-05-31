//
//  DSKVideoPlayer.m
//  DSKVideoPlayer
//  OpenBids
//
//  Copyright © 2016 OpenBids, Inc. All rights reserved.
//

#import <ASKDiskUtils/ASKDataCacher.h>
#import <ASKLogger/ASKLogger.h>
#import <ASKExtension/NSString+ASKExtension.h>
#import <ASKExtension/NSError+ASKExtension.h>

#import "DSKVideoPlayer.h"
#import "UIView+DSKConstraint.h"
#import "DSKConstraintMaker+Private.h"


#define DSK_VIDEO_ERROR [NSError ask_errorWithDescription:@"DSKVideoPlayer crashed"]

#define __DSK_IS_IOS8_4_AND_LOW ([[UIDevice currentDevice].systemVersion floatValue] <= 8.4)

typedef NS_ENUM(NSInteger, DSKVideoProgress) {
    DSKZero = 0,
    DSKFirstQurtile,
    DSKMidpoint,
    DSKThirdQurtile
};


typedef NS_ENUM(NSInteger, DSKFileType) {
    DSKFileTypeURL = 0,
    DSKFileTypeLocal
};





static void *DSKAVPlayerPlaybackRateObservationContext = &DSKAVPlayerPlaybackRateObservationContext;


@interface DSKVideoPlayer ()

@property (nonatomic, strong) AVPlayer* player;
@property (nonatomic, strong) NSURL* videoUrl;
@property (nonatomic, strong) id playerTimeObserver;
@property (nonatomic, strong) UITapGestureRecognizer* tap;

@property (nonatomic, assign) DSKVideoProgress progress;
@property (nonatomic, assign) DSKFileType fileType;

@end

@implementation DSKVideoPlayer

#pragma mark - Player

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (AVPlayer*)player {
    return [(AVPlayerLayer *)[self layer] player];
}

- (void)setPlayer:(AVPlayer *)player {
    [(AVPlayerLayer *)[self layer] setPlayer:player];
}

- (void)setProgressBarHidden:(BOOL)progressBarHidden{
    _progressBarHidden = progressBarHidden;
    self.progressView.hidden = YES;
}

#pragma mark - Lifecycle

- (instancetype)init {
    self = [super init];
    if (self){
        self.layer.backgroundColor = [UIColor blackColor].CGColor;
        self.clipsToBounds = YES;
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    return self;
}

- (void)dealloc {
    ASKLogInfo(@"Video player deallocated");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self finishObsering];
}

#pragma mark - Public

- (void)loadWithURL:(NSURL *)videoURL {
    self.fileType = DSKFileTypeURL;
    [self cacheVideoFromUrl:[videoURL copy]];
}

- (void)prepareToPlayWithLocalURL:(NSURL *)url {
    self.fileType = DSKFileTypeLocal;
    self.videoUrl = [url copy];
    [self videoReady];
}

- (void)invalidate {
    [self.player pause];
    [self finishObsering];
    if (self.playerTimeObserver) {
        [self.player removeTimeObserver:self.playerTimeObserver];
        self.playerTimeObserver = nil;
    }
}

- (void)play {
    [self.player play];
    self.progress = DSKZero;
    ASKLogInfo(@"Video started playing");
    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    self.progressView.progressTintColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.9f];
    self.progressView.backgroundColor = [UIColor clearColor];
    self.progressView.progress = 0.0;
    self.progressView.hidden = self.progressBarHidden;
    [self addSubview:self.progressView];
    
    self.progressView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [[self.progressView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor] setActive:YES];
    [[self.progressView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor] setActive:YES];
    [[self.progressView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor] setActive:YES];
    [[self.progressView.heightAnchor constraintEqualToConstant:1.5] setActive:YES];

    CMTime interval = CMTimeMakeWithSeconds(0.015, NSEC_PER_SEC); // 60 FPS
    
    __weak typeof(self) weakSelf = self;
    self.playerTimeObserver = [self.player addPeriodicTimeObserverForInterval:interval
                                                                        queue:NULL
                                                                   usingBlock:^(CMTime time) {
                                                                       __strong typeof(self) strongSelf = weakSelf;
                                                                       [strongSelf processEvent];
                                                                       [strongSelf updateProgress];
                                                                   }];
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleClick)];
    tap.numberOfTapsRequired = 1;
    self.userInteractionEnabled = YES;
    
    
    [self startOberving];
    
    [self addGestureRecognizer:tap];
    self.tap = tap;
}

- (void)resume {
    [self.player play];
}

- (void)pause {
    [self.player pause];
}

- (void)repeat {
    [self stop];
    [self play];
}

- (void)setMute:(BOOL)mute {
    ASKLogInfo(@"Video mute: %@", mute ? @"YES" : @"NO");
    self.player.volume = mute ? 0.0f : 1.0f;
    _mute = mute;
}

- (void)stop {
    [self.player pause];
    [self.player seekToTime: kCMTimeZero];
    [self.progressView removeFromSuperview];
    self.progressView = nil;
    [self removeGestureRecognizer: self.tap];
    if (self.playerTimeObserver) {
        [self.player removeTimeObserver:self.playerTimeObserver];
        self.playerTimeObserver = nil;
    }
}

- (float)duration {
    if (CMTimeGetSeconds(self.player.currentItem.duration))
        return CMTimeGetSeconds(self.player.currentItem.duration);
    return 0;
}

- (float)currentTime {
    if (CMTimeGetSeconds(self.player.currentItem.currentTime))
        return CMTimeGetSeconds(self.player.currentItem.currentTime);
    return 0;
}

#pragma mark - Playback Observing

- (void)startOberving {
    @try {
        [self.player removeObserver:self forKeyPath:@"rate"];
    } @catch (NSException *exception) {
    } @finally {
        [self.player addObserver:self
                      forKeyPath:@"rate"
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:DSKAVPlayerPlaybackRateObservationContext];
    }
}

- (void)finishObsering {
    @try {
        [self.player removeObserver:self forKeyPath:@"rate"];
    } @catch (NSException *exception) {}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (object != self.player) {
        return;
    }
    
    if (![self.player rate]) {
        [self.delegate videoPlayer:self sendEvent:DSKVideoEventPause];
        ASKLogInfo(@"Video player paused");
    } else {
        [self.delegate videoPlayer:self sendEvent:DSKVideoEventResume];
        ASKLogInfo(@"Video player resumed");
    }
}

#pragma mark - Private

- (void)handleClick {
    ASKLogInfo(@"Video was clicked");
   
    if (!self.player.rate) {
        [self resume];
    } else {
        [self.delegate videoPlayer:self sendEvent:DSKVideoEventClick];
    }
}

- (void)updateProgress {
    [self.progressView setProgress: [self currentTime]/[self duration]];
}

- (void)processEvent {
    float duration = [self duration];
    float currentTime = [self currentTime];
    float percenOfView =  currentTime*100/duration;
    
    if (percenOfView > 25.0 && self.progress < DSKFirstQurtile) {
        self.progress = DSKFirstQurtile;
        [self.delegate videoPlayer:self sendEvent:DSKVideoEventFirstQurtile];
        ASKLogInfo(@"Video reached First Quartile");
    } else if (percenOfView > 50.0 && self.progress < DSKMidpoint) {
        self.progress = DSKMidpoint;
        [self.delegate videoPlayer:self sendEvent:DSKVideoEventMidpoint];
        ASKLogInfo(@"Video reached Midpoint");
    } else if (percenOfView > 75.0 && self.progress < DSKThirdQurtile) {
        self.progress = DSKThirdQurtile;
        [self.delegate videoPlayer:self sendEvent:DSKVideoEventThirdQurtile];
        ASKLogInfo(@"Video reached Third Quartile");
    }
}

- (dispatch_queue_t)workQueue {
    static dispatch_once_t queueCreationGuard;
    static dispatch_queue_t queue;
    dispatch_once(&queueCreationGuard, ^{
        queue = dispatch_queue_create("com.appodealplayer.workqueue", 0);
    });
    return queue;
}

- (void)videoReady {
    __weak typeof(self) weakSelf = self;
    dispatch_sync([self workQueue], ^{
        AVAsset* asset = [AVAsset assetWithURL:self.videoUrl];
        if __DSK_IS_IOS8_4_AND_LOW {
        [asset loadValuesAsynchronouslyForKeys:@[@"duration"] completionHandler:^{
            __strong typeof(self) strongSelf = weakSelf;
            [strongSelf setAsset:asset];
            }];
        }
        else {
            __strong typeof(self) strongSelf = weakSelf;
            [strongSelf setAsset:asset];
        }
    });
}

- (void)setAsset:(AVAsset *)asset {
    __weak typeof(self) weakSelf = self;
    if ([[asset tracksWithMediaType:AVMediaTypeVideo] count] == 0){
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(self) strongSelf = weakSelf;
            [strongSelf playerItemDidFail:nil];
        });
        return;
    }
    
    AVPlayerItem* playerItem = [AVPlayerItem playerItemWithAsset:asset];
    AVPlayer* player = [AVPlayer playerWithPlayerItem:playerItem];
    player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    player.volume = self.mute ? 0.0f : 1.0f;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf setPlayer:player];
        [strongSelf addObservers];
        ASKLogInfo(@"Video is ready");
        if ([self.delegate respondsToSelector:@selector(videoPlayerReady:)]) {
            [self.delegate videoPlayerReady:self];
        }
        
    });
}

- (void)itemDidFinishPlaying:(NSNotification*)notification {
    ASKLogInfo(@"Video was finished");
    [self.delegate videoPlayer:self sendEvent:DSKVideoEventFinish];
}

- (void)playerItemDidFail:(NSNotification*)notification {
    [self invalidate];
    if ([self.delegate respondsToSelector:@selector(videoPlayer:didFailWithError:)]){
        [self.delegate videoPlayer:self didFailWithError: DSK_VIDEO_ERROR];
    }
}

- (void)cacheVideoFromUrl:(NSURL*)url {
    __weak typeof(self) weakSelf = self;
    ASKDataCacher.cacheURL(url,  ^(ASKFile *file){
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf.videoUrl = url;
        [strongSelf videoReady];
    }, ^(NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        if ([strongSelf.delegate respondsToSelector:@selector(videoPlayer:didFailWithError:)]){
            [strongSelf.delegate videoPlayer:strongSelf didFailWithError:error];
        }
    });
}


#pragma mark - Helpers

- (void) addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(itemDidFinishPlaying:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[self.player currentItem]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidFail:)
                                                 name:AVPlayerItemFailedToPlayToEndTimeNotification
                                               object:[self.player currentItem]];
}

- (UIImage *)takeScreenshot {
    if (!self.player.currentItem.asset) {
        return nil;
    }
    
    CMTime time = self.player.currentTime;
    
    if (self.currentTime >= self.duration) {
        float sec = self.duration / 2;
        int32_t scale = self.player.currentItem.duration.timescale;
        time = CMTimeMakeWithSeconds(sec, scale);
    }
    
    AVAsset *asset = self.player.currentItem.asset;
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    imageGenerator.requestedTimeToleranceAfter = kCMTimeZero;
    imageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
    CGImageRef thumb = [imageGenerator copyCGImageAtTime:time
                                              actualTime:NULL
                                                   error:NULL];
    UIImage *videoImage = [UIImage imageWithCGImage:thumb];
    CGImageRelease(thumb);
    return videoImage;
}

@end
