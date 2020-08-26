//
//  BDMAdUnit.h
//  BidMachine
//
//  Created by Stas Kochkin on 18/07/2019.
//  Copyright © 2019 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BidMachine/BDMDefines.h>


NS_ASSUME_NONNULL_BEGIN

@interface BDMAdUnit : NSObject <NSSecureCoding, NSCopying>

@property (nonatomic, assign, readonly) BDMAdUnitFormat format;
@property (nonatomic, copy,   readonly) NSDictionary <NSString *, id> *customParams;
@property (nonatomic, copy,   readonly, nullable) NSDictionary <NSString *, id> *extras;

- (instancetype)initWithFormat:(BDMAdUnitFormat)format
                  customParams:(NSDictionary <NSString *, id> *)customParams;

- (instancetype)initWithFormat:(BDMAdUnitFormat)format
                  customParams:(NSDictionary <NSString *, id> *)customParams
                        extras:(nullable NSDictionary <NSString *, id> *)extras;

+ (instancetype)adUnitWithFormat:(BDMAdUnitFormat)format
                    customParams:(NSDictionary <NSString *, id> *)customParams;

@end

NS_ASSUME_NONNULL_END
