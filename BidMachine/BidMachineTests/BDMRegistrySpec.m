//
//  BDMRegistrySpec.m
//  BidMachineKiwiTests
//
//  Created by Yaroslav Skachkov on 11/26/18.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import <Kiwi/Kiwi.h>

#import "BDMDefines.h"
#import "BDMRegistry.h"
#import "BDMSdk.h"
#import "BDMAdNetworksMocks.h"

@interface BDMRegistry ()

@property (nonatomic, strong) NSMutableSet *networkClasses;

@end

SPEC_BEGIN(BDMRegistrySpec)

describe(@"BDMRegistrySpec", ^{
    __block BDMRegistry *registry;
    
    beforeEach(^{
        registry = [BDMRegistry new];
    });
    
    it(@"should register network class", ^{
        [[registry.networkClasses should] receive:@selector(addObject:) withArguments:BDMMRAIDNetwork.class];
        [registry registerNetworkClass:BDMMRAIDNetwork.class];
    });
    
    it(@"should return network class by name", ^{
        [registry registerNetworkClass:BDMMRAIDNetwork.class];
        [registry initNetworks];
        NSObject *network = (NSObject *)[registry networkByName:@"mraid"];
        [[network should] beKindOfClass:BDMMRAIDNetwork.class];
    });
    
    it(@"should retrun banner adapter for class", ^{
        [registry registerNetworkClass:BDMMRAIDNetwork.class];
        [registry initNetworks];
        NSObject *adapter = (NSObject *)[registry bannerAdapterForNetwork:@"mraid"];
        [[adapter shouldNot] beNil];
    });

    it(@"should not return network class by name", ^{
        [registry registerNetworkClass:BDMMRAIDNetwork.class];
        NSObject *network = (NSObject *)[registry networkByName:@"mraid"];
        [[network should] beNil];
    });
    
    it(@"should retrun banner adapter for class", ^{
        [registry registerNetworkClass:BDMMRAIDNetwork.class];
        [registry initNetworks];
        NSObject *adapter = (NSObject *)[registry interstitialAdAdapterForNetwork:@"mraid"];
        [[adapter should] beNil];
    });
});

SPEC_END

