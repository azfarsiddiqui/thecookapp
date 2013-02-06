//
//  TextViewEditingViewController.m
//  Cook
//
//  Created by Jonny Sagorin on 1/25/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "TextViewEditingViewController.h"
#import "Theme.h"

@interface TextViewEditingViewController () <UITextViewDelegate>
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *limitLabel;

@end

@implementation TextViewEditingViewController

-(id)initWithDelegate:(id<CKEditingViewControllerDelegate>)delegate sourceEditingView:(UIView *)sourceEditingView
{
    if (self = [super initWithDelegate:delegate sourceEditingView:sourceEditingView]) {
        [self defaultStyle];
    }
    return self;
}
- (UIView *)createTargetEditingView {
    UIEdgeInsets textViewInsets = UIEdgeInsetsMake(75.0, 50.0, 400.0, 50.0);
    
    CGRect frame = CGRectMake(textViewInsets.left,
                              textViewInsets.top,
                              self.view.bounds.size.width - textViewInsets.left - textViewInsets.right,
                              self.view.bounds.size.height - textViewInsets.top - textViewInsets.bottom);
    UITextView *editableTextView = [[UITextView alloc] initWithFrame:frame];
    editableTextView.autoresizingMask = UIViewAutoresizingNone;
    editableTextView.backgroundColor = [UIColor whiteColor];
    editableTextView.font = self.editableTextFont;
    editableTextView.textColor = [UIColor blackColor];
    editableTextView.delegate = self;
    return editableTextView;
}

//overridden methods

- (void)editingViewWillAppear:(BOOL)appear {
    [super editingViewWillAppear:appear];
    UITextView *textView = (UITextView *)self.targetEditingView;
    
    if (!appear) {
        [self.doneButton removeFromSuperview];
        [self.titleLabel removeFromSuperview];
        [self.limitLabel removeFromSuperview];
        textView.text = nil;
        [textView resignFirstResponder];
    }

}

- (void)editingViewDidAppear:(BOOL)appear {
    [super editingViewDidAppear:appear];
    
    if (appear) {
        [self addSubviews];
        UITextView *textView = (UITextView *)self.targetEditingView;
        textView.text = self.text;
        [textView becomeFirstResponder];
        
    }
}

- (void)performSave {
    
    UITextView *textView = (UITextView *)self.targetEditingView;
    [self.delegate editingView:self.sourceEditingView saveRequestedWithResult:textView.text];
    
    [super performSave];
}


#pragma mark - UITextViewDelegate methods

- (BOOL)textViewShouldEndEditing:(UITextView *)textView:(UITextField *)textField {
    DLog();
    [self performSave];
    return YES;
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSString *newString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    BOOL isBackspace = [newString length] < [textView.text length];
    
    if ([textView.text length] >= self.characterLimit && !isBackspace) {
        DLog("text view length %i, character limit is %i, returning NO", [textView.text length] ,self.characterLimit);
        return NO;
    }
    
    // Update character limit.
    NSUInteger currentLimit = self.characterLimit - [newString length];
    self.limitLabel.text = [NSString stringWithFormat:@"%d", currentLimit];
    [self updateLimitLabel];
    
    // No save if no characters
    self.doneButton.enabled = [newString length] > 0;
    
    NSRange scrollRange = NSMakeRange(textView.text.length - 1, 1);
    [textView scrollRangeToVisible:scrollRange];
    
    return YES;
}

#pragma mark - Private Methods

-(void)defaultStyle
{
    self.editableTextFont = [Theme textEditableTextFont];
    self.titleFont = [Theme textViewTitleFont];

}
-(void)addSubviews
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
    titleLabel.textColor = [UIColor whiteColor];
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
