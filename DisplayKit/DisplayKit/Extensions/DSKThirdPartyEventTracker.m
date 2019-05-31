//
//  DSKVideoEventTracker.m
//  OpenBids
//

//  Copyright © 2016 OpenBids, Inc. All rights reserved.
//

#import "DSKThirdPartyEventTracker.h"
#import <ASKExtension/NSURLSession+ASKExtension.h>
#import <ASKExtension/NSObject+ASKExtension.h>


#define ERROR_MASK @[@"[ERRORCODE]",@"%5BERRORCODE%5D"]

@implementation DSKThirdPartyEventTracker

#pragma mark - Public

+ (void)sendTrackingEvent:(NSString *)trackingEvent{
    [self _sendTrackingEvent:[NSURL URLWithString:trackingEvent]];
}

+ (void)sendTrackingEvents:(NSArray *)trackingEvents {
    [trackingEvents enumerateObjectsUsingBlock:^(id  _Nonnull event, NSUInteger idx, BOOL * _Nonnull stop) {
        NSURL * eventURL = NSString.ask_isValid(event) ? [NSURL URLWithString:(NSString *)event] : NSURL.ask_isValid(event) ? event :nil;
        [self _sendTrackingEvent:eventURL];
    }];
}

+ (void)sendError:(NSUInteger)errorCode trackingEvent:(NSString *)trackingEvent {
    
    __block NSString * replaceString = trackingEvent;
    [ERROR_MASK enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        replaceString = [replaceString stringByReplacingOccurrencesOfString:obj withString:[NSString stringWithFormat:@"%ld", (long)errorCode]];
    }];
    
    
    [self _sendTrackingEvent:[NSURL URLWithString:replaceString]];
}

#pragma mark - Private

+ (void)_sendTrackingEvent:(NSURL *)eventURL {
    if (!eventURL) {
        //DSKLogDebug(@"Unable to send event on empty URL!");
        return;
    }
    
    dispatch_queue_t sendTrackRequestQueue = dispatch_queue_create("com.appodeal.event-tracking", DISPATCH_QUEUE_SERIAL);
    dispatch_async(sendTrackRequestQueue, ^{
       
        NSURLRequest * eventRequest = eventURL ? [NSURLRequest requestWithURL:eventURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:2.0] : nil;
        NSURLSessionConfiguration * configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession * session = [NSURLSession sessionWithConfiguration:configuration];
        if (eventRequest) {
            NSURLSessionDataTask * task = [session dataTaskWithRequest:eventRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                //DSKLogInfo(@"%@ %@", error != nil ? @"Unable to send event to: " : @"Successfully send event to: ", eventURL);
            }];
            [task resume];
        }
    });
}

@end
