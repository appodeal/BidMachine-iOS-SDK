//
//  BDMViewabilityMetricProvider.m
//  BidMachine
//
//  Created by Stas Kochkin on 19/10/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import "BDMViewabilityMetricProvider.h"


@implementation BDMViewabilityMetricConfiguration

- (instancetype)init {
    if (self = [super init]) {
        self.impressionInterval = 1.0;
        self.visiblePercent = 100.0f;
        self.overlayDetection = NO;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    BDMViewabilityMetricConfiguration * copy = [BDMViewabilityMetricConfiguration new];
    
    copy.impressionInterval = self.impressionInterval;
    copy.visibleSubviews = self.visibleSubviews;
    copy.visiblePercent = self.visiblePercent;
    copy.overlayDetection = self.overlayDetection;
    
    return copy;
}

#pragma mark - Overriding

- (NSString *)description {
    return [NSString stringWithFormat:@"Viewability Congiguratioh with time: %1.2f ms, visible percent: %1.2f, overlay detection: %@", self.impressionInterval, self.visiblePercent, self.overlayDetection ? @"enabled" : @"disabled"];
}

@end

static NSMutableArray <Class<BDMViewabilityMetric>> * BDMRegisteredMetircs;

@interface BDMViewabilityMetricProvider ()

@property (nonatomic, copy) NSArray<id<BDMViewabilityMetric>> * activeMetrics;
@property (nonatomic, assign) BOOL hasImpression;
@property (nonatomic, assign) BOOL hasFinish;

@end

@implementation BDMViewabilityMetricProvider

+ (void)load {
    BDMRegisteredMetircs = [NSMutableArray new];
}

#pragma mark - Public

- (void)startViewabilityMonitoringForView:(UIView *)view
                            configuration:(BDMViewabilityMetricConfiguration *)configuration
                                 delegate:(id<BDMViewabilityMetricProviderDelegate>)delegate {
    NSMutableArray <id<BDMViewabilityMetric>> * activeMetrics = [NSMutableArray arrayWithCapacity:BDMRegisteredMetircs.count];
    __weak typeof(self) weakSelf = self;
    __weak typeof(view) weakView = view;
    [BDMRegisteredMetircs enumerateObjectsUsingBlock:^(Class<BDMViewabilityMetric> metricClass, NSUInteger idx, BOOL * stop) {
        id <BDMViewabilityMetric> metric = [metricClass metricWithConfiguration:configuration];
        [metric startViewabilityMonitoringForView:view startView:^{
            if (!weakSelf.hasImpression) {
                [weakSelf.delegate viewabilityMetricProvider:weakSelf detectStartView:weakView];
                weakSelf.hasImpression = YES;
            }
        } finishView:^{
            if (!weakSelf.hasFinish) {
                [weakSelf.delegate viewabilityMetricProvider:weakSelf detectImpression:weakView];
                weakSelf.hasFinish = YES;
            }
        }];
        [activeMetrics addObject:metric];
    }];
    self.activeMetrics = activeMetrics;
}

- (void)finishViewabilityMonitoringForView:(UIView *)view {
    [self.activeMetrics enumerateObjectsUsingBlock:^(id<BDMViewabilityMetric> metric, NSUInteger idx, BOOL * stop) {
        [metric finishViewabilityMonitoringForView:view];
    }];
    [self.delegate viewabilityMetricProvider:self detectFinishView:view];
}

@end


@implementation BDMViewabilityMetricProvider (Private)

+ (void)registerMetric:(Class<BDMViewabilityMetric>)metricClass {
    [BDMRegisteredMetircs addObject:metricClass];
}

@end
