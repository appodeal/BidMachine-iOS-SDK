//
//  BDMCreative.h
//  BidMachine
//
//  Created by Stas Kochkin on 21/11/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BDMResponseProtocol.h"

@interface BDMCreative : NSObject <BDMCreative>

+ (instancetype)parseFromData:(NSData *)data;

@end
