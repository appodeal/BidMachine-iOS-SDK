//
//  DSKVideoPlayer.h
//  OpenBids
//

//  Copyright © 2016 OpenBids, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSInteger, DSKVideoEvent) {
    DSKVideoEventStart = 0,
    DSKVideoEventFirstQurtile,
    DSKVideoEventMidpoint,
    DSKVideoEventThirdQurtile,
    DSKVideoEventFinish,
    DSKVideoEventClick,
    DSKVideoEventPause,
    DSKVideoEventResume
};

@class DSKVideoPlayer;

@protocol DSKVideoPlayerDelegate <NSObject>

- (void)videoPlayerReady:(DSKVideoPlayer*)videoPlayer;
- (void)videoPlayer:(DSKVideoPlayer*)videoPlayer didFailWithError:(NSError*)error;
- (void)videoPlayer:(DSKVideoPlayer*)videoPlayer sendEvent:(DSKVideoEvent)event;

@end

@interface DSKVideoPlayer : UIView

@property (nonatomic, weak) id<DSKVideoPlayerDelegate> delegate;

@property (nonatomic, strong) UIProgressView* progressView;
@property (nonatomic, assign) BOOL progressBarHidden;
@property (nonatomic, assign) BOOL mute;

- (void)loadWithURL:(NSURL*)videoURL;
- (void)prepareToPlayWithLocalURL:(NSURL *)url;
- (void)play;
- (void)pause;
- (void)resume;
- (void)stop;
- (void)repeat;
- (void)invalidate;

- (float)duration;
- (float)currentTime;

- (UIImage *)takeScreenshot;

@end
