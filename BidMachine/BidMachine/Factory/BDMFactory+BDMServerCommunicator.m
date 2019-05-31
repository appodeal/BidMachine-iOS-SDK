//
//  BDMFactory+BDMServerCommunicator.m
//  BidMachine
//
//  Created by Stas Kochkin on 07/11/2017.
//  Copyright © 2017 Appodeal. All rights reserved.
//

#import "BDMFactory+BDMServerCommunicator.h"
#import "BDMResponse.h"

@implementation BDMFactory (BDMServerCommunicator)

- (id<BDMResponse>)wrappedResponseData:(NSData *)data {
    return [BDMResponse parseFromData:data];
}

- (BDMServerCommunicator *)serverCommunicator {
    return [BDMServerCommunicator new];
}

- (NSURLSession *)session {
    return [NSURLSession sharedSession];
}

@end
