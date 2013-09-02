//
//  DateHelper.m
//  Cook
//
//  Created by Jeff Tan-Ang on 1/09/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "DateHelper.h"
#import "TTTTimeIntervalFormatter.h"

@interface DateHelper ()

@property (nonatomic, strong) TTTTimeIntervalFormatter *timeIntervalFormatter;

@end

@implementation DateHelper

+ (DateHelper *)sharedInstance {
    static dispatch_once_t pred;
    static DateHelper *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance =  [[DateHelper alloc] init];
    });
    return sharedInstance;
}


- (id)init {
    if (self = [super init]) {
        
        // Past dates formatting.
        self.timeIntervalFormatter = [[TTTTimeIntervalFormatter alloc] init];
        [self.timeIntervalFormatter setUsesIdiomaticDeicticExpressions:NO];
    }
    return self;
}

- (NSString *)relativeDateTimeDisplayForDate:(NSDate *)date {
    return [self.timeIntervalFormatter stringForTimeIntervalFromDate:[NSDate date] toDate:date];
}

@end