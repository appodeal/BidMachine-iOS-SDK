//
//  BDMSdk.h
//  BidMachine
//
//  Created by Stas Kochkin on 07/11/2017.
//  Copyright © 2017 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BidMachine/BDMSdkConfiguration.h>

/**
 Poxy object that provides communcation between bidding and networks adapter
 */
@interface BDMSdk : NSObject
/**
 Boolean getter that indicated that sdk ready for auction
 */
@property (nonatomic, assign, readonly, getter=isInitialized) BOOL initialized;
/**
 Enable logging. by default logging disabled
 */
@property (nonatomic, assign, readwrite) BOOL enableLogging;
/**
 Restrictions
 */
@property (copy, nonatomic, readwrite, nullable) BDMUserRestrictions * restrictions;


+ (nonnull instancetype)new NS_UNAVAILABLE;
- (nonnull instancetype)init NS_UNAVAILABLE;
/**
 Singelton sdk object
 
 @return Shared instance
 */
+ (nonnull instancetype)sharedSdk;
/**
 Starts session with publisher id
 
 @param sellerID Your seller id registered in exchange dashboard
 @param completion Called then sdk complete initialisation actions
 */
- (void)startSessionWithSellerID:(nonnull NSString *)sellerID
                      completion:(void(^ _Nullable)(void))completion;
/**
 Starts session with publisher id and configured start data
 
 @param sellerID Your publisher id registered in exchange dashboard
 @param configuration Initial configuration
 @param completion Called then sdk complete initialisation actions
 */
- (void)startSessionWithSellerID:(nonnull NSString *)sellerID
                   configuration:(nonnull BDMSdkConfiguration *)configuration
                      completion:(void(^ _Nullable)(void))completion;

@end
