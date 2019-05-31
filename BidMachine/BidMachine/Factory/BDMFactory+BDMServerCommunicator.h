//
//  BDMFactory+BDMServerCommunicator.h
//  BidMachine
//
//  Created by Stas Kochkin on 07/11/2017.
//  Copyright © 2017 Appodeal. All rights reserved.
//

#import "BDMFactory.h"
#import "BDMResponseProtocol.h"
#import "BDMServerCommunicator.h"

@interface BDMFactory (BDMServerCommunicator)

- (id<BDMResponse>)wrappedResponseData:(NSData *)data;
- (BDMServerCommunicator *)serverCommunicator;
- (NSURLSession *)session;

@end
