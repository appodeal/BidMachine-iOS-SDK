//
//  BDMAdapterProtocol.h
//  BidMachine
//
//  Created by Stas Kochkin on 08/11/2017.
//  Copyright © 2017 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@protocol BDMAdapter;
@protocol BDMFullscreenAdapter;
@protocol BDMBannerAdapter;
@protocol BDMNativeAdServiceAdapter;
@protocol BDMNativeAd;

/**
 Parent adapter delegate protocol
 */
@protocol BDMAdapterLoadingDelegate <NSObject>

/**
 Call when adapter prepare content and ready for present ad
 
 @param adapter Ready adapter
 */
- (void)adapterPreparedContent:(id<BDMAdapter>)adapter;
/**
 Call when adapter failed with error
 
 @param adapter Ready adapter
 @param error Error object
 */
- (void)adapter:(id<BDMAdapter>)adapter failedToPrepareContentWithError:(NSError *)error;
@end


@protocol BDMAdapterDisplayDelegate <NSObject>

/**
 Call when adapter failed to present ad

 @param adapter Adapter that try to present ad
 @param error Erroe object
 */
- (void)adapter:(id<BDMAdapter>)adapter failedToPresentAdWithError:(NSError *)error;
@end

/**
 Parent adapter protocol for get bidding info
 */
@protocol BDMAdapter <NSObject>
/**
 Callback handler object
 */
@property (nonatomic, weak) id<BDMAdapterLoadingDelegate> loadingDelegate;
/**
 Callback handler object
 */
@property (nonatomic, weak) id<BDMAdapterDisplayDelegate> displayDelegate;
/**
 Relative ad network class

 @return Class of relative ad network
 */
- (Class)relativeAdNetworkClass;
/**
 Call this method if adapter need to prepare content
 
 @param contentInfo Custom content info
 */
- (void)prepareContent:(NSDictionary *)contentInfo;
/**
 Getter for raw ad content data string

 @return raw ad content data string
 */
- (NSString *)adContent;

@optional
/**
 Transfoms and populate adunit information for auction
 Need to implement if Third party SDK contains several info
 that Appodeal Ad Exchange SDK doesn't have
 
 @param loadingParameters Recieved information
 @param error Autoreleasing error
 @return Prepared info dictionary
 */
- (NSDictionary *)externalBiddingInformationForLoadingParamters:(NSDictionary *)loadingParameters error:(NSError **)error;

@end


/**
 Banner adapter protocol delegate for rendering inline banner ad
 */
@protocol BDMBannerAdapterDisplayDelegate <BDMAdapterDisplayDelegate>
/**
 Return nonnul root view controller for presenting product page
 and tracking viewability

 @param adapter Current presentig adapter
 @return Nonnul instance root view controller that view is superview of banner
 */
- (UIViewController *)rootViewControllerForAdapter:(id<BDMBannerAdapter>)adapter;
/**
 Called when user tap on banner

 @param adapter Current presentig adapter
 */
- (void)adapterRegisterUserInteraction:(id<BDMBannerAdapter>)adapter;
/**
 Called when adapter open product link in external
 browser (Safari) after user interaction
 
 @param adapter Adapter that revieve user interaction
 */
- (void)adapterWillLeaveApplication:(id<BDMBannerAdapter>)adapter;
/**
 Called before adapter open product link in StoreKit or Safari
 view controller internally in application after user interaction
 
 @param adapter Adapter that revieve user interaction
 */
- (void)adapterWillPresentScreen:(id<BDMBannerAdapter>)adapter;
/**
 Called after adapter dismiss product link in StoreKit or Safari
 view controller internally in application after user interaction
 
 @param adapter Adaoter that revieve user interaction
 */
- (void)adapterDidDismissScreen:(id<BDMBannerAdapter>)adapter;

@end


/**
  Banner adapter protocol for rendering inline banner ad
 */
@protocol BDMBannerAdapter <BDMAdapter>
/**
 Callback handler
 */
@property (nonatomic, weak) id <BDMBannerAdapterDisplayDelegate> displayDelegate;
/**
 Call this method to start rendering banner ad
 @param container Container for presenting ad view
 */
- (void)presentInContainer:(UIView *)container;
@optional
/**
 Remove banner content
 */
- (void)invalidate;
@end

/**
 Fullscreen adapter protocol delegate for rendering banner and video ad
 */
@protocol BDMFullscreenAdapterDisplayDelegate <BDMAdapterDisplayDelegate>
/**
 Return nonnul root view controller for presenting ad content
 and tracking viewability

 @param adapter Current presenting adapter
 @return Nonnul instance root view controller
 */
- (UIViewController *)rootViewControllerForAdapter:(id<BDMFullscreenAdapter>)adapter;
/**
 Called when adapter will present screen

 @param adapter Current presenting adapter
 */
- (void)adapterWillPresent:(id<BDMFullscreenAdapter>)adapter;
/**
 Called when adapter dismiss ad screen

 @param adapter Current presenting adapter
 */
- (void)adapterDidDismiss:(id<BDMFullscreenAdapter>)adapter;
/**
 Called when user interact with adapter

 @param adapter Current presenting adapter
 */
- (void)adapterRegisterUserInteraction:(id<BDMFullscreenAdapter>)adapter;
/**
 Adapter finish reward action (video was fully watched, playable ad complete, etc)

 @param adapter Current presenting adapter
 */
- (void)adapterFinishRewardAction:(id<BDMFullscreenAdapter>)adapter;
@end


/**
 Adapter protocol for rendering fullscreen banner or video ad
 */
@protocol BDMFullscreenAdapter <BDMAdapter>
/**
 Callback handler
 */
@property (nonatomic, weak) id <BDMFullscreenAdapterDisplayDelegate> displayDelegate;
/**
 Getter for presented adView
 
 @return presented adView
 */
- (UIView *)adView;
/**
 Call this method to start present ad
 */
- (void)present;

@optional
/**
 Boolean flag that indicates adapter should perform reward action
 */
@property (nonatomic, assign, readwrite) BOOL rewarded;
/**
 Call this method to destroy ad
 */
- (void)invalidate;

@end


@protocol BDMNativeAdServiceAdapterLoadingDelegate <BDMAdapterLoadingDelegate>

- (void)service:(id<BDMNativeAdServiceAdapter>)service didLoadNativeAds:(NSArray <id<BDMNativeAd>> *)nativeAds;

@end

@protocol BDMNativeAdServiceAdapter <BDMAdapter>

@property (nonatomic, weak) id <BDMNativeAdServiceAdapterLoadingDelegate> loadingDelegate;

@end
