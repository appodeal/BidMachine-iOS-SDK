//
//  NSString+DSKExtensions.m
//  OpenBids
//
//  Created by Stas Kochkin on 05/09/2017.
//  Copyright © 2017 OpenBids, Inc. All rights reserved.
//

#import "NSString+DSKExtensions.h"
#import <CommonCrypto/CommonDigest.h>


#define DSK_URL_COMPATIBLE_SCHEMES  @[ @"http://", @"https://", @"file://" ]

@implementation NSString (DSKCache)

+ (NSString *)DSK_uniqFileName {
    return [NSString stringWithFormat:@"DSK_video_%ld.mp4", random()];
}

- (BOOL)DSK_isUrlCompatible {
    NSPredicate * filter = [NSPredicate predicateWithBlock:^BOOL(NSString * scheme, NSDictionary<NSString *,id> * bindings) {
        return [self.lowercaseString containsString:scheme];
    }];
    return [DSK_URL_COMPATIBLE_SCHEMES filteredArrayUsingPredicate:filter].count;
}

- (BOOL)DSK_isEmpty {
    return [self isEqualToString:@""];
}

@end


@implementation NSString (DSKAdWatch)

+ (NSString *)DSK_stringFromVastData:(NSData *)vastData {
    return [[NSString alloc] initWithData:vastData encoding:NSUTF8StringEncoding];
}

- (NSString *)DSK_prettyCopy {
    
    NSString * prettyCopy = [[[self substringToIndex:1] uppercaseString] stringByAppendingString:[self substringWithRange:NSMakeRange(1, self.length -1)]]; // Make first letter stroke
    [prettyCopy stringByReplacingOccurrencesOfString:@"_" withString:@" "]; // Replace underscores with whitespaces
    return prettyCopy;
}

@end


@implementation NSString (DSKCrypto)

- (NSString *)DSK_SHA1HexUpperCase {
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, (uint32_t)data.length, digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02X", digest[i]];
    }
    
    return output;
}

- (NSString *)DSK_SHA256HexUpperCase {
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t digest[CC_SHA256_DIGEST_LENGTH];
    
    CC_SHA256(data.bytes, (uint32_t)data.length, digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02X", digest[i]];
    }
    
    return output;
}

- (NSString *)DSK_md5HexUppercased {
    NSString *output = [self copy];
    const char *cstr = [output UTF8String];
    unsigned char result[16];
    CC_MD5(cstr, (unsigned int)strlen(cstr), result);
    output = [NSString stringWithFormat:
              @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
              result[0], result[1], result[2], result[3],
              result[4], result[5], result[6], result[7],
              result[8], result[9], result[10], result[11],
              result[12], result[13], result[14], result[15]
              ];
    return output;
}

- (NSData *)DSK_SHA256 {
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t digest[CC_SHA256_DIGEST_LENGTH];
    
    CC_SHA256(data.bytes, (uint32_t)data.length, digest);
    
    return [NSData dataWithBytes:&digest length:CC_SHA256_DIGEST_LENGTH];
}

@end


@implementation NSString (DSKScanner)

- (NSTimeInterval)DSK_timeInterval {
    NSString * stringForScan = [self copy];
    
    //TODO: Maybe regex better
    if ([stringForScan length] == 5) {
        stringForScan = [@"00:" stringByAppendingString:stringForScan];
    }
    
    NSScanner *scn = [NSScanner scannerWithString:stringForScan];

    int h = 0, m = 0, s = 0, c = 0;
    [scn scanInt:&h];
    [scn scanString:@":" intoString:NULL];
    [scn scanInt:&m];
    [scn scanString:@":" intoString:NULL];
    [scn scanInt:&s];
    [scn scanString:@"." intoString:NULL];
    [scn scanInt:&c];
    
    return h * 3600 + m * 60 + s + c / 100.0;
}

@end

@implementation NSString (DSKParsing)

- (NSString *)DSK_clearParseString{
    NSString * originalValue = [self copy];
    NSURL * urlValue = [self.class DSK_cleanURLFromString:originalValue];
    
    if (urlValue) {
        return [urlValue absoluteString];
    }
    
    return originalValue;
}

+ (NSURL *)DSK_cleanURLFromString:(NSString *)string {
    NSString *cleanUrlString = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];  // remove leading, trailing \n or space
    cleanUrlString = [cleanUrlString stringByReplacingOccurrencesOfString:@"|" withString:@"%7c"];
    cleanUrlString = [cleanUrlString stringByReplacingOccurrencesOfString:@"${" withString:@"%24%7B"];
    cleanUrlString = [cleanUrlString stringByReplacingOccurrencesOfString:@"}" withString:@"%7D"];
    return [NSURL URLWithString:cleanUrlString];                                                                            // return the resulting URL
}

