//
//  DSKCustomControlLayer.m
//  OpenBids
//

//  Copyright © 2017 OpenBids, Inc. All rights reserved.
//

#import "DSKCustomControlLayer.h"
#import "DSKGraphicButton.h"
#import "DSKCircleTimerButton.h"
#import "DSKConstraintMaker+Private.h"
#import "UIView+DSKConstraint.h"

#import <NexageSourceKitMRAID/UIView+SKExtension.h>
#import <ASKExtension/ASKTimer.h>
#import <ASKExtension/UIColor+ASKExtension.h>

@interface DSKCustomControlLayer()

@property (nonatomic, strong) NSDictionary * scenario;
@property (nonatomic, strong) NSDictionary * cachedScenario;

@property (nonatomic, weak) UIView * parentView;
@property (nonatomic, assign) BOOL isInvisabillity;

@property (nonatomic, strong) NSPointerArray * scenarioHiddenControl;

@property (nonatomic, strong) ASKTimer * closeTimer;
@property (nonatomic, strong) ASKTimer * hidenTimer;

@end

@implementation DSKCustomControlLayer

#pragma mark - App life cicle

- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appGoToBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appGoToForeground) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)appGoToBackground {
    
}

- (void)appGoToForeground {
    [self showControllsIfNeeded];
}

- (void)orientationChanged{
    if (self.interfaceOrientation == DSKInterfaceOrientationUnknown) {
        for (UIView * subview in self.subviews) {
            [subview DSK_updateConstraintsIfNeeded];
        }
    }
}

- (void)dealloc{
    [self removeObservers];
}

#pragma mark - Life cicle

- (instancetype)initWithScenario:(NSDictionary *)scenario {
    return [self initWithScenario:scenario delegate:nil dataSource:nil];
}

- (instancetype)initWithScenario:(NSDictionary *)scenario extention:(id<DSKControllExtension>)extention{
    return [self initWithScenario:scenario extention:extention delegate:nil dataSource:nil];
}

- (instancetype)initWithScenario:(NSDictionary *)scenario
                        delegate:(id<DSKCustomControlLayerDelegate>)delegate
                      dataSource:(id<DSKCustomControlLayerDataSource>)dataSource
{
    return [self initWithScenario:scenario extention:nil delegate:delegate dataSource:dataSource];
}

- (instancetype)initWithScenario:(NSDictionary *)scenario
                       extention:(id<DSKControllExtension>)extention
                        delegate:(id<DSKCustomControlLayerDelegate>)delegate
                      dataSource:(id<DSKCustomControlLayerDataSource>)dataSource
{
    self = [super init];
    if (self) {
        [self addObservers];
        
        self.scenario = scenario;
        self.delegate = delegate;
        self.dataSource = dataSource;
        self.extention = extention;
        
        self.scenarioHiddenControl = [NSPointerArray weakObjectsPointerArray];
        
        [self processEvent:CCEventApplyScenario];
    }
    return self;
}

- (void)addOnView:(UIView *)view{
    BOOL isSuperview = [self.superview isEqual:view];
    
    if (!isSuperview && self.superview) {
        self.parentView = self.superview;
    } else if (!isSuperview && view){
        [view addSubview:self];
        self.parentView = view;
    } else if (!isSuperview){
        return;
    } else {
        self.parentView = self.superview;
    }

    [self sk_makeEdgesEqualToView:self.parentView];    
}


- (void)setOffsetFromParrentView:(UIView *)parentView{
    
}

- (void)setNewScenario:(NSDictionary *)scenario{
    self.cachedScenario = scenario;
}

- (void)clearCurentScenario{
    if (self.cachedScenario) {
        self.scenario = self.cachedScenario;
        self.cachedScenario = nil;
    }
    
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

- (void)willRemoveSubview:(UIView *)subview{
    [super willRemoveSubview:subview];
}

- (void)addControl:(DSKGraphicButton *)control inScenarioHidden:(BOOL)hidden{
    if (!control) {
        return;
    }
    
    [self removePointerObjectIfNeeded:control];
    if (hidden) {
        [self.scenarioHiddenControl addPointer:(__bridge void *)control];
    }
}

- (void)removePointerObjectIfNeeded:(DSKGraphicButton *)object{
    NSInteger index = [[self.scenarioHiddenControl allObjects] indexOfObject:object];
    if (index < [self.scenarioHiddenControl count]) {
        [self.scenarioHiddenControl removePointerAtIndex:index];
    }
}

#pragma mark - Overide view tap

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    UIView * hitView = [super hitTest:point withEvent:event];
    
    if ([hitView isKindOfClass:self.class]) {
        [self fakeTouchOnView];
        return nil;
    }
    return hitView;
    
}

