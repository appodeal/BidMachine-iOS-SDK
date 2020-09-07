//
//  BDMAmazonAdLoader.m
//  BDMAmazonAdapter
//
//  Created by Stas Kochkin on 31.08.2020.
//  Copyright © 2020 Stas Kochkin. All rights reserved.
//

@import DTBiOSSDK;
@import StackFoundation;
@import BidMachine.Adapters;

#import "BDMAmazonNetwork.h"
#import "BDMAmazonAdLoader.h"


@interface BDMAmazonAdLoader () <DTBAdCallback>

@property (nonatomic, strong) DTBAdLoader *loader;
@property (nonatomic, assign) BDMAdUnitFormat format;
@property (nonatomic,   copy) BDMAmazonAdLoaderCompletion completion;

@end

@implementation BDMAmazonAdLoader

- (instancetype)initWithFormat:(BDMAdUnitFormat)format {
    if (self = [super init]) {
        self.format = format;
    }
    return self;
}

- (void)prepareWithParameters:(NSDictionary<NSString *,id> *)parameters completion:(BDMAmazonAdLoaderCompletion)completion {
    NSString *slotUUID = ANY(parameters).from(BDMAmazonSlotIdKey).string;
    if (!slotUUID) {
        NSError *error = [NSError bdm_errorWithCode:BDMErrorCodeHeaderBiddingNetwork
                                        description:@"Amazon adapter was not receive valid bidding data"];
        STK_RUN_BLOCK(completion, self, nil, error);
        return;
    }
    
    DTBAdSize *adSize = [self configureAdSizeWith:slotUUID];
    NSMutableArray *adSizes = [NSMutableArray arrayWithObject:adSize];
    self.completion = completion;
    self.loader = [DTBAdLoader new];
    [self.loader setAdSizes:adSizes];
    [self.loader loadAd:self];
}

#pragma mark - AdSize

- (DTBAdSize *)configureAdSizeWith:(NSString *)slotUUID {
    CGSize size;
    DTBAdSize *adSize;
    switch (self.format) {
        case BDMAdUnitFormatInLineBanner: size = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? CGSizeMake(728, 90) : CGSizeMake(320, 50); break;
        case BDMAdUnitFormatBanner320x50: size = CGSizeMake(320, 50); break;
        case BDMAdUnitFormatBanner728x90: size = CGSizeMake(728, 90); break;
        case BDMAdUnitFormatBanner300x250: size = CGSizeMake(300, 250); break;
        case BDMAdUnitFormatInterstitialUnknown: adSize = [[DTBAdSize alloc] initInterstitialAdSizeWithSlotUUID: slotUUID]; break;
        case BDMAdUnitFormatInterstitialStatic: adSize = [[DTBAdSize alloc] initInterstitialAdSizeWithSlotUUID: slotUUID]; break;
        case BDMAdUnitFormatInterstitialVideo: adSize = [[DTBAdSize alloc] initVideoAdSizeWithPlayerWidth:STKScreen.width
                                                                                                   height:STKScreen.height
                                                                                              andSlotUUID:slotUUID]; break;
        default: break;
    }
    
    adSize = adSize ?: [[DTBAdSize alloc] initBannerAdSizeWithWidth:size.width height:size.height andSlotUUID:slotUUID];
    return adSize;
}

#pragma mark - DTBAdCallback

- (void)onFailure:(DTBAdError)error {
    NSError *wrapped = [NSError bdm_errorWithCode:BDMErrorCodeNoContent
                                      description:@"DTBAdLoader returned error"];
    STK_RUN_BLOCK(self.completion, self, nil, wrapped);
    self.completion = nil;
}

- (void)onSuccess:(DTBAdResponse *)adResponse {
    NSMutableDictionary *bidding = [[NSMutableDictionary alloc] initWithCapacity:6];
    NSMutableDictionary *response = [[NSMutableDictionary alloc] initWithDictionary:adResponse.customTargeting];
    NSString *slot = response[@"amznslots"];
    bidding[@"amznslots"] = slot;
    if (response[@"amzn_vid"]) {
        bidding[@"amzn_vid"] = response[@"amzn_vid"];
    }
    bidding[@"amzn_h"] = response[@"amzn_h"];
    bidding[@"amzn_b"] = response[@"amzn_b"];
    bidding[@"amznrdr"] = [response[@"amznrdr"] firstObject];
    bidding[@"amznp"] = [response[@"amznp"] firstObject];
    bidding[@"dc"] = [response[@"dc"] firstObject];
    
    STK_RUN_BLOCK(self.completion, self, bidding, nil);
    self.completion = nil;
}

@end
