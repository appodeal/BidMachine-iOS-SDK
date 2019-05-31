//
//  DSKCustomControlLayer.h
//  OpenBids
//

//  Copyright © 2017 OpenBids, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DSKVASTExtension.h"

//CC - CustomControl oO
typedef NS_ENUM(NSUInteger, CCType){
    CCTypeNoContent = 50,
    CCTypeClose,
    CCTypeRepeat,
    CCTypeTimerClose,
    CCTypeMore,
    CCTypeMute,
    CCTypeUnMute
};

typedef NS_ENUM(NSUInteger, CCAction){
    CCActionShow = 0,
    CCActionHide,
    CCActionAdd,
    CCActionRemove,
    CCActionStartTimer,
    CCActionSwitchValue,
    CCActionFillType
};

//TODO: Mb use string?
typedef NS_ENUM(NSUInteger, CCEvent){
    CCEventApplyScenario = 0, // automatic start when initialize class
    CCEventStartScenario, // start curent scenario // start show - hide automatic control
    CCEventEndCloseTime, // automatic start after close time. if close time > 0
    CCEventUseCustomCloseTrue,
    CCEventUseCustomCloseFalse,
    
    CCEventExternalEmpty, // empty event, use in any time // can and more count noname event and use it
    CCEventExternalEmptyRV, //
    CCEventExternalEmptySV,
    CCEventExternalEmptyMut,
    CCEventExternalEmptyMore,
    CCEventExternalEmptyRepeat,
    CCEventExternalEmptyCompletly,
};




@protocol DSKCustomControlLayerDelegate <NSObject>

@optional;

- (void)DSK_clickOnButtonType:(CCType)type;

- (void)DSK_hidden:(BOOL)hidden alpha:(CGFloat)alpha;

@end

@protocol DSKCustomControlLayerDataSource <NSObject>

@optional;

- (NSNumber *)DSK_closeTime;

- (NSString *)DSK_learnMore;

- (UIColor *)DSK_fillColor;

- (UIColor *)DSK_strokeColor;

- (BOOL)DSK_isEstimatedInterfaceOritentationInLandscape;

- (BOOL)DSK_isAutoHideControlls;

- (BOOL)DSK_isAllowControlls;

@end

@interface DSKCustomControlLayer : UIView

@property (nonatomic, weak) id <DSKCustomControlLayerDelegate> delegate;
@property (nonatomic, weak) id <DSKCustomControlLayerDataSource> dataSource;

@property (nonatomic, strong) id<DSKControllExtension> extention;

- (instancetype)initWithScenario:(NSDictionary *)scenario
                       extention:(id<DSKControllExtension>)extention
                        delegate:(id<DSKCustomControlLayerDelegate>)delegate
                      dataSource:(id<DSKCustomControlLayerDataSource>)dataSource;

- (instancetype)initWithScenario:(NSDictionary *)scenario
                        delegate:(id<DSKCustomControlLayerDelegate>)delegate
                      dataSource:(id<DSKCustomControlLayerDataSource>)dataSource;

- (instancetype)initWithScenario:(NSDictionary *)scenario;

- (instancetype)initWithScenario:(NSDictionary *)scenario
                       extention:(id<DSKControllExtension>)extention;

- (void)addOnView:(UIView *)view;

- (void)setNewScenario:(NSDictionary *)scenario;

- (void)processEvent:(CCEvent)event;



@end