- (void)fakeTouchOnView{
    [self showControllsIfNeeded];
}

#pragma mark - Event

- (void)processEvent:(CCEvent)event{
    if (event == CCEventApplyScenario) {
        [self clearCurentScenario];
    }
    
    if (event == CCEventStartScenario) {
        self.isInvisabillity = NO;
        [self hideControlIfNeeded];
    }
    
    NSDictionary * scenario = self.scenario[@(event)];
    if ([scenario isKindOfClass:NSDictionary.class]) {
        [scenario enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [self processType:[key integerValue] withActions:obj];
        }];
    }
}

- (void)processType:(CCType)type withActions:(NSArray *)actions{
    [actions enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        switch ([obj integerValue]) {
            case CCActionAdd:           [self addType:type]; break;
            case CCActionRemove:        [self removeType:type]; break;
            case CCActionShow:          [self showType:type]; break;
            case CCActionHide:          [self hideType:type]; break;
            case CCActionStartTimer:    [self startTimerType:type]; break;
            case CCActionSwitchValue:   [self switchValueType:type]; break;
            case CCActionFillType:      [self fillColorType:type]; break;
            default: break;
        }
    }];
}

#pragma mark - Action

- (void)addType:(CCType)type{
    DSKGraphicButton * control = [self viewWithTag:type];
    if ([self extentionIsAllowControll:type] && !control) {
        [self createControlWithType:type];
    }
}

- (void)removeType:(CCType)type{
    DSKGraphicButton * control = [self viewWithTag:type];
    if (control) {
        [control removeFromSuperview];
    }
}

- (void)showType:(CCType)type{
    DSKGraphicButton * control = [self viewWithTag:type];
    control.hidden = self.isInvisabillity;
    
    [self addControl:control inScenarioHidden:NO];
}

- (void)hideType:(CCType)type{
    DSKGraphicButton * control = [self viewWithTag:type];
    control.hidden = YES;
    
    [self addControl:control inScenarioHidden:YES];
}

- (void)startTimerType:(CCType)type{
    
    if (self.closeTimer) {
        //timer allready started
        return;
    }
    
    DSKCircleTimerButton * control = [self viewWithTag:type];
    if ([control isKindOfClass:DSKCircleTimerButton.class]) {
        [control startWithSkippInterval:[self.closeTime integerValue]];
    }
    
    if (self.closeTime && [self.closeTime integerValue] > 0) {
        __weak typeof(self) weakSelf = self;
        self.closeTimer = [ASKTimer timerWithInterval:[self.closeTime integerValue] periodic:NO block:^{
            __strong typeof(self) strongSelf = weakSelf;
            [strongSelf endCloseTime];
        }];
    } else if (self.closeTime) {
        [self endCloseTime];
    }
}

- (void)endCloseTime{
    [self processEvent:CCEventEndCloseTime];
    [self.closeTimer cancel];
}

- (void)switchValueType:(CCType)type{
    DSKGraphicButton * control = [self viewWithTag:type];
    if (control && (type == CCTypeMute || type == CCTypeUnMute)) {
        DSKGraphicsButtonType graphicsType = control.type == DSKGraphicsButtonMuteOn ? DSKGraphicsButtonMuteOff : DSKGraphicsButtonMuteOn;
        
        [control setFillColor:self.extentionFillColor];
        [control setStrokeColor:self.extentionStrokeColor];
        
        [control drawButtonWithType:graphicsType];
    }
}

- (void)fillColorType:(CCType)type{
    DSKGraphicButton * control = [self viewWithTag:type];
    if (control) {
        [self drawControl:control];
    }
}

#pragma mark - Create control

