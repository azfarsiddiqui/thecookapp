//
//  EventHelper.h
//  Cook
//
//  Created by Jeff Tan-Ang on 11/10/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EventHelper : NSObject

+ (void)registerLoginSucessful:(id)observer selector:(SEL)selector;
+ (void)postLoginSuccessful:(BOOL)success;
+ (void)unregisterLoginSucessful:(id)observer;
+ (BOOL)loginSuccessfulForNotification:(NSNotification *)notification;

+ (void)registerBenchtopFreeze:(id)observer selector:(SEL)selector;
+ (void)postBenchtopFreeze:(BOOL)freeze;
+ (void)unregisterBenchtopFreeze:(id)observer;
+ (BOOL)benchFreezeForNotification:(NSNotification *)notification;

+ (void)registerOpenBook:(id)observer selector:(SEL)selector;
+ (void)postOpenBook:(BOOL)open;
+ (void)unregisterOpenBook:(id)observer;
+ (BOOL)openBookForNotification:(NSNotification *)notification;

+ (void)registerEditMode:(id)observer selector:(SEL)selector;
+ (void)postEditMode:(BOOL)editMode;
+ (void)unregisterEditMode:(id)observer;
+ (BOOL)editModeForNotification:(NSNotification *)notification;

@end
