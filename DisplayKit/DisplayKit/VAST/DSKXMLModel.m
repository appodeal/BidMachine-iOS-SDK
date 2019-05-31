//
//  DSKXMLModel.m
//  OpenBids
//
//  Created by Lozhkin Ilya on 8/3/17.
//  Copyright © 2017 OpenBids, Inc. All rights reserved.
//

#import "DSKXMLModel.h"
#import <objc/runtime.h>

#import "NSString+DSKExtensions.h"

@interface DSKXMLNodeTransformer ()

@property (nonatomic, copy) transformerNodeBlock transformerBlock;

@end

@implementation DSKXMLNodeTransformer

+ (instancetype)nodeTransformer:(transformerNodeBlock)transformer{
    return [[self alloc] initNodeTransformer:transformer];
}

- (instancetype)initNodeTransformer:(transformerNodeBlock)transformer{
    self = [super init];
    if (self) {
        self.transformerBlock = transformer;
    }
    return self;
}

- (id)transformedNodeWith:(NSDictionary *)JSON nodeName:(NSString *)nodeName{
    if (self.transformerBlock) {
        return self.transformerBlock(JSON, nodeName);
    }
    return nil;
}

@end


@interface DSKXMLValueTransformer ()

@property (nonatomic, copy) transformerValueBlock transformerBlock;

@end

@implementation DSKXMLValueTransformer

+ (instancetype)valueTransformer:(transformerValueBlock)transformer{
    return [[self alloc] initValueTransformer:transformer];
}

- (instancetype)initValueTransformer:(transformerValueBlock)transformer{
    self = [super init];
    if (self) {
        self.transformerBlock = transformer;
    }
    return self;
}

- (id)transformedValueWith:(id)value{
    if (self.transformerBlock) {
        return self.transformerBlock(value);
    }
    return nil;
}

@end


@implementation DSKXMLModel

+ (NSDictionary *)DSK_xmlModel{
    return nil;
}

+ (DSKXMLNodeTransformer *)JSONTransformer{
    return nil;
}

+ (DSKXMLValueTransformer *)ValueTransformer{
    return nil;
}

+ (instancetype)parseXMLWithJSON:(NSDictionary *)JSON{
    id instance = [self new];
    [instance createObjectWithJSON:JSON];
    
    return instance;
}

#pragma mark - Setter

- (void)setValue:(id)value forSelectorArray:(NSArray *)selectorArray{
    for (NSString * selectorName in selectorArray) {
        [self setValue:value forSelectorName:selectorName];
    }
}

- (void)setValue:(id)value forSelectorName:(NSString *)selectorName{
    SEL valueTransformedSelector = NSSelectorFromString([NSString stringWithFormat:@"%@%@",selectorName,@"ValueTransformer"]);
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if ([self.class respondsToSelector:valueTransformedSelector]) {
        DSKXMLValueTransformer * transformer = [self.class performSelector:valueTransformedSelector];
        value = [transformer transformedValueWith:value];
    } else {
        value = [self tryToAutoTransformValue:value toIvar:selectorName];
    }
#pragma clang diagnostic pop
    
    if ([self respondsToSelector:NSSelectorFromString(selectorName)]){
        [self setValue:value forKey:selectorName];
    }
}

#pragma mark - private

- (void)createObjectWithJSON:(NSDictionary *)JSON{
    __block NSMutableDictionary * attributedMap = nil;
    __block NSMutableDictionary * nodeMap = nil;
    
    [self.class.DSK_xmlModel enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj hasPrefix:@"attr_"]) {
            NSString * value = [obj stringByReplacingOccurrencesOfString:@"attr_" withString:@""];
            if (!attributedMap) {
                attributedMap = [NSMutableDictionary dictionary];
            }
            attributedMap[key] = value;
        } else {
            if (!nodeMap) {
                nodeMap = [NSMutableDictionary dictionary];
            }
            nodeMap[key] = obj;
        }
    }];
    
    [self createAttributedObjectWithJSON:JSON map:attributedMap];
    [self createEndedNodeWithJSON:JSON map:nodeMap];
    
}

- (void)createAttributedObjectWithJSON:(NSDictionary *)JSON map:(NSDictionary *)map{
    
    if (!map) {
        return;
    }
    
    
    NSArray <NSDictionary <NSString *, NSString *> *>* nodeAttributeArray = JSON[@"nodeAttributeArray"];
    [nodeAttributeArray enumerateObjectsUsingBlock:^(NSDictionary<NSString *,NSString *> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([[map allValues] containsObject:obj[@"attributeName"]]) {
            NSArray * ivar = [map allKeysForObject:obj[@"attributeName"]];
            [self setValue:obj[@"nodeContent"] forSelectorArray:ivar];
        }
    }];
}

