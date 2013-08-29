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


- (void)RS_commonInit {
    [super RS_commonInit];
    [super setTextColor:self.textColour];
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
