//
//  AnalyticsHelper.h
//  Cook
//
//  Created by Gerald Kim on 8/10/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/PFAnalytics.h>

@interface AnalyticsHelper : NSObject

+ (void)trackEventName:(NSString *)eventName params:(NSDictionary *)dimensions;

@end
