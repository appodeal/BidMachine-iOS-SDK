//
//  SKVASTModel.m
//  VAST
//
//  Created by Jay Tucker on 10/4/13.
//  Copyright (c) 2013 Nexage. All rights reserved.
//

#import "DSKSKVASTModel.h"
#import "DSKSKVASTUrlWithId.h"
#import "DSKSKVASTMediaFile.h"
#import "DSKVASTXMLUtil.h"
#import "DSKSKVASTCompanion.h"

NSString * const kDSKSKVASTStaticCompanion = @"StaticResource";
NSString * const kDSKSKVASTIFrameCompanion = @"IFrameResource";
NSString * const kDSKSKVASTHTMLCompanion = @"HTMLResource";

@interface DSKSKVASTModel ()
{
    NSMutableArray *vastDocumentArray;
}

// returns an array of VASTUrlWithId objects
- (NSArray *)resultsForQuery:(NSString *)query;

// returns the text content of both simple text and CDATA sections
- (NSString *)content:(NSDictionary *)node;

@end

@implementation DSKSKVASTModel

#pragma mark - "private" method

// We deliberately do not declare this method in the header file in order to hide it.
// It should be used only be the VAST2Parser to build the model.
// It should not be used by anybody else receiving the model object.
- (void)addVASTDocument:(NSData *)vastDocument
{
    if (!vastDocumentArray) {
        vastDocumentArray = [NSMutableArray array];
    }
    [vastDocumentArray addObject:vastDocument];
}

#pragma mark - public methods

- (NSString *)vastVersion
{
    // sanity check
    if ([vastDocumentArray count] == 0) {
        return nil;
    }
    
    NSString *version;
    NSString *query = @"/VAST/@version";
    NSArray *results = DSK_performXMLXPathQuery(vastDocumentArray[0], query);
    // there should be only a single result
    if ([results count] > 0) {
        NSDictionary *attribute = results[0];
        version = attribute[@"nodeContent"];
    }
    return version;
}

- (NSArray *)errors
{
    NSString *query = @"//Error";
    return [self resultsForQuery:query];
}

- (NSArray *)impressions
{
    NSString *query = @"//Impression";
    return [self resultsForQuery:query];
}

- (NSDictionary *)trackingEvents {
    return [self trackingEventsForQuery:@"//Linear//Tracking"];
}

- (NSDictionary *)trackingEventsForQuery:(NSString *)query
{
    NSMutableDictionary *eventDict;

    for (NSData *document in vastDocumentArray) {
        NSArray *results = DSK_performXMLXPathQuery(document, query);
        for (NSDictionary *result in results) {
            // use lazy initialization
            if (!eventDict) {
                eventDict = [NSMutableDictionary dictionary];
            }
            
            NSString *urlString = [self content:result];
            NSArray *attributes = result[@"nodeAttributeArray"];
            for (NSDictionary *attribute in attributes) {
                NSString *name = attribute[@"attributeName"];
                if ([name isEqualToString:@"event"]) {
                    NSString *event = attribute[@"nodeContent"];
                    NSMutableArray * newEventArray = [NSMutableArray array];
                    NSArray *oldEventArray = [eventDict valueForKey:event];
                    
                    if (oldEventArray) {
                        [newEventArray addObjectsFromArray:oldEventArray];
                    }
                    
                    NSURL *eventURL = [self urlWithCleanString:urlString];
                    if (eventURL) {
                        [newEventArray addObject:[self urlWithCleanString:urlString]];
                        [eventDict setValue:newEventArray forKey:event];
                    }
                }
            }
        }
    }
    
    return eventDict;
}

- (DSKSKVASTUrlWithId *)clickThrough
{
    NSString *query = @"//ClickThrough";
    NSArray *array = [self resultsForQuery:query];
    // There should be at most only one array element.
    return ([array count] > 0) ? array[0] : nil;
}

