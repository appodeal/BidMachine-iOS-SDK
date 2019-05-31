////
////  BDMRegistrySpec.m
////  BidMachineKiwiTests
////
////  Created by Yaroslav Skachkov on 11/26/18.
////  Copyright © 2018 Appodeal. All rights reserved.
////
//
//#import <Kiwi/Kiwi.h>
//
//#import "BDMDefines.h"
//#import "BDMRegistry.h"
//#import <objc/runtime.h>
//#import "BDMSdk.h"
//
//@import BidMachine.Adapters;
//#import "BDMMRAIDBannerAdapter.h"
//
//@interface MRAIDNetwork : NSObject<BDMNetwork>
//
//@end
//
//@implementation MRAIDNetwork
//+ (Class<BDMBannerAdapter>)bannerAdapterClassForSdk:(BDMSdk *)sdk {
//    return BDMMRAIDBannerAdapter.class;
//}
//+ (NSString *)name {
//    return @"MRAIDNetwork";
//}
//
//@end
//
//@interface VASTNetwork : NSObject<BDMNetwork>
//
//@end
//
//@implementation VASTNetwork
//
//+ (NSString *)name {
//    return @"VASTNetwork";
//}
//
//@end
//
//@interface NASTNetwork : NSObject<BDMNetwork>
//
//@end
//
//@implementation NASTNetwork
//
//+ (NSString *)name {
//    return @"NASTNetwork";
//}
//
//@end
//
//@interface BDMRegistry ()
//
//@property (nonatomic, strong) NSMutableSet * networkClasses;
//
//@end
//
//SPEC_BEGIN(BDMRegistrySpec)
//
//describe(@"BDMRegistrySpec", ^{
//    
//    __block BDMRegistry * registry;
//    
//    beforeEach(^{
//        registry = [BDMRegistry new];
//    });
//    
//    it(@"should register network class", ^{
//        [[registry.networkClasses should] receive:@selector(addObject:) withArguments:@"MRAIDNetwork"];
//        [registry registerNetworkClass:@"MRAIDNetwork"];
//    });
//    
//    it(@"should return network class by name", ^{
//        [registry registerNetworkClass:@"MRAIDNetwork"];
//        Class mraid = [registry networkClassByName:@"MRAIDNetwork"];
//        [[mraid should] equal:MRAIDNetwork.class];
//    });
//    
//    it(@"should retrun banner adapter for class", ^{
//        [registry registerNetworkClass:@"MRAIDNetwork"];
//        id<BDMBannerAdapter> banner = [registry bannerAdapterForNetwork:@"MRAIDNetwork"];
//        [[banner.class should] equal:[[[MRAIDNetwork.class bannerAdapterClassForSdk:BDMSdk.sharedSdk] class] new]];
//    });
//    
//});
//
//SPEC_END
//
