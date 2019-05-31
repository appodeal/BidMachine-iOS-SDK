//
//  BDMInterstitialPreloadService.m
//
//  Copyright © 2018 Stas Kochkin. All rights reserved.
//

#import "BDMInterstitialPreloadService.h"
#import "NSError+BDMMRAIDAdapter.h"
#import <ASKExtension/ASKExtension.h>
#import <DisplayKit/DisplayKit.h>

@interface BDMInterstitialPreloadService ()

@property (nonatomic, weak) id<BDMInterstitialPreloadServiceDelegate> delegate;

@property (nonatomic, copy) dispatch_block_t preloadBlock;
@property (nonatomic, copy) dispatch_block_t presentBlock;

@property (nonatomic, weak) UIViewController *controller;
@property (nonatomic, strong) DSKSplashScreenController *splashScreen;

@end

@implementation BDMInterstitialPreloadService

- (instancetype)initWithDelegate:(id<BDMInterstitialPreloadServiceDelegate>)delegate {
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
        ASK_RUN_BLOCK(self.preloadBlock);
    } else {
        if ([self.delegate respondsToSelector:@selector(mraidInterstitialAdReady:)]){
            [self.delegate mraidInterstitialAdReady:nil];
        }
    }
}

- (void)presentProcess:(UIViewController *)controller
          preloadBlock:(dispatch_block_t)preloadBlock
{
    self.presentBlock = preloadBlock;
    self.controller = controller;
    if (self.preload) {
        ASK_RUN_BLOCK(self.presentBlock);
    } else {
        [self startSplashScreenIfNeeded];
        ASK_RUN_BLOCK(self.preloadBlock);
    }
}

#pragma mark - Private

- (void)startSplashScreenIfNeeded {
    if (!self.splashScreen) {
        self.splashScreen = DSKSplashScreenController.new;
        [self.splashScreen addTarget:self action:@selector(userAction)];
        [self.splashScreen presentFromViewController:self.controller
                                        withInterval:self.closeTime];
    }
}

- (void)invalidateSplashScreenIfNeeded {
    if (self.splashScreen) {
        [self.splashScreen dismiss];
        self.splashScreen = nil;
    }
}

#pragma mark - Action

- (void)userAction {
    [self invalidateSplashScreenIfNeeded];
    if ([self.delegate respondsToSelector:@selector(mraidInterstitial:failToPresentAdThrowError:)]) {
        NSError * error = NSError.bdm_error(@"Failed to present ad.");
        [self.delegate mraidInterstitial:nil failToPresentAdThrowError:error];
    }
}

#pragma mark - SKMRAIDInterstitialDelegate

- (void)mraidInterstitialAdReady:(SKMRAIDInterstitial *)mraidInterstitial {
    if (self.preload) {
        if ([self.delegate respondsToSelector:@selector(mraidInterstitialAdReady:)]) {
            [self.delegate mraidInterstitialAdReady:mraidInterstitial];
        }
    } else {
        [self invalidateSplashScreenIfNeeded];
        ASK_RUN_BLOCK(self.presentBlock);
    }
}

- (void)mraidInterstitialAdFailed:(SKMRAIDInterstitial *)mraidInterstitial {
    if (self.preload) {
        if ([self.delegate respondsToSelector:@selector(mraidInterstitialAdFailed:)]){
            [self.delegate mraidInterstitialAdFailed:mraidInterstitial];
        }
    } else {
        [self invalidateSplashScreenIfNeeded];
        if ([self.delegate respondsToSelector:@selector(mraidInterstitial:failToPresentAdThrowError:)]) {
            NSError * error = NSError.bdm_error(@"Failed to present ad.");
            [self.delegate mraidInterstitial:mraidInterstitial failToPresentAdThrowError:error];
        }
    }
}

- (void)mraidInterstitialWillShow:(SKMRAIDInterstitial *)mraidInterstitial {
    if ([self.delegate respondsToSelector:@selector(mraidInterstitialWillShow:)]) {
        [self.delegate mraidInterstitialWillShow:mraidInterstitial];
    }
}

- (void)mraidInterstitialDidHide:(SKMRAIDInterstitial *)mraidInterstitial {
    if ([self.delegate respondsToSelector:@selector(mraidInterstitialDidHide:)]) {
        [self.delegate mraidInterstitialDidHide:mraidInterstitial];
    }
}

- (void)mraidInterstitialNavigate:(SKMRAIDInterstitial *)mraidInterstitial withURL:(NSURL *)url {
    if ([self.delegate respondsToSelector:@selector(mraidInterstitialNavigate:withURL:)]) {
        [self.delegate mraidInterstitialNavigate:mraidInterstitial withURL:url];
    }
}

- (void)mraidInterstitial:(SKMRAIDInterstitial *)mraidInterstitial intersectJsLogMessage:(NSString *)logMessage {
    if ([self.delegate respondsToSelector:@selector(mraidInterstitial:intersectJsLogMessage:)]) {
        [self.delegate mraidInterstitial:mraidInterstitial intersectJsLogMessage:logMessage];
    }
}

- (void)mraidInterstitial:(SKMRAIDInterstitial *)mraidInterstitial useCustomClose:(BOOL)customClose {
    if ([self.delegate respondsToSelector:@selector(mraidInterstitial:useCustomClose:)]) {
        [self.delegate mraidInterstitial:mraidInterstitial useCustomClose:customClose];
    }
}

@end
