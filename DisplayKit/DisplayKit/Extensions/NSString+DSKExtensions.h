//
//  NSString+DSKExtensions.h
//  OpenBids
//
//  Created by Stas Kochkin on 05/09/2017.
//  Copyright © 2017 OpenBids, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, DSKStringNumberCompare) {
    DSKCompareEqual = 0,
    DSKCompareLess,
    DSKCompareGreat,
    DSKCompareLessOrEqual,
    DSKGreatOrEqual
};

@interface NSString (DSKCache)

@property (nonatomic, readonly) BOOL DSK_isEmpty;
@property (nonatomic, readonly) BOOL DSK_isUrlCompatible;

+ (NSString *)DSK_uniqFileName;

@end


@interface NSString (DSKAdWatch)

+ (NSString *)DSK_stringFromVastData:(NSData *)vastData;
- (NSString *)DSK_prettyCopy;

@end


@interface NSString (DSKCrypto)

@property (nonatomic, readonly) NSString * DSK_SHA1HexUpperCase;
@property (nonatomic, readonly) NSString * DSK_SHA256HexUpperCase;
@property (nonatomic, readonly) NSString * DSK_md5HexUppercased;
@property (nonatomic, readonly) NSData * DSK_SHA256;

@end


@interface NSString (DSKScanner)

@property (nonatomic, readonly) NSTimeInterval DSK_timeInterval;

@end

@interface NSString (DSKParsing)

- (NSString *)DSK_clearParseString;
- (NSString *)DSK_underscoreCopy;

@end

@interface NSString (DSKIndex)

- (NSArray <NSString *>*)DSK_stringIndexArray;
- (NSArray <NSNumber *>*)DSK_indexArray;

@end


/*
@interface NSString (DSKCompare)

- (BOOL)DSK_compare:(NSString *)string apdOptions:(DSKStringNumberCompare)mask;
- (NSComparisonResult)DSK_compare:(NSString *)string options:(NSStringCompareOptions)mask;

@end
*/
