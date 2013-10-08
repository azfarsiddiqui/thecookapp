//
//  AnalyticsHelper.m
//  Cook
//
//  Created by Gerald Kim on 8/10/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "AnalyticsHelper.h"

@implementation AnalyticsHelper

+ (void)trackEventName:(NSString *)eventName params:(NSDictionary *)dimensions
{
    if (dimensions)
        [PFAnalytics trackEvent:eventName dimensions:dimensions];
    else
        [PFAnalytics trackEvent:eventName];
}

@end
