//
//  BDMInterstitialPreloadService.h
//
//  Copyright © 2018 Stas Kochkin. All rights reserved.
//

#import <NexageSourceKitMRAID/SKMRAIDInterstitial.h>
#import <NexageSourceKitMRAID/SKMRAIDServiceDelegate.h>

@protocol BDMInterstitialPreloadServiceDelegate <SKMRAIDInterstitialDelegate>

@optional

- (void)mraidInterstitial:(SKMRAIDInterstitial *)mraidInterstitial failToPresentAdThrowError:(NSError *)error;

@end

@interface BDMInterstitialPreloadService : NSObject <SKMRAIDInterstitialDelegate, SKMRAIDServiceDelegate>

@property (nonatomic, assign) float closeTime;
@property (nonatomic, assign) bool preload;

- (instancetype)initWithDelegate:(id<BDMInterstitialPreloadServiceDelegate>)delegate;

- (void)loadProcess:(dispatch_block_t)preloadBlock;
- (void)presentProcess:(UIViewController *)controller preloadBlock:(dispatch_block_t)preloadBlock;

@end
