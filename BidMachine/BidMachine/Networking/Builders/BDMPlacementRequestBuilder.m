//
//  BDMPlacementRequestBuilder.m
//
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import "BDMPlacementRequestBuilder.h"
#import "BDMProtoAPI-Umbrella.h"
#import <ASKExtension/ASKExtension.h>


@interface BDMPlacementRequestBuilder ()

@property (nonatomic, readwrite, strong) ADCOMPlacement *placement;

@end

@implementation BDMPlacementRequestBuilder

- (id<BDMPlacementRequestBuilder> (^)(NSString *))appendSDK {
    return ^id<BDMPlacementRequestBuilder>(NSString * sdk){
        self.placement.sdk = sdk;
        return self;
    };
}

- (id<BDMPlacementRequestBuilder> (^)(NSString *))appendSDKVer {
    return ^id<BDMPlacementRequestBuilder>(NSString * sdkVer){
        self.placement.sdkver = sdkVer;
        return self;
    };
}

- (id<BDMPlacementRequestBuilder> (^)(BOOL))appendReward {
    return ^id<BDMPlacementRequestBuilder>(BOOL reward){
        self.placement.reward = reward;
        return self;
    };
}

- (id<BDMPlacementRequestBuilder> (^)(id<BDMVideoPlacementBuilder>))appendVideoPlacement {
    return ^id<BDMPlacementRequestBuilder>(id<BDMVideoPlacementBuilder> placement){
        self.placement.video = (ADCOMPlacement_VideoPlacement *)placement.placement;
        return self;
    };
}

- (id<BDMPlacementRequestBuilder> (^)(id<BDMDisplayPlacementBuilder>))appendDisplayPlacement {
    return ^id<BDMPlacementRequestBuilder>(id<BDMDisplayPlacementBuilder> placement){
        self.placement.display = (ADCOMPlacement_DisplayPlacement *)placement.placement;
        return self;
    };
}

- (ADCOMPlacement *)placement {
    if (!_placement) {
        _placement = [ADCOMPlacement message];
    }
    return _placement;
}

@end


@interface BDMVideoPlacementBuilder ()

@property (nonatomic, readwrite, strong) ADCOMPlacement_VideoPlacement *placement;

@end

@implementation BDMVideoPlacementBuilder

- (id<BDMVideoPlacementBuilder> (^)(unsigned int))appendPos {
    return ^id<BDMVideoPlacementBuilder>(unsigned int pos){
        self.placement.pos = (ADCOMPlacementPosition)pos;
        return self;
    };
}

- (id<BDMVideoPlacementBuilder> (^)(BOOL))appendskip {
    return ^id<BDMVideoPlacementBuilder>(BOOL skip){
        self.placement.skip = skip;
        return self;
    };
}

- (id<BDMVideoPlacementBuilder> (^)(unsigned int))appendUnit {
    return ^id<BDMVideoPlacementBuilder>(unsigned int unitSize){
        self.placement.unit = (ADCOMSizeUnit)unitSize;
        return self;
    };
}

- (id<BDMVideoPlacementBuilder> (^)(NSArray<NSNumber *>*))appendCType {
    return ^id<BDMVideoPlacementBuilder>(NSArray<NSNumber *>* cTypes){
        self.placement.ctypeArray = ASKObj(cTypes).reduce([GPBEnumArray array], ^(GPBEnumArray *array, NSNumber *value){
            [array addValue:value.unsignedIntValue];
        }).original;
        return self;
    };
}

- (id<BDMVideoPlacementBuilder> (^)(id<BDMExtPlacementBuilder>))appendExt {
    return ^id<BDMVideoPlacementBuilder>(id<BDMExtPlacementBuilder> ext){
        self.placement.extArray = ASKObj(ext.placement).transform(^id(BDMPlacementExtension *extention, NSUInteger idx){
            NSError *error = nil;
            GPBAny *any = [[GPBAny alloc] initWithMessage:extention error:&error];
            return !error ? any : nil;
        }).array.mutableCopy;
        return self;
    };
}


- (id<BDMVideoPlacementBuilder> (^)(float))appendHeight {
    return ^id<BDMVideoPlacementBuilder>(float value){
        self.placement.h = value;
        return self;
    };
}

- (id<BDMVideoPlacementBuilder> (^)(float))appendWidth {
    return ^id<BDMVideoPlacementBuilder>(float value){
        self.placement.w = value;
        return self;
    };
}

