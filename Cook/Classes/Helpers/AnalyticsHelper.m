//
//  AnalyticsHelper.m
//  Cook
//
//  Created by Gerald Kim on 8/10/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "AnalyticsHelper.h"
#import "Flurry.h"

@implementation AnalyticsHelper

#pragma mark - Events

NSString *const kEventLibraryView                   = @"Library View";
NSString *const kEventLibraryBookSummaryView        = @"Library Book Summary";
NSString *const kEventBookView                      = @"Book View";
NSString *const kEventBookLoad                      = @"Book Load";
NSString *const kEventBookAdd                       = @"Book Add";
NSString *const kEventBookDelete                    = @"Book Delete";
NSString *const kEventPageView                      = @"Page View";
NSString *const kEventSearch                        = @"Search";
NSString *const kEventRecipeView                    = @"Recipe View";
NSString *const kEventRecipeSave                    = @"Recipe Save";
NSString *const kEventRecipeShare                   = @"Recipe Share";
NSString *const kEventRecipeComment                 = @"Recipe Comment";
NSString *const kEventRecipeLike                    = @"Recipe Like";
NSString *const kEventRecipePin                     = @"Recipe Pin";
NSString *const kEventRecipeSocialView              = @"Recipe Social View";
NSString *const kEventNotificationsView             = @"Notifications View";
NSString *const kEventSearchView                    = @"Search View";

#pragma mark - Properties

NSString *const kEventParamsBookPageName            = @"Page";
NSString *const kEventParamsBookPageIndex           = @"Index";

#pragma mark - Tracking methods

+ (void)trackEventName:(NSString *)eventName {
    [self trackEventName:eventName params:nil];
}

+ (void)trackEventName:(NSString *)eventName params:(NSDictionary *)params {
    [self trackEventName:eventName params:params timed:NO];
}

+ (void)trackEventName:(NSString *)eventName params:(NSDictionary *)params timed:(BOOL)timed {
    if ([params count] == 0) {
        [Flurry logEvent:eventName timed:timed];
    } else {
        [Flurry logEvent:eventName withParameters:params timed:timed];
    }
}

+ (void)endTrackEventName:(NSString *)eventName {
    [self endTrackEventName:eventName params:nil];
}

+ (void)endTrackEventName:(NSString *)eventName params:(NSDictionary *)params {
    [Flurry endTimedEvent:eventName withParameters:params];
}


@end
