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

@property (nonatomic, strong) UITextField *textField;

@end

@implementation CKTextFieldEditViewController

#define kTitleLimitGap          12.0

- (id)initWithEditView:(UIView *)editView delegate:(id<CKEditViewControllerDelegate>)delegate
         editingHelper:(CKEditingViewHelper *)editingHelper white:(BOOL)white title:(NSString *)title
        characterLimit:(NSUInteger)characterLimit {
    
    if (self = [super initWithEditView:editView delegate:delegate editingHelper:editingHelper white:white title:title characterLimit:characterLimit]) {
        self.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}

- (UIView *)createTargetEditView {
    
    CGSize size = CGSizeMake(800.0, 90.0);
    CGFloat singleLineHeight = [self singleLineHeight];
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(floorf((self.view.bounds.size.width - size.width) / 2.0),
                                                                           [self textFieldTopOffset],
                                                                           size.width,
                                                                           singleLineHeight)];
    textField.font = self.font;
    textField.textColor = [self editingTextColour];
    textField.backgroundColor = [UIColor clearColor];
    textField.textAlignment = self.textAlignment;
    textField.delegate = self;
    textField.text = self.clearOnFocus ? @"" : [self currentTextValue];
    self.textField = textField;
    return textField;
}

- (id)updatedValue {
    return self.textField.text;
}

#pragma mark - CKTextFieldEditViewController methods

- (CGFloat)textFieldTopOffset {
    return 160.0;
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
    self.showTitle = YES;
    if (appear) {
        
        // Focus on text field.
        [self.textField becomeFirstResponder];
        
        // Add title/limit labels.
        self.titleLabel.alpha = 0.0;
        self.limitLabel.alpha = 0.0;
        [self.scrollView addSubview:self.titleLabel];
        [self.scrollView addSubview:self.limitLabel];
        
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
    BOOL shouldChange = NO;
    
    if ([textField.text length] >= self.characterLimit && !isBackspace) {
        return NO;
    }
    
    // Update character limit.
    NSUInteger currentLimit = self.characterLimit - [newString length];
    self.limitLabel.text = [NSString stringWithFormat:@"%d", currentLimit];
    [self updateInfoLabels];

    if (self.forceUppercase) {
        
        UITextPosition *beginning = textField.beginningOfDocument;
        UITextPosition *start = [textField positionFromPosition:beginning offset:range.location];
        UITextPosition *end = [textField positionFromPosition:start offset:range.length];
        UITextRange *textRange = [textField textRangeFromPosition:start toPosition:end];
        
        // replace the text in the range with the upper case version of the replacement string
        [textField replaceRange:textRange withText:[string uppercaseString]];
        
    } else {
        shouldChange = YES;
    }
    
    //If trying to paste in content over char limit, cut off and apply
    if ([newString length] > self.characterLimit && !isBackspace) {
        textField.text = [newString substringToIndex:self.characterLimit];
        if (self.forceUppercase) textField.text = [textField.text uppercaseString];
        
        [self updateInfoLabels];
        return NO;
    }
    
    return shouldChange;
}

#pragma mark - Private methods

- (CGFloat)singleLineHeight {
    return [CKEditingViewHelper singleLineHeightForFont:self.font
                                                   size:self.view.bounds.size];
}

@end
