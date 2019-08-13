//
//  BDMNASTDisplayAdapter.h
//  BDMNASTAdapter
//
//  Created by Stas Kochkin on 04/11/2018.
//  Copyright © 2018 Stas Kochkin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BidMachine/BDMNativeAdProtocol.h>

@import StackNASTKit;


@interface BDMNASTDisplayAdapter : NSObject <BDMNativeAd>

+ (instancetype)displayAdapterForAd:(STKNASTAd *)ad;

@end

