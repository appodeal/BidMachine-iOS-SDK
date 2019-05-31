//
//  BDMBannerPreloadService.h
//
//  Copyright © 2018 Stas Kochkin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NexageSourceKitMRAID/SKMRAIDView.h>
#import <NexageSourceKitMRAID/SKMRAIDServiceDelegate.h>

@protocol BDMBannerPreloadServiceDelegate <SKMRAIDViewDelegate>

@optional

- (void)mraidView:(SKMRAIDView *)mraidView failToPresentAdThrowError:(NSError *)error;

@end

@interface BDMBannerPreloadService : NSObject <SKMRAIDViewDelegate, SKMRAIDServiceDelegate>

@property (nonatomic, assign) float closeTime;
@property (nonatomic, assign) bool preload;

- (instancetype)initWithDelegate:(id<BDMBannerPreloadServiceDelegate>)delegate;

- (void)loadProcess:(dispatch_block_t)preloadBlock;
- (void)presentProcess:(UIView *)container preloadBlock:(dispatch_block_t)preloadBlock;

@end
