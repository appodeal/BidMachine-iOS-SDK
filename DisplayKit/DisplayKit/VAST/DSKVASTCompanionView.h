//
//  DSKVastCompanionView.h
//  OpenBids
//

//  Copyright © 2016 OpenBids, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DSKVASTCompanion.h"

@class DSKVASTCompanionView;

@protocol DSKVASTCompanionViewDelegate <NSObject>

- (void)companionViewDidReciveTap:(DSKVASTCompanionView *)companionView destanationURL:(NSURL *)URL;

@optional

- (void)staticCompanionViewDidReciveTap:(DSKVASTCompanionView *)companionView;

- (void)mraidCompanionViewDidLoad:(DSKVASTCompanionView *) companionView;
- (void)mraidCompanionViewDidDismiss:(DSKVASTCompanionView *)companionView;
- (void)mraidCompanionDidFailToLoad:(DSKVASTCompanionView *)companionView;
- (void)mraidCompanion:(DSKVASTCompanionView *)companionView useCustomClose:(BOOL)useCustomClose;

@end

@interface DSKVASTCompanionView : UIView

@property (nonatomic, weak) id<DSKVASTCompanionViewDelegate> delegate;
@property (nonatomic, assign, readonly) DSKVASTAspectRatio aspectRatio;

+ (DSKVASTCompanionView *)extentionCompanionFromCompanion:(DSKVASTCompanion *)companion
                                       rootViewController:(UIViewController *)controller;

+ (DSKVASTCompanionView *)bannerCompanionFromArray:(NSArray *)companionArray
                                rootViewController:(UIViewController *)controller;

+ (DSKVASTCompanionView *)companionViewFromArray:(NSArray *)companions
                              rootViewController:(UIViewController *)controller
                                     aspectRatio:(DSKVASTAspectRatio)aspectRatio;

+ (DSKVASTCompanionView *)companionViewFromImage:(UIImage *)staticImage
                              rootViewController:(UIViewController *)controller
                                     aspectRatio:(DSKVASTAspectRatio)aspectRatio;

- (void)load;
- (void)show;
- (void)hide;

- (void)sendImpression;

@end
