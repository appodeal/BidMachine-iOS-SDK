//
//  HBBDMConfiguration.h
//  HBAppodealAdExchangeAdapter
//
//  Created by Stas Kochkin on 25/10/2017.
//  Copyright © 2017 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BDMResponseProtocol.h"
#import "BDMDefines.h"

@interface BDMResponse : NSObject <BDMResponse>

+ (instancetype)parseFromData:(NSData *)data;

@end
