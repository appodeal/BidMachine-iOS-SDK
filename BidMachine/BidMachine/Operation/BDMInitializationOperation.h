//
//  BDMInitializationOperation.h
//  BidMachine
//
//  Created by Stas Kochkin on 19/02/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import "BDMAsyncOperation.h"
#import "BDMNetworkItem.h"
#import "BDMNetworkConfigurator.h"


@interface BDMInitializationOperation : BDMAsyncOperation

@property (nonatomic, weak) id <BDMNetworkConfiguratorDataSource> dataSource;

+ (instancetype)initilizeNetworkOperation:(NSArray <BDMNetworkItem *> *)networks;

@end
