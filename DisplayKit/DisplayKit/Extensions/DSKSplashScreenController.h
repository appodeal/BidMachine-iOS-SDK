//
//  DSKSplashScreenController.h
//

#import <UIKit/UIKit.h>

@interface DSKSplashScreenController : UIViewController

- (void)addTarget:(id)target action:(SEL)action;

- (void)presentFromViewController:(UIViewController *)controller
                     withInterval:(NSTimeInterval)interval;

- (void)dismiss;

@end
