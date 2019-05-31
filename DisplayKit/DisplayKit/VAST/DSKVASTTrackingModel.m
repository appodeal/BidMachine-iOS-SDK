//
//  DSKVASTTrackingModel.m
//  OpenBids
//

//  Copyright © 2016 OpenBids, Inc. All rights reserved.
//

#import "DSKVASTTrackingModel.h"
#import <ASKExtension/NSObject+ASKExtension.h>
#import "DSKSKVASTUrlWithId.h"

static NSString * const kDSKVASTTrackingFirstQuartile   = @"firstQuartile";
static NSString * const kDSKVASTTrackingMidpoint        = @"midpoint";
static NSString * const kDSKVASTTrackingThirdQuartile   = @"thirdQuartile";
static NSString * const kDSKVASTTrackingComplete        = @"complete";
static NSString * const kDSKVASTTrackingMute            = @"mute";
static NSString * const kDSKVASTTrackingUnmute          = @"unmute";
static NSString * const kDSKVASTTrackingPause           = @"pause";
static NSString * const kDSKVASTTrackingResume          = @"resume";
static NSString * const kDSKVASTTrackingFullscreen      = @"fullscreen";
static NSString * const kDSKVASTTrackingClose           = @"close";
static NSString * const kDSKVASTTrackingStart           = @"start";
static NSString * const kDSKVASTTrackingCreativeView    = @"creativeView";


@interface DSKVASTTrackingModel ()

@property (nonatomic, strong, readwrite) NSArray* impressions;
@property (nonatomic, strong, readwrite) NSArray* clickTrackingUrl;
@property (nonatomic, strong, readwrite) NSArray* firstQurtileURL;
@property (nonatomic, strong, readwrite) NSArray* midpointURL;
@property (nonatomic, strong, readwrite) NSArray* thirdQurtileURL;
@property (nonatomic, strong, readwrite) NSArray* finishURL;
@property (nonatomic, strong, readwrite) NSArray* closeURL;
@property (nonatomic, strong, readwrite) NSArray* fullScreenURL;
@property (nonatomic, strong, readwrite) NSArray* muteURL;
@property (nonatomic, strong, readwrite) NSArray* unmuteURL;
@property (nonatomic, strong, readwrite) NSArray* startURL;
@property (nonatomic, strong, readwrite) NSArray * creativeView;
@property (nonatomic, strong, readwrite) NSArray * pauseURL;
@property (nonatomic, strong, readwrite) NSArray * resumeURL;

@end

@implementation DSKVASTTrackingModel

- (void)fillWithImpressions:(NSArray *)impressions {
    NSMutableArray * impressionsMut = [NSMutableArray new];
    for (DSKSKVASTUrlWithId * vastUrl in impressions) {
        if ([vastUrl url]) {
            [impressionsMut addObject:[vastUrl url]];
        }
    }
    self.impressions = impressionsMut;
}

- (void)fillWithClickTrackings:(NSArray *)clickTrackings {
    NSMutableArray * clickTrackingsMut = [NSMutableArray new];
    for (DSKSKVASTUrlWithId * clickUrl in clickTrackings) {
        if ([clickUrl url]) {
            [clickTrackingsMut addObject:[clickUrl url]];
        }
    }
    self.clickTrackingUrl = clickTrackingsMut;
}

- (void)fillWithTrackingEvents:(NSDictionary *)trackingEvents {
    self.startURL           = [self arrayFromDict:trackingEvents withKey:kDSKVASTTrackingStart];
    self.firstQurtileURL    = [self arrayFromDict:trackingEvents withKey:kDSKVASTTrackingFirstQuartile];
    self.midpointURL        = [self arrayFromDict:trackingEvents withKey:kDSKVASTTrackingMidpoint];
    self.thirdQurtileURL    = [self arrayFromDict:trackingEvents withKey:kDSKVASTTrackingThirdQuartile];
    self.finishURL          = [self arrayFromDict:trackingEvents withKey:kDSKVASTTrackingComplete];
    self.closeURL           = [self arrayFromDict:trackingEvents withKey:kDSKVASTTrackingClose];
    self.fullScreenURL      = [self arrayFromDict:trackingEvents withKey:kDSKVASTTrackingFullscreen];
    self.muteURL            = [self arrayFromDict:trackingEvents withKey:kDSKVASTTrackingMute];
    self.unmuteURL          = [self arrayFromDict:trackingEvents withKey:kDSKVASTTrackingUnmute];
    self.creativeView       = [self arrayFromDict:trackingEvents withKey:kDSKVASTTrackingCreativeView];
    self.pauseURL           = [self arrayFromDict:trackingEvents withKey:kDSKVASTTrackingPause];
    self.resumeURL          = [self arrayFromDict:trackingEvents withKey:kDSKVASTTrackingResume];
}

- (NSArray *)arrayFromDict:(NSDictionary *)dict withKey:(NSString *)key {
    NSMutableArray * mutTrack = [NSMutableArray new];
    for (NSURL *aURL in (dict)[key]) {
        [mutTrack addObject:aURL];
    }
    return mutTrack;
}

@end
