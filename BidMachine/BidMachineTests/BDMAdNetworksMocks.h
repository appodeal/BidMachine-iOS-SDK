//
//  BDMAdNetworksMocks.h
//  BidMachineTests
//
//  Created by Stas Kochkin on 08/08/2019.
//  Copyright © 2019 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BidMachine/BDMNetworkProtocol.h>


@interface BDMMRAIDNetwork : NSObject <BDMNetwork>
@end


@interface BDMVASTNetwork : NSObject <BDMNetwork>
@end


@interface BDMNASTNetwork : NSObject <BDMNetwork>
@end


@interface BDMHeaderBiddingNetwork : NSObject <BDMNetwork>
@end
