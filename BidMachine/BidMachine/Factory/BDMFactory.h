//
//  BDMFactory.h
//  BidMachine
//
//  Created by Stas Kochkin on 07/11/2017.
//  Copyright © 2017 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@class BDMSdk;
@class BDMRegistry;
@class BDMNetworkConfigurator;
@class BDMInitializationOperation;
@class BDMNetworkItem;

@interface BDMFactory : NSObject

+ (instancetype)sharedFactory;
- (BDMSdk *)sharedSdk;
- (BDMRegistry *)registry;
- (BDMNetworkConfigurator *)configurator;
- (BDMInitializationOperation *)initializeNetworkOperation:(NSArray<BDMNetworkItem *> *)networks;
- (UIViewController *)topPresentedViewController;

@end