- (id<BDMVideoPlacementBuilder> (^)(NSArray<NSString *> *))appendMimes {
    return ^id<BDMVideoPlacementBuilder>(NSArray<NSString *> * value){
        self.placement.mimeArray = value.mutableCopy;
        return self;
    };
}

- (id<BDMVideoPlacementBuilder> (^)(unsigned int))appendMaxdur {
    return ^id<BDMVideoPlacementBuilder>(unsigned int value){
        self.placement.maxdur = value;
        return self;
    };
}

- (id<BDMVideoPlacementBuilder> (^)(unsigned int))appendMindur {
    return ^id<BDMVideoPlacementBuilder>(unsigned int value){
        self.placement.mindur = value;
        return self;
    };
}

- (id<BDMVideoPlacementBuilder> (^)(unsigned int))appendMinbitr {
    return ^id<BDMVideoPlacementBuilder>(unsigned int value){
        self.placement.minbitr = value;
        return self;
    };
}

- (id<BDMVideoPlacementBuilder> (^)(unsigned int))appendMaxbitr {
    return ^id<BDMVideoPlacementBuilder>(unsigned int value){
        self.placement.maxbitr = value;
        return self;
    };
}

- (id<BDMVideoPlacementBuilder> (^)(unsigned int))appendLinearity {
    return ^id<BDMVideoPlacementBuilder>(unsigned int value){
        self.placement.linear = value;
        return self;
    };
}

- (ADCOMPlacement_VideoPlacement *)placement {
    if (!_placement) {
        _placement = [ADCOMPlacement_VideoPlacement message];
    }
    return _placement;
}

@end


@interface BDMDisplayPlacementBuilder ()

@property (nonatomic, readwrite, strong) ADCOMPlacement_DisplayPlacement *placement;

@end


@implementation BDMDisplayPlacementBuilder

- (id<BDMDisplayPlacementBuilder> (^)(unsigned int))appendPos {
    return ^id<BDMDisplayPlacementBuilder>(unsigned int pos){
        self.placement.pos = (ADCOMPlacementPosition)pos;
        return self;
    };
}

- (id<BDMDisplayPlacementBuilder> (^)(BOOL))appendInstl {
    return ^id<BDMDisplayPlacementBuilder>(BOOL instl){
        self.placement.instl = instl;
        return self;
    };
}

- (id<BDMDisplayPlacementBuilder> (^)(unsigned int))appendApi {
    return ^id<BDMDisplayPlacementBuilder>(unsigned int api){
        self.placement.apiArray = [GPBEnumArray arrayWithValidationFunction:nil
                                                                   rawValue:api];
        return self;
    };
}

- (id<BDMDisplayPlacementBuilder> (^)(float))appendHeight {
    return ^id<BDMDisplayPlacementBuilder>(float value){
        self.placement.h = value;
        return self;
    };
}

- (id<BDMDisplayPlacementBuilder> (^)(float))appendWidth {
    return ^id<BDMDisplayPlacementBuilder>(float value){
        self.placement.w = value;
        return self;
    };
}

- (id<BDMDisplayPlacementBuilder> (^)(id<BDMNativeFormatBuilder>))appendNativeFmt {
    return ^id<BDMDisplayPlacementBuilder>(id<BDMNativeFormatBuilder> fmt){
        self.placement.nativefmt = (ADCOMPlacement_DisplayPlacement_NativeFormat *)fmt.format;
        return self;
    };
}

- (id<BDMDisplayPlacementBuilder> (^)(id<BDMExtPlacementBuilder>))appendExt {
    return ^id<BDMDisplayPlacementBuilder>(id<BDMExtPlacementBuilder> ext){
        self.placement.extArray = ASKObj(ext.placement).transform(^id(BDMPlacementExtension *extention, NSUInteger idx){
            NSError *error = nil;
            GPBAny *any = [[GPBAny alloc] initWithMessage:extention error:&error];
            return !error ? any : nil;
        }).array.mutableCopy;
        return self;
    };
}

- (id<BDMDisplayPlacementBuilder> (^)(unsigned int))appendUnit {
    return ^id<BDMDisplayPlacementBuilder>(unsigned int unitSize){
        self.placement.unit = (ADCOMSizeUnit)unitSize;
        return self;
    };
}

- (id<BDMDisplayPlacementBuilder> (^)(NSArray<NSString *> *))appendMimes {
    return ^id<BDMDisplayPlacementBuilder>(NSArray<NSString *> * value){
        self.placement.mimeArray = value.mutableCopy;
        return self;
    };
}