- (NSArray *)clickTracking
{
    NSString *query = @"//ClickTracking";
    return [self resultsForQuery:query];
}

- (NSArray *)companions {
    NSMutableArray * companionsArray = [NSMutableArray new];
    
    //Companion
    {
        NSDictionary * tracking = [self trackingEventsForQuery:@"//CompanionAds/TrackingEvents/Tracking"];
        
        NSArray * companions = [self companionsFromQuery:@"//Companion"
                                                tracking:tracking];
        [companionsArray addObjectsFromArray:companions];
    }
    
    //Non Linear
    {
        NSDictionary * tracking = [self trackingEventsForQuery:@"//NonLinearAds/TrackingEvents/Tracking"];
        
        NSArray * companions = [self companionsFromQuery:@"//NonLinear"
                                                tracking:tracking];
        [companionsArray addObjectsFromArray:companions];
    }
    
    return companionsArray;
}

- (NSArray *)companionsFromQuery:(NSString *)query
                        tracking:(NSDictionary *)tracking {
    
    NSMutableArray * companionsArray = [NSMutableArray new];
    for (NSData *document in vastDocumentArray){
        NSArray *results = DSK_performXMLXPathQuery(document, query);
        for (NSDictionary * result in results) {
            NSArray *attributes = result[@"nodeAttributeArray"];
//            NSString * id_;
            NSString * width;
            NSString * height;
            for (NSDictionary *attribute in attributes) {
                if ([attribute[@"attributeName"] isEqualToString:@"width"]) {
                    width = attribute[@"nodeContent"];
                }
//                if ([attribute[@"attributeName"] isEqualToString:@"id"]) {
//                    id_ = attribute[@"nodeContent"];
//                }
                if ([attribute[@"attributeName"] isEqualToString:@"height"]) {
                    height = attribute[@"nodeContent"];
                }
            }
            
            NSMutableDictionary * companionDataDict = [NSMutableDictionary new];
            DSKSKVASTUrlWithId * clickThrough;
            
            NSArray * creatives = result[@"nodeChildArray"];
            for (NSDictionary * creativeNode in creatives) {
                NSString * companionNodeName = creativeNode[@"nodeName"];
                
                if ([companionNodeName isEqualToString:kDSKSKVASTHTMLCompanion] ||
                    [companionNodeName isEqualToString:kDSKSKVASTStaticCompanion] ||
                    [companionNodeName isEqualToString:kDSKSKVASTIFrameCompanion]) {
                    
                    companionDataDict[companionNodeName] = [self contentOfNode:creativeNode];
                }
                
                if ([companionNodeName hasSuffix:@"ClickThrough"]) {
                    NSString * _id = companionNodeName;
                    NSString * stringURL = [self contentOfNode:creativeNode];
                    NSURL * url = stringURL ? [NSURL URLWithString:stringURL] : nil;
                    
                    clickThrough = [[DSKSKVASTUrlWithId alloc] initWithID:_id url:url];
                }
            }
            
            DSKSKVASTCompanion * vastCompanion = [[DSKSKVASTCompanion alloc] initWithData:companionDataDict
                                                                                    width:width
                                                                                   height:height
                                                                          clickThroughURL:clickThrough
                                                                           clickTrackings:nil
                                                                                 tracking:tracking];
            [companionsArray addObject:vastCompanion];
        }
    }
    return companionsArray;
}


- (NSString *)contentOfNode:(NSDictionary *)node {
    if (node[@"nodeContent"] && ![node[@"nodeContent"] isEqualToString:@""]) {
        return node[@"nodeContent"];
    } else {
        for (NSDictionary * childNode in node[@"nodeChildArray"]) {
            NSString * content = childNode[@"nodeContent"];
            if (content && ![content isEqualToString:@""]) {
                return content;
            }
        }
    }
    return nil;
}

