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
@property (nonatomic, strong) UITextView *sandboxTextView;
@property (nonatomic, assign) CGFloat minHeight;

@end

@implementation CKTextViewEditViewController

#define kTextViewMinHeight      232.0
#define kTextViewWidth          800.0
#define kKeyboardDefaultFrame   CGRectMake(0.0, 396.0, 1024.0, 352.0)
#define kTextViewAdjustments    UIEdgeInsetsMake(0.0, 0.0, 20.0, 0.0)

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
        self.numLines = 6;
    }
    return self;
}

- (UIView *)createTargetEditView {
    UIEdgeInsets contentInsets = [self contentInsets];
    CGFloat width = kTextViewWidth;
    
    // TextView adjustments.
    UIEdgeInsets textViewAdjustments = kTextViewAdjustments;
    
    // Initial TextView height taking into account containing text.
    NSString *currentText = self.clearOnFocus ? @"" : [self currentTextValue];
    self.textView.text = currentText;
    CGFloat requiredTextViewHeight = [self requiredTextViewHeight];
//    requiredTextViewHeight = [self heightForText:currentText];
    CGFloat minHeight = textViewAdjustments.top + self.minHeight + textViewAdjustments.bottom;
    
    NSLog(@"*** requiredTextViewHeight %f", requiredTextViewHeight);
    NSLog(@"*** minHeight              %f", minHeight);
    
    // TextView positioning.
    self.textView.frame = (CGRect){
        textViewAdjustments.left + floorf((self.view.bounds.size.width - width) / 2.0),
        contentInsets.top,
        textViewAdjustments.left + width + textViewAdjustments.right,
        ceilf(MAX(requiredTextViewHeight, minHeight)),
    };
    
    // Set contentSize to be same as bounds.
    self.textView.contentSize = self.textView.bounds.size;
    
    return self.textView;
}

- (id)updatedValue {
    return self.textView.text;
}

- (UIEdgeInsets)contentInsets {
    return (UIEdgeInsets) { 93.0, 20.0, 50.0, 20.0 };
}

- (BOOL)contentScrollable {
    return YES;
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
    
    if ([textView.text length] >= self.characterLimit && !isBackspace) {
        
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
    
    [self updateInfoLabels];
    [self updateContentSize];
}

#pragma mark - Properties

- (UITextView *)textView {
    if (!_textView) {
        _textView = [self createTextView];
    }
    return _textView;
}

- (UITextView *)sandboxTextView {
    if (!_sandboxTextView) {
        _sandboxTextView = [self createTextView];
        _sandboxTextView.hidden = YES;
        [_sandboxTextView sizeToFit];
    }
    return _sandboxTextView;
}

- (CGFloat)minHeight {
    if (_minHeight == 0) {
        
        // Set the sandbox textView for measurement purposes.
        self.sandboxTextView.text = @"A";
        CGRect sandboxUsedRect = [self.sandboxTextView.layoutManager usedRectForTextContainer:self.sandboxTextView.textContainer];
        _minHeight = ceilf(sandboxUsedRect.size.height * self.numLines);
        NSLog(@"minHeight [%f]", _minHeight);
    }
    return _minHeight;
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
        
        // Move this somewhere else?
        [self updateContentSize];
        
    }
}

- (void)keyboardWillAppear:(BOOL)appear {
    CGRect keyboardFrame = [self currentKeyboardFrame];
    
    // Update the scrollView to be above the keyboard area.
    self.scrollView.contentInset = (UIEdgeInsets) { 0.0, 0.0, keyboardFrame.size.height, 0.0 };
    NSLog(@"contentInset %@", NSStringFromUIEdgeInsets(self.scrollView.contentInset));
    
}

#pragma mark - Private methods

