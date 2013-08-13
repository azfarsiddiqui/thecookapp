//
//  BookRecipeGridLargeCell.m
//  Cook
//
//  Created by Jeff Tan-Ang on 13/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookRecipeGridLargeCell.h"

@implementation BookRecipeGridLargeCell

- (void)updateTitle {
    [super updateTitle];
    
    UIEdgeInsets contentInsets = [self contentInsets];
    CGRect frame = self.titleLabel.frame;
    CGSize availableSize = [self availableSize];
    CGSize size = [self.titleLabel sizeThatFits:availableSize];
    frame.origin.x = contentInsets.left + floorf((availableSize.width - size.width) / 2.0);
    
    if (self.imageView.hidden) {
        frame.origin.y = contentInsets.top;
    } else {
        frame.origin.y = self.imageView.frame.origin.y + self.imageView.frame.size.height + contentInsets.top;
    }
    
    frame.size.width = size.width;
    frame.size.height = size.height;
    self.titleLabel.frame = frame;
}

@end
