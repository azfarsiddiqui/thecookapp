//
//  ServesAndTimeEditViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 9/05/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "ServesAndTimeEditViewController.h"

@interface ServesAndTimeEditViewController ()

@end

@implementation ServesAndTimeEditViewController

#define kSize   CGSizeMake(850.0, 580.0)

- (UIView *)createTargetEditView {
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(floorf((self.view.bounds.size.width - kSize.width) / 2.0),
                                                                     floorf((self.view.bounds.size.height - kSize.height) / 2.0),
                                                                     kSize.width,
                                                                     kSize.height)];
    return containerView;
}

@end
