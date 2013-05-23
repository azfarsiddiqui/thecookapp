//
//  CKTextViewEditViewController.m
//  CKEditViewControllerDemo
//
//  Created by Jeff Tan-Ang on 16/04/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKTextViewEditViewController.h"
#import "CKEditingTextBoxView.h"
#import "CKEditingViewHelper.h"

@interface CKTextViewEditViewController () <UITextViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UITextView *sandboxTestView;
@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation CKTextViewEditViewController

#define kTextViewMinHeight      232.0
#define kTextViewWidth          800.0
#define kKeyboardDefaultFrame   CGRectMake(0.0, 396.0, 1024.0, 352.0)

- (id)initWithEditView:(UIView *)editView delegate:(id<CKEditViewControllerDelegate>)delegate
         editingHelper:(CKEditingViewHelper *)editingHelper white:(BOOL)white title:(NSString *)title {
    
    return [self initWithEditView:editView delegate:delegate editingHelper:editingHelper white:white title:title
                   characterLimit:NSUIntegerMax];
}

- (id)initWithEditView:(UIView *)editView delegate:(id<CKEditViewControllerDelegate>)delegate
         editingHelper:(CKEditingViewHelper *)editingHelper white:(BOOL)white title:(NSString *)title
        characterLimit:(NSUInteger)characterLimit {
    
    if (self = [super initWithEditView:editView delegate:delegate editingHelper:editingHelper white:white title:title
                        characterLimit:characterLimit]) {
        self.fontSize = 30.0;
        self.numLines = 6;
    }
    return self;
}

- (UIView *)createTargetEditView {
    UIEdgeInsets contentInsets = [self contentInsets];
    CGFloat width = kTextViewWidth;
    
    // Create a corresponding sandbox version to provide exact measurements.
    self.sandboxTestView = [self createTextView];
    self.sandboxTestView.hidden = YES;
    if (!self.sandboxTestView.superview) {
        [self.view addSubview:self.sandboxTestView];
    }
    
    // TextView positioning.
    CGFloat textViewHeight = [self minimumTextViewHeight];
    UITextView *textView = [self createTextView];
    textView.text = [self currentTextValue];
    textView.frame = CGRectMake(floorf((self.view.bounds.size.width - width) / 2.0),
                                self.textLimited ? floorf((kKeyboardDefaultFrame.origin.y - textViewHeight) / 2.0) : contentInsets.top,
                                width,
                                textViewHeight);
    self.textView = textView;
    
    // Set contentSize to be same as bounds.
    textView.contentSize = textView.bounds.size;
    
    // Set the textview frame as large as its contentSize height.
    CGRect textViewFrame = self.textView.frame;
    textViewFrame.size.height = self.textView.contentSize.height;
    self.textView.frame = textViewFrame;
    
    // Register pan on the textView.
    if ([self contentScrollable]) {
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
        panGesture.delegate = self;
        [self.textView addGestureRecognizer:panGesture];
    }
    
    return self.textView;
}

- (id)updatedValue {
    return self.textView.text;
}

- (UIEdgeInsets)contentInsets {
    return UIEdgeInsetsMake(93.0, 20.0, 50.0, 20.0);
}

- (BOOL)contentScrollable {
    return !self.textLimited;
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}

#pragma mark - UITextViewDelegate methods

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    BOOL shouldChangeText = YES;
    
    NSString *newString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    BOOL isBackspace = [newString length] < [textView.text length];
    
    if (self.textLimited && [text isEqualToString:@"\n"]) {
        
        // Disallow newline characters in textLimited mode.
        shouldChangeText = NO;
        
    } else if ([textView.text length] >= self.characterLimit && !isBackspace) {
        
        // Disallow text entry if it's over limit and NOT backspace.
        shouldChangeText = NO;
    }
    
    return shouldChangeText;
}

- (void)textViewDidChange:(UITextView *)textView {
    
    // Update character limit.
    NSUInteger currentLimit = self.characterLimit - [textView.text length];
    self.limitLabel.text = [NSString stringWithFormat:@"%d", currentLimit];
    [self.limitLabel sizeToFit];
    
    // No save if no characters
    CKEditingTextBoxView *targetTextBoxView = [self targetEditTextBoxView];
    [targetTextBoxView showSaveIcon:YES enabled:([textView.text length] > 0) animated:NO];
    
    [self updateInfoLabels];
    [self updateContentSize];
}

#pragma mark - Lifecycle events

- (void)targetTextEditingViewDidCreated {
    [super targetTextEditingViewDidCreated];
}

- (void)targetTextEditingViewWillAppear:(BOOL)appear {
    [super targetTextEditingViewWillAppear:appear];
    
    if (appear) {

        
    } else {
        [self.textView resignFirstResponder];
        
        // Fade the titleLabel out.
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
        [self.textView becomeFirstResponder];
        
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
        
        [self updateContentSize];
        
    }
}

- (void)panned:(UIPanGestureRecognizer *)panGesture {
    CGPoint translation = [panGesture translationInView:self.view];
    
    if (panGesture.state == UIGestureRecognizerStateBegan) {
    } else if (panGesture.state == UIGestureRecognizerStateChanged) {
        [self panWithTranslation:translation];
	} else if (panGesture.state == UIGestureRecognizerStateEnded) {
        [self panSnapIfRequired];
    }
    
    [panGesture setTranslation:CGPointZero inView:self.view];
}