- (ADCOMPlacement_DisplayPlacement *)placement {
    if (!_placement) {
        _placement = [ADCOMPlacement_DisplayPlacement message];
    }
    return _placement;
}

@end

@interface BDMExtPlacementBuilder()

@property (nonatomic, readwrite, strong) BDMPlacementExtension *placement;

@end

@implementation BDMExtPlacementBuilder

- (id<BDMExtPlacementBuilder> (^)(NSString *))appendAdSpaceId {
    return ^id<BDMExtPlacementBuilder> (NSString *spaceId) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
        self.placement.adSpaceId = spaceId;
#pragma clang diagnostic pop

        return self;
    };
}

- (BDMPlacementExtension *)placement {
    if (!_placement) {
        _placement = [BDMPlacementExtension message];
    }
    return _placement;
}

@end

@interface BDMNativeFormatBuilder()

@property (nonatomic, readwrite, strong) ADCOMPlacement_DisplayPlacement_NativeFormat *format;

@end

@implementation BDMNativeFormatBuilder

- (id<BDMNativeFormatBuilder> (^)(id<BDMNativeFormatTypeBuilder>))appendTitle {
    return ^id<BDMNativeFormatBuilder> (id<BDMNativeFormatTypeBuilder>builder){
        ADCOMPlacement_DisplayPlacement_NativeFormat_AssetFormat_TitleAssetFormat *title = ADCOMPlacement_DisplayPlacement_NativeFormat_AssetFormat_TitleAssetFormat.new;
        [title setLen:104];
        [(ADCOMPlacement_DisplayPlacement_NativeFormat_AssetFormat *)builder.format setTitle:title];
        [self.format.assetArray ask_addObject:builder.format];
        return self;
    };
}

- (id<BDMNativeFormatBuilder> (^)(id<BDMNativeFormatTypeBuilder>))appendIcon {
    return ^id<BDMNativeFormatBuilder> (id<BDMNativeFormatTypeBuilder>builder){
        ADCOMPlacement_DisplayPlacement_NativeFormat_AssetFormat_ImageAssetFormat *img = ADCOMPlacement_DisplayPlacement_NativeFormat_AssetFormat_ImageAssetFormat.new;
        [img setType:ADCOMNativeImageAssetType_NativeImageAssetTypeIconImage];
        [(ADCOMPlacement_DisplayPlacement_NativeFormat_AssetFormat *)builder.format setImg:img];
        [self.format.assetArray ask_addObject:builder.format];
        return self;
    };
}

- (id<BDMNativeFormatBuilder> (^)(id<BDMNativeFormatTypeBuilder>))appendImage {
    return ^id<BDMNativeFormatBuilder> (id<BDMNativeFormatTypeBuilder>builder){
        ADCOMPlacement_DisplayPlacement_NativeFormat_AssetFormat_ImageAssetFormat *img = ADCOMPlacement_DisplayPlacement_NativeFormat_AssetFormat_ImageAssetFormat.new;
        [img setType:ADCOMNativeImageAssetType_NativeImageAssetTypeMainImage];
        [(ADCOMPlacement_DisplayPlacement_NativeFormat_AssetFormat *)builder.format setImg:img];
        [self.format.assetArray ask_addObject:builder.format];
        return self;
    };
}

- (id<BDMNativeFormatBuilder> (^)(id<BDMNativeFormatTypeBuilder>))appendDescription {
    return ^id<BDMNativeFormatBuilder> (id<BDMNativeFormatTypeBuilder>builder){
        ADCOMPlacement_DisplayPlacement_NativeFormat_AssetFormat_DataAssetFormat *data = ADCOMPlacement_DisplayPlacement_NativeFormat_AssetFormat_DataAssetFormat.new;
        [data setType:ADCOMNativeDataAssetType_NativeDataAssetTypeDesc];
        [(ADCOMPlacement_DisplayPlacement_NativeFormat_AssetFormat *)builder.format setData_p:data];
        [self.format.assetArray ask_addObject:builder.format];
        return self;
    };
}