- (NSString *)skippOffset {
    NSString * query = @"//Linear";
    for (NSData *document in vastDocumentArray) {
        NSArray *results = DSK_performXMLXPathQuery(document, query);
        for (NSDictionary * result in results) {
            NSArray * attributes = result[@"nodeAttributeArray"];
            for (NSDictionary * attribute in attributes) {
                if ([attribute[@"attributeName"] isEqualToString:@"skipoffset"] && [attribute[@"nodeContent"] isKindOfClass:[NSString class]]) {
                    return attribute[@"nodeContent"];
                }
            }
        }
    }
    return nil;
}

- (DSKVASTExtensionModel *)extension {
    NSMutableArray <DSKVASTExtensionModel *>* extentions = (NSMutableArray <DSKVASTExtensionModel *> *)[NSMutableArray array];
    
    NSString * query = @"//Extension";
    for (NSData *document in vastDocumentArray){
        NSArray *results = DSK_performXMLXPathQuery(document, query);
        
        for (NSDictionary * result in results) {
            DSKVASTExtensionModel * extModel = [DSKVASTExtensionModel parseXMLWithJSON:result];
            if (extModel) {
                [extentions addObject:extModel];
            }
        }
    }
    
    [extentions filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(DSKVASTExtensionModel *  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [evaluatedObject.typeName isEqualToString:@"appodeal"];
    }]];
    
    return [extentions firstObject];
}

//- (NSDictionary *)extensions {
//    NSMutableDictionary * extensions = [NSMutableDictionary new];
//
//    static NSArray * supportedAttributes;
//    static dispatch_once_t onceToken;
////    TODO: UPDATE
////    dispatch_once(&onceToken, ^{
////        supportedAttributes = @[kVASTSkippTimeAttribute,
////                                kVASTCallToActionTextAttribute,
////                                kVASTIteractionEnabledForBannerAttribute,
////                                kVASTSkippTrackerAttribute,
////                                kVASTClickTrackerBannerAttribute,
////                                kVASTContolsOnScreen];
////    });
//    
//    
//    DSKVastExtentionModel * extModel = nil;
//    
//    
//    
//    
//    for (NSData *document in vastDocumentArray){
//        NSArray *results = DSK_performXMLXPathQuery(document, query);
//        
//        for (NSDictionary * result in results) {
//            NSArray *attributes = result[@"nodeAttributeArray"];
//            
//            for (NSDictionary *attribute in attributes) {
//                NSString * attrubuteType = attribute[@"nodeContent"];
//                
//                if (attrubuteType && [supportedAttributes containsObject:attrubuteType]) {
//                    extensions[attrubuteType] = result[@"nodeChildArray"] ? [result[@"nodeChildArray"] firstObject][@"nodeContent"] : result[@"nodeContent"];
//                }
//            }
//        }
//    }
//    
//    return extensions;
//}

- (NSString *)rawData {
    NSData * vastData = [vastDocumentArray firstObject];
    NSString * rawData = vastData ? [[NSString alloc] initWithData:vastData encoding:NSUTF8StringEncoding] : @"";
    return rawData;
}

