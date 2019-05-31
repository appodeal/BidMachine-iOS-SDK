//
//  APDFactory+BDMOperation.m
//  BidMachine
//
//  Created by Stas Kochkin on 12/02/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import "BDMFactory+BDMOperation.h"

@implementation BDMFactory (BDMOperation)

- (NSOperationQueue *)operationQueue {
    return NSOperationQueue.new;
}

- (BDMAsyncOperation *)operationOnThread:(dispatch_queue_t)thread
                                  action:(void(^)(BDMAsyncOperation *))action {
    return [BDMAsyncOperation operationOnThread:thread
                                         action:action];
}

@end
