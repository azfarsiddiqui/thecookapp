//
//  PagingScrollView.m
//  Cook
//
//  Created by Jeff Tan-Ang on 24/06/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "PagingScrollView.h"

@interface PagingScrollView ()

@property (nonatomic, assign) CGFloat pageWidth;

@end

@implementation PagingScrollView

- (id)initWithFrame:(CGRect)frame pageWidth:(CGFloat)pageWidth {
    if (self = [super initWithFrame:frame]) {
        self.pageWidth = pageWidth;
    }
    return self;
}

- (void)setContentOffset:(CGPoint)contentOffset {
    
    [super setContentOffset:contentOffset];
    
    CGRect frame = self.bounds;
    if (contentOffset.x >= (self.pageWidth * 2.0)) {
        frame.size.width = self.pageWidth;
    } else {
        frame.size.width = (self.pageWidth * 2.0);
    }
    self.bounds = frame;
    
}

@end
