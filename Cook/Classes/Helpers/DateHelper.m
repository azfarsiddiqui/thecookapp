//
//  DateHelper.m
//  Cook
//
//  Created by Jeff Tan-Ang on 19/02/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "DateHelper.h"

@implementation DateHelper

+ (NSString *)timeDisplayForSeconds:(CGFloat)seconds {
    if (seconds <= 0) {
        return @"";
    }
    return [NSString stringWithFormat:@"%d", (int)(seconds / 60)];
}

@end
