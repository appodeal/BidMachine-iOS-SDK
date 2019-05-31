//
//  DSKXMLModel.h
//  OpenBids
//
//  Created by Lozhkin Ilya on 8/3/17.
//  Copyright © 2017 OpenBids, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef id(^transformerNodeBlock)(NSDictionary *,NSString *);

typedef id(^transformerValueBlock)(id);

@interface DSKXMLNodeTransformer : NSObject

/**
 Create value transformer

 @param transformer block return current node (NSDictionary), nodeName (NSString)
 @return value transformer
 */
+ (instancetype)nodeTransformer:(transformerNodeBlock)transformer;

@end


@interface DSKXMLValueTransformer : NSObject

+ (instancetype)valueTransformer:(transformerValueBlock)transformer;

@end


@interface DSKXMLModel : NSObject


/**
 MAP OF NODE
 attr_type if property saved as attribute
 
 @return dictionary of map
 */
+ (NSDictionary <NSString *, NSString *> *)DSK_xmlModel;

/**
 Use and return instance

 @param JSON NODE JSON
 @return instance type
 */
+ (instancetype)parseXMLWithJSON:(NSDictionary *)JSON;

/**
 Use in instance if need overide transformer
 
 EXAMPLE: +(DSKXMLValueTransformer *)properyName+JSONTransformer
 @return transformer
 */
+ (DSKXMLNodeTransformer *)JSONTransformer;


/**
 Use if need overide value transformer

 @return transformer
 */
+ (DSKXMLValueTransformer *)ValueTransformer;

/**
 Use if need transform array of node

 @param classObjects class isKind DSKXMLModel
 @return transformer
 */
+ (DSKXMLNodeTransformer *)transformerArrayOfObjects:(Class)classObjects;

/**
 Use if need save object as string or cleen url string

 @return value transformer
 */
+ (DSKXMLValueTransformer *)transformerStringAsStringOrURLString;

@end
