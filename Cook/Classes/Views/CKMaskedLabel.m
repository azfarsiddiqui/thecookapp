//
//  CKMaskedLabel.m
//  Cook
//
//  Created by Jeff Tan-Ang on 26/03/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKMaskedLabel.h"

@interface CKMaskedLabel ()

@end

@implementation CKMaskedLabel

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.boxBackgroundColour = [UIColor colorWithWhite:1.0 alpha:0.9];
    }
    return self;
}

- (void)drawTextInRect:(CGRect)rect {
    return [super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.insets)];
}

- (void)RS_drawBackgroundInRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.boxBackgroundColour set];
    CGContextFillRect(context, rect);
}

@end
