//
//  BDMInterstitial.h
//  BidMachine
//
//  Created by Stas Kochkin on 07/11/2017.
//  Copyright © 2017 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <BidMachine/BDMRequest.h>
#import <BidMachine/BDMAuctionInfo.h>
#import <BidMachine/BDMAdEventProducerProtocol.h>
#import <BidMachine/BDMAdRequests.h>


@class BDMInterstitial;

/**
 Interstitial callback handler protocol
 */
@protocol BDMInterstitialDelegate <NSObject>
/**
 Called when interstitial ready to present creative on screen
 
 @param interstitial Ready to present rewarded
 */
- (void)interstitialReadyToPresent:(nonnull BDMInterstitial *)interstitial;
/**
 Trigger fail to load event

 @param interstitial Failed instance of interstitial ad
 @param error Error object that contains information about fail reason
 */
- (void)interstitial:(nonnull BDMInterstitial *)interstitial failedWithError:(nonnull NSError *)error;
/**
 Trigger fail to present event
 
 @param interstitial Failed instance of interstitial ad
 @param error Error object that contains information about fail reason
 */
- (void)interstitial:(nonnull BDMInterstitial *)interstitial failedToPresentWithError:(nonnull NSError *)error;
/**
 Trigger when interstitial present creative

 @param interstitial Presenting instance of interstitial ad
 */
- (void)interstitialWillPresent:(nonnull BDMInterstitial *)interstitial;
/**
 Trigger when interstitial was closed

 @param interstitial Presented instance of interstitial ad
 */
- (void)interstitialDidDismiss:(nonnull BDMInterstitial *)interstitial;
/**
 Trigger when interstitial register user interaction with creative

 @param interstitial Presenting instance of interstitial ad
 */
- (void)interstitialRecieveUserInteraction:(nonnull BDMInterstitial *)interstitial;
@optional
/**
 Trigger ready event
 
 @param interstitial Ready instance of interstitial ad
 @param auctionInfo Auction info
 */
- (void)interstitial:(nonnull BDMInterstitial *)interstitial
    readyToPresentAd:(nonnull BDMAuctionInfo *)auctionInfo __attribute__((deprecated("Use -interstitialReadyToPresent: instead")));
/**
 Trigger when interstitial did expire
 
 @param interstitial Expired instance of interstitial
 */
- (void)interstitialDidExpire:(nonnull BDMInterstitial *)interstitial;
@end


/**
 Object to present regular interstitial ad
 */
@interface BDMInterstitial : NSObject <BDMAdEventProducer>
/**
 Delegate of producer
 */
@property (nonatomic, weak, nullable) id<BDMAdEventProducerDelegate> producerDelegate;
/**
 Specify ad type of interstitial
 */
@property (nonatomic, assign, readwrite) BDMFullscreenAdType type __attribute__((deprecated("Use BDMInterstitialRequest.adSize instead")));
/**
 Info of latest sucessful auctuion
 */
@property (nonatomic, copy, readonly, nullable) BDMAuctionInfo * auctionInfo;
/**
 Callback handler
 */
@property (nonatomic, weak, nullable) id<BDMInterstitialDelegate> delegate;
/**
 Boolean flag indicates ad availability
 */
@property (nonatomic, assign, readonly, getter=isLoaded) BOOL loaded;
/**
 Boolean flag indicates can SDK show ad or not
 */
@property (nonatomic, assign, readonly) BOOL canShow;
/**
 Presented ad view. If ad not on screen this property are nil
 */
@property (nonatomic, readonly, nullable) UIView * adView;
/**
 Begin loading of interstitial ad

 @param request Request with mediation specific parameters
 */
- (void)makeRequest:(nonnull BDMRequest *)request __attribute__((deprecated("Use -populateWithRequest: instead")));
/**
 Add request to ad object instance. If request not was not
 performed, ad object will perform by itslef
 
 @param request Request
 */
- (void)populateWithRequest:(nonnull BDMInterstitialRequest *)request;
/**
 Begin presentation of ad if it's available

 @param rootViewController view controller for presentation
 */
- (void)presentFromRootViewController:(nonnull UIViewController *)rootViewController;
/**
 Remove all loaded ad data
 */
- (void)invalidate;
@end
