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
@property (nonatomic, assign) BOOL animating;

// Headless support.
@property (nonatomic, assign) NSNumber *headlessNumber;
@property (nonatomic, assign) UIOffset headlessTransformOffset;

// To remember the existing text tint colours.
@property (nonatomic, strong) UIColor *appTextInputColour;

@end

@implementation CKEditViewController

#define kOverlayAlpha   0.7
#define kHeadlessScale  0.9

- (void)dealloc {
    
    // Restore app tint colour.
    [CKEditingViewHelper setTextInputTintColour:self.appTextInputColour];
    
    // Unsubscribe from keyboard.
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
        
        // Text input tint colour.
        self.appTextInputColour = [CKEditingViewHelper existingAppTextInputColour];
        
        if (self.white) {
            
            // White background uses our blue as caret colour.
            [CKEditingViewHelper setTextInputTintColour:[UIColor colorWithHexString:@"56b7f0"]];
            
        } else {
            
            // Dark background uses the white caret colour.
            [CKEditingViewHelper setTextInputTintColour:[UIColor whiteColor]];
        }
        
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
    [self performEditing:editing headless:[self.headlessNumber boolValue] transformOffset:self.headlessTransformOffset];
}

- (void)performEditing:(BOOL)editing headless:(BOOL)headless transformOffset:(UIOffset)transformOffset {
    
    // Headless editing or, editingView scaling required.
    if (headless) {
        self.headlessNumber = @YES;
        self.headlessTransformOffset = transformOffset;
        [self doHeadlessEditing:editing];
    } else {
        [self doStandardEditing:editing];
    }
    
}

// Subclasses to implement.
- (UIView *)createTargetEditView {
    return nil;
}

- (NSString *)currentTextValue {
    NSString *textValue = nil;
    
    if ([self.delegate respondsToSelector:@selector(editViewControllerInitialValueForEditView:)]) {
        textValue = [self.delegate editViewControllerInitialValueForEditView:self.sourceEditView];
    } else {
        if ([self.sourceEditView isKindOfClass:[UILabel class]]) {
            textValue = ((UILabel *)self.sourceEditView).text;
        } else if ([self.sourceEditView isKindOfClass:[UITextField class]]) {
            textValue = ((UITextField *)self.sourceEditView).text;
        } else if ([self.sourceEditView isKindOfClass:[UITextView class]]) {
            textValue = ((UITextView *)self.sourceEditView).text;
        }
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
    UIOffset titleOffset = [self titleOffsetAdjustments];
    CKEditingTextBoxView *targetTextBoxView = [self targetEditTextBoxView];
    self.titleLabel.text = [self.titleLabel.text uppercaseString];
    [self.titleLabel sizeToFit];
    self.titleLabel.frame = (CGRect){
        floorf((self.view.bounds.size.width - self.titleLabel.frame.size.width) / 2.0) + titleOffset.horizontal,
        targetTextBoxView.frame.origin.y - self.titleLabel.frame.size.height + titleOffset.vertical,
        self.titleLabel.frame.size.width,
        self.titleLabel.frame.size.height
    };
}

- (void)wrapTargetEditView:(UIView *)targetEditView delegate:(id<CKEditingTextBoxViewDelegate>)delegate {
    [self.editingHelper wrapEditingView:targetEditView delegate:delegate white:self.white animated:NO];
}

- (void)wrapTargetEditView:(UIView *)targetEditView editMode:(BOOL)editMode delegate:(id<CKEditingTextBoxViewDelegate>)delegate {
    [self.editingHelper wrapEditingView:targetEditView delegate:delegate white:self.white editMode:editMode animated:NO];
}

- (BOOL)showTitleLabel {
    return self.showTitle;
}

- (BOOL)showSaveIcon {
    return YES;
}

- (BOOL)headless {
    return [self.headlessNumber boolValue];
}

- (void)dismissEditView {
    [self.delegate editViewControllerDismissRequested];
}

- (UIFont *)titleFont {
    return [self.font fontWithSize:30.0];
}

- (UIOffset)titleOffsetAdjustments {
    return (UIOffset) { 0.0, 5.0 };
}

- (void)updateTitle:(NSString *)title {
    [self updateTitle:title toast:NO];
}

- (void)updateTitle:(NSString *)title toast:(BOOL)toast {
    self.titleLabel.text = title;
    [self updateInfoLabels];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        self.titleLabel.text = self.editTitle;
        [self updateInfoLabels];
    });

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
    [self doSave];
}

#pragma mark - Lazy getters.

