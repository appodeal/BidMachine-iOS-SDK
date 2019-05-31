//
//  BDMRewarded.h
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


@class BDMRewarded;

/**
 rewarded callback handler protocol
 */
@protocol BDMRewardedDelegate <NSObject>
@required
/**
 Called when rewarded ready to present creative on screen
 
 @param rewarded Ready to present rewarded
 */
- (void)rewardedReadyToPresent:(nonnull BDMRewarded *)rewarded;
/**
 Trigger fail to load event
 
 @param rewarded Failed instance of rewarded ad
 @param error Error object that contains information about fail reason
 */
- (void)rewarded:(nonnull BDMRewarded *)rewarded failedWithError:(nonnull NSError *)error;
/**
 Trigger fail to present event
 
 @param rewarded Failed instance of rewarded ad
 @param error Error object that contains information about fail reason
 */
- (void)rewarded:(nonnull BDMRewarded *)rewarded failedToPresentWithError:(nonnull NSError *)error;
/**
 Trigger when rewarded present creative
 
 @param rewarded Presenting instance of rewarded ad
 */
- (void)rewardedWillPresent:(nonnull BDMRewarded *)rewarded;
/**
 Trigger when rewarded was closed
 
 @param rewarded Presented instance of rewarded ad
 */
- (void)rewardedDidDismiss:(nonnull BDMRewarded *)rewarded;
/**
 Trigger when rewarded register user interaction with creative
 
 @param rewarded Presenting instance of rewarded ad
 */
- (void)rewardedRecieveUserInteraction:(nonnull BDMRewarded *)rewarded;
/**
 Trigger when rewarded register completion of reward action in creative
 
 @param rewarded Presenting rewarded adinterstitial
 */
- (void)rewardedFinishRewardAction:(nonnull BDMRewarded *)rewarded;
@optional
/**
 Trigger ready event
 
 @param rewarded Ready instance of rewarded ad
 @param auctionInfo Auction info
 */
- (void)rewarded:(nonnull BDMRewarded *)rewarded
readyToPresentAd:(nonnull BDMAuctionInfo *)auctionInfo __attribute__((deprecated("Use -rewardedViewReadyToPresent: instead")));
/**
 Trigger when rewarded did expire
 
 @param rewarded Expired instance of rewarded
 */
- (void)rewardedDidExpire:(nonnull BDMRewarded *)rewarded;
@end

/**
 Object to present regular rewarded ad
 */
@interface BDMRewarded : NSObject <BDMAdEventProducer>
/**
 Delegate of producer
 */
@property (nonatomic, weak, nullable) id<BDMAdEventProducerDelegate> producerDelegate;
/**
 Callback handler
 */
@property (nonatomic, weak, nullable) id<BDMRewardedDelegate> delegate;
/**
 Info of latest sucessful auctuion
 */
@property (nonatomic, copy, readonly, nullable) BDMAuctionInfo * auctionInfo;
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
 Begin loading of rewarded ad
 
 @param request Request with mediation specific parameters
 */
- (void)makeRequest:(nonnull BDMRequest *)request __attribute__((deprecated("Use -populateWithRequest: instead")));
/**
 Add request to ad object instance. If request not was not
 performed, ad object will perform by itslef
 
 @param request Request
 */
- (void)populateWithRequest:(nonnull BDMRewardedRequest *)request;
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
