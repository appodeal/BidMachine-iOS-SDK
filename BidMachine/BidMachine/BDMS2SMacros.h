//
//  BDMS2SMacros.h
//  BidMachine
//
//  Created by Ilia Lozhkin on 7/16/18.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#ifndef BDMS2SMacros_h
#define BDMS2SMacros_h

//  _interfaceName:
//
//  Banner
//  Fullscreen
//  NativeAdService

#define BDMPBS2SAdapterInterface(_adapterName, _interfaceName) \
@interface BDMPB##_adapterName##_interfaceName##Adapter : NSObject <BDM##_interfaceName##Adapter> \
@property (nonatomic, weak) id <BDM##_interfaceName##AdapterDelegate> delegate; \
@end

#define BDMPBS2SAdapterImplementation(_adapterName, _interfaceName, _adNetworkCls) \
@implementation BDMPB##_adapterName##_interfaceName##Adapter \
- (Class)relativeAdNetworkClass { return _adNetworkCls.class; } \
- (NSString *)adContent { return nil; } \
- (UIView *)adView { return nil; } \
- (NSDictionary *)externalBiddingInformationForLoadingParamters:(NSDictionary *)loadingParameters error:(NSError *__autoreleasing *)error { \
NSDictionary *ext = loadingParameters[@"parallel_bidding_ext"]; \
return [ext isKindOfClass:NSDictionary.class] ? ext : nil; } \
- (void)prepareContent:(NSDictionary *)contentInfo { \
NSDictionary * userInfo = @{ NSLocalizedFailureReasonErrorKey : @#_adapterName" Parallel Biddibg adapter not contains embeded renderers!"}; \
NSError * error = [NSError errorWithDomain:kBDMErrorDomain code:0 userInfo:userInfo]; \
[self.delegate adapter:self failedToPrepareContentWithError:error]; } \
- (void)presentInContainer:(UIView *)container { /*result unused*/ } \
- (void)present { /*result unused*/ } \
@end

#endif /* BDMS2SMacros_h */