- (UILabel *)titleLabel {
    if (!_titleLabel && [self showTitleLabel]) {
        
        // Get a reference to the target textbox for relative positioning.
        CKEditingTextBoxView *targetTextBoxView = [self targetEditTextBoxView];
        
        UIOffset titleOffset = [self titleOffsetAdjustments];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.text = [self.editTitle uppercaseString];
        _titleLabel.font = [self titleFont];
        _titleLabel.textColor = [self titleColour];
        [_titleLabel sizeToFit];
        _titleLabel.frame = CGRectMake(floorf((self.view.bounds.size.width - _titleLabel.frame.size.width) / 2.0) + titleOffset.horizontal,
                                       targetTextBoxView.frame.origin.y - _titleLabel.frame.size.height + titleOffset.vertical,
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
    if (self.dismissableOverlay && CGRectEqualToRect(self.keyboardFrame, CGRectZero)) {
        [self dismissEditView];
    }
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

- (void)doSave {
    BOOL canSave = YES;
    if ([self.delegate respondsToSelector:@selector(editViewControllerCanSaveFor:)]) {
        canSave = [self.delegate editViewControllerCanSaveFor:self];
    }
    
    // Return if cannot save.
    if (!canSave) {
        return;
    }
    
    if ([self.headlessNumber boolValue]) {
        
        if ([self.delegate respondsToSelector:@selector(editViewControllerHeadlessUpdatedWithValue:)]) {
            [self.delegate editViewControllerHeadlessUpdatedWithValue:[self updatedValue]];
        }
        
    } else {
        
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
        
    }
    
    // Transition back.
    [self performEditing:NO];
}

- (void)doStandardEditing:(BOOL)editing {
    
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
                             originalTextBoxView.iconImageView.alpha = 0.0;
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
                                                  
                                                  // Fade in the save icon.
                                                  if ([self showSaveIcon]) {
                                                      [originalTextBoxView showSaveIcon:YES animated:NO];
                                                  }
                                                  
                                                  // Bring in the overlay.
                                                  self.overlayView.alpha = kOverlayAlpha;
                                                  
                                                  // Move the original textbox to the target textbox
                                                  originalTextBoxView.frame = targetTextBoxView.frame;
                                                  
                                              }
                                              completion:^(BOOL finished) {
                                                  
                                                  // Show the save icon.
                                                  if ([self showSaveIcon]) {
                                                      [targetTextBoxView showSaveIcon:YES animated:NO];
                                                  }
                                                  
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
                                                  
                                                  // Fade in the save icon.
                                                  if ([self showSaveIcon]) {
                                                      [originalTextBoxView showSaveIcon:NO animated:NO];
                                                  }
                                                  
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
                                                                       originalTextBoxView.iconImageView.alpha = 1.0;
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

- (void)doHeadlessEditing:(BOOL)editing {
    
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
        
        // Lifecycle start event.
        [self targetTextEditingViewWillAppear:YES];
        
        // Create target editing view.
        UIView *targetEditView = [self createTargetEditView];
        
        // Prepare the target view on fullscreen mode.
        targetEditView.alpha = 0.0;
        [self.scrollView addSubview:targetEditView];
        self.targetEditView = targetEditView;
        
        // Wrap and prepare the target field textbox.
        [self wrapTargetEditView:targetEditView editMode:NO delegate:self];
        CKEditingTextBoxView *targetTextBoxView = [self.editingHelper textBoxViewForEditingView:targetEditView];
        targetTextBoxView.alpha = 0.0;
        
        // Lifecycle event to inform of creation/adding of target editing view.
        [self targetTextEditingViewDidCreated];
        
        // Start transform.
        CGAffineTransform scaleTransform = CGAffineTransformMakeScale(kHeadlessScale, kHeadlessScale);
        CGAffineTransform translateTransform = CGAffineTransformMakeTranslation(self.headlessTransformOffset.horizontal,
                                                                                self.headlessTransformOffset.vertical);
        CGAffineTransform transform = CGAffineTransformConcat(scaleTransform, translateTransform);
        targetEditView.transform = transform;
        targetTextBoxView.transform = transform;
        
        // Animate into fullscreen edit mode.
        [UIView animateWithDuration:0.25
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             
                             // Scale up.
                             targetEditView.transform = CGAffineTransformIdentity;
                             targetTextBoxView.transform = CGAffineTransformIdentity;
                             
                             // Fade in target editing view.
                             targetEditView.alpha = 1.0;
                             targetTextBoxView.alpha = 1.0;
                             
                             if (!self.white) {
                                 [targetTextBoxView setTextBoxViewWithEdit:NO];
                             }
                             
                             // Bring in the overlay.
                             self.overlayView.alpha = kOverlayAlpha;
                             
                         }
                         completion:^(BOOL finished) {
                             
                             // Show the save icon.
                             if ([self showSaveIcon]) {
                                 [targetTextBoxView showSaveIcon:YES animated:YES];
                             }
                             
                             // Lifecycle event.
                             [self targetTextEditingViewDidAppear:YES];
                             
                             // Mark end of animation.
                             self.animating = NO;
                             
                         }];
    } else {
        
        // Lifecycle start event.
        [self targetTextEditingViewWillAppear:NO];
        
        // Stop transform.
        CGAffineTransform scaleTransform = CGAffineTransformMakeScale(kHeadlessScale, kHeadlessScale);
        CGAffineTransform translateTransform = CGAffineTransformMakeTranslation(self.headlessTransformOffset.horizontal,
                                                                                self.headlessTransformOffset.vertical);
        CGAffineTransform transform = CGAffineTransformConcat(scaleTransform, translateTransform);
        
        // Get a reference on the targetTextBoxView for closing animation.
        CKEditingTextBoxView *targetTextBoxView = [self.editingHelper textBoxViewForEditingView:self.targetEditView];
        
        [UIView animateWithDuration:0.2
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             
                             // Transform the views.
                             self.targetEditView.transform = transform;
                             targetTextBoxView.transform = transform;
                             
                             // Fade out the target editing view.
                             self.targetEditView.alpha = 0.0;
                             targetTextBoxView.alpha = 0.0;
                             self.overlayView.alpha = 0.0;
                             
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
                             self.headlessNumber = nil;
                         }];
    }
}

@end
