//
//  CKTextFieldEditViewController.m
//  CKEditViewControllerDemo
//
//  Created by Jeff Tan-Ang on 12/04/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKTextFieldEditViewController.h"

@interface CKTextFieldEditViewController ()

@end

@implementation CKTextFieldEditViewController

- (UIView *)createTargetEditView {
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:100.0];
    label.textColor = [UIColor darkGrayColor];
    label.shadowColor = [UIColor lightGrayColor];
    label.shadowOffset = CGSizeMake(0.0, 1.0);
    label.text = @"NERD RECIPES";
    [label sizeToFit];
    label.frame = CGRectMake(floorf((self.view.bounds.size.width - label.frame.size.width) / 2.0),
                             floorf((self.view.bounds.size.height - label.frame.size.height) / 2.0),
                             label.frame.size.width,
                             label.frame.size.height);
    return label;
}


@end
