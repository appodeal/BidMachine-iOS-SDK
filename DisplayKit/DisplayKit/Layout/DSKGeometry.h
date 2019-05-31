//
//  DSKGeometry.h
//  OpenBids
//
//  Created by Lozhkin Ilya on 8/5/17.
//  Copyright © 2017 OpenBids, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

struct DSKRect {
    CGPoint origin;
    CGSize size;
    BOOL cX;
    BOOL cY;
};

typedef struct DSKRect DSKRect;

CG_EXTERN const DSKRect DSKRectZero;

CG_INLINE DSKRect frame (CGFloat width, CGFloat height, CGFloat x, CGFloat y, BOOL mX, BOOL mY){
    return (DSKRect){.size = {.width = width, .height = height}, .origin = {.x = x, .y = y}, .cX = mX, .cY = mY};
}

CG_INLINE bool DSKRectEqualToRect(DSKRect rect1, DSKRect rect2) {
    return CGSizeEqualToSize(rect1.size, rect2.size) && CGPointEqualToPoint(rect1.origin, rect2.origin) && rect1.cX == rect2.cX && rect1.cY == rect2.cY;
}


UIInterfaceOrientation DSKCurrentInterfaceOrientation(void);
UIEdgeInsets DSKSafeArea(void);
bool DSKStatusBarUnhidden(void);
bool DSKSystemVersionIsiOS11(void);
bool DSKCurrentDeviceIsiPhoneX(void);
bool DSKIsSafeAreaLayoutGuideUntrasted(void);