- (NSArray *)mediaFiles;
{
    NSMutableArray *mediaFileArray;
    NSString *query = @"//MediaFile";
    
    for (NSData *document in vastDocumentArray) {
        NSArray *results = DSK_performXMLXPathQuery(document, query);
        for (NSDictionary *result in results) {
 
            // use lazy initialization
            if (!mediaFileArray) {
                mediaFileArray = [NSMutableArray array];
            }
            
            NSString *id_;
            NSString *delivery;
            NSString *type;
            NSString *bitrate;
            NSString *width;
            NSString *height;
            NSString *scalable;
            NSString *duration;
            NSString *maintainAspectRatio;
            NSString *apiFramework;
            
            NSArray *attributes = result[@"nodeAttributeArray"];
            for (NSDictionary *attribute in attributes) {
                NSString *name = attribute[@"attributeName"];
                NSString *content = attribute[@"nodeContent"];
                if ([name isEqualToString:@"id"]) {
                    id_ = content;
                } else  if ([name isEqualToString:@"delivery"]) {
                    delivery = content;
                } else  if ([name isEqualToString:@"type"]) {
                    type = content;
                } else  if ([name isEqualToString:@"bitrate"]) {
                    bitrate = content;
                } else  if ([name isEqualToString:@"width"]) {
                    width = content;
                } else  if ([name isEqualToString:@"height"]) {
                    height = content;
                } else  if ([name isEqualToString:@"scalable"]) {
                    scalable = content;
                }else  if ([name isEqualToString:@"duration"]) {
                    duration = content;
                } else  if ([name isEqualToString:@"maintainAspectRatio"]) {
                    maintainAspectRatio = content;
                } else  if ([name isEqualToString:@"apiFramework"]) {
                    apiFramework = content;
                }
            }
            NSString *urlString = [self content:result];
            if (urlString != nil) {
                urlString = [[self urlWithCleanString:urlString] absoluteString];
            }
            
            DSKSKVASTMediaFile *mediaFile = [[DSKSKVASTMediaFile alloc] initWithId:id_
                                                                          delivery:delivery
                                                                              type:type
                                                                           bitrate:bitrate
                                                                             width:width
                                                                            height:height
                                                                          duration:duration
                                                                          scalable:scalable
                                                               maintainAspectRatio:maintainAspectRatio
                                                                      apiFramework:apiFramework
                                                                               url:urlString];
            
            [mediaFileArray addObject:mediaFile];
        }
    }
    
    return mediaFileArray;
}

#pragma mark - helper methods

- (NSArray *)resultsForQuery:(NSString *)query
{
    NSMutableArray *array;
//    NSString *elementName = [query stringByReplacingOccurrencesOfString:@"/" withString:@""];
    
    for (NSData *document in vastDocumentArray) {
        NSArray *results = DSK_performXMLXPathQuery(document, query);
        for (NSDictionary *result in results) {
            // use lazy initialization
            if (!array) {
                array = [NSMutableArray array];
            }
            NSString *urlString = [self content:result];
            
            NSString *id_; // add underscore to avoid confusion with kewyord id
            NSArray *attributes = result[@"nodeAttributeArray"];
            for (NSDictionary *attribute in attributes) {
                NSString *name = attribute[@"attributeName"];
                if ([name isEqualToString:@"id"]) {
                    id_ = attribute[@"nodeContent"];
                    break;
                }
            }
            DSKSKVASTUrlWithId *impression = [[DSKSKVASTUrlWithId alloc] initWithID:id_ url:[self urlWithCleanString:urlString]];
            [array addObject:impression];
        }
    }
    
    return array;
}

- (NSString *)content:(NSDictionary *)node
{
    // this is for string data
    if ([node[@"nodeContent"] length] > 0) {
        return node[@"nodeContent"];
    }
    
    // this is for CDATA
    NSArray *childArray = node[@"nodeChildArray"];
    if ([childArray count] > 0) {
        // return the first array element that is not a comment
        for (NSDictionary *childNode in childArray) {
            if ([childNode[@"nodeName"] isEqualToString:@"comment"]) {
                continue;
            }
            return childNode[@"nodeContent"];
        }
    }
    
    return nil;
}

- (NSURL*)urlWithCleanString:(NSString *)string
{
    NSString *cleanUrlString = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];  // remove leading, trailing \n or space
    cleanUrlString = [cleanUrlString stringByReplacingOccurrencesOfString:@"|" withString:@"%7c"];
    cleanUrlString = [cleanUrlString stringByReplacingOccurrencesOfString:@"${" withString:@"%24%7B"];
    cleanUrlString = [cleanUrlString stringByReplacingOccurrencesOfString:@"}" withString:@"%7D"];
    return [NSURL URLWithString:cleanUrlString];                                                                            // return the resulting URL
}

@end
