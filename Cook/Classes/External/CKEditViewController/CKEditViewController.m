//
//  CKEditViewController.m
//  CKEditViewControllerDemo
//
//  Created by Jeff Tan-Ang on 12/04/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKEditViewController.h"
#import "CKEditingViewHelper.h"
#import "UIColor+Expanded.h"
#import <QuartzCore/QuartzCore.h>

@interface CKEditViewController () <UIGestureRecognizerDelegate, UIScrollViewDelegate, CKEditingTextBoxViewDelegate>

@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, assign) CGRect startTextBoxSourceFrame;
@property (nonatomic, assign) CGRect startTextBoxFullScreenFrame;
@property (nonatomic, assign) CGRect keyboardFrame;
@property (nonatomic, assign) BOOL animating;

@end

@implementation CKEditViewController

#define kOverlayAlpha   0.7

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (id)initWithEditView:(UIView *)editView delegate:(id<CKEditViewControllerDelegate>)delegate
         editingHelper:(CKEditingViewHelper *)editingHelper white:(BOOL)white {
    return [self initWithEditView:editView delegate:delegate editingHelper:editingHelper white:white title:nil];
}

- (id)initWithEditView:(UIView *)editView delegate:(id<CKEditViewControllerDelegate>)delegate
         editingHelper:(CKEditingViewHelper *)editingHelper white:(BOOL)white title:(NSString *)title {
    
    if (self = [super init]) {
        self.sourceEditView = editView;
        self.editingHelper = editingHelper;
        self.delegate = delegate;
        self.white = white;
        self.editTitle = title;
        self.dismissableOverlay = YES;
        self.keyboardFrame = CGRectZero;
        
        // Register for keyboard events.
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardDidHideNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    // Attach a scrollView for edit content to be scrollable.
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    scrollView.backgroundColor = [UIColor clearColor];
    scrollView.alwaysBounceVertical = YES;
    scrollView.alwaysBounceHorizontal = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    scrollView.delegate = self;
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;
}

- (void)performEditing:(BOOL)editing {
    
    // Ignore if animation in progress.
    if (self.animating) {
        return;
    }
    self.animating = YES;
    
    if (editing) {
        
        // Attach to the rootView for fullscreen mode.
        UIView *rootView = [self rootView];
        self.view.frame = rootView.bounds;
        [rootView addSubview:self.view];
        
        // Overlay.
        [self initOverlay];
        
        // Get original textbox and remember its frame on the source's parent.
        CKEditingTextBoxView *originalTextBoxView = [self sourceEditTextBoxView];
        self.startTextBoxSourceFrame = originalTextBoxView.frame;
        
        // Get the originalTextBoxView's frame relative to the fullscreen view.
        CGRect sourceOnFullScreenFrame = [originalTextBoxView.superview convertRect:originalTextBoxView.frame toView:self.view];
        self.startTextBoxFullScreenFrame = sourceOnFullScreenFrame;
        
        // Lifecycle start event.
        [self targetTextEditingViewWillAppear:YES];
        
        // Create target editing view.
        UIView *targetEditView = [self createTargetEditView];
        
        // Animate into fullscreen edit mode.
        [UIView animateWithDuration:0.2
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             
                             // Fade out source editing view.
                             self.sourceEditView.alpha = 0.0;
                             
                         }
                         completion:^(BOOL finished) {
                             
                             // Lift the originalTextBox from its superview and place it on the editing fullscreen view.
                             [originalTextBoxView removeFromSuperview];
                             originalTextBoxView.frame = sourceOnFullScreenFrame;
                             [self.scrollView addSubview:originalTextBoxView];
                             
                             // Hide the source view.
                             self.sourceEditView.hidden = YES;
                             
                             // Prepare the target view on fullscreen mode.
                             targetEditView.alpha = 0.0;
                             [self.scrollView addSubview:targetEditView];
                             self.targetEditView = targetEditView;
                             
                             // Lifecycle event to inform of creation/adding of target editing view.
                             [self targetTextEditingViewDidCreated];
                             
                             // Wrap and prepare the target field textbox.
                             [self wrapTargetEditView:targetEditView delegate:self];
                             CKEditingTextBoxView *targetTextBoxView = [self.editingHelper textBoxViewForEditingView:targetEditView];
                             targetTextBoxView.hidden = YES;
                             
                             // Animate into fullscreen edit mode.
                             [UIView animateWithDuration:[self transitionDurationBetweenFrame:originalTextBoxView.frame
                                                                                 anotherFrame:targetTextBoxView.frame]
                                                   delay:0.0
                                                 options:UIViewAnimationOptionCurveEaseOut
                                              animations:^{
                                                  
                                                  // Bring in the overlay.
                                                  self.overlayView.alpha = kOverlayAlpha;
                                                  
                                                  // Move the original textbox to the target textbox
                                                  originalTextBoxView.frame = targetTextBoxView.frame;
                                                  
                                              }
                                              completion:^(BOOL finished) {
                                                  
                                                  // Swap visibility of target with original.
                                                  originalTextBoxView.hidden = YES;
                                                  targetTextBoxView.hidden = NO;
                                                  
                                                  [UIView animateWithDuration:0.2
                                                                        delay:0.0
                                                                      options:UIViewAnimationOptionCurveEaseIn
                                                                   animations:^{
                                                                       
                                                                       // Fade in target editing view.
                                                                       targetEditView.alpha = 1.0;
                                                                       
                                                                       if (!self.white) {
                                                                           [targetTextBoxView setTextBoxViewWithEdit:NO];
                                                                       }
                                                                       
                                                                       // Show the save icon.
                                                                       if ([self showSaveIcon]) {
                                                                           [targetTextBoxView showSaveIcon:YES animated:NO];
                                                                       }
                                                   
                                                                   }
                                                                   completion:^(BOOL finished) {
                                                                       
                                                                       // Lifecycle event.
                                                                       [self targetTextEditingViewDidAppear:YES];
                                                                       
                                                                       // Mark end of animation.
                                                                       self.animating = NO;
                                                                       
                                                                   }];
                                              }];
                         }];
    } else {
        
        // Target textbox to hide.
        CKEditingTextBoxView *targetTextBoxView = [self targetEditTextBoxView];

        // Get original textbox to fade in.
        CKEditingTextBoxView *originalTextBoxView = [self sourceEditTextBoxView];
        
        // Lifecycle start event.
        [self targetTextEditingViewWillAppear:NO];
        
        [UIView animateWithDuration:0.2
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             
                             // Fade out the target editing view.
                             self.targetEditView.alpha = 0.0;
                             
                         }
                         completion:^(BOOL finished) {
                             
                             // Swap visibility of target with original.
                             targetTextBoxView.hidden = YES;
                             originalTextBoxView.hidden = NO;
                             
                             [UIView animateWithDuration:[self transitionDurationBetweenFrame:originalTextBoxView.frame
                                                                                 anotherFrame:self.startTextBoxFullScreenFrame]
                                                   delay:0.0
                                                 options:UIViewAnimationOptionCurveEaseOut
                                              animations:^{
                                                  
                                                  // Fade out the overlay.
                                                  self.overlayView.alpha = 0.0;
                                                  
                                                  // Resize the original textbox back to its original frame.
                                                  originalTextBoxView.frame = self.startTextBoxFullScreenFrame;
                                                  
                                              }
                                              completion:^(BOOL finished) {
                                                  
                                                  // Now re-attach the originalTextBoxView to the source view's parent.
                                                  [originalTextBoxView removeFromSuperview];
                                                  originalTextBoxView.frame = self.startTextBoxSourceFrame;
                                                  [self.sourceEditView.superview insertSubview:originalTextBoxView belowSubview:self.sourceEditView];
                                                  
                                                  // Prepare source edit view to be faded in.
                                                  self.sourceEditView.hidden = NO;
                                                  self.sourceEditView.alpha = 0.0;
                                                  
                                                  [UIView animateWithDuration:0.3
                                                                        delay:0.0
                                                                      options:UIViewAnimationOptionCurveEaseIn
                                                                   animations:^{
                                                                       
                                                                       self.sourceEditView.alpha = 1.0;
                                                                       
                                                                   }
                                                                   completion:^(BOOL finished) {
                                                                       
                                                                       // Clean up editing helper.
                                                                       [self.editingHelper unwrapEditingView:self.targetEditView];
                                                                        
                                                                       // Remove myself from the parent.
                                                                       [self.view removeFromSuperview];
                                                                        
                                                                       // Lifecycle end event.
                                                                       [self targetTextEditingViewDidAppear:NO];
                                                                       
                                                                       // Mark end of animation.
                                                                       self.animating = NO;
                                                                       
                                                                   }];
                                                  
                                              }];
                         }];
    }
}

