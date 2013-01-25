//
//  TextViewEditingViewController.m
//  Cook
//
//  Created by Jonny Sagorin on 1/25/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "TextViewEditingViewController.h"

@interface TextViewEditingViewController () <UITextViewDelegate>
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *limitLabel;

@end

@implementation TextViewEditingViewController

- (UIView *)createTargetEditingView {
    UIEdgeInsets textFieldInsets = UIEdgeInsetsMake(0.0, 50.0, 0.0, 50.0);
    
//    CGSize size = [@"A" sizeWithFont:self.editableTextFont forWidth:MAXFLOAT lineBreakMode:NSLineBreakByClipping];
    CGRect frame = CGRectMake(textFieldInsets.left,
                              floorf((self.view.bounds.size.height) / 2.0),
                              floorf((self.view.bounds.size.width - textFieldInsets.left - textFieldInsets.right)/2),
                              50.0f);
    UITextView *editableTextView = [[UITextView alloc] initWithFrame:frame];
    editableTextView.autoresizingMask = UIViewAutoresizingNone;
    editableTextView.backgroundColor = [UIColor blackColor];
//    editableTextView.font = self.editableTextFont;
    editableTextView.textColor = [UIColor whiteColor];
    editableTextView.delegate = self;
//    editableTextView.textAlignment = self.textAlignment;
    return editableTextView;
}

//overridden methods

- (void)editingViewWillAppear:(BOOL)appear {
    [super editingViewWillAppear:appear];
    UITextView *textView = (UITextView *)self.targetEditingView;
    
    if (!appear) {
        [self.doneButton removeFromSuperview];
//        [self.titleLabel removeFromSuperview];
//        [self.limitLabel removeFromSuperview];
        
        textView.text = nil;
        [textView resignFirstResponder];
    }

}

- (void)editingViewDidAppear:(BOOL)appear {
    [super editingViewDidAppear:appear];
    
    if (appear) {
        [self addFields];
        UITextView *textView = (UITextView *)self.targetEditingView;
        textView.text = self.text;
        [textView becomeFirstResponder];
        
    }
}

- (id)editingResult {
    UITextView *textView = (UITextView *)self.targetEditingView;
    return textView.text;
}


#pragma mark - UITextViewDelegate methods

- (BOOL)textViewShouldEndEditing:(UITextView *)textView:(UITextField *)textField {
    DLog();
    //    [self performSave];
    return YES;
    return YES;
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSString *newString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    BOOL isBackspace = [newString length] < [textView.text length];
    
    if ([textView.text length] >= self.characterLimit && !isBackspace) {
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

#pragma mark - Private Methods

-(void)addFields
{
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
    UITextView *textView = (UITextView *)self.targetEditingView;
    self.doneButton.frame = CGRectMake(textView.frame.origin.x + textView.frame.size.width - floorf(self.doneButton.frame.size.width / 2.0),
                                       textView.frame.origin.y - floorf(self.doneButton.frame.size.height / 3.0),
                                       self.doneButton.frame.size.width,
                                       self.doneButton.frame.size.height);
    [self.view addSubview:self.doneButton];
}


@end
