//
//  BDMApiRequest.m
//
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import "BDMApiRequest.h"
#import "BDMUserAgentProvider.h"
#import "BDMSdk+Project.h"
#import <ASKExtension/ASKExtension.h>


#define BDM_API_REQUEST_CONTENT_TYPE_OPEN_RTB   ask_debugSession() ? @"application/x-protobuf; messageType=bidmachine.protobuf.openrtb.Openrtb" : @"application/x-protobuf"
#define BDM_API_REQUEST_CONTENT_TYPE_INIT       ask_debugSession() ? @"application/x-protobuf; messageType=bidmachine.protobuf.InitRequest" : @"application/x-protobuf"

#define BDM_API_REQUEST_USER_AGENT              BDMUserAgentProvider.userAgent
#define BDM_INIT_REQUEST_ENDPOINT               @"https://api.appodealx.com/init" // @"https://staging.appodealx.com/init"

static NSTimeInterval const kBDMRequestTimeoutInterval = 10.0;


@interface BDMApiRequest ()

@property (nonatomic, copy) id HTTPBodyModel;

@end

@implementation BDMApiRequest

+ (BDMApiRequest *)request:(void (^)(BDMAuctionBuilder *))build {
    BDMAuctionBuilder * builder = [BDMAuctionBuilder new];
    build(builder);
    NSURL *URL = [NSURL URLWithString:BDMSdk.sharedSdk.auctionSettings.auctionURL];
    BDMApiRequest * request = [BDMApiRequest requestWithURL:URL
                                                cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                            timeoutInterval:kBDMRequestTimeoutInterval];
    
    request.timeoutInterval = kBDMRequestTimeoutInterval;
    request.HTTPBodyModel = builder.message;
    [request setHTTPMethod:@"POST"];
    
    [request setValue:BDM_API_REQUEST_CONTENT_TYPE_OPEN_RTB forHTTPHeaderField:@"Content-Type"];
    [request setValue:BDM_API_REQUEST_USER_AGENT forHTTPHeaderField:@"User-Agent"];
    
    return request;
}

+ (BDMApiRequest *)sessionRequest:(void (^)(BDMSessionBuilder *))build {
    BDMSessionBuilder *builder = [BDMSessionBuilder new];
    build(builder);
    
    NSURL * URL = [NSURL URLWithString:BDM_INIT_REQUEST_ENDPOINT];
    BDMApiRequest * request = [BDMApiRequest requestWithURL:URL
                                                cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                            timeoutInterval:kBDMRequestTimeoutInterval];
    
    request.timeoutInterval = kBDMRequestTimeoutInterval;
    request.HTTPBodyModel = builder.message;
    [request setHTTPMethod:@"POST"];
    
    [request setValue:BDM_API_REQUEST_CONTENT_TYPE_INIT forHTTPHeaderField:@"Content-Type"];
    [request setValue:BDM_API_REQUEST_USER_AGENT forHTTPHeaderField:@"User-Agent"];
    
    return request;
}

#pragma mark - Overriding

- (NSData *)HTTPBody {
    return [self.HTTPBodyModel performSelector:@selector(data)];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Destanation URL: %@\nMethod: %@\nHTTP Headers: %@\nBody: %@", self.URL, self.HTTPMethod, self.allHTTPHeaderFields, self.HTTPBodyModel];
}

@end
