//
//  BDMServerCommunicatorSpec.m
//  BidMachineKiwiTests
//
//  Created by Yaroslav Skachkov on 11/15/18.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import <Kiwi/Kiwi.h>

#import "BDMServerCommunicator.h"
#import "BDMResponse.h"
#import "BDMApiRequest.h"

#import "BDMFactory+BDMServerCommunicator.h"

#import "BDMDefines.h"

SPEC_BEGIN(BDMServerCommunicatorSpec)

describe(@"BDMServerCommunicator", ^{
    __block BDMServerCommunicator * communicator;
    __block BDMRequest * requestMock;
    __block BDMApiRequest * apiRequestMock;
    __block BDMAuctionBuilder * auctionBuilderMock;
    __block NSURLSession * sessionMock;
    __block NSURLSessionDataTask * dataTaskMock;
    
    beforeEach(^{
        communicator = [BDMServerCommunicator new];
        requestMock = [BDMRequest nullMock];
        sessionMock = [NSURLSession nullMock];
        apiRequestMock = [BDMApiRequest nullMock];
        dataTaskMock = [NSURLSessionDataTask nullMock];
        auctionBuilderMock = [BDMAuctionBuilder nullMock];
    });
    
    context(@"Request", ^{
        it(@"RequestBuilder should build request", ^{
            [communicator stub:@selector(session) andReturn:sessionMock];
            [[BDMApiRequest should] receive:@selector(request:)];
            [communicator makeAuctionRequest:^(BDMAuctionBuilder *builder) {} success:^(id<BDMResponse> response) {} failure:^(NSError * error) {}];
        });
    });
});

SPEC_END
