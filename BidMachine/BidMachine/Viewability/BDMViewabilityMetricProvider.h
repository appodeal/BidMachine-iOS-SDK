//
//  BDMViewabilityMetricProvider.h
//  BidMachine
//
//  Created by Stas Kochkin on 19/10/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class BDMViewabilityMetricProvider;
@class BDMViewabilityMetricConfiguration;

typedef NS_ENUM (NSInteger, BDMMetricPolicy) {
    BDMMetricPolicyAll = 0,
    BDMMetricPolicyAny
};

@protocol BDMViewabilityMetric <NSObject>

+ (instancetype)metricWithConfiguration:(BDMViewabilityMetricConfiguration *)configuration;
- (void)startViewabilityMonitoringForView:(UIView *)view
                                startView:(dispatch_block_t)startView
                               finishView:(dispatch_block_t)finishView;

- (void)finishViewabilityMonitoringForView:(UIView *)view;

@end

@protocol BDMViewabilityMetricProviderDelegate <NSObject>

- (void)viewabilityMetricProvider:(BDMViewabilityMetricProvider *)provider detectStartView:(UIView *)view;
- (void)viewabilityMetricProvider:(BDMViewabilityMetricProvider *)provider detectImpression:(UIView *)view;
- (void)viewabilityMetricProvider:(BDMViewabilityMetricProvider *)provider detectFinishView:(UIView *)view;

@end

@interface BDMViewabilityMetricConfiguration : NSObject <NSCopying>

@property (nonatomic, assign, readwrite) NSTimeInterval impressionInterval;
@property (nonatomic, copy, readwrite) NSArray <UIView *> * visibleSubviews;
@property (nonatomic, assign, readwrite) CGFloat visiblePercent;
@property (nonatomic, assign, readwrite) BOOL overlayDetection;

@end

@interface BDMViewabilityMetricProvider : NSObject

@property (nonatomic, weak, readwrite) id<BDMViewabilityMetricProviderDelegate> delegate;

- (void)startViewabilityMonitoringForView:(UIView *)view
                            configuration:(BDMViewabilityMetricConfiguration *)configuration
                                 delegate:(id <BDMViewabilityMetricProviderDelegate>)delegate;

- (void)finishViewabilityMonitoringForView:(UIView *)view;

@end

@interface BDMViewabilityMetricProvider (Private)

+ (void)registerMetric:(Class<BDMViewabilityMetric>)metricClass;

@end