// Subclasses to implement.
- (UIView *)createTargetEditView {
    return nil;
}

- (NSString *)currentTextValue {
    NSString *textValue = nil;
    if ([self.sourceEditView isKindOfClass:[UILabel class]]) {
        textValue = ((UILabel *)self.sourceEditView).text;
    } else if ([self.sourceEditView isKindOfClass:[UITextView class]]) {
        textValue = ((UITextView *)self.sourceEditView).text;
    }
    return textValue;
}

- (id)updatedValue {
    return nil;
}

- (UIColor *)editingTextColour {
    return self.white ? [UIColor blackColor] : [UIColor whiteColor];
}

- (UIColor *)editingBackgroundColour {
    return [UIColor clearColor];
    // return self.white ? [UIColor whiteColor] : [UIColor colorWithHexString:@"363839"];
}

- (UIColor *)editingOverlayColour {
//    return self.white ? [UIColor blackColor] : [UIColor whiteColor];
    return [UIColor blackColor];
}

- (UIColor *)titleColour {
//    return self.white ? [UIColor whiteColor] : [UIColor blackColor];
    return [UIColor whiteColor];
}

- (UIEdgeInsets)contentInsets {
    return UIEdgeInsetsMake(110.0, 20.0, 110.0, 20.0);
}

- (CKEditingTextBoxView *)sourceEditTextBoxView {
    return [self.editingHelper textBoxViewForEditingView:self.sourceEditView];
}