- (void)createEndedNodeWithJSON:(NSDictionary *)JSON map:(NSDictionary *)map{
    if (!map) {
        return;
    }
    
    if (![JSON[@"nodeContent"] length] && [JSON[@"nodeChildArray"] count]) {
        
        [JSON[@"nodeChildArray"] enumerateObjectsUsingBlock:^(NSDictionary *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (!obj[@"nodeName"] && [obj[@"nodeContent"] length]) {
                NSArray * ivar = [map allKeysForObject:JSON[@"nodeName"]];
                [self setValue:obj[@"nodeContent"] forSelectorArray:ivar];
            } else if ([[map allValues] containsObject:obj[@"nodeName"]] && [obj[@"nodeContent"] length]) {
                NSArray * ivar = [map allKeysForObject:obj[@"nodeName"]];
                [self setValue:obj[@"nodeContent"] forSelectorArray:ivar];
            } else if ([[map allValues] containsObject:obj[@"nodeName"]]){
                [self parseNextObjectWithJSON:obj map:map];
            }
        }];
    }
}

#pragma mark - NextObject

- (void)parseNextObjectWithJSON:(NSDictionary *)JSON map:(NSDictionary <NSString *,NSString *> *)map{
    [map enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj isEqualToString:JSON[@"nodeName"]]) {
            [self tryParseJSON:JSON inIvar:key];
        }
    }];
}

- (void)tryParseJSON:(NSDictionary *)JSON inIvar:(NSString *)ivar{
    Class objectClass = [self getClassByIvar:ivar];
    
    SEL transformedSelector = NSSelectorFromString([NSString stringWithFormat:@"%@%@",ivar,@"JSONTransformer"]);
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    id parsedObject = nil;
    if ([objectClass isSubclassOfClass:DSKXMLModel.class]) {
        parsedObject = [objectClass parseXMLWithJSON:JSON];
    } else if ([self.class respondsToSelector:transformedSelector]){
        DSKXMLNodeTransformer * transformer = [self.class performSelector:transformedSelector];
        parsedObject = [transformer transformedNodeWith:JSON nodeName:JSON[@"nodeName"]];
    }
#pragma clang diagnostic pop
    
    [self setValue:parsedObject forSelectorName:ivar];
}

- (Class)getClassByIvar:(NSString *)ivar{
    __block Class objectClass = nil;
    
    objc_property_t property = class_getProperty(self.class, [ivar UTF8String]);
    if (!property) {
        return nil;
    }
    
    const char * propertyAttributes = property_getAttributes(property);
    NSString * propertyAttributesString = [NSString stringWithUTF8String:propertyAttributes];
    [propertyAttributesString enumerateSubstringsInRange:NSMakeRange(0, propertyAttributesString.length - 1) options:NSStringEnumerationByWords usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
        if (object_isClass(NSClassFromString(substring))) {
            objectClass = NSClassFromString(substring);
            *stop = YES;
        }
    }];
    
    return objectClass;
    
    //    return with "@\"+++\""
    //    Ivar ivarB = class_getInstanceVariable(self.class, [[NSString stringWithFormat:@"_%@",ivar] UTF8String]);
    //    const char * ivarName = ivar_getTypeEncoding(ivarB);
}

#pragma mark - transform

- (id)tryToAutoTransformValue:(id)value toIvar:(NSString *)ivar{
    Class ivarClass = [self getClassByIvar:ivar];
    
    if (!value) {
        return nil;
    }
    
    if ([[value class] isSubclassOfClass:ivarClass]) {
        return value;
    }
    
    if ([ivarClass isSubclassOfClass:NSNumber.class] && [value isKindOfClass:NSString.class]) {
        NSNumber * numberValue = nil;
        if ([(NSString *)value isEqualToString:@"true"] || [(NSString *)value isEqualToString:@"false"]) {
            numberValue = @([(NSString *)value boolValue]);
        } else if ([(NSString *)value containsString:@","] || [(NSString *)value containsString:@"."]) {
            numberValue = @([(NSString *)value floatValue]);
        } else {
            numberValue = @([(NSString *)value integerValue]);
        }
        return numberValue;
    }
//    TODO: сделать трансформеры под разные типы.
    return value;
}

#pragma mark - Extention

+ (DSKXMLNodeTransformer *)transformerArrayOfObjects:(Class)classObjects{
    if (![classObjects isSubclassOfClass:DSKXMLModel.class]) {
        return nil;
    }
    
    return [DSKXMLNodeTransformer nodeTransformer:^id(NSDictionary * JSON, NSString * nodeName) {
        NSMutableArray * objectsArray = nil;
        for (NSDictionary * modelDict in JSON[@"nodeChildArray"]) {
            id obj = [classObjects parseXMLWithJSON:modelDict];
            if (obj) {
                if (!objectsArray) {
                    objectsArray = [NSMutableArray array];
                }
                [objectsArray addObject:obj];
            }
        }
        return objectsArray;
    }];
}

+ (DSKXMLValueTransformer *)transformerStringAsStringOrURLString{
    return [DSKXMLValueTransformer valueTransformer:^id(id value) {
        if (![value isKindOfClass:NSString.class]){
            return nil;
        }
        
        return [(NSString *)value DSK_clearParseString];
    }];
}

@end
