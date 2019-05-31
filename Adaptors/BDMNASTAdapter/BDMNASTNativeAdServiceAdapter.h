//
//  BDMNASTNativeServiceAdapter.h
//  BDMNASTAdapter
//
//  Created by Stas Kochkin on 04/11/2018.
//  Copyright © 2018 Stas Kochkin. All rights reserved.
//

#import <Foundation/Foundation.h>
@import BidMachine.Adapters;


@interface BDMNASTNativeAdServiceAdapter : NSObject <BDMNativeAdServiceAdapter>

@property (nonatomic, weak) id <BDMNativeAdServiceAdapterLoadingDelegate> loadingDelegate;
@property (nonatomic, weak) id <BDMAdapterDisplayDelegate> displayDelegate;

@end

