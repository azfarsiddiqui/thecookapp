//
//  PageListCell.m
//  Cook
//
//  Created by Jeff Tan-Ang on 3/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "PageListCell.h"

@implementation PageListCell

- (NSString *)textValueForValue:(id)value {
    return [[super textValueForValue:value] uppercaseString];
}

@end
