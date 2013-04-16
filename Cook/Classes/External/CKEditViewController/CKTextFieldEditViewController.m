//
//  CKTextFieldEditViewController.m
//  CKEditViewControllerDemo
//
//  Created by Jeff Tan-Ang on 12/04/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKTextFieldEditViewController.h"
#import "CKEditingTextBoxView.h"
#import "CKEditingViewHelper.h"

@interface CKTextFieldEditViewController () <UITextFieldDelegate>

@property (nonatomic, assign) NSUInteger characterLimit;

@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UILabel *limitLabel;

@end

@implementation CKTextFieldEditViewController

#define kTextFieldDefaultFont   [UIFont boldSystemFontOfSize:80.0]
#define kTextFieldDefaultLimit  20
#define kTitleLimitGap          12.0

- (id)initWithEditView:(UIView *)editView delegate:(id<CKEditViewControllerDelegate>)delegate
         editingHelper:(CKEditingViewHelper *)editingHelper white:(BOOL)white title:(NSString *)title
        characterLimit:(NSUInteger)characterLimit {
    
    if (self = [super initWithEditView:editView delegate:delegate editingHelper:editingHelper white:white title:title]) {
        self.characterLimit = characterLimit;
        self.fontSize = 70.0;
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

- (NSString *)updatedTextValue {
    return self.textField.text;
}

#pragma mark - Lifecycle events

- (void)targetTextEditingViewWillAppear:(BOOL)appear {
    [super targetTextEditingViewWillAppear:appear];
    
    if (!appear) {
        [self.textField resignFirstResponder];
        
        // Fade the labels out.
        [UIView animateWithDuration:0.1
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.titleLabel.alpha = 0.0;
                             self.limitLabel.alpha = 0.0;
                         }
                         completion:^(BOOL finished) {
                         }];

    }
}

- (void)targetTextEditingViewDidAppear:(BOOL)appear {
    [super targetTextEditingViewDidAppear:appear];
    
    if (appear) {
        
        // Focus on text field.
        [self.textField becomeFirstResponder];
        
        // Add title/limit labels.
        self.titleLabel.alpha = 0.0;
        self.limitLabel.alpha = 0.0;
        [self.view addSubview:self.titleLabel];
        [self.view addSubview:self.limitLabel];
        
        // Fade the labels in.
        [UIView animateWithDuration:0.1
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.titleLabel.alpha = 1.0;
                             self.limitLabel.alpha = 1.0;
                         }
                         completion:^(BOOL finished) {
                         }];
    }
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    BOOL isBackspace = [newString length] < [textField.text length];
    
    if ([textField.text length] >= self.characterLimit && !isBackspace) {
        return NO;
    }
    
    // Update character limit.
    NSUInteger currentLimit = self.characterLimit - [newString length];
    self.limitLabel.text = [NSString stringWithFormat:@"%d", currentLimit];
    [self.limitLabel sizeToFit];
    self.limitLabel.frame = CGRectMake(self.titleLabel.frame.origin.x + self.titleLabel.frame.size.width + kTitleLimitGap,
                                       self.titleLabel.frame.origin.y,
                                       self.limitLabel.frame.size.width,
                                       self.limitLabel.frame.size.height);

    // No save if no characters
    CKEditingTextBoxView *targetTextBoxView = [self targetEditTextBoxView];
    [targetTextBoxView showSaveIcon:YES enabled:([newString length] > 0) animated:NO];
    
    return YES;
}

#pragma mark - Lazy getters

- (UILabel *)limitLabel {
    if (!_limitLabel) {
        
        _limitLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _limitLabel.backgroundColor = [UIColor clearColor];
        _limitLabel.alpha = 0.5;
        _limitLabel.text = [NSString stringWithFormat:@"%d", self.characterLimit - [self.textField.text length]];
        _limitLabel.font = self.titleLabel.font;
        _limitLabel.textColor = self.titleLabel.textColor;
        [_limitLabel sizeToFit];
        
        // Reposition both title and limit labels.
        CGFloat requiredWidth = self.titleLabel.frame.size.width + kTitleLimitGap + _limitLabel.frame.size.width;
        self.titleLabel.frame = CGRectMake(floorf((self.view.bounds.size.width - requiredWidth) / 2.0),
                                           self.titleLabel.frame.origin.y,
                                           self.titleLabel.frame.size.width,
                                           self.titleLabel.frame.size.height);
        _limitLabel.frame = CGRectMake(self.titleLabel.frame.origin.x + self.titleLabel.frame.size.width + kTitleLimitGap,
                                       self.titleLabel.frame.origin.y,
                                       _limitLabel.frame.size.width,
                                       _limitLabel.frame.size.height);
    }
    return _limitLabel;
}

#pragma mark - Private methods

- (CGFloat)singleLineHeight {
    return [@"A" sizeWithFont:[UIFont boldSystemFontOfSize:self.fontSize] constrainedToSize:self.view.bounds.size
                lineBreakMode:NSLineBreakByClipping].height;
}


@end
