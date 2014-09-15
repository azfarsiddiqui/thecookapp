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
#import "PSPDFTextView.h"
#import "IngredientsKeyboardAccessoryViewController.h"

@interface CKTextViewEditViewController () <UITextViewDelegate, UIGestureRecognizerDelegate, IngredientsKeyboardAccessoryViewControllerDelegate>

@property (nonatomic, strong) PSPDFTextView *textView;
@property (nonatomic, strong) PSPDFTextView *sandboxTextView;
@property (nonatomic, assign) CGFloat minHeight;
@property (nonatomic, strong) IngredientsKeyboardAccessoryViewController *accessoryView;

@end

@implementation CKTextViewEditViewController

#define kTextViewMinHeight      232.0
#define kTextViewWidth          780.0
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
        self.numLines = 8;
        self.accessoryView = [[IngredientsKeyboardAccessoryViewController alloc] init];
        self.accessoryView.delegate = self;
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
    CGFloat accessoryViewHeight = 0;
    if (self.textView.inputAccessoryView) {
        accessoryViewHeight = self.accessoryView.view.frame.size.height;
    }
    
    
    CGFloat minHeight = textViewAdjustments.top + self.minHeight + textViewAdjustments.bottom - accessoryViewHeight;
    
    if ([self.titleLabel.text length] > 0) {
        self.titleLabel.frame = CGRectMake(self.titleLabel.frame.origin.x, self.textView.frame.origin.y/2 + 20, self.titleLabel.frame.size.width, self.titleLabel.frame.size.height);
        minHeight += self.titleLabel.frame.size.height;
    }
    
    CGFloat labelHeight = 0;
    if ([self.titleLabel.text length] > 0) {
        labelHeight = self.titleLabel.frame.size.height;
    }
    
    // TextView positioning.
    self.textView.frame = (CGRect){
        textViewAdjustments.left + floorf((self.view.bounds.size.width - width) / 2.0),
        MAX(kKeyboardDefaultFrame.origin.y/2 - minHeight/2, contentInsets.top + labelHeight/2),
        textViewAdjustments.left + width + textViewAdjustments.right,
        ceilf(minHeight)
    };
    
    // Set contentSize to be same as bounds.
//    [self updateContentSize];
    
    return self.textView;
}

- (id)updatedValue {
    return self.textView.text;
}

- (UIEdgeInsets)contentInsets {
    return (UIEdgeInsets) { 43.0, 20.0, 50.0, 20.0 };
}

- (BOOL)contentScrollable {
    return YES;
}

- (void)doSave {
    //Trim whitespace and newlines when dismissing keyboard to circumvent iOS7.0 UITextView crash bug
//    self.textView.text = [self.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [super doSave];
}

- (void)includeAccessoryView:(BOOL)doInclude {
    if (doInclude) {
        self.textView.inputAccessoryView = self.accessoryView.view;
    }
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
    NSInteger currentLimit = self.characterLimit - [textView.text length];
    self.limitLabel.text = [NSString stringWithFormat:@"%i", (int)currentLimit];
    [self.limitLabel sizeToFit];
}

#pragma mark - IngredientsKeyboardAccessoryViewController delegate method

- (void)ingredientsKeyboardAccessorySelectedValue:(NSString *)value unit:(BOOL)unit {
    [self.textView insertText:value];
    [self.textView insertText:@" "];
}

#pragma mark - Properties

- (PSPDFTextView *)textView {
    if (!_textView) {
        _textView = [self createTextView];
    }
    return _textView;
}

- (PSPDFTextView *)sandboxTextView {
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
        [self.textView becomeFirstResponder];
        [self.textView scrollToVisibleCaretAnimated:NO];
        
        // Add title/limit labels.
        self.titleLabel.alpha = 0.0;
        self.limitLabel.alpha = 0.0;
        [self.scrollView addSubview:self.titleLabel];
        [self.scrollView addSubview:self.limitLabel];
        self.scrollView.scrollEnabled = NO;
        
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

- (void)keyboardWillAppear:(BOOL)appear {
    CGRect keyboardFrame = [self currentKeyboardFrame];
    
    // Update the scrollView to be above the keyboard area.
    CKEditingTextBoxView *targetTextBoxView = [self targetEditTextBoxView];
    if (targetTextBoxView) {
        CGRect targetEditViewFrame = self.textView.frame;
        
        CGFloat labelHeight = 0;
        if ([self.titleLabel.text length] > 0) {
            labelHeight = self.titleLabel.frame.size.height;
        }
        targetEditViewFrame.origin.y = MAX(kKeyboardDefaultFrame.origin.y/2 - self.textView.frame.size.height/2, [self contentInsets].top) + labelHeight/2;

        [UIView animateWithDuration:0.2 animations:^{
            self.textView.frame = targetEditViewFrame;
            targetTextBoxView.frame = [targetTextBoxView updatedFrameForProposedEditingViewFrame:self.textView.frame];
        }];
    }
    self.scrollView.contentInset = (UIEdgeInsets) { 0.0, 0.0, keyboardFrame.size.height, 0.0 };
    
    if (appear) {
        [self updateContentSize];
        [self scrollToCursorIfRequired];
    } else {
        //Trim whitespace and newlines when dismissing keyboard to circumvent iOS7.0 UITextView crash bug
//        self.textView.text = [self.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
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

    CGFloat accessoryViewHeight = 0;
    if (self.textView.inputAccessoryView) {
        accessoryViewHeight = self.accessoryView.view.frame.size.height;
    }
    DLog("Keyboard origin: %f, accessory height: %f, min Height: %f", self.keyboardFrame.origin.y - self.textView.frame.origin.y - 10, accessoryViewHeight, minHeight);
    minHeight = MIN(minHeight, self.keyboardFrame.origin.y - self.textView.frame.origin.y - 10);
    
    // Updates the textView frame.
    CGRect textViewFrame = self.textView.frame;
    
    //For small title labels, use required Height if smaller. For large textboxes, use the min height so it fills the space above keyboard
    if (self.numLines > 5) {
        textViewFrame.size.height = minHeight;
    } else {
        textViewFrame.size.height = MIN(requiredHeight, minHeight);
    }
    
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
//    [self scrollToCursorIfRequired];
}

- (void)scrollToCursorIfRequired {
    [self.textView scrollToVisibleCaretAnimated:NO];
}

- (PSPDFTextView *)createTextView {
    PSPDFTextView *textView = [[PSPDFTextView alloc] initWithFrame:CGRectZero];
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
    textView.panGestureRecognizer.enabled = NO;
    textView.alwaysBounceVertical = YES;
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
