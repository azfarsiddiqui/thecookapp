//
//  BookContentCell.m
//  Cook
//
//  Created by Jeff Tan-Ang on 12/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookContentCell.h"

@implementation BookContentCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    if (_contentViewController) {
        [_contentViewController.view removeFromSuperview];
        _contentViewController = nil;
    }
}

- (void)setContentViewController:(BookContentViewController *)contentViewController {
    contentViewController.view.frame = self.contentView.bounds;
    [self.contentView addSubview:contentViewController.view];
    _contentViewController = contentViewController;
}

@end
