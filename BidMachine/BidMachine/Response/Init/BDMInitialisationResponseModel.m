//
//  BDMInitialisationResponseModel.m
//  BidMachine
//
//  Created by Stas Kochkin on 05/12/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import "BDMInitialisationResponseModel.h"
#import "BDMProtoAPI-Umbrella.h"


@interface BDMInitialisationResponseModel ()

@property (nonatomic, copy, readwrite) NSURL * auctionURL;

@end


@implementation BDMInitialisationResponseModel

+ (instancetype)modelWithData:(NSData *)data {
    BDMInitResponse * responseMessage = [[BDMInitResponse alloc] initWithData:data error:nil];
    if (!responseMessage) {
        return nil;
    }
    
    BDMInitialisationResponseModel * model = BDMInitialisationResponseModel.new;
    model.auctionURL = responseMessage.endpoint ? [NSURL URLWithString:responseMessage.endpoint] : nil;
    return model;
}

@end
