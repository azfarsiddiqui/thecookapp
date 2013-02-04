//
//  CKTextEditingViewController.m
//  CKEditingViewControllerDemo
//
//  Created by Jeff Tan-Ang on 6/12/12.
//  Copyright (c) 2012 Cook App Pty Ltd. All rights reserved.
//

#import "CKTextFieldEditingViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "CKEditingTextField.h"

@interface CKTextFieldEditingViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *limitLabel;

@end

@implementation CKTextFieldEditingViewController

#pragma mark - CKEditingViewController methods

- (UIView *)createTargetEditingView {
    UIEdgeInsets textFieldInsets = UIEdgeInsetsMake(0.0, 50.0, 0.0, 50.0);
    
    CGSize size = [@"A" sizeWithFont:self.editableTextFont forWidth:MAXFLOAT lineBreakMode:NSLineBreakByClipping];
    CGRect frame = CGRectMake(textFieldInsets.left,
                              floorf((self.view.bounds.size.height - size.height) / 2.0),
                              self.view.bounds.size.width - textFieldInsets.left - textFieldInsets.right,
                              size.height - 10.0);
    CKEditingTextField *textField = [[CKEditingTextField alloc] initWithFrame:frame];
    textField.autoresizingMask = UIViewAutoresizingNone;
    textField.backgroundColor = [UIColor blackColor];
    textField.font = self.editableTextFont;
    textField.textColor = [UIColor whiteColor];
    textField.delegate = self;
    textField.textAlignment = self.textAlignment;
    return textField;
}

- (void)editingViewWillAppear:(BOOL)appear {
    UITextField *textField = (UITextField *)self.targetEditingView;
    if (!appear) {
        [self.doneButton removeFromSuperview];
        [self.titleLabel removeFromSuperview];
        [self.limitLabel removeFromSuperview];
        
        textField.text = nil;
        [textField resignFirstResponder];
    }
    [super editingViewWillAppear:appear];
}

- (void)editingViewDidAppear:(BOOL)appear {
    [super editingViewDidAppear:appear];

    if (appear) {

        [self addSubviews];
        UITextField *textField = (UITextField *)self.targetEditingView;
        textField.text = self.text;
        [textField becomeFirstResponder];
        
    }
}

- (void)editingViewKeyboardWillAppear:(BOOL)appear keyboardFrame:(CGRect)keyboardFrame {
    [super editingViewKeyboardWillAppear:appear keyboardFrame:keyboardFrame];
    if (appear) {
        UITextField *textField = (UITextField *)self.targetEditingView;
        
        // Convert from rect at window to root view.
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        CGRect keyboardFrameConverted = [self.view convertRect:keyboardFrame fromView:window];
        
        // Animate to the shifted position.
        CGFloat shiftOffset = - floorf(textField.frame.origin.y - ((keyboardFrameConverted.origin.y - textField.bounds.size.height) / 2));
        
        CGAffineTransform shiftTransform = appear ? CGAffineTransformMakeTranslation(0.0, shiftOffset) : CGAffineTransformIdentity;

            [UIView animateWithDuration:0.3
                                  delay:0.0
                                options:UIViewAnimationCurveEaseIn
                             animations:^{
                                 self.titleLabel.transform = shiftTransform;
                                 self.limitLabel.transform = shiftTransform;
                                 self.doneButton.transform = shiftTransform;
                                 textField.transform = shiftTransform;
                             }
                             completion:^(BOOL finished) {
                             }];
    }

}

- (void)performSave {
    
    UITextField *textField = (UITextField *)self.targetEditingView;
    [self.delegate editingView:self.sourceEditingView saveRequestedWithResult:textField.text];

    [super performSave];
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self performSave];
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
    [self updateLimitLabel];
    
    // No save if no characters
    self.doneButton.enabled = [newString length] > 0;
    
    return YES;
}

#pragma mark - Private methods

- (void)addSubviews {
    [self addDoneButton];
    [self addTitleLabel];
    [self updateLimitLabel];
}

- (void)addTitleLabel {
    UITextField *textField = (UITextField *)self.targetEditingView;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = self.editingTitle;
    titleLabel.font = self.titleFont;
    titleLabel.textColor = textField.textColor;
    titleLabel.shadowColor = [UIColor blackColor];
    titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    [titleLabel sizeToFit];
    titleLabel.frame = CGRectMake(textField.frame.origin.x + floorf((textField.frame.size.width - titleLabel.frame.size.width) / 2.0),
                                  textField.frame.origin.y - titleLabel.frame.size.height + 5.0,
                                  titleLabel.frame.size.width,
                                  titleLabel.frame.size.height);
    [self.view addSubview:titleLabel];
    self.titleLabel = titleLabel;
}

- (void)updateLimitLabel {
    CGFloat limitGap = 12.0;
    
    if (!self.limitLabel) {
        UILabel *limitLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        limitLabel.backgroundColor = [UIColor clearColor];
        limitLabel.text = [NSString stringWithFormat:@"%d", self.characterLimit - [self.text length]];
        limitLabel.font = self.titleLabel.font;
        limitLabel.textColor = [UIColor colorWithRed:255.0 green:255.0 blue:255.0 alpha:0.5];
        limitLabel.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
        limitLabel.shadowOffset = CGSizeMake(0.0, -1.0);
        [self.view addSubview:limitLabel];
        self.limitLabel = limitLabel;
        
        self.titleLabel.frame = CGRectMake(self.titleLabel.frame.origin.x - floorf((limitLabel.frame.size.width + limitGap) / 2.0),
                                           self.titleLabel.frame.origin.y,
                                           self.titleLabel.frame.size.width,
                                           self.titleLabel.frame.size.height);
    }
    
    [self.limitLabel sizeToFit];
    self.limitLabel.frame = CGRectMake(self.titleLabel.frame.origin.x + self.titleLabel.frame.size.width + limitGap,
                                       self.titleLabel.frame.origin.y,
                                       self.limitLabel.frame.size.width,
                                       self.limitLabel.frame.size.height);
}

- (void)addDoneButton {
    UITextField *textField = (UITextField *)self.targetEditingView;
    
    self.doneButton.frame = CGRectMake(textField.frame.origin.x + textField.frame.size.width - floorf(self.doneButton.frame.size.width / 2.0),
                                       textField.frame.origin.y - floorf(self.doneButton.frame.size.height / 3.0),
                                       self.doneButton.frame.size.width,
                                       self.doneButton.frame.size.height);
    [self.view addSubview:self.doneButton];
}

@end
