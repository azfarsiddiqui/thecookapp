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

- (void)drawTextInRect:(CGRect)rect {
    return [super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.insets)];
}

@end
