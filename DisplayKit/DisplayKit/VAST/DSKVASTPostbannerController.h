//
//  DSKVASTPostbannerController.h
//  OpenBids

//  Copyright © 2017 OpenBids, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DSKVASTCompanion.h"
#import "DSKVASTAutoRotationViewController.h"

@class DSKVASTPostbannerController;

@protocol DSKVASTPostbannerControllerDelegate <NSObject>

- (void)postbannerDidReciveTap:(DSKVASTPostbannerController *)postbanner destanationURL:(NSURL *)URL;
- (void)postbannerDidLoad:(DSKVASTPostbannerController *)postbanner;
- (void)postbanner:(DSKVASTPostbannerController *)postbanner didFailToLoadWithError:(NSError *)error;
- (void)postbannerDidHide:(DSKVASTPostbannerController *)postbanner;
- (void)postbannerDidRepeatAction:(DSKVASTPostbannerController *)postbanner;
- (void)postbannerDidMoreAction:(DSKVASTPostbannerController *)postbanner;

@optional

- (NSNumber *)postbannerCloseTime;

@end

@interface DSKVASTPostbannerController : DSKVASTAutoRotationViewController

@property (nonatomic, weak) id<DSKVASTPostbannerControllerDelegate> delegate;

+ (DSKVASTPostbannerController *)controllerFromCompanions:(NSArray *)companions
                                       rootViewController:(UIViewController *)controller
                                              aspectRatio:(DSKVASTAspectRatio)aspectRatio;

+ (DSKVASTPostbannerController *)controllerFromScreen:(UIImage *)screen
                                   rootViewController:(UIViewController *)controller
                                          aspectRatio:(DSKVASTAspectRatio)aspectRatio;


- (void)show;

@end
