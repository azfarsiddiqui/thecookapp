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
@property (nonatomic, strong) NSNumberFormatter *numberFormatter;

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
        self.numberFormatter = [[NSNumberFormatter alloc] init];
        self.numberFormatter.maximumIntegerDigits = 2;
        self.numberFormatter.minimumIntegerDigits = 2;
    }
    return self;
}

- (NSString *)relativeDateTimeDisplayForDate:(NSDate *)date {
    return [self relativeDateTimeDisplayForDate:date fromDate:[NSDate date]];
}

- (NSString *)relativeDateTimeDisplayForDate:(NSDate *)date fromDate:(NSDate *)fromDate {
    return [self.timeIntervalFormatter stringForTimeIntervalFromDate:fromDate toDate:date];
}

-  (NSString *)formattedDurationDisplayForMinutes:(NSInteger)minutes {
    return [self formattedDurationDisplayForMinutes:minutes isHourOnly:NO];
}

- (NSString *)formattedDurationDisplayForMinutes:(NSInteger)minutes isHourOnly:(BOOL)isHourOnly {
    NSMutableString *formattedDisplay = [NSMutableString string];
    NSInteger hours = (minutes / 60);

    NSInteger remainderMinutes = minutes % 60;
    if (minutes == 0) {
        return @" 0m";
    }
    if (hours > 0) {
        [formattedDisplay appendFormat:@"%@h", [@(hours) stringValue]];
    }
    if (!isHourOnly) {
        [formattedDisplay appendFormat:@" %@m", [self.numberFormatter stringFromNumber:@(remainderMinutes)]];
    }

    return formattedDisplay;
}

- (NSString *)formattedShortDurationDisplayForMinutes:(NSInteger)minutes {
    NSMutableString *formattedDisplay = [NSMutableString string];
    NSInteger hours = (minutes / 60);
    if (hours > 0) {
        NSInteger remainderMinutes = minutes % 60;
        [formattedDisplay appendFormat:@"%dh", hours];
        if (remainderMinutes > 0) {
            [formattedDisplay appendString:@" "];
            if (remainderMinutes < 10) {
                [formattedDisplay appendString:@"0"];
            }
            [formattedDisplay appendFormat:@"%dm", remainderMinutes];
        }
    } else {
        [formattedDisplay appendFormat:@"%dm", minutes];
    }
    return formattedDisplay;
}

@end