- (CKEditingTextBoxView *)targetEditTextBoxView {
    return [self.editingHelper textBoxViewForEditingView:self.targetEditView];
}

- (CGRect)currentVisibleFrame {
    return (CGRect) {
        self.view.bounds.origin.x,
        self.view.bounds.origin.y,
        self.view.bounds.size.width,
        self.view.bounds.size.height - [self currentKeyboardFrame].size.height
    };
}

- (CGRect)currentKeyboardFrame {
    return self.keyboardFrame;
}

- (CGRect)defaultKeyboardFrame {
    return CGRectMake(self.view.bounds.origin.x, 396.0, self.view.bounds.size.width, 352.0);
}

- (void)updateInfoLabels {
    CKEditingTextBoxView *targetTextBoxView = [self targetEditTextBoxView];
    self.titleLabel.frame = CGRectMake(self.titleLabel.frame.origin.x,
                                       targetTextBoxView.frame.origin.y - self.titleLabel.frame.size.height + 5.0,
                                       self.titleLabel.frame.size.width,
                                       self.titleLabel.frame.size.height);
}

- (void)wrapTargetEditView:(UIView *)targetEditView delegate:(id<CKEditingTextBoxViewDelegate>)delegate {
    [self.editingHelper wrapEditingView:targetEditView delegate:delegate white:self.white animated:NO];
}

- (BOOL)showTitleLabel {
    return YES;
}

- (BOOL)showSaveIcon {
    return YES;
}

- (void)dismissEditView {
    [self.delegate editViewControllerDismissRequested];
}

- (UIFont *)textFontWithSize:(CGFloat)size {
    return [self.font fontWithSize:size];
}

#pragma mark - Lifecycle events

- (void)targetTextEditingViewDidCreated {
    if ([self.delegate respondsToSelector:@selector(editViewControllerDidCreated)]) {
        [self.delegate editViewControllerDidCreated];
    }
}

- (void)targetTextEditingViewWillAppear:(BOOL)appear {
    [self.delegate editViewControllerWillAppear:appear];
}

- (void)targetTextEditingViewDidAppear:(BOOL)appear {
    [self.delegate editViewControllerDidAppear:appear];
}

- (void)keyboardWillAppear:(BOOL)appear {
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (self.dismissableOverlay) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.scrollView) {
        
        // Track the black overlay.
        self.overlayView.frame = (CGRect){
            self.scrollView.contentOffset.x,
            self.scrollView.contentOffset.y - floorf(self.scrollView.bounds.size.width / 2.0),
            self.overlayView.frame.size.width,
            self.overlayView.frame.size.height
        };
        
    }
}

#pragma mark - Keyboard events

- (void)keyboardWillShow:(NSNotification *)notification {
    CGRect windowKeyboardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [self targetEditingViewKeyboardWillAppear:YES keyboardFrame:[self convertedKeyboardFrame:windowKeyboardFrame]];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    CGRect windowKeyboardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [self targetEditingViewKeyboardWillAppear:NO keyboardFrame:[self convertedKeyboardFrame:windowKeyboardFrame]];
}

#pragma mark - CKEditingTextBoxViewDelegate methods