- (NSString *)DSK_underscoreCopy {
    NSString * input = [self copy];
    NSMutableString * output = [NSMutableString string];
    NSCharacterSet * uppercase = [NSCharacterSet uppercaseLetterCharacterSet];
    
    for (NSInteger idx = 0; idx < [input length]; idx += 1) {
        unichar c = [input characterAtIndex:idx];
        if ([uppercase characterIsMember:c]) {
            [output appendFormat:@"_%@", [[NSString stringWithCharacters:&c length:1] lowercaseString]];
        } else {
            [output appendFormat:@"%C", c];
        }
    }
    return output;
}

@end

@implementation NSString (DSKIndex)

- (NSArray <NSString *>*)DSK_stringIndexArray{
    NSMutableArray * transformedIndex = [NSMutableArray array];
    
    [self enumerateSubstringsInRange:NSMakeRange(0, self.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop)
     {
         if ([substring integerValue]) {
             [transformedIndex addObject:[@(substringRange.location) stringValue]];
         } else {
             [transformedIndex addObject:@"-"];
         }
     }];
    return transformedIndex;
}


- (NSArray <NSNumber *>*)DSK_indexArray{
    NSMutableArray * transformedIndex = [NSMutableArray array];
    
    [self enumerateSubstringsInRange:NSMakeRange(0, self.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop)
     {
         if ([substring integerValue]) {
             [transformedIndex addObject:@(substringRange.location)];
         } else {
             [transformedIndex addObject:@(NSNotFound)];
         }
     }];
    return transformedIndex;
}

@end

/// Unused NSString category to compare strings with numbers (or strings as numbers such @"x.x.x" and @"y.y")
/*
@implementation NSString (DSKCompare)

- (BOOL)DSK_compare:(NSString *)string apdOptions:(DSKStringNumberCompare)mask{
    return mask == [self DSK_numberCompare:string];
}

- (DSKStringNumberCompare)DSK_numberCompare:(NSString *)string{
    NSComparisonResult result = [self DSK_compare:string options:NSNumericSearch];
    
    DSKStringNumberCompare compareValue = DSKCompareEqual;
    if (result == NSOrderedSame) {
        compareValue = DSKCompareEqual;
    }else if (result == NSOrderedAscending) {
        compareValue = DSKCompareLess;
    } else if (result == NSOrderedDescending) {
        compareValue = DSKCompareGreat;
    } else if (result != NSOrderedDescending) {
        compareValue = DSKCompareLessOrEqual;
    } else if (result != NSOrderedAscending) {
        compareValue = DSKGreatOrEqual;
    }
    
    return compareValue;
}

- (NSComparisonResult)DSK_compare:(NSString *)string options:(NSStringCompareOptions)mask {
    if (mask != NSNumericSearch) {
        return [self compare:string options:mask];
    }
    return [self DSK_compareNumber:string];
}

- (NSComparisonResult)DSK_compareNumber:(NSString *)string {
    NSArray * firstNumberArray = [self DSK_cleanNumberArrayFromString:self];
    NSArray * secondNumberArray = [self DSK_cleanNumberArrayFromString:string];
    
    if (!firstNumberArray && secondNumberArray) {
        return NSOrderedAscending;
    } else if (firstNumberArray && !secondNumberArray){
        return NSOrderedDescending;
    } else if (!firstNumberArray && !secondNumberArray){
        return NSOrderedSame;
    }
    
    __block NSComparisonResult result = NSOrderedSame;
    
    [firstNumberArray enumerateObjectsUsingBlock:^(NSNumber *  _Nonnull number, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx >= secondNumberArray.count) {
            result = NSOrderedDescending;
        } else {
            result = number.integerValue - [secondNumberArray[idx] integerValue];
        }

        if (result != NSOrderedSame) {
            *stop = YES;
        }
    }];
    
    return result;
}

- (NSArray *)DSK_cleanNumberArrayFromString:(NSString *)string {
    if (!string.length) {
        return nil;
    }
    
    __block NSMutableArray * cleanNumberArray = nil;
    __block BOOL canRemoveNumber = YES;
    [[string componentsSeparatedByString:@"."] enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSString *  _Nonnull stringNumber, NSUInteger idx, BOOL * _Nonnull stop) {
        if (stringNumber.integerValue || !canRemoveNumber) {
            canRemoveNumber = NO;
            if (!cleanNumberArray) {
                cleanNumberArray = [NSMutableArray array];
            }
            [cleanNumberArray insertObject:@(stringNumber.integerValue) atIndex:0];
        }
    }];
    
    return cleanNumberArray;
}

@end
 */

