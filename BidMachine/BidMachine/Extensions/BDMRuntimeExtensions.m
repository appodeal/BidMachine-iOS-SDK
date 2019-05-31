//
//  BDMRuntimeExtensions.m
//  BidMachine
//
//  Created by Stas Kochkin on 28/08/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import "BDMRuntimeExtensions.h"
#import <objc/runtime.h>
#import <pthread/pthread.h>

// https://github.com/jspahrsummers/libextobjc/tree/master/extobjc

#pragma mark - Declarations

typedef struct {
    __unsafe_unretained Protocol * protocol;
    void * injectionAction;
    BOOL ready;
} BDMInjection;

#pragma mark - Static variables

static BDMInjection * restrict BDMInjectionsList = 0;
static size_t BDMInjectionCount = 0;
static size_t BDMInjectionCapacity = 0;
static size_t BDMReadyInjectionsCount = 0;
static pthread_mutex_t BDMInjectionMutexLock = PTHREAD_MUTEX_INITIALIZER;

#pragma mark - Private

BOOL adx_resizeInjectionList(void) {
    // Check that we need to resize list of injections
    if (BDMInjectionCount >= BDMInjectionCapacity) {
        size_t newCapacity;
        // For first injection just setup 1
        if (BDMInjectionCapacity == 0) {
            newCapacity = 1;
        } else {
            // For next injections double old capacity
            newCapacity = BDMInjectionCapacity >> 1;
            // Avoid unsinged integer overfloating
            if (newCapacity <= BDMInjectionCapacity)  {
                newCapacity = SIZE_MAX;
                if (newCapacity <= BDMInjectionCapacity)  {
                    return NO;
                }
            }
        }
        
        void * restrict list = realloc(BDMInjectionsList, sizeof(* BDMInjectionsList) * newCapacity);
        if (!list) {
            return NO;
        }
        
        BDMInjectionsList = list;
        BDMInjectionCapacity = newCapacity;
    }
    
    return YES;
}

void adx_setupInjectionsList(Protocol * protocol, void(^injectionAction)(Class destinationCls)) {
    @autoreleasepool {
        // Check variables and lock state
        if (!protocol ||
            !injectionAction ||
            pthread_mutex_lock(&BDMInjectionMutexLock) != 0) {
            return;
        }
        // check current injections count
        if (BDMInjectionCount == SIZE_MAX) {
            pthread_mutex_unlock(&BDMInjectionMutexLock);
            return;
        }
        // Resize list size and capacity
        if (!adx_resizeInjectionList()) {
            pthread_mutex_unlock(&BDMInjectionMutexLock);
            return;
        }
        // Add new injection
        void(^injectionActionCopy)(Class cls) = [injectionAction copy];
        BDMInjectionsList[BDMInjectionCount] = (BDMInjection) {
            .protocol = protocol,
            .injectionAction = (__bridge_retained void *)(injectionActionCopy),
            .ready = NO
        };
        // Increment cursor
        BDMInjectionCount += 1;
        pthread_mutex_unlock(&BDMInjectionMutexLock);
    }
}

void adx_evaluateInjection(Protocol * protocol, Class containerCls, Class destinationClass) {
    // Inject only instance method
    unsigned methodCount = 0;
    Method * methodList = class_copyMethodList(containerCls, &methodCount);
    for (unsigned idx = 0; idx < methodCount; idx += 1) {
        Method method = methodList[idx];
        SEL selector = method_getName(method);
        // Check that class not has this selector already
        if (class_getInstanceMethod(destinationClass, selector)) {
            continue;
        }
        IMP imp = method_getImplementation(method);
        const char *types = method_getTypeEncoding(method);
        class_addMethod(destinationClass,
                        selector,
                        imp,
                        types);
    }
}

void adx_evaluateInjectionsList(void) {
    qsort_b(BDMInjectionsList,
            BDMInjectionCount,
            sizeof(BDMInjection),
            ^int(const void *a, const void *b) {
                if (a == b) {
                    return 0;
                }
                
                const BDMInjection * injectionA = a;
                const BDMInjection * injectionB = b;
                
                int (^comprassionBlock)(const BDMInjection *) = ^(const BDMInjection * injection) {
                    int total = 0;
                    for (size_t idx = 0; idx < BDMReadyInjectionsCount; idx += 1) {
                        if (injection == BDMInjectionsList + idx) {
                            continue;
                        }
                        
                        if (protocol_conformsToProtocol(injection->protocol, BDMInjectionsList[idx].protocol)) {
                            total ++;
                        }
                    }
                    return total;
                };
                
                return comprassionBlock(injectionB) - comprassionBlock(injectionA);
            });
    
    unsigned clsCount = objc_getClassList(NULL, 0);
    if (!clsCount) {
        return;
    }
    
    Class * allClasses = (Class *)malloc(sizeof(Class) * (clsCount + 1));
    if (!allClasses) {
        return;
    }
    
    clsCount = objc_getClassList(allClasses, clsCount);
    
    @autoreleasepool {
        for (size_t idx = 0; idx < BDMInjectionCount; idx += 1) {
            Protocol * protocol = BDMInjectionsList[idx].protocol;
            void(^injectionAction)(Class) = (__bridge_transfer  id)(BDMInjectionsList[idx].injectionAction);
            BDMInjectionsList[idx].injectionAction = NULL;
            
            for (unsigned clsIdx = 0; clsIdx < clsCount; clsIdx += 1) {
                Class class = allClasses[clsIdx];
                if (!class_conformsToProtocol(class, protocol)) {
                    continue;
                }
                
                injectionAction(class);
            }
        }
    }
    
    free(allClasses);
    free(BDMInjectionsList);
    BDMInjectionsList = NULL;
    BDMInjectionCapacity = 0;
    BDMInjectionCount = 0;
    BDMReadyInjectionsCount = 0;
}

#pragma mark - Public

void adx_addConcreteProtocol(Protocol * protocol, Class containerCls) {
    adx_setupInjectionsList(protocol, ^(__unsafe_unretained Class destinationCls) {
        adx_evaluateInjection(protocol, containerCls, destinationCls);
    });
}

void adx_loadConcreteProtocol(Protocol * protocol) {
    @autoreleasepool {
        if (pthread_mutex_lock(&BDMInjectionMutexLock)) {
            return;
        }
        // Enumerate list
        for (size_t idx = 0; idx < BDMInjectionCount; idx += 1) {
            if (BDMInjectionsList[idx].protocol == protocol) {
                if (!BDMInjectionsList[idx].ready) {
                    BDMInjectionsList[idx].ready = YES;
                    BDMReadyInjectionsCount += 1;
                    if (BDMReadyInjectionsCount == BDMInjectionCount) {
                        adx_evaluateInjectionsList();
                    }
                }
                break;
            }
        }
        pthread_mutex_unlock(&BDMInjectionMutexLock);
    }
}
