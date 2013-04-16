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

- (id)initWithEditView:(UIView *)editView delegate:(id<CKEditViewControllerDelegate>)delegate editingHelper:(CKEditingViewHelper *)editingHelper white:(BOOL)white title:(NSString *)title {
    if (self = [super initWithEditView:editView delegate:delegate editingHelper:editingHelper white:white title:title]) {
        self.fontSize = 30.0;
    }
    return self;
}

- (UIView *)createTargetEditView {
    NSString *text = [self currentTextValue];
    CGFloat width = 800.0;
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectZero];
    textView.font = [UIFont systemFontOfSize:self.fontSize];
    textView.textColor = [self editingTextColour];
    textView.backgroundColor = [UIColor clearColor];
    textView.textAlignment = NSTextAlignmentLeft;
    textView.delegate = self;
    textView.scrollEnabled = NO;
    textView.text = [self currentTextValue];
    textView.text = @"Facebook director of product Adam Mosseri revealed to Bloomberg on Monday that talks were underway with both Apple and Microsoft, saying the social network titan is looking to expand the reach of its newest initiative to other smartphone platforms.";
    [textView sizeToFit];
    textView.frame = CGRectMake(floorf((self.view.bounds.size.width - width) / 2.0),
                                100.0,
                                width,
                                220.0);
    self.textView = textView;
    
    // Register pan on the textView.
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
    panGesture.delegate = self;
    [textView addGestureRecognizer:panGesture];

    
    return textView;
}

- (NSString *)updatedTextValue {
    return self.textView.text;
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}

#pragma mark - UITextViewDelegate methods

- (void)textViewDidChange:(UITextView *)textView {
    NSLog(@"");
    
    CGRect textViewFrame = self.textView.frame;
    
    // Set the textview frame as large as its contentSize height.
    textViewFrame.size.height = self.textView.contentSize.height;
    self.textView.frame = textViewFrame;
    
    // Update the textbox view for textView and change mockedTextBoxView to match.
    [self.editingHelper updateEditingView:self.textView animated:NO];
    CKEditingTextBoxView *targetTextBoxView = [self targetEditTextBoxView];
    CKEditingTextBoxView *mockedTextBoxView = [self mockedEditTextBoxView];
    mockedTextBoxView.frame = targetTextBoxView.frame;
}

#pragma mark - Lifecycle events

- (void)targetTextEditingViewWillAppear:(BOOL)appear {
    [super targetTextEditingViewWillAppear:appear];
    
    if (!appear) {
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

@end
