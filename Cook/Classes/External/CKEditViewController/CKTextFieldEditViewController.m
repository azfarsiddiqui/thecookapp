//
//  CKTextFieldEditViewController.m
//  CKEditViewControllerDemo
//
//  Created by Jeff Tan-Ang on 12/04/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKTextFieldEditViewController.h"

@interface CKTextFieldEditViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *textField;

@end

@implementation CKTextFieldEditViewController

- (UIView *)createTargetEditView {
    
    CGSize size = CGSizeMake(800.0, 90.0);
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(floorf((self.view.bounds.size.width - size.width) / 2.0),
                                                                           160.0,
                                                                           size.width,
                                                                           size.height)];
    textField.font = [UIFont boldSystemFontOfSize:80.0];
    textField.textColor = [self editingTextColour];
    textField.backgroundColor = [UIColor clearColor];
    textField.textAlignment = NSTextAlignmentCenter;
    textField.delegate = self;
    textField.text = [self currentTextValue];
    self.textField = textField;
    return textField;
}

- (void)targetTextEditingViewWillAppear:(BOOL)appear {
    [self.textField resignFirstResponder];
    [super targetTextEditingViewWillAppear:appear];
}

- (void)targetTextEditingViewDidAppear:(BOOL)appear {
    [self.textField becomeFirstResponder];
    [super targetTextEditingViewDidAppear:appear];
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    return YES;
}

@end
