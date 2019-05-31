//
//  BDMInitializationOperation.m
//  BidMachine
//
//  Created by Stas Kochkin on 19/02/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import "BDMInitializationOperation.h"
#import "BDMFactory.h"
#import "BDMDefines.h"

@interface BDMInitializationOperation ()

@property (nonatomic, strong) BDMNetworkConfigurator * configurator;

@end

@implementation BDMInitializationOperation

+ (instancetype)initilizeNetworkOperation:(NSArray<BDMNetworkItem *> *)networks {
    return [super operationOnThread:dispatch_get_main_queue()
                             action:^(BDMAsyncOperation *operation) {
                                 [(BDMInitializationOperation *)operation initializeNetworkOperation:networks];
                             }];
}

- (void)initializeNetworkOperation:(NSArray<BDMNetworkItem *> *)networks {
    BDMLog(@"Start initialisation operation %@", self);
    self.configurator = [BDMFactory.sharedFactory configurator];
    self.configurator.dataSource = self.dataSource;
    __weak typeof(self) weakSelf = self;
    [self.configurator initialize:networks completion:^{
        BDMLog(@"Complete initialisation operation %@", weakSelf);
        [weakSelf complete];
    }];
}

@end
