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

#define kTextFieldDefaultFont [UIFont boldSystemFontOfSize:80.0]

- (id)initWithEditView:(UIView *)editView delegate:(id<CKEditViewControllerDelegate>)delegate
         editingHelper:(CKEditingViewHelper *)editingHelper white:(BOOL)white {
    
    if (self = [super initWithEditView:editView delegate:delegate editingHelper:editingHelper white:white]) {
        self.fontSize = 80.0;
    }
     return self;
}

- (UIView *)createTargetEditView {
    
    CGSize size = CGSizeMake(800.0, 90.0);
    CGFloat singleLineHeight = [self singleLineHeight];
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(floorf((self.view.bounds.size.width - size.width) / 2.0),
                                                                           160.0,
                                                                           size.width,
                                                                           singleLineHeight)];
    textField.font = [UIFont boldSystemFontOfSize:self.fontSize];
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

#pragma mark - Private methods

- (CGFloat)singleLineHeight {
    return [@"A" sizeWithFont:[UIFont boldSystemFontOfSize:self.fontSize] constrainedToSize:self.view.bounds.size
                lineBreakMode:NSLineBreakByClipping].height;
}


@end