- (id<BDMNativeFormatBuilder> (^)(id<BDMNativeFormatTypeBuilder>))appendCta {
    return ^id<BDMNativeFormatBuilder> (id<BDMNativeFormatTypeBuilder>builder){
        ADCOMPlacement_DisplayPlacement_NativeFormat_AssetFormat_DataAssetFormat *data = ADCOMPlacement_DisplayPlacement_NativeFormat_AssetFormat_DataAssetFormat.new;
        [data setType:ADCOMNativeDataAssetType_NativeDataAssetTypeCtaText];
        [(ADCOMPlacement_DisplayPlacement_NativeFormat_AssetFormat *)builder.format setData_p:data];
        [self.format.assetArray ask_addObject:builder.format];
        return self;
    };
}

- (id<BDMNativeFormatBuilder> (^)(id<BDMNativeFormatTypeBuilder>))appendRating {
    return ^id<BDMNativeFormatBuilder> (id<BDMNativeFormatTypeBuilder>builder){
        ADCOMPlacement_DisplayPlacement_NativeFormat_AssetFormat_DataAssetFormat *data = ADCOMPlacement_DisplayPlacement_NativeFormat_AssetFormat_DataAssetFormat.new;
        [data setType:ADCOMNativeDataAssetType_NativeDataAssetTypeRating];
        [(ADCOMPlacement_DisplayPlacement_NativeFormat_AssetFormat *)builder.format setData_p:data];
        [self.format.assetArray ask_addObject:builder.format];
        return self;
    };
}

- (id<BDMNativeFormatBuilder> (^)(id<BDMNativeFormatTypeBuilder>))appendSponsored {
    return ^id<BDMNativeFormatBuilder> (id<BDMNativeFormatTypeBuilder>builder){
        ADCOMPlacement_DisplayPlacement_NativeFormat_AssetFormat_DataAssetFormat *data = ADCOMPlacement_DisplayPlacement_NativeFormat_AssetFormat_DataAssetFormat.new;
        [data setType:ADCOMNativeDataAssetType_NativeDataAssetTypeSponsored];
        [(ADCOMPlacement_DisplayPlacement_NativeFormat_AssetFormat *)builder.format setData_p:data];
        [self.format.assetArray ask_addObject:builder.format];
        return self;
    };
}

- (id<BDMNativeFormatBuilder> (^)(id<BDMNativeFormatTypeBuilder>))appendVideo {
    return ^id<BDMNativeFormatBuilder> (id<BDMNativeFormatTypeBuilder>builder){
        BDMVideoPlacementBuilder *videoBuilder = BDMVideoPlacementBuilder.new;
        videoBuilder.appendCType(@[@2, @3, @5, @6]);
        videoBuilder.appendMimes(@[@"video/mpeg" , @"video/mp4", @"video/quicktime", @"video/avi"]);
        videoBuilder.appendskip(NO);
        videoBuilder.appendMaxdur(30);
        videoBuilder.appendMindur(5);
        videoBuilder.appendMinbitr(56);
        videoBuilder.appendMaxbitr(4096);
        videoBuilder.appendLinearity(1);
        
        ADCOMPlacement_VideoPlacement *video = (ADCOMPlacement_VideoPlacement *)videoBuilder.placement ;
        [(ADCOMPlacement_DisplayPlacement_NativeFormat_AssetFormat *)builder.format setVideo:video];
        [self.format.assetArray ask_addObject:builder.format];
        return self;
    };
}

- (ADCOMPlacement_DisplayPlacement_NativeFormat *)format {
    if (!_format) {
        _format = [ADCOMPlacement_DisplayPlacement_NativeFormat message];
        _format.assetArray = [NSMutableArray array];
    }
    return _format;
}

@end

@interface BDMNativeFormatTypeBuilder ()

@property (nonatomic, readwrite, strong) ADCOMPlacement_DisplayPlacement_NativeFormat_AssetFormat *format;

@end

@implementation BDMNativeFormatTypeBuilder

- (id<BDMNativeFormatTypeBuilder> (^)(unsigned int))appendId {
    return ^id<BDMNativeFormatTypeBuilder>(unsigned int ID){
        self.format.id_p = ID;
        return self;
    };
}

- (id<BDMNativeFormatTypeBuilder> (^)(BOOL))appendReq {
    return ^id<BDMNativeFormatTypeBuilder>(BOOL req){
        self.format.req = req;
        return self;
    };
}

- (ADCOMPlacement_DisplayPlacement_NativeFormat_AssetFormat *)format {
    if (!_format) {
        _format = [ADCOMPlacement_DisplayPlacement_NativeFormat_AssetFormat message];
    }
    return _format;
}

@end
