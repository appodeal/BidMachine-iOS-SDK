//
//  BDMBannerView.h
//  BidMachine
//
//  Created by Stas Kochkin on 10/11/2017.
//  Copyright © 2017 Appodeal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BidMachine/BDMRequest.h>
#import <BidMachine/BDMAuctionInfo.h>
#import <BidMachine/BDMDefines.h>
#import <BidMachine/BDMAdEventProducerProtocol.h>
#import <BidMachine/BDMAdRequests.h>


@class BDMBannerView;

/**
 Banner view callback handler protocol
 */
@protocol BDMBannerDelegate <NSObject>
@required
/**
 Called when banner ready tp render creative on screen

 @param bannerView Ready to present banner view
 */
- (void)bannerViewReadyToPresent:(nonnull BDMBannerView *)bannerView;
/**
 Called in case if banner view failed to load

 @param bannerView Failed instance of banner view
 @param error Error object
 */
- (void)bannerView:(nonnull BDMBannerView *)bannerView failedWithError:(nonnull NSError *)error;
/**
 Called when user interact with banner

 @param bannerView Ready banner view
 */
- (void)bannerViewRecieveUserInteraction:(nonnull BDMBannerView *)bannerView;
@optional
/**
 Called when banner view ready for present
 
 @param bannerView Ready for present instance of BDMBannerView
 @param auctionInfo Auction info
 */
- (void)bannerView:(nonnull BDMBannerView *)bannerView readyToPresentAd:(nonnull BDMAuctionInfo *)auctionInfo __attribute__((deprecated("Use -bannerViewReadyToPresent: instead")));
/**
 Called in case banner perform request by itself
 when instance of banner view expired
 
 @param bannerView banner view
 */
- (void)bannerViewDidExpire:(nonnull BDMBannerView *)bannerView;
/**
 Called when banner open product link in external
 browser (Safari) after user interaction

 @param bannerView Banner that revieve user interaction
 */
- (void)bannerViewWillLeaveApplication:(nonnull BDMBannerView *)bannerView;
/**
 Called before banner open product link in StoreKit or Safari
 view controller internally in application after user interaction

 @param bannerView Banner that revieve user interaction
 */
- (void)bannerViewWillPresentScreen:(nonnull BDMBannerView *)bannerView;
/**
 Called after banner dissmis product link in StoreKit or Safari
 view controller internally in application after user interaction

 @param bannerView Banner that revieve user interaction
 */
- (void)bannerViewDidDismissScreen:(nonnull BDMBannerView *)bannerView;
@end

/**
 View for present inline banner ad
 */
@interface BDMBannerView : UIView <BDMAdEventProducer>
/**
 Delegate of producer
 */
@property (nonatomic, weak, nullable) id<BDMAdEventProducerDelegate> producerDelegate;
/**
 Calback handler
 */
@property (nonatomic, weak, nullable) id<BDMBannerDelegate> delegate;
/**
 Root view controller for present modal controllers and
 viewability tracking
 */
@property (nonatomic, weak, nullable) IBOutlet UIViewController * rootViewController;
/**
 Info of latest sucessful auctuion
 */
@property (nonatomic, copy, readonly, nullable) BDMAuctionInfo * latestAuctionInfo;
/**
 Banner ad size
 */
@property (nonatomic, assign, readwrite) BDMBannerAdSize adSize __attribute__((deprecated("Use BDMBannerRequest.adSize instead")));
/**
 Getter that indicates that ad ready or not
 */
@property (nonatomic, assign, readonly, getter=isLoaded) BOOL loaded;
/**
 Boolean flag indicates can SDK show ad or not
 */
@property (nonatomic, assign, readonly) BOOL canShow;
/**
 Call this method to perform auction

 @param request Reuest object
 */
- (void)makeRequest:(nonnull BDMRequest *)request __attribute__((deprecated("Use -populateWithRequest: instead")));
/**
 Add request to ad object instance. If request not was not
 performed, ad object will perform by itslef

 @param request Request
 */
- (void)populateWithRequest:(nonnull BDMBannerRequest *)request;
@end
