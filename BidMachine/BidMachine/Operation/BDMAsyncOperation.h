//
//  BDMAsyncOperation.h
//  BidMachine
//
//  Created by Stas Kochkin on 12/02/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BDMAsyncOperation : NSOperation

+ (instancetype)operationOnThread:(dispatch_queue_t)thread
                           action:(void(^)(BDMAsyncOperation *))action;
- (void)complete;

@end