- (void)createControlWithType:(CCType)type{
    id control = [DSKGraphicButton new];
    
    __weak typeof(self) weakSelf = self;
    switch (type) {
        case CCTypeTimerClose:
        {
            control = [DSKCircleTimerButton new];
            [control apdGraphicsMakeConstraintsOnView:self withBlock:^(DSKConstraintMaker *maker) {
                __strong typeof(self) strongSelf = weakSelf;
                [maker copyPozition:strongSelf.extention.closePosition ? : [DSKConstraintMaker constraintMakerFromString:@"right" yPozition:@"top"]];
                maker.interfaceOrientation = strongSelf.interfaceOrientation;
            }];
        } break;
        case CCTypeClose:
        {
            [control apdGraphicsMakeConstraintsOnView:self withBlock:^(DSKConstraintMaker *maker) {
                __strong typeof(self) strongSelf = weakSelf;
                [maker copyPozition:strongSelf.extention.closePosition ? : [DSKConstraintMaker constraintMakerFromString:@"right" yPozition:@"top"]];
                maker.interfaceOrientation = strongSelf.interfaceOrientation;
            }];
        } break;
        case CCTypeRepeat:
        {
            [control apdGraphicsMakeConstraintsOnView:self withBlock:^(DSKConstraintMaker *maker) {
                __strong typeof(self) strongSelf = weakSelf;
                [maker copyPozition:[DSKConstraintMaker constraintMakerFromString:@"left" yPozition:@"bottom"]];
                maker.interfaceOrientation = strongSelf.interfaceOrientation;
            }];
        } break;
        case CCTypeMute:
        {
            [control apdGraphicsMakeConstraintsOnView:self withBlock:^(DSKConstraintMaker *maker) {
                __strong typeof(self) strongSelf = weakSelf;
                [maker copyPozition:strongSelf.extention.mutePosition ? : [DSKConstraintMaker constraintMakerFromString:@"left" yPozition:@"top"]];
                maker.interfaceOrientation = strongSelf.interfaceOrientation;
            }];
        } break;
        case CCTypeUnMute:
        {
            [control apdGraphicsMakeConstraintsOnView:self withBlock:^(DSKConstraintMaker *maker) {
                __strong typeof(self) strongSelf = weakSelf;
                [maker copyPozition:strongSelf.extention.mutePosition ? : [DSKConstraintMaker constraintMakerFromString:@"left" yPozition:@"top"]];
                maker.interfaceOrientation = strongSelf.interfaceOrientation;
            }];
        } break;
        case CCTypeMore:
        {
            [control apdGraphicsMakeConstraintsOnView:self withBlock:^(DSKConstraintMaker *maker) {
                __strong typeof(self) strongSelf = weakSelf;
                [maker copyPozition:strongSelf.extention.ctaPosition ? : [DSKConstraintMaker constraintMakerFromString:@"right" yPozition:@"bottom"]];
                maker.interfaceOrientation = strongSelf.interfaceOrientation;
            }];
        } break;
        default:
            break;
    }
    [(DSKGraphicButton *)control addTarget:self action:@selector(buttonPressed:)];
    [(DSKGraphicButton *)control setTag:type];
    
    [(DSKGraphicButton *)control setHidden:self.isInvisabillity];
    
    [self drawControl:(DSKGraphicButton *)control];
}

- (void)drawControl:(DSKGraphicButton *)control{ // re-draw // start-draw
    [control setStrokeColor:self.extentionStrokeColor];
    [control setFillColor:self.extentionFillColor];
    
    DSKGraphicsButtonType drawType = control.tag - 50;
    
    if (drawType == DSKGraphicsButtonText) {
        [control drawText:self.extentionLearnMoreText];
    } else {
        [control drawButtonWithType:drawType];
    }
}

#pragma mark - Button action

- (IBAction)buttonPressed:(id)sender{
    if ([sender isKindOfClass:UIGestureRecognizer.class]) {
        [self sendDelegateMessageWithType:[[(UIGestureRecognizer *)sender view] tag]];
    }
}

- (void)sendDelegateMessageWithType:(CCType)type{
    if ([self.delegate respondsToSelector:@selector(DSK_clickOnButtonType:)]){
        [self.delegate DSK_clickOnButtonType:type];
    }
}

#pragma mark - Extention 

- (BOOL)extentionIsAllowControll:(CCType)type{
    if (!self.extention) {
        return self.isAllowControlls;
    }
    
    BOOL enabledType = YES;
    switch (type) {
        case CCTypeMore: enabledType = self.extention.ctaEnabled; break;
        case CCTypeMute: enabledType = self.extention.muteEnabled; break;
        case CCTypeUnMute: enabledType = self.extention.muteEnabled; break;
            
        default: break;
    }
    return enabledType;
}