// Note that editingView is actually the targetEditingView (e.g.UITextField)
- (void)editingTextBoxViewSaveTappedForEditingView:(UIView *)editingView {
    
    CKEditingTextBoxView *originalTextBoxView = [self sourceEditTextBoxView];
    CKEditingTextBoxView *targetTextBoxView = [self targetEditTextBoxView];
    
    // Re-attach to source parentView to update its wrapping.
    [originalTextBoxView removeFromSuperview];
    originalTextBoxView.frame = self.startTextBoxSourceFrame;
    [self.sourceEditView.superview insertSubview:originalTextBoxView belowSubview:self.sourceEditView];
    
    // Tell original editingView to update with new value.
    [self.delegate editViewControllerUpdateEditView:self.sourceEditView value:[self updatedValue]];
    
    // Update the start textbox frame.
    self.startTextBoxSourceFrame = originalTextBoxView.frame;
    
    // Get the originalTextBoxView's frame relative to the fullscreen view.
    CGRect sourceOnFullScreenFrame = [originalTextBoxView.superview convertRect:originalTextBoxView.frame toView:self.view];
    self.startTextBoxFullScreenFrame = sourceOnFullScreenFrame;
    
    // Now re-attach to the fullscreen view.
    [originalTextBoxView removeFromSuperview];
    originalTextBoxView.frame = targetTextBoxView.frame;
    [self.view insertSubview:originalTextBoxView belowSubview:targetTextBoxView];
    
    // Ensure that source is still hidden before transitioning back.
    self.sourceEditView.hidden = YES;
    
    // Transition back.
    [self performEditing:NO];
}

#pragma mark - Lazy getters.

- (UILabel *)titleLabel {
    if (!_titleLabel && [self showTitleLabel]) {
        
        // Get a reference to the target textbox for relative positioning.
        CKEditingTextBoxView *targetTextBoxView = [self targetEditTextBoxView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.text = [self.editTitle uppercaseString];
        _titleLabel.font = [self textFontWithSize:30.0];
        _titleLabel.textColor = [self titleColour];
        [_titleLabel sizeToFit];
        _titleLabel.frame = CGRectMake(floorf((self.view.bounds.size.width - _titleLabel.frame.size.width) / 2.0),
                                       targetTextBoxView.frame.origin.y - _titleLabel.frame.size.height + 5.0,
                                       _titleLabel.frame.size.width,
                                       _titleLabel.frame.size.height);
    }
    return _titleLabel;
}

#pragma mark - Private methods.

- (void)initOverlay {
    
    // Black overlay.
    UIView *overlayView = [[UIView alloc] initWithFrame:(CGRect){
        self.scrollView.bounds.origin.x,
        self.scrollView.bounds.origin.y - floorf(self.scrollView.bounds.size.width / 2.0),
        self.scrollView.bounds.size.width,
        self.scrollView.bounds.size.height * 2.0
    }];
    overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    overlayView.backgroundColor = [self editingOverlayColour];
    overlayView.alpha = 0.0;
    [self.scrollView addSubview:overlayView];
    self.overlayView = overlayView;
    
    // Register tap on overlay.
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(overlayTapped:)];
    tapGesture.delegate = self;
    [overlayView addGestureRecognizer:tapGesture];
}

- (UIView *)rootView {
    return [UIApplication sharedApplication].keyWindow.rootViewController.view;
}

- (void)overlayTapped:(UITapGestureRecognizer *)tapGesture {
    [self dismissEditView];
}

- (void)targetEditingViewKeyboardWillAppear:(BOOL)appear keyboardFrame:(CGRect)keyboardFrame {
    self.keyboardFrame = appear ? keyboardFrame : CGRectZero;
    [self keyboardWillAppear:appear];
}

- (CGRect)convertedKeyboardFrame:(CGRect)keyboardFrame {
    // fromView:nil means convert from Window.
    CGRect convertedKeyboardFrame = [self.view convertRect:keyboardFrame fromView:nil];
    return convertedKeyboardFrame;
}

- (CGFloat)transitionDurationBetweenFrame:(CGRect)frame anotherFrame:(CGRect)anotherFrame {
    CGFloat x = ABS(frame.origin.x - anotherFrame.origin.x);
    CGFloat y = ABS(frame.origin.y - anotherFrame.origin.y);
    CGFloat h = sqrtf(powf(x, 2.0) + powf(y, 2.0));
    CGFloat duration = 0.0;
    CGFloat unitLength = 50.0;
    
    if (h < unitLength) {
        duration = 0.2;
    } else {
        duration = 0.3;
    }
    
    duration = 0.25;
    return duration;
}

@end
