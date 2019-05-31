//
//  DSKVASTCompanion.m
//  OpenBids
//

//  Copyright © 2016 OpenBids, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ASKExtension/NSObject+ASKExtension.h>

#import "DSKVASTCompanion.h"
#import "DSKVASTCompanion+Private.h"


static NSString * const kDSKVASTCompanionTrackingCreativeView = @"creativeView";

DSKVASTCompanionType DSK_companionTypeFromString(NSString * typeString) {
    // Beware wrong enumeration!
    NSArray * supportedValues = @[
                                  kDSKSKVASTStaticCompanion,
                                  kDSKSKVASTHTMLCompanion,
                                  kDSKSKVASTIFrameCompanion
                                  ];
    
    DSKVASTCompanionType type = DSKVASTCompanionTypeUndefined;
    if (NSString.ask_isValid(typeString)) {
        type = [supportedValues indexOfObject:typeString];
    }
    
    return type;
}


@interface DSKVASTCompanion ()

@property (nonatomic, strong) DSKVASTCompanionModel * companionModel;

@property (nonatomic, strong, readwrite) NSString * data;
@property (nonatomic, strong, readwrite) NSURL * clickThroughURL;
@property (nonatomic, strong, readwrite) NSArray * clickTrackingURLs;
@property (nonatomic, strong, readwrite) NSArray * creativeViewTrackingURLs;

@property (nonatomic, assign, readwrite) DSKVASTCompanionType type;

@end

@implementation DSKVASTCompanion

+ (NSArray<DSKVASTCompanion *> *)companionFromModels:(NSArray<DSKVASTCompanionModel *> *)extentionModels{
    NSMutableArray * companions = nil;
    
    for (DSKVASTCompanionModel * extModel in extentionModels) {
        DSKVASTCompanion * companion = [self companionFromModel:extModel];
        if (companion) {
            if (!companions) {
                companions = [NSMutableArray array];
            }
            [companions addObject:companion];
        }
    }
    
    return companions;
}

+ (instancetype)companionFromModel:(DSKVASTCompanionModel *)companionModel{
    if (!companionModel){
        return nil;
    }
    
    DSKVASTCompanion * _instance = [[DSKVASTCompanion alloc] initWithCompanionModel:companionModel];
    return _instance;;
}

- (instancetype)initWithCompanionModel:(DSKVASTCompanionModel *)companionModel{
    self = [super init];
    if (self) {
        _companionModel     = companionModel;
        _clickThroughURL    = [NSURL URLWithString:companionModel.companionClick.resource];
        _data               = companionModel.resource.resource;
        _type               = DSK_companionTypeFromString(companionModel.resource.type);
        
        _width              = [companionModel.width intValue];
        _heigth             = [companionModel.height intValue];
    }
    return self;
}

+ (NSArray *)companionsFormSKVASTCompanions:(NSArray *)companions {
    NSMutableArray * apdCompanions = [NSMutableArray new];
    for (DSKSKVASTCompanion * companion in companions) {
        [apdCompanions addObjectsFromArray: [[self class] companionsFromSKVASTCompanion:companion]];
    }
    return apdCompanions;
}

+ (NSArray *)companionsFromSKVASTCompanion:(DSKSKVASTCompanion *)vastCompanion {
    NSMutableArray * apdCompanions = [NSMutableArray new];
    for (NSString * key in [vastCompanion.dataByType allKeys]) {
        DSKVASTCompanion * apdCompanion = [[DSKVASTCompanion alloc] initWithData:vastCompanion.dataByType[key]
                                                                            type:key width:vastCompanion.width
                                                                          height:vastCompanion.height
                                                                 clickThroughURL:vastCompanion.clickThroughURL
                                                                  clickTrackings:vastCompanion.clickTrackingURL
                                                                        tracking:vastCompanion.tracking];
        [apdCompanions addObject:apdCompanion];
    }
    return apdCompanions;
}

- (instancetype)initWithData:(NSString *)dataString
                        type:(NSString *)type
                       width:(int)width
                      height:(int)height
             clickThroughURL:(DSKSKVASTUrlWithId *)clickThroughURL
              clickTrackings:(NSArray *)clickTrackings
                    tracking:(NSDictionary *)tracking {
    
    self = [super init];
    if (self) {
        //Fill data
        self.type   = DSK_companionTypeFromString(type);
        self.data   = dataString;
        self.width  = width;
        self.heigth = height;
        
        //Filters
        NSPredicate * clickTrackingURLsFilter = [NSPredicate predicateWithBlock:^BOOL(DSKSKVASTUrlWithId * tracker, NSDictionary<NSString *,id> * _Nullable bindings) {
            return NSURL.ask_isValid(tracker.url);
        }];
        
        NSPredicate * creativeViewTrackingURLsFilter =  [NSPredicate predicateWithBlock:^BOOL(id object, NSDictionary<NSString *,id> * _Nullable bindings) {
            return NSURL.ask_isValid(object);
        }];
        
        NSArray * creativeViewTrackingURLs = NSArray.ask_isValid(tracking[kDSKVASTCompanionTrackingCreativeView]) ? tracking[kDSKVASTCompanionTrackingCreativeView] : @[];
        
        self.clickThroughURL            = clickThroughURL.url;
        self.clickTrackingURLs          = [clickTrackings filteredArrayUsingPredicate:clickTrackingURLsFilter];
        self.creativeViewTrackingURLs   = [creativeViewTrackingURLs filteredArrayUsingPredicate:creativeViewTrackingURLsFilter];
    }
    
    return self;
}


- (DSKVASTAspectRatio)aspectRatio {
    if (self.width == 0 || self.heigth == 0) {
        return DSKVASTAspectRatioUnknown;
    }
    
    if (self.width == 320 && self.heigth == 50) {
        return DSKVASTAspectRatioBanner;
    } else if (self.heigth > self.width ||
               (self.heigth == 250 && self.width == 300)) { //Portrait include mrec
        return DSKVASTAspectRatioPortrait;
    } else if (self.width / self.heigth < 6) { // exclude narrow banners
        return DSKVASTAspectRatioLandscape;
    }
    
    return DSKVASTAspectRatioUnknown;
}

@end
