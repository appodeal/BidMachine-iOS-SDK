//
//  BDMViewabilityMetricAppodeal.m
//  BidMachine
//
//  Created by Stas Kochkin on 22/10/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import "BDMViewabilityMetricAppodeal.h"
#import <ASKViewabilityTracker/ASKViewabilityTracker.h>

@interface BDMViewabilityMetricAppodeal ()

@property (nonatomic, strong) BDMViewabilityMetricConfiguration * configuration;
@property (nonatomic, strong) ASKViewabilityTracker * tracker;

@end

@implementation BDMViewabilityMetricAppodeal

+ (instancetype)metricWithConfiguration:(BDMViewabilityMetricConfiguration *)configuration {
    BDMViewabilityMetricAppodeal * metric = [[BDMViewabilityMetricAppodeal alloc] initWithConfiguration:configuration];
    return metric;
}

- (instancetype)initWithConfiguration:(BDMViewabilityMetricConfiguration *)configuration {
    if (self = [super init]) {
        self.configuration = configuration;
    }
    return self;
}

- (void)finishViewabilityMonitoringForView:(UIView *)view {
    self.tracker = nil;
}

- (void)startViewabilityMonitoringForView:(UIView *)view
                                startView:(dispatch_block_t)startView
                               finishView:(dispatch_block_t)finishView {
    self.tracker = [ASKViewabilityTracker defaultTracker];
    // Impression in tracker is first show on screen.
    // Add small delay
    self.tracker.impressionInterval = 0.1f;
    // For BidMachine we tracks impression as event that
    // target view was visible on screen for some interval
    // as same as ASKViewabilityTracker viewable logic
    self.tracker.viewabilityInterval = self.configuration.impressionInterval;
    // Setup percent
    // Fix https://jira.appodeal.com/browse/SDK-649
    // iPhone 6s, iOS 9.3.5 what's wrong with you 🙈
    self.tracker.viewabilityPercentage = MIN(self.configuration.visiblePercent, 99.9);
    // Setup overlay detection
    self.tracker.overlayDetection = self.configuration.overlayDetection;
    // Begin tracking
    [self.tracker startTracking:view
                       subviews:self.configuration.visibleSubviews
                     impression:startView
                       viewable:finishView];
}

@end
