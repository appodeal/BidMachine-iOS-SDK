//
//  BDMBannerPreloadService.m
//
//  Copyright © 2018 Stas Kochkin. All rights reserved.
//

#import "BDMBannerPreloadService.h"
#import "NSError+BDMMRAIDAdapter.h"
#import <ASKExtension/ASKExtension.h>
#import <DisplayKit/DisplayKit.h>


@interface BDMBannerPreloadService ()

@property (nonatomic, weak) id <BDMBannerPreloadServiceDelegate> delegate;

@property (nonatomic, copy) dispatch_block_t preloadBlock;
@property (nonatomic, copy) dispatch_block_t presentBlock;

@property (nonatomic, weak) UIView *container;
@property (nonatomic, strong) DSKSplashScreenView *splashScreen;

@end

@implementation BDMBannerPreloadService

- (instancetype)initWithDelegate:(id<BDMBannerPreloadServiceDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
        self.preload = YES;
        self.closeTime = 10.0f;
    }
    return self;
}

- (void)loadProcess:(dispatch_block_t)preloadBlock {
    self.preloadBlock = [preloadBlock copy];
    if (self.preload) {
        ASK_RUN_BLOCK(preloadBlock);
    } else {
        if ([self.delegate respondsToSelector:@selector(mraidViewAdReady:)]){
            [self.delegate mraidViewAdReady:nil];
        }
    }
}

- (void)presentProcess:(UIView *)container
          preloadBlock:(dispatch_block_t)preloadBlock
{
    self.presentBlock = [preloadBlock copy];
    self.container = container;
    if (self.preload) {
        ASK_RUN_BLOCK(self.presentBlock);
    } else {
        [self startSplashScreenIfNeeded];
        ASK_RUN_BLOCK(self.preloadBlock);
    }
}

#pragma mark - Private

- (void)startSplashScreenIfNeeded {
    if (!self.splashScreen && self.container.subviews.count == 0) {
        self.splashScreen = DSKSplashScreenView.new;
        [self.splashScreen presentViewFrom:self.container withInterval:self.closeTime];
        [self.splashScreen addTarget:self action:@selector(userAction)];
    }
}

- (void)invalidateSplashScreenIfNeeded:(dispatch_block_t)completion {
    if (self.splashScreen) {
        [self.splashScreen dismiss:completion];
        self.splashScreen = nil;
    } else {
        completion ? completion() : nil;
    }
}

#pragma mark - Action

- (void)userAction {
    [self invalidateSplashScreenIfNeeded:nil];
    if ([self.delegate respondsToSelector:@selector(mraidView:failToPresentAdThrowError:)]) {
        NSError * error = NSError.bdm_error(@"Failed to present ad.");
        [self.delegate mraidView:nil failToPresentAdThrowError:error];
    }
}

#pragma mark - SKMRAIDViewDelegate

- (void)mraidViewAdReady:(SKMRAIDView *)mraidView {
    if (self.preload) {
        if ([self.delegate respondsToSelector:@selector(mraidViewAdReady:)]) {
            [self.delegate mraidViewAdReady:mraidView];
        }
    } else {
        __weak typeof(self) weakSelf = self;
        [self invalidateSplashScreenIfNeeded:^{
            ASK_RUN_BLOCK(weakSelf.presentBlock);
        }];
    }
}

- (void)mraidView:(SKMRAIDView *)mraidView failToLoadAdThrowError:(NSError *)error {
    if (self.preload) {
        if ([self.delegate respondsToSelector:@selector(mraidView:failToLoadAdThrowError:)]){
            [self.delegate mraidView:mraidView failToLoadAdThrowError:error];
        }
    } else {
        [self invalidateSplashScreenIfNeeded:nil];
        if ([self.delegate respondsToSelector:@selector(mraidView:failToPresentAdThrowError:)]) {
            [self.delegate mraidView:mraidView failToPresentAdThrowError:error];
        }
    }
}

- (void)mraidViewWillExpand:(SKMRAIDView *)mraidView {
    if ([self.delegate respondsToSelector:@selector(mraidViewWillExpand:)]) {
        [self.delegate mraidViewWillExpand:mraidView];
    }
}

- (void)mraidViewDidClose:(SKMRAIDView *)mraidView {
    if ([self.delegate respondsToSelector:@selector(mraidViewDidClose:)]) {
        [self.delegate mraidViewDidClose:mraidView];
    }
}

- (void)mraidViewNavigate:(SKMRAIDView *)mraidView withURL:(NSURL *)url {
    if ([self.delegate respondsToSelector:@selector(mraidViewNavigate:withURL:)]) {
        [self.delegate mraidViewNavigate:mraidView withURL:url];
    }
}

- (void)mraidView:(SKMRAIDView *)mraidView intersectJsLogMessage:(NSString *)logMessage {
    if ([self.delegate respondsToSelector:@selector(mraidView:intersectJsLogMessage:)]) {
        [self.delegate mraidView:mraidView intersectJsLogMessage:logMessage];
    }
}

- (BOOL)mraidViewShouldResize:(SKMRAIDView *)mraidView
                   toPosition:(CGRect)position
               allowOffscreen:(BOOL)allowOffscreen {
    if ([self.delegate respondsToSelector:@selector(mraidViewShouldResize:
                                                    toPosition:
                                                    allowOffscreen:)]) {
        [self.delegate mraidViewShouldResize:mraidView
                                  toPosition:position
                              allowOffscreen:allowOffscreen];
    }
    return YES;
}

@end
