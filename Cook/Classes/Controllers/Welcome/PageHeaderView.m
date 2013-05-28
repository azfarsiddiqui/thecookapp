//
//  PageHeaderView.m
//  Cook
//
//  Created by Jeff Tan-Ang on 28/05/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "PageHeaderView.h"

@interface PageHeaderView ()

@end

@implementation PageHeaderView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        DLog(@"FRAME: %@", NSStringFromCGRect(frame));
    }
    return self;
}

- (void)setContentView:(UIView *)contentView {
    [_contentView removeFromSuperview];
    [self addSubview:contentView];
    _contentView = contentView;
}

@end
