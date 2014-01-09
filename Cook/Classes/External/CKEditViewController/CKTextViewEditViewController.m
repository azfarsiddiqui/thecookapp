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
#define kTextViewWidth          780.0
#define kKeyboardDefaultFrame   CGRectMake(0.0, 396.0, 1024.0, 352.0)
#define kTextViewAdjustments    UIEdgeInsetsMake(0.0, 0.0, 50.0, 0.0)

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
    self.textView.text = self.forceUppercase ? [currentText uppercaseString] : currentText;
    CGFloat requiredTextViewHeight = [self requiredTextViewHeight];
    CGFloat minHeight = textViewAdjustments.top + self.minHeight + textViewAdjustments.bottom;
    
    // TextView positioning.
    self.textView.frame = (CGRect){
        textViewAdjustments.left + floorf((self.view.bounds.size.width - width) / 2.0),
        contentInsets.top,
        textViewAdjustments.left + width + textViewAdjustments.right,
        ceilf(MAX(requiredTextViewHeight, minHeight)),
    };
    
    // Set contentSize to be same as bounds.
    [self updateContentSize];
    
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

- (void)doSave {
    //Trim whitespace and newlines when dismissing keyboard to circumvent iOS7.0 UITextView crash bug
    self.textView.text = [self.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [super doSave];
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
    
    // Disallow text entry if it's over limit and NOT backspace.
    if ([textView.text length] >= self.characterLimit && !isBackspace) {
        shouldChangeText = NO;
    }
    
    // If trying to paste in content over char limit, cut off and apply
    if (([newString length] > self.characterLimit && !isBackspace)) {
        textView.text = [newString substringToIndex:self.characterLimit];
        [self updateContentSize];
        [self updateInfoLabels];
        return NO;
    }
    
    // Number of lines check.
    CGFloat requiredHeight = [newString boundingRectWithSize:CGSizeMake(self.textView.frame.size.width, CGFLOAT_MAX)
                                                     options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                  attributes:@{ NSFontAttributeName : self.textViewFont }
                                                     context:nil].size.height;
    
    // Only add the extra height if it was ended in newline character, to add to the requredHeight.
    if ([text isEqualToString:@"\n"] && [newString hasSuffix:text]) {
        DLog(@"+= [%f]", self.textViewFont.pointSize);
        requiredHeight += self.textViewFont.pointSize;
    }
    if (self.maxHeight && self.numLines > 0 && !isBackspace && requiredHeight > self.maxHeight) {
        [self updateInfoLabels];
        return NO;
    }
    
    // Force uppercase here by replacing the entry into uppercase.
    if (shouldChangeText && self.forceUppercase && ![self isRomanisedAsianInput:text]) {
        
        UITextPosition *beginning = textView.beginningOfDocument;
        UITextPosition *start = [textView positionFromPosition:beginning offset:range.location];
        UITextPosition *end = [textView positionFromPosition:start offset:range.length];
        UITextRange *textRange = [textView textRangeFromPosition:start toPosition:end];
        
        // replace the text in the range with the upper case version of the replacement string
        [textView replaceRange:textRange withText:[text uppercaseString]];
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
//        NSLog(@"minHeight [%f]", _minHeight);
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
    self.showTitle = YES;
    if (appear) {
        
        // Focus on text field.
        CGFloat requiredHeight = [self requiredTextViewHeight];
        if (requiredHeight < [self defaultKeyboardFrame].origin.y) {
            [self.textView becomeFirstResponder];
        }
        
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
    
    if (appear) {
        [self scrollToCursorIfRequired];
        [self updateContentSize];
    } else {
        //Trim whitespace and newlines when dismissing keyboard to circumvent iOS7.0 UITextView crash bug
        self.textView.text = [self.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
}

#pragma mark - Private methods

- (void)updateContentSize {
    
    // No need to adjust if textLimited.
    if (![self contentScrollable]) {
        return;
    }
    
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
    CGRect proposedTargetTextBoxFrame = CGRectZero;
    if (targetTextBoxView) {
        CKEditingTextBoxView *sourceTextBoxView = [self sourceEditTextBoxView];
        proposedTargetTextBoxFrame = [targetTextBoxView updatedFrameForProposedEditingViewFrame:textViewFrame];
        targetTextBoxView.frame = proposedTargetTextBoxFrame;
        sourceTextBoxView.frame = proposedTargetTextBoxFrame;
    }
    
    // Figure out the required contentSize of main scrollView. The contentInsets is relative to the targetEditView, so
    // we have to take into account the textBox's contentInsets.
    UIEdgeInsets contentInsets = [self contentInsets];
    CGFloat requiredContentHeight = (contentInsets.top - targetTextBoxView.contentInsets.top) + proposedTargetTextBoxFrame.size.height + (contentInsets.bottom - targetTextBoxView.contentInsets.bottom);
    self.scrollView.contentSize = (CGSize) {
        self.scrollView.contentSize.width,
        ceilf(MAX(self.scrollView.bounds.size.height, requiredContentHeight))
    };
    
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
        CGRect scrollFrame = [self.view convertRect:cursorFrameToScrollView fromView:self.scrollView];
        if (CGRectIntersectsRect(scrollFrame, noGoFrame)) {
            
            CGRect visibleFrame = [self currentVisibleFrame];
            CGPoint scrollToPoint = (CGPoint){
                self.scrollView.contentOffset.x,
                cursorFrameToScrollView.origin.y - visibleFrame.size.height + cursorFrameToScrollView.size.height + textViewAdjustments.bottom + contentInsets.bottom - targetTextBoxView.contentInsets.bottom
            };
            
            NSLog(@"Scroll to reveal %@", NSStringFromCGPoint(scrollToPoint));
            [self.scrollView setContentOffset:scrollToPoint
                                     animated:YES];
        }
    }
}

- (UITextView *)createTextView {
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectZero];
    textView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    textView.font = self.textViewFont;
    textView.textColor = [self editingTextColour];
    textView.textAlignment = self.textAlignment;
    if (self.forceUppercase) {
        textView.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    }
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
    
    NSDictionary *attributeDict;
    if (self.textView.font)
        attributeDict = @{NSFontAttributeName : self.textView.font};
    else
        attributeDict = @{NSFontAttributeName : [UIFont fontWithName:@"BrandonGrotesque-Regular" size:48.0]};
    CGRect cRect = [self.textView.text boundingRectWithSize:CGSizeMake(self.textView.frame.size.width, CGFLOAT_MAX)
                                                    options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                 attributes:attributeDict
                                                    context:nil];
    CGFloat requiredHeight = cRect.size.height;
    
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