- (void)updateContentSize {
    
    // No need to adjust if textLimited.
    if (![self contentScrollable]) {
        return;
    }
    
//    NSLog(@"updateContentSize");
    
    // TextView adjustments.
    UIEdgeInsets textViewAdjustments = kTextViewAdjustments;

    // Figure out the requiredHeight vs minimum height.
    CGFloat requiredHeight = [self requiredTextViewHeight];
    CGFloat minHeight = textViewAdjustments.top + self.minHeight + textViewAdjustments.bottom;

    // Updates the textView frame.
    CGRect textViewFrame = self.textView.frame;
    textViewFrame.size.height = MAX(requiredHeight, minHeight);
    self.textView.frame = textViewFrame;

    // Updates the surrounding textboxes.
    CKEditingTextBoxView *targetTextBoxView = [self targetEditTextBoxView];
    CKEditingTextBoxView *sourceTextBoxView = [self sourceEditTextBoxView];
    CGRect proposedTargetTextBoxFrame = [targetTextBoxView updatedFrameForProposedEditingViewFrame:textViewFrame];
    targetTextBoxView.frame = proposedTargetTextBoxFrame;
    sourceTextBoxView.frame = proposedTargetTextBoxFrame;
    
    // Figure out the required contentSize of main scrollView. The contentInsets is relative to the targetEditView, so
    // we have to take into account the textBox's contentInsets.
    UIEdgeInsets contentInsets = [self contentInsets];
    CGFloat requiredContentHeight = (contentInsets.top - targetTextBoxView.contentInsets.top) + proposedTargetTextBoxFrame.size.height + (contentInsets.bottom - targetTextBoxView.contentInsets.bottom);
//    NSLog(@"requiredContentHeight [%f]", requiredContentHeight);
//    NSLog(@"self.scrollView.contentSize.height [%f]", self.scrollView.contentSize.height);
//    NSLog(@"self.scrollView.bounds.size.height [%f]", self.scrollView.bounds.size.height);
    self.scrollView.contentSize = (CGSize) {
        self.scrollView.contentSize.width,
        ceilf(MAX(self.scrollView.bounds.size.height, requiredContentHeight))
    };
//    NSLog(@"self.scrollView.contentSize.height2 [%f]", self.scrollView.contentSize.height);
    
    // See if the caret is out of view?
    [self scrollToCursorIfRequired];
}

- (void)scrollToCursorIfRequired {
    if (self.textView.selectedTextRange.empty) {
        
        CKEditingTextBoxView *targetTextBoxView = [self targetEditTextBoxView];
        UIEdgeInsets contentInsets = [self contentInsets];
        UIEdgeInsets textViewAdjustments = kTextViewAdjustments;

        // Work out the no-go area for the textbox.
        CGRect keyboardFrame = [self currentKeyboardFrame];
        CGRect noGoFrame = keyboardFrame;
        noGoFrame.origin.y -= contentInsets.bottom;
        noGoFrame.size.height += contentInsets.bottom;
        
        CGRect cursorFrame = [self.textView caretRectForPosition:self.textView.selectedTextRange.start];
        CGRect cursorFrameToScrollView = [self.scrollView convertRect:cursorFrame fromView:self.textView];
        if (CGRectIntersectsRect(cursorFrameToScrollView, noGoFrame)) {
            
            CGRect visibleFrame = [self currentVisibleFrame];
            CGPoint scrollToPoint = (CGPoint){
                self.scrollView.contentOffset.x,
                cursorFrameToScrollView.origin.y - visibleFrame.size.height + cursorFrameToScrollView.size.height + textViewAdjustments.bottom + contentInsets.bottom - targetTextBoxView.contentInsets.bottom
            };
            
            NSLog(@"Scroll to reveal %@", NSStringFromCGPoint(scrollToPoint));
            [self.scrollView setContentOffset:scrollToPoint
                                     animated:YES];
        }
        
        //        NSLog(@"cursorFrame %@", NSStringFromCGRect(cursorFrame));
        //        NSLog(@"cursorFrameToScrollView %@", NSStringFromCGRect(cursorFrameToScrollView));
    }
}

- (UITextView *)createTextView {
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectZero];
    textView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    textView.font = self.textViewFont;
    textView.textColor = [self editingTextColour];
    textView.textAlignment = NSTextAlignmentLeft;
    textView.delegate = self;
    textView.showsHorizontalScrollIndicator = NO;
    textView.showsVerticalScrollIndicator = NO;
    textView.backgroundColor = [UIColor clearColor];
    
    // iOS7-b2 scrollEnabled causes characters to be left over after deleting from line below.
    textView.scrollEnabled = NO;
    textView.panGestureRecognizer.enabled = NO;
    return textView;
}

- (CGFloat)requiredTextViewHeight {
    CGFloat requiredHeight = [self.textView.layoutManager usedRectForTextContainer:self.textView.textContainer].size.height;
    requiredHeight += (kTextViewAdjustments.top + kTextViewAdjustments.bottom);
    return requiredHeight;
}

- (CGFloat)heightForText:(NSString *)text {
    self.sandboxTextView.text = text;
    [self.sandboxTextView sizeToFit];
    CGRect sandboxUsedRect = [self.sandboxTextView.layoutManager usedRectForTextContainer:self.sandboxTextView.textContainer];
    return sandboxUsedRect.size.height;
}

@end
