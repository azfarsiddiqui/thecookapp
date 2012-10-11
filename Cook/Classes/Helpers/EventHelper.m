//
//  EventHelper.m
//  Cook
//
//  Created by Jeff Tan-Ang on 11/10/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "EventHelper.h"

@implementation EventHelper

#define kEventBenchtopFreeze    @"CKEventBenchtopFreeze"
#define kBoolBenchtopFreeze     @"CKBoolBenchtopFreeze"

+ (void)registerBenchtopFreeze:(id)observer selector:(SEL)selector {
    [EventHelper registerObserver:observer withSelector:selector toEventName:kEventBenchtopFreeze];
}

+ (void)postBenchtopFreeze:(BOOL)freeze {
    [EventHelper postEvent:kEventBenchtopFreeze
              withUserInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:freeze]
                                                       forKey:kBoolBenchtopFreeze]];
}

+ (void)unregisterBenchtopFreeze:(id)observer {
    [EventHelper unregisterObserver:observer toEventName:kEventBenchtopFreeze];
}

+ (BOOL)benchFreezeForNotification:(NSNotification *)notification {
    return [[[notification userInfo] valueForKey:kBoolBenchtopFreeze] boolValue];
}

#pragma mark - Private

+ (void)registerObserver:(id)observer withSelector:(SEL)selector toEventName:(NSString *)eventName {
    [[NSNotificationCenter defaultCenter] addObserver:observer
                                             selector:selector
                                                 name:eventName object:nil];
}

+ (void)postEvent:(NSString *)eventName {
    [EventHelper postEvent:eventName withUserInfo:nil];
}

+ (void)postEvent:(NSString *)eventName withUserInfo:(NSDictionary *)theUserInfo {
    [[NSNotificationCenter defaultCenter] postNotificationName:eventName object:nil userInfo:theUserInfo];
}

+ (void)unregisterObserver:(id)observer toEventName:(NSString *)eventName {
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:eventName object:nil];
}

@end
