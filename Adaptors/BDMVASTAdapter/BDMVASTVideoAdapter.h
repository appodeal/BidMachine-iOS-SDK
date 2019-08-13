//
//  BDMVASTVideoAdapter.h
//  BDMVASTVideoAdapter
//
//  Created by Pavel Dunyashev on 24/09/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>
@import BidMachine.Adapters;

@interface BDMVASTVideoAdapter : NSObject <BDMFullscreenAdapter>

@property (nonatomic, weak) id <BDMFullscreenAdapterDisplayDelegate> displayDelegate;
@property (nonatomic, weak) id <BDMAdapterLoadingDelegate> loadingDelegate;

@property (nonatomic, assign) BOOL rewarded;

@end
