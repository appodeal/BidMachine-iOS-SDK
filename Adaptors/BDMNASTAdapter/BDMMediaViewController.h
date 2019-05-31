//
//  BDMMediaViewController.h
//
//  Copyright © 2016 Appodeal, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DisplayKit/DisplayKit.h>

@interface BDMMediaViewController : UIViewController

- (void)presentFromController:(UIViewController *)controller
                   completion:(void(^)(BOOL muted))completion;

- (instancetype)initWithPlayer:(DSKVideoPlayer *)player;

@end
