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
    }
}

- (void)setContentViewController:(BookContentViewController *)contentViewController {
    contentViewController.view.frame = self.contentView.bounds;
    
    if (_contentViewController) {
        
        // Prep for the BookContentVC to be faded in first time.
        contentViewController.view.alpha = 0.0;
        [self.contentView addSubview:contentViewController.view];
        
        [UIView animateWithDuration:0.25
                              delay:0.0
                            options:UIViewAnimationCurveEaseIn
                         animations:^{
                             _contentViewController.view.alpha = 0.0;
                             contentViewController.view.alpha = 1.0;
                         }
                         completion:^(BOOL finished)  {
                             _contentViewController = contentViewController;
                         }];
    } else {
        [self.contentView addSubview:contentViewController.view];
        _contentViewController = contentViewController;
    }
}

@end
