//
//  DSKVASTTrackingModel.h
//  OpenBids
//

//  Copyright © 2016 OpenBids, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DSKVASTTrackingModel : NSObject

@property (nonatomic, strong, readonly) NSArray * impressions;
@property (nonatomic, strong, readonly) NSArray * startURL;
@property (nonatomic, strong, readonly) NSArray * creativeView;
@property (nonatomic, strong, readonly) NSArray * clickTrackingUrl;
@property (nonatomic, strong, readonly) NSArray * firstQurtileURL;
@property (nonatomic, strong, readonly) NSArray * midpointURL;
@property (nonatomic, strong, readonly) NSArray * thirdQurtileURL;
@property (nonatomic, strong, readonly) NSArray * finishURL;
@property (nonatomic, strong, readonly) NSArray * closeURL;
@property (nonatomic, strong, readonly) NSArray * fullScreenURL;
@property (nonatomic, strong, readonly) NSArray * resumeURL;
@property (nonatomic, strong, readonly) NSArray * pauseURL;
@property (nonatomic, strong, readonly) NSArray * muteURL;
@property (nonatomic, strong, readonly) NSArray * unmuteURL;

- (void)fillWithTrackingEvents:(NSDictionary *)trackingEvents;
- (void)fillWithImpressions:(NSArray *)impressions;
- (void)fillWithClickTrackings:(NSArray *)clickTrackings;

@end
