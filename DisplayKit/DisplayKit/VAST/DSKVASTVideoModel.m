//
//  DSKVASTVideoModel.m
//  OpenBids
//

//  Copyright © 2016 OpenBids, Inc. All rights reserved.
//

#import "DSKVASTVideoModel.h"

#import "NSError+DSKVAST.h"
#import <ASKLogger/ASKLogger.h>
#import "DSKSKVAST2Parser.h"
#import "DSKSKVASTModel.h"
#import "DSKSKVASTMediaFile.h"
#import "DSKSKVASTUrlWithId.h"
#import "DSKSKVASTCompanion.h"
#import "DSKVASTCompanion+Private.h"
#import "NSString+DSKExtensions.h"


@interface DSKVASTVideoModel ()

@property (nonatomic, strong) DSKSKVASTModel * parsedVast;
@property (nonatomic, strong) DSKSKVASTMediaFile * optimalFile;
@property (nonatomic, strong, readwrite) DSKVASTTrackingModel * tracking;
@property (nonatomic, strong, readwrite) DSKVASTExtension * extension;

@end

@implementation DSKVASTVideoModel {
    BOOL _extensionsWasParsed;
}

#pragma mark - Public

+ (void)parseVastData:(NSData *)XMLData completion:(void (^)(DSKVASTVideoModel *model, NSError *error))completion {
    DSKSKVAST2Parser * parser = [DSKSKVAST2Parser new];
    [parser parseWithData:XMLData completion:^(DSKSKVASTModel *model, DSKVASTErrorCode errorCode) {
        [self validateVastMovel:model errorCode:errorCode completion:completion];
    }];
}


+ (void)parseVastUrl:(NSURL *)Url completion:(void (^)(DSKVASTVideoModel *model, NSError *error))completion {
    DSKSKVAST2Parser * parser = [DSKSKVAST2Parser new];
    [parser parseWithUrl:Url completion:^(DSKSKVASTModel *model, DSKVASTErrorCode errorCode) {
        [self validateVastMovel:model errorCode:errorCode completion:completion];
    }];
}

+ (void)validateVastMovel:(DSKSKVASTModel *)model errorCode:(DSKVASTErrorCode)errorCode completion:(void (^)(DSKVASTVideoModel *model, NSError *error))completion{
    if (!completion) {
        return;
    }
    
    NSError * error = nil;
    DSKVASTVideoModel * vast = [[DSKVASTVideoModel alloc] initWithParsedVast:model];
    
    if (errorCode != DSKVASTNoError) {
        error = [NSError DSK_vastErrorWithCode:errorCode];
    } else if (!vast.videoURL || !vast.tracking.impressions) {
        error = [NSError DSK_vastErrorWithCode:DSKVASTValidationError];
    }
    
    completion(vast,error);
    
}

#pragma mark - Private

- (instancetype)initWithParsedVast:(DSKSKVASTModel *)parsedVast {
    self = [super init];
    if (self) {
        self.parsedVast = parsedVast;
        self.tracking = [DSKVASTTrackingModel new];
        [self.tracking fillWithImpressions:[self.parsedVast impressions]];
        [self.tracking fillWithClickTrackings:[self.parsedVast clickTracking]];
        [self.tracking fillWithTrackingEvents:[self.parsedVast trackingEvents]];
    }
    return self;
}

- (DSKSKVASTMediaFile *)optimalFile {
    if (!_optimalFile) {
        for (DSKSKVASTMediaFile * mediaFile in [self.parsedVast mediaFiles]) {
            if ([mediaFile.type isEqualToString:@"video/mp4"]) {
                _optimalFile = mediaFile;
                break;
            }
        }
    }
    return _optimalFile;
}

#pragma mark - SKVASTModel forwarding

- (NSURL *)videoURL {
    return self.optimalFile.url;
}

- (float)duration {
    return self.optimalFile.duration;
}

- (float)skippOffset {
    NSString * skipOffset = [self.parsedVast skippOffset];
    return skipOffset ? [skipOffset DSK_timeInterval] : 5.0f;
}

- (DSKVASTAspectRatio)aspectRatio {
    if (self.width == 0 ||
        self.heigth == 0) {
        return DSKVASTAspectRatioUnknown;
    }
    
    if (self.heigth > self.width) {
        return DSKVASTAspectRatioPortrait;
    } else {
        return DSKVASTAspectRatioLandscape;
    }
}

- (NSInteger)width {
    return [self.optimalFile width];
}

- (NSInteger)heigth {
    return [self.optimalFile height];
}

- (NSURL *)clickThroughURL {
    return [[self.parsedVast clickThrough] url];
}

- (NSString *)errorNoticeUrl {
   return [[[[self.parsedVast errors] firstObject] url] absoluteString];
}

- (DSKVASTExtension *)extension {
    if (!_extension && !_extensionsWasParsed) {
        _extension = [DSKVASTExtension extensionFromModel:[self.parsedVast extension]];
        _extensionsWasParsed = YES;
    }
    return _extension;
}

- (NSArray <__kindof DSKVASTCompanion *> *)companionsArray {
    if (!_companionsArray) {
        _companionsArray = [DSKVASTCompanion companionsFormSKVASTCompanions:[self.parsedVast companions]];
    }
    return _companionsArray;
}

- (NSString *)rawData {
    return [self.parsedVast rawData];
}

@end
