//
//  DSKVASTController.h
//  OpenBids
//

//  Copyright © 2016 OpenBids, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DSKVASTAutoRotationViewController.h"

@class DSKVASTController;

@protocol DSKVASTControllerDelegate <NSObject>

- (void)vastControllerReady:(DSKVASTController *)controller;
- (void)vastController:(DSKVASTController *)controller didFailToLoad:(NSError *)error;
- (void)vastController:(DSKVASTController *)controller didFailWhileShow:(NSError *)error;
- (void)vastControllerDidPresent:(DSKVASTController *)controller;
- (void)vastControllerDidClick:(DSKVASTController *)controller clickURL:(NSString *)clickURL;
- (void)vastControllerDidFinish:(DSKVASTController *)controller;
- (void)vastControllerDidSkip:(DSKVASTController *)controller;
- (void)vastControllerDidDismiss:(DSKVASTController *)controller;

- (BOOL)isRewarded; // Default set to NO
- (BOOL)isAutoclose;
- (NSNumber *)closeTime; //Settings for PlayingVideo

@optional

- (NSString *)placementId;
- (NSString *)segmentId;

@end

@interface DSKVASTController : DSKVASTAutoRotationViewController

@property (nonatomic, weak) id <DSKVASTControllerDelegate> delegate;

@property (nonatomic, strong, readonly) NSString * adCreative;

- (void)loadForVastURL:(NSURL *)vastURL;
- (void)loadForVastXML:(NSData *)XML;
- (void)presentFromViewController:(UIViewController *)viewController;

- (void)pause;
- (void)resume;

@end