- (NSString *)extentionLearnMoreText{
    NSString * learnMoreText = self.learnMoreText;
    if (self.extention.callToActionText) {
        learnMoreText = self.extention.callToActionText;
    }
    return learnMoreText;
}

- (UIColor *)extentionFillColor{
    UIColor * fillColor = self.fillColor;
    if (self.extention.assetFillColor) {
        fillColor = self.extention.assetFillColor;
    }
    return fillColor;
}

- (UIColor *)extentionStrokeColor{
    UIColor * strokeColor = self.strokeColor;
    if (self.extention.assetStrokeColor) {
        strokeColor = self.extention.assetStrokeColor;
    }
    return strokeColor;
}

#pragma mark - Private

- (NSNumber *)closeTime{
    NSNumber * closeT = nil;
    if ([self.dataSource respondsToSelector:@selector(DSK_closeTime)]) {
        closeT = [self.dataSource DSK_closeTime];
    }
    return closeT;
}

- (NSString *)learnMoreText{
    NSString * learnMore = NSLocalizedString(@"Learn more", nil);
    if ([self.dataSource respondsToSelector:@selector(DSK_learnMore)]) {
        learnMore = [self.dataSource DSK_learnMore] ?: learnMore;
    }
    return learnMore;
}

- (UIColor *)fillColor{
    UIColor * fillColor = [UIColor ask_defaultFillColor];
    if ([self.dataSource respondsToSelector:@selector(DSK_fillColor)]) {
        fillColor = [self.dataSource DSK_fillColor] ? : fillColor;
    }
    return fillColor;
}

- (UIColor *)strokeColor{
    UIColor * strokeColor = [UIColor whiteColor];
    if ([self.dataSource respondsToSelector:@selector(DSK_strokeColor)]) {
        strokeColor = [self.dataSource DSK_strokeColor] ? : strokeColor;
    }
    return strokeColor;
}

- (DSKInterfaceOrientation)interfaceOrientation{
    DSKInterfaceOrientation interfaceOrientation = DSKInterfaceOrientationUnknown;
    if ([self.dataSource respondsToSelector:@selector(DSK_isEstimatedInterfaceOritentationInLandscape)]) {
        interfaceOrientation = [self.dataSource DSK_isEstimatedInterfaceOritentationInLandscape] ? DSKInterfaceOrientationLandscape : DSKInterfaceOrientationPortrait;
    }
    return interfaceOrientation;
}

- (BOOL)isAutoHideControlls{
    BOOL autoHide = NO;
    if ([self.dataSource respondsToSelector:@selector(DSK_isAutoHideControlls)]) {
        autoHide = [self.dataSource DSK_isAutoHideControlls];
    }
    return autoHide;
}

- (BOOL)isAllowControlls{
    BOOL allow = YES;
    if ([self.dataSource respondsToSelector:@selector(DSK_isAllowControlls)]) {
        allow = [self.dataSource DSK_isAllowControlls];
    }
    return allow;
}

#pragma mark - Controls hidden

- (void)hideControlIfNeeded{
    if (!self.isAutoHideControlls) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    self.hidenTimer = [ASKTimer timerWithInterval:3.0f periodic:NO block:^{
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf.hidenTimer cancel];
        [strongSelf setControlsHidden:YES];
    }];
}

- (void)showControllsIfNeeded {
    if (!self.isAutoHideControlls) {
        return;
    }
    
    [self setControlsHidden:NO];
    [self hideControlIfNeeded];
}

- (void)setControlsHidden:(BOOL)hidden{
    self.isInvisabillity = hidden;
    NSArray * supportedControls = [self.subviews filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return ![[self.scenarioHiddenControl allObjects] containsObject:evaluatedObject];
    }]];
    
    [supportedControls enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self animateView:(UIView *)obj hidden:hidden];
    }];
}

- (void)animateView:(UIView *)view hidden:(BOOL)hidden {
    @synchronized (view) {
        __weak typeof(self) weakSelf = self;
        [UIView transitionWithView:view
                          duration:hidden ? 0.8 : 0.2
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            @synchronized (view) {
                                if ([weakSelf.delegate respondsToSelector:@selector(DSK_hidden:alpha:)]) {
                                    [weakSelf.delegate DSK_hidden:hidden alpha:!hidden];
                                }
                                view.alpha = !hidden;
                            }
                        }
                        completion:^(BOOL finished) {
                            view.hidden = hidden;
                        }];
    }
}

@end
