//
//  DataHelper.m
//  Sandbox
//
//  Created by Jeff Tan-Ang on 19/09/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "DataHelper.h"

@implementation DataHelper

+ (NSString *)friendlyDisplayForCount:(NSUInteger)count {
    NSMutableString *display = [NSMutableString string];
    
    if (count < 1000) {
        [display appendFormat:@"%d", count];
    } else if (count < 1000000) {
        if ((count % 1000) == 0) {
            [display appendFormat:@"%dK", (count / 1000)];
        } else {
            [display appendFormat:@"%.fK", (count / 1000.0)];
        }
    } else {
        if ((count % 1000000) == 0) {
            [display appendFormat:@"%dM", (count / 1000000)];
        } else {
            [display appendFormat:@"%.fM", (count / 1000000.0)];
        }
    }
    
    return display;
}

@end
