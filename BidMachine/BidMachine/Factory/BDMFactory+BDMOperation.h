//
//  APDFactory+BDMOperation.h
//  BidMachine
//
//  Created by Stas Kochkin on 12/02/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import "BDMFactory.h"
#import "BDMAsyncOperation.h"


@interface BDMFactory (BDMOperation)

- (NSOperationQueue *)operationQueue;
- (BDMAsyncOperation *)operationOnThread:(dispatch_queue_t)thread
                                  action:(void(^)(BDMAsyncOperation *))action;

@end
