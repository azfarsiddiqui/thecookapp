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
@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation CKTextViewEditViewController

#define kTextViewMinHeight 232.0

- (id)initWithEditView:(UIView *)editView delegate:(id<CKEditViewControllerDelegate>)delegate editingHelper:(CKEditingViewHelper *)editingHelper white:(BOOL)white title:(NSString *)title {
    if (self = [super initWithEditView:editView delegate:delegate editingHelper:editingHelper white:white title:title]) {
        self.fontSize = 30.0;
    }
    return self;
}

- (UIView *)createTargetEditView {
    UIEdgeInsets contentInsets = [self contentInsets];
    CGFloat width = 800.0;
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectZero];
    textView.font = [UIFont systemFontOfSize:self.fontSize];
    textView.textColor = [self editingTextColour];
    textView.backgroundColor = [UIColor clearColor];
    textView.textAlignment = NSTextAlignmentLeft;
    textView.delegate = self;
    textView.scrollEnabled = NO;
    textView.text = [self currentTextValue];
    textView.frame = CGRectMake(floorf((self.view.bounds.size.width - width) / 2.0),
                                contentInsets.top,
                                width,
                                kTextViewMinHeight);
    self.textView = textView;
    
    // Set contentSize to be same as bounds.
    textView.contentSize = textView.bounds.size;
    
    // Set the textview frame as large as its contentSize height.
    CGRect textViewFrame = self.textView.frame;
    textViewFrame.size.height = self.textView.contentSize.height;
    self.textView.frame = textViewFrame;
    
    // Register pan on the textView.
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
    panGesture.delegate = self;
    [textView addGestureRecognizer:panGesture];

    return textView;
}

- (NSString *)updatedTextValue {
    return self.textView.text;
}

- (UIEdgeInsets)contentInsets {
    return UIEdgeInsetsMake(93.0, 20.0, 50.0, 20.0);
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}

#pragma mark - UITextViewDelegate methods

- (void)textViewDidChange:(UITextView *)textView {
    [self updateContentSize];
}

#pragma mark - Lifecycle events

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
        [self.view addSubview:self.titleLabel];
        
        // Fade the labels in.
        [UIView animateWithDuration:0.1
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.titleLabel.alpha = 1.0;
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
//        [self panSnapIfRequired];
    }
    
    [panGesture setTranslation:CGPointZero inView:self.view];
}

- (void)panWithTranslation:(CGPoint)translation {
    CGFloat dragRatio = 0.5;
    CGFloat panOffset = ceilf(translation.y * dragRatio);
    
    CKEditingTextBoxView *targetTextBoxView = [self targetEditTextBoxView];
    CKEditingTextBoxView *mockedTextBoxView = [self mockedEditTextBoxView];
    CGRect titleFrame = self.titleLabel.frame;
    CGRect textBoxFrame = targetTextBoxView.frame;
    CGRect mockedTextBoxFrame = mockedTextBoxView.frame;
    CGRect contentFrame = self.textView.frame;
    
    // Move everything together: title + textbox + textview + mocked textbox view (to be transitioned back).
    titleFrame.origin.y += panOffset;
    textBoxFrame.origin.y += panOffset;
    mockedTextBoxFrame.origin.y += panOffset;
    contentFrame.origin.y += panOffset;
    self.titleLabel.frame = titleFrame;
    targetTextBoxView.frame = textBoxFrame;
    mockedTextBoxView.frame = mockedTextBoxFrame;
    self.textView.frame = contentFrame;
}

- (void)updateContentSize {
    
    CKEditingTextBoxView *targetTextBoxView = [self targetEditTextBoxView];
    CKEditingTextBoxView *mockedTextBoxView = [self mockedEditTextBoxView];
    
    // Various frames to update.
    CGRect textViewFrame = self.textView.frame;
    
    // Set the textview frame as large as its contentSize height.
    textViewFrame.size.height =  self.textView.contentSize.height;
    textViewFrame.size.height = (textViewFrame.size.height < kTextViewMinHeight) ? kTextViewMinHeight : textViewFrame.size.height;
    
    // Work out the no-go area for the textbox.
    UIEdgeInsets contentInsets = [self contentInsets];
    CGRect keyboardFrame = [self currentKeyboardFrame];
    CGRect noGoFrame = keyboardFrame;
    noGoFrame.origin.y -= contentInsets.bottom;
    noGoFrame.size.height += contentInsets.bottom;
    
    // Adjust positioning.
    CGRect proposedTargetTextBoxFrame = [targetTextBoxView updatedFrameForProposedEditingViewFrame:textViewFrame];
    
    // Flush to the bottom of the visible area.
    proposedTargetTextBoxFrame.origin.y = noGoFrame.origin.y - proposedTargetTextBoxFrame.size.height;
    textViewFrame.origin.y = proposedTargetTextBoxFrame.origin.y + targetTextBoxView.contentInsets.top;

    // Animate frame around to fit content.
    [UIView animateWithDuration:0.1
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         
                         self.textView.frame = textViewFrame;
                         targetTextBoxView.frame = proposedTargetTextBoxFrame;
                         mockedTextBoxView.frame = proposedTargetTextBoxFrame;

                         [self updateTitleLabel];
                         
                     }
                     completion:^(BOOL finished) {
                     }];
    
    NSLog(@"TEXTVIEW FRAME %@", NSStringFromCGRect(textViewFrame));
    NSLog(@"TEXTBOX  FRAME %@", NSStringFromCGRect(proposedTargetTextBoxFrame));
}

@end
