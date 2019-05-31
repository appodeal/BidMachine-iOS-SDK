//
//  BDMVASTNetwork.h
//  BDMVASTNetwork
//
//  Created by Pavel Dunyashev on 24/09/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import "BDMVASTNetwork.h"
#import "BDMVASTVideoAdapter.h"

@interface BDMVASTNetwork ()

@end


@implementation BDMVASTNetwork

#pragma mark - BDMNetwork

+ (NSString *)name {
    return @"vast";
}

+ (NSString *)sdkVersion {
    return @"1.3.18";
}

+ (Class<BDMFullscreenAdapter>)videoAdapterClassForSdk:(BDMSdk *)sdk {
    return BDMVASTVideoAdapter.class;
}


@end