- (void)panWithTranslation:(CGPoint)translation {
    CGFloat dragRatio = 0.5;
    CGFloat panOffset = translation.y * dragRatio;
    
    CKEditingTextBoxView *targetTextBoxView = [self targetEditTextBoxView];
    CKEditingTextBoxView *sourceTextBoxView = [self sourceEditTextBoxView];
    CGRect titleFrame = self.titleLabel.frame;
    CGRect textBoxFrame = targetTextBoxView.frame;
    CGRect sourceTextBoxFrame = sourceTextBoxView.frame;
    CGRect contentFrame = self.textView.frame;
    
    // Move everything together: title + textbox + textview + mocked textbox view (to be transitioned back).
    titleFrame.origin.y += panOffset;
    textBoxFrame.origin.y += panOffset;
    sourceTextBoxFrame.origin.y += panOffset;
    contentFrame.origin.y += panOffset;
    self.titleLabel.frame = titleFrame;
    targetTextBoxView.frame = textBoxFrame;
    sourceTextBoxView.frame = sourceTextBoxFrame;
    self.textView.frame = contentFrame;
}

- (void)panSnapIfRequired {
    UIEdgeInsets contentInsets = [self contentInsets];
    CGRect keyboardFrame = [self currentKeyboardFrame];
    CGRect noGoFrame = keyboardFrame;
    noGoFrame.origin.y -= contentInsets.bottom;
    noGoFrame.size.height += contentInsets.bottom;
    
    CKEditingTextBoxView *targetTextBoxView = [self targetEditTextBoxView];
    CKEditingTextBoxView *sourceTextBoxView = [self sourceEditTextBoxView];
    if (targetTextBoxView.frame.origin.y + targetTextBoxView.frame.size.height < noGoFrame.origin.y) {
        
        CGRect proposedTargetTextBoxFrame = CGRectMake(targetTextBoxView.frame.origin.x,
                                                       noGoFrame.origin.y - targetTextBoxView.frame.size.height,
                                                       targetTextBoxView.frame.size.width,
                                                       targetTextBoxView.frame.size.height);
        CGRect textViewFrame = self.textView.frame;
        textViewFrame.origin.y = proposedTargetTextBoxFrame.origin.y + targetTextBoxView.contentInsets.top;
        
        [UIView animateWithDuration:0.15
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             targetTextBoxView.frame = proposedTargetTextBoxFrame;
                             sourceTextBoxView.frame = proposedTargetTextBoxFrame;
                             self.textView.frame = textViewFrame;
                             [self updateInfoLabels];
                         }
                         completion:^(BOOL finished) {
                         }];

    }
}

- (void)updateContentSize {
    
    // No need to adjust if textLimited.
    if (![self contentScrollable]) {
        return;
    }
    
    CKEditingTextBoxView *targetTextBoxView = [self targetEditTextBoxView];
    CKEditingTextBoxView *sourceTextBoxView = [self sourceEditTextBoxView];
    
    // Various frames to update.
    CGRect textViewFrame = self.textView.frame;
    
    // The minimum height of the textView.
    CGFloat textViewHeight = [self minimumTextViewHeight];
    
    // Set the textview frame as large as its contentSize height.
    textViewFrame.size.height =  self.textView.contentSize.height;
    textViewFrame.size.height = (textViewFrame.size.height < textViewHeight) ? textViewHeight : textViewFrame.size.height;
    
    // Work out the no-go area for the textbox.
    UIEdgeInsets contentInsets = [self contentInsets];
    CGRect keyboardFrame = [self currentKeyboardFrame];
    CGRect noGoFrame = keyboardFrame;
    noGoFrame.origin.y -= contentInsets.bottom;
    noGoFrame.size.height += contentInsets.bottom;
    
    // Adjust positioning.
    CGRect proposedTargetTextBoxFrame = [targetTextBoxView updatedFrameForProposedEditingViewFrame:textViewFrame];
    
    // Flush to the bottom of the visible area.
    if (keyboardFrame.origin.y > 0) {
        proposedTargetTextBoxFrame.origin.y = noGoFrame.origin.y - proposedTargetTextBoxFrame.size.height;
        textViewFrame.origin.y = proposedTargetTextBoxFrame.origin.y + targetTextBoxView.contentInsets.top;
    }

    // Animate frame around to fit content.
    [UIView animateWithDuration:0.1
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         
                         self.textView.frame = textViewFrame;
                         targetTextBoxView.frame = proposedTargetTextBoxFrame;
                         sourceTextBoxView.frame = proposedTargetTextBoxFrame;

                         [self updateInfoLabels];
                         
                     }
                     completion:^(BOOL finished) {
                     }];
}

- (UIFont *)textViewFont {
    return [UIFont systemFontOfSize:self.fontSize];
}

- (CGFloat)minimumTextViewHeight {
    
    NSMutableString *testString = [NSMutableString stringWithString:@"A"];
    for (NSInteger line = 1; line < self.numLines; line++) {
        [testString appendString:@"\nA"];
    }
    self.sandboxTestView.text = testString;
    return self.sandboxTestView.contentSize.height;
}

- (UITextView *)createTextView {
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectZero];
    textView.font = [self textViewFont];
    textView.textColor = [self editingTextColour];
    textView.backgroundColor = [UIColor clearColor];
    textView.textAlignment = NSTextAlignmentLeft;
    textView.delegate = self;
    textView.scrollEnabled = NO;
    return textView;
}

@end
