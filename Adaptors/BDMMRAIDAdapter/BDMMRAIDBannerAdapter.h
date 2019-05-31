//
//  ABDMMRAIDBannerAdapter.h
//  BDMMRAIDBannerAdapter
//
//  Created by Pavel Dunyashev on 11/09/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>
@import BidMachine.Adapters;

@interface BDMMRAIDBannerAdapter : NSObject <BDMBannerAdapter>

@property (nonatomic, weak) id <BDMBannerAdapterDisplayDelegate> displayDelegate;
@property (nonatomic, weak) id <BDMAdapterLoadingDelegate> loadingDelegate;

@property (nonatomic, strong) NSString * adContent;
 
@end

