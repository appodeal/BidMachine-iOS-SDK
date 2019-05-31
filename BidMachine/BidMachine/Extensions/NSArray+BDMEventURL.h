//
//  NSArray+BDMEventTarcker.h
//  BidMachine
//
//  Created by Stas Kochkin on 28/11/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BDMEventURL.h"


@interface NSArray (BDMEventURL)

- (BDMEventURL *)bdm_searchTrackerOfType:(NSInteger)type;

@end

