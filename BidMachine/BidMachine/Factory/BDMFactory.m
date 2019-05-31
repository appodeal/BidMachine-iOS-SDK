//
//  BDMFactory.m
//  BidMachine
//
//  Created by Stas Kochkin on 07/11/2017.
//  Copyright © 2017 Appodeal. All rights reserved.
//

#import "BDMFactory.h"
#import "BDMSdk.h"
#import "BDMRegistry.h"
#import "BDMNetworkConfigurator.h"
#import "BDMInitializationOperation.h"

@implementation BDMFactory

+ (instancetype)sharedFactory {
    static BDMFactory * _sharedFactory;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedFactory = BDMFactory.new;
    });
    return _sharedFactory;
}

- (BDMSdk *)sharedSdk {
    return [BDMSdk sharedSdk];
}

- (BDMRegistry *)registry {
    return [BDMRegistry new];
}

- (BDMNetworkConfigurator *)configurator {
    return [BDMNetworkConfigurator new];
}

- (BDMInitializationOperation *)initializeNetworkOperation:(NSArray<BDMNetworkItem *> *)networks {
    return [BDMInitializationOperation initilizeNetworkOperation:networks];
}

- (UIViewController *)topPresentedViewController {
    UIViewController * topController = UIApplication.sharedApplication.keyWindow.rootViewController;
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    return topController;
}

@end
