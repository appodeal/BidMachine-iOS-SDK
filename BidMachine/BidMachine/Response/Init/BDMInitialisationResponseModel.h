//
//  BDMInitialisationResponseModel.h
//  BidMachine
//
//  Created by Stas Kochkin on 05/12/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BDMInitialisationResponseProtocol.h"

@interface BDMInitialisationResponseModel : NSObject <BDMInitialisationResponse>

+ (instancetype)modelWithData:(NSData *)data;

@end

