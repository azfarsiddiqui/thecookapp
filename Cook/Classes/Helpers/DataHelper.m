//
//  DataHelper.m
//  Sandbox
//
//  Created by Jeff Tan-Ang on 19/09/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "DataHelper.h"
#import "NSString+Utilities.h"

@implementation DataHelper

+ (NSString *)friendlyDisplayForCount:(NSUInteger)count {
    return [self friendlyDisplayForCount:count showFractional:YES];
}

+ (NSString *)friendlyDisplayForCount:(NSUInteger)count showFractional:(BOOL)showFractional {
    NSMutableString *display = [NSMutableString string];
    
    if (count < 1000) {
        [display appendFormat:@"%ld", (unsigned long)count];
    } else if (count < 1000000) {
        if ((count % 1000) == 0) {
            [display appendFormat:@"%ldK", ((unsigned long)count / 1000)];
        } else if (showFractional) {
            [display appendFormat:@"%.1fK", (count / 1000.0)];
        } else {
            [display appendFormat:@"%.fK", (count / 1000.0)];
        }
    } else {
        if ((count % 1000000) == 0) {
            [display appendFormat:@"%ldM", ((unsigned long)count / 1000000)];
        } else if (showFractional) {
            [display appendFormat:@"%.1fM", (count / 1000000.0)];
        } else {
            [display appendFormat:@"%.fM", (count / 1000000.0)];
        }
    }
    
    return [display stringByReplacingOccurrencesOfString:@".0" withString:@""];
}

+ (NSString *)formattedDisplayForInteger:(NSInteger)integer {
    return [[self numberFormatter] stringFromNumber:@(integer)];
}

#pragma mark - Private methods

+ (NSNumberFormatter *)numberFormatter {
    static dispatch_once_t pred;
    static NSNumberFormatter *formatter = nil;
    dispatch_once(&pred, ^{
        formatter = [NSNumberFormatter new];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    });
    return formatter;
}

@end
