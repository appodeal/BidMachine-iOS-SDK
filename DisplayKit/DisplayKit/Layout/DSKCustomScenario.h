//
//  DSKCustomScenario.h
//  OpenBids
//
//  Created by Lozhkin Ilya on 6/5/17.
//  Copyright © 2017 OpenBids, Inc. All rights reserved.
//

#import "DSKCustomControlLayer.h"


static inline NSDictionary * mraidInterstitialScenario(){
    return @{@(CCEventApplyScenario)        : @{@(CCTypeTimerClose)      : @[@(CCActionAdd)]},
             
             @(CCEventStartScenario)        : @{@(CCTypeTimerClose)      : @[@(CCActionStartTimer)]},
             
             @(CCEventUseCustomCloseTrue)   : @{@(CCTypeTimerClose)      : @[@(CCActionHide)]},
             
             @(CCEventUseCustomCloseFalse)  : @{@(CCTypeTimerClose)      : @[@(CCActionShow)]}
             };
}

static inline NSDictionary * mraidRewardedInterstitialScenario(){
    return @{@(CCEventApplyScenario)        : @{@(CCTypeTimerClose) : @[@(CCActionAdd)]},
             
             @(CCEventStartScenario)        : @{@(CCTypeTimerClose) : @[@(CCActionStartTimer)]},
             
             @(CCEventUseCustomCloseTrue)   : @{@(CCTypeTimerClose) : @[@(CCActionHide)]},
             
             @(CCEventUseCustomCloseFalse)  : @{@(CCTypeTimerClose) : @[@(CCActionShow)]}             
             };
}

static inline NSDictionary * vastPlayerScenario(){
    return @{@(CCEventStartScenario)        : @{@(CCTypeUnMute)     : @[@(CCActionAdd)],
                                                @(CCTypeMore)       : @[@(CCActionAdd)]},
             
             @(CCEventExternalEmptyRV)      : @{@(CCTypeClose)      : @[@(CCActionAdd)]},
             
             @(CCEventExternalEmptySV)      : @{@(CCTypeTimerClose) : @[@(CCActionAdd),
                                                                        @(CCActionStartTimer)]},
             
             @(CCEventExternalEmptyRepeat)  : @{@(CCTypeClose)      : @[@(CCActionAdd)]},
             
             @(CCEventExternalEmptyMut)     : @{@(CCTypeUnMute)     : @[@(CCActionSwitchValue)]},
             
             @(CCEventExternalEmptyMore)    : @{@(CCTypeMore)       : @[@(CCActionRemove)]},
             
             @(CCEventExternalEmptyCompletly):@{@(CCTypeUnMute)     : @[@(CCActionRemove)],
                                                @(CCTypeTimerClose) : @[@(CCActionRemove)]},
             
//             @(CCEventExternalEmptyCompletly):@{@(CCTypeRepeat)     : @[@(CCActionAdd)],
//                                                @(CCTypeUnMute)     : @[@(CCActionRemove)],
//                                                @(CCTypeTimerClose) : @[@(CCActionRemove)]},
             
             @(CCEventEndCloseTime)         : @{@(CCTypeTimerClose) : @[@(CCActionRemove)],
                                                @(CCTypeClose)      : @[@(CCActionAdd)]}
             
             };
}

static inline NSDictionary * vastPlayerRepeatScenario(){
    return @{@(CCEventStartScenario)        : @{@(CCTypeUnMute)     : @[@(CCActionAdd)],
                                                @(CCTypeMore)       : @[@(CCActionAdd)],
                                                @(CCTypeClose)      : @[@(CCActionAdd)]},
             
             @(CCEventExternalEmptyMut)     : @{@(CCTypeUnMute)     : @[@(CCActionSwitchValue)]},
             
             @(CCEventExternalEmptyMore)    : @{@(CCTypeMore)       : @[@(CCActionRemove)]},
             
             @(CCEventExternalEmptyCompletly):@{@(CCTypeRepeat)     : @[@(CCActionAdd)],
                                                @(CCTypeUnMute)     : @[@(CCActionRemove)],
                                                @(CCTypeTimerClose) : @[@(CCActionRemove)]}
             
             };
}

static inline NSDictionary * vastPostbannerScenario(){
    return @{@(CCEventApplyScenario)        : @{@(CCTypeTimerClose) : @[@(CCActionAdd)]},
             
             @(CCEventStartScenario)        : @{@(CCTypeTimerClose) : @[@(CCActionStartTimer)]},
             
//             @(CCEventStartScenario)        : @{@(CCTypeRepeat)     : @[@(CCActionAdd)],
//                                                @(CCTypeTimerClose) : @[@(CCActionStartTimer)]},
             
             @(CCEventUseCustomCloseTrue)   : @{@(CCTypeTimerClose) : @[@(CCActionHide)],
                                                @(CCTypeClose)      : @[@(CCActionHide)]},
             
             @(CCEventUseCustomCloseFalse)  : @{@(CCTypeTimerClose) : @[@(CCActionShow)],
                                                @(CCTypeClose)      : @[@(CCActionShow)]}
             
//             @(CCEventEndCloseTime)         : @{@(CCTypeTimerClose) : @[@(CCActionRemove)],
//                                                @(CCTypeClose)      : @[@(CCActionAdd)]}
             
             };
}


static inline NSDictionary * vastPostbannerScreenScenario(){
    return @{@(CCEventStartScenario)        : @{@(CCTypeRepeat)     : @[@(CCActionAdd)],
                                                @(CCTypeClose)      : @[@(CCActionAdd)],
                                                @(CCTypeMore)       : @[@(CCActionAdd)]},
             
             @(CCEventExternalEmptyMore)    : @{@(CCTypeMore)       : @[@(CCActionRemove)]}
             
             };
}
