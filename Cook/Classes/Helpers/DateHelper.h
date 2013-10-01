//
//  DateHelper.h
//  Cook
//
//  Created by Jeff Tan-Ang on 1/09/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateHelper : NSObject

+ (DateHelper *)sharedInstance;
- (NSString *)relativeDateTimeDisplayForDate:(NSDate *)date;
- (NSString *)relativeDateTimeDisplayForDate:(NSDate *)date fromDate:(NSDate *)fromDate;
- (NSString *)formattedDurationDisplayForMinutes:(NSInteger)minutes;

@end
