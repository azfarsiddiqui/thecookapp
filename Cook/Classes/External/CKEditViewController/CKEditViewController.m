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

@interface CKEditViewController () <UIGestureRecognizerDelegate, CKEditingTextBoxViewDelegate>

@property (nonatomic, strong) UIView *mockedEditView;
@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) UIColor *editingViewBackgroundOriginalColour;
@property (nonatomic, assign) CGRect startTextBoxFrame;
@property (nonatomic, assign) CGRect keyboardFrame;

@end

@implementation CKEditViewController

#define kOverlayAlpha   0.8

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
        self.editingViewBackgroundOriginalColour = editView.backgroundColor;
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
}

- (void)performEditing:(BOOL)editing {
    if (editing) {
        
        // Attach to the rootView for fullscreen mode.
        UIView *rootView = [self rootView];
        self.view.frame = rootView.bounds;
        [rootView addSubview:self.view];
        
        // Overlay.
        [self initOverlay];
        
        // Wrap up 
        [self mockAndWrapOriginalEditingView];
        
        // Get original textbox to fade out.
        CKEditingTextBoxView *originalTextBoxView = [self sourceEditTextBoxView];
        
        // Get mocked textbox to be scaled up.
        CKEditingTextBoxView *mockedTextBoxView = [self mockedEditTextBoxView];
        
        // Remember the start frame for the textbox so that we can transition back.
        self.startTextBoxFrame = mockedTextBoxView.frame;
        
        // Also hide it too.
        self.sourceEditView.hidden = YES;
        
        // Lifecycle start event.
        [self targetTextEditingViewWillAppear:YES];
        
        // Create target editing view.
        UIView *targetEditView = [self createTargetEditView];
        
        // Animate into fullscreen edit mode.
        [UIView animateWithDuration:0.2
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             
                             // Fade out mocked editing field and box.
                             self.mockedEditView.alpha = 0.0;
                             originalTextBoxView.alpha = 0.0;
                             
                             // Hide the pencil icon.
                             [mockedTextBoxView showEditingIcon:NO animated:NO];
                         }
                         completion:^(BOOL finished) {
                             
                             targetEditView.alpha = 0.0;
                             [self.view addSubview:targetEditView];
                             self.targetEditView = targetEditView;
                             
                             // Lifecycle event to inform of creation/adding of target editing view.
                             [self targetTextEditingViewDidCreated];
                             
                             // Wrap target textField textbox.
                             [self wrapTargetEditView:targetEditView delegate:self];
                             CKEditingTextBoxView *targetTextBoxView = [self.editingHelper textBoxViewForEditingView:targetEditView];
                             [targetTextBoxView showEditingIcon:NO animated:NO];
                             targetTextBoxView.hidden = YES;
                             
                             // Animate into fullscreen edit mode.
                             [UIView animateWithDuration:0.15
                                                   delay:0.0
                                                 options:UIViewAnimationOptionCurveEaseIn
                                              animations:^{
                                                  
                                                  // Bring in the overlay.
                                                  self.overlayView.alpha = kOverlayAlpha;
                                                  
                                                  // Move the original textbox to the target textbox
                                                  mockedTextBoxView.frame = targetTextBoxView.frame;
                                                  
                                              }
                                              completion:^(BOOL finished) {
                                                  
                                                  // Show target textbox view.
                                                  targetTextBoxView.hidden = NO;
                                                  
                                                  // Hide mocked textbox view.
                                                  mockedTextBoxView.hidden = YES;
                                                  
                                                  [UIView animateWithDuration:0.2
                                                                        delay:0.0
                                                                      options:UIViewAnimationOptionCurveEaseIn
                                                                   animations:^{
                                                                       
                                                                       // Fade in target editing view.
                                                                       targetEditView.alpha = 1.0;
                                                                       
                                                                       // Show the save icon.
                                                                       if ([self showSaveIcon]) {
                                                                           [targetTextBoxView showSaveIcon:YES animated:NO];
                                                                       }
                                                   
                                                                   }
                                                                   completion:^(BOOL finished) {
                                                                       
                                                                       // Lifecycle event.
                                                                       [self targetTextEditingViewDidAppear:YES];
                                                                       
                                                                   }];
                                              }];
                         }];
    } else {
        
        // Target textbox to hide.
        CKEditingTextBoxView *targetTextBoxView = [self targetEditTextBoxView];

        // Get mocked textbox to scale back.
        CKEditingTextBoxView *mockedTextBoxView = [self mockedEditTextBoxView];
        mockedTextBoxView.hidden = NO;
        
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
                             targetTextBoxView.alpha = 0.0;
                             
                         }
                         completion:^(BOOL finished) {
                             
                             targetTextBoxView.hidden = YES;
                             
                             [UIView animateWithDuration:0.2
                                                   delay:0.0
                                                 options:UIViewAnimationOptionCurveEaseIn
                                              animations:^{
                                                  
                                                  // Resize the original textbox back to its original frame.
                                                  mockedTextBoxView.frame = self.startTextBoxFrame;
                                                  
                                              }
                                              completion:^(BOOL finished) {
                                                  
                                                  // Restore the background colour the editing view.
                                                  self.sourceEditView.hidden = NO;
                                                  self.sourceEditView.alpha = 1.0;
                                                  self.sourceEditView.backgroundColor = self.editingViewBackgroundOriginalColour;
                                                  
                                                  [UIView animateWithDuration:0.2
                                                                        delay:0.0
                                                                      options:UIViewAnimationOptionCurveEaseIn
                                                                   animations:^{
                                                                       
                                                                       // Show pencil.
                                                                       [mockedTextBoxView showEditingIcon:YES animated:NO];
                                                                       
                                                                       // Fade in the mocked edit view.
                                                                       self.mockedEditView.alpha = 1.0;
                                                                       
                                                                       // Show the original box
                                                                       originalTextBoxView.alpha = 1.0;
                                                                       
                                                                   }
                                                                   completion:^(BOOL finished) {
                                                                       
                                                                       // Fade out the overlay.
                                                                       [UIView animateWithDuration:0.3
                                                                                             delay:0.0
                                                                                           options:UIViewAnimationOptionCurveEaseOut
                                                                                        animations:^{
                                                                                            
                                                                                            // Fade out the overlay view.
                                                                                            self.overlayView.alpha = 0.0;
                                                                                            
                                                                                        }
                                                                                        completion:^(BOOL finished) {
                                                                                            
                                                                                            // Hide mocked text view.
                                                                                            mockedTextBoxView.hidden = YES;
                                                                                            
                                                                                            // Clean up editing helper.
                                                                                            [self.editingHelper unwrapEditingView:self.mockedEditView];
                                                                                            [self.editingHelper unwrapEditingView:self.targetEditView];
                                                                                            
                                                                                            // Remove myself from the parent.
                                                                                            [self.view removeFromSuperview];
                                                                                            
                                                                                            // Lifecycle end event.
                                                                                            [self targetTextEditingViewDidAppear:NO];
                                                                                            
                                                                                        }];
                                                                       
                                                                       
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
    return self.white ? [UIColor whiteColor] : [UIColor colorWithHexString:@"363839"];
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

- (CKEditingTextBoxView *)mockedEditTextBoxView {
    return [self.editingHelper textBoxViewForEditingView:self.mockedEditView];
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

- (void)keyboardWillAppear:(BOOL)appear {
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

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (self.dismissableOverlay) {
        return YES;
    } else {
        return NO;
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
    
    // Tell original editingView to update with new value.
    [self.delegate editViewControllerUpdateEditView:self.sourceEditView value:[self updatedValue]];
    
    // Remove current mock and its wrapper.
    [self.editingHelper unwrapEditingView:self.mockedEditView];
    [self.mockedEditView removeFromSuperview];
    self.mockedEditView = nil;
    
    // Recreate mock and corresponding textbox.
    self.sourceEditView.hidden = NO;
    [self mockAndWrapOriginalEditingView];
    
    // Get mocked textbox and prepare for transition.
    CKEditingTextBoxView *mockedTextBoxView = [self mockedEditTextBoxView];
    
    // Get current targetTextbox to obtain its current frame.
    CKEditingTextBoxView *targetTextBoxView = [self targetEditTextBoxView];
    
    // Remember the start frame for the textbox so that we can transition back.
    self.startTextBoxFrame = mockedTextBoxView.frame;

    // Prepare for transitions back.
    self.mockedEditView.alpha = 0.0;
    self.sourceEditView.alpha = 0.0;
    mockedTextBoxView.frame = targetTextBoxView.frame;
    
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
        _titleLabel.font = [UIFont boldSystemFontOfSize:30.0];
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
    UIView *overlayView = [[UIView alloc] initWithFrame:self.view.bounds];
    overlayView.backgroundColor = [self editingOverlayColour];
    overlayView.alpha = 0.0;
    [self.view addSubview:overlayView];
    self.overlayView = overlayView;
    
    // Register tap on overlay.
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(overlayTapped:)];
    tapGesture.delegate = self;
    [overlayView addGestureRecognizer:tapGesture];
}

- (UIImage *)screenshotView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (UIView *)rootView {
    return [UIApplication sharedApplication].keyWindow.rootViewController.view;
}

- (void)overlayTapped:(UITapGestureRecognizer *)tapGesture {
    [self dismissEditView];
}

- (void)mockAndWrapOriginalEditingView {
    UIView *rootView = [self rootView];
    
    // Get original textbox view to obtain its contentInsets.
    CKEditingTextBoxView *originalTextBoxView = [self sourceEditTextBoxView];
    
    // Capture the editing view as a mock image on the editing view. Editing view needs to be opaque.
    self.sourceEditView.backgroundColor = [self editingBackgroundColour];
    
    // Wrap up the mock edit view in a textbox.
    CGRect editingViewFrame = [rootView convertRect:self.sourceEditView.frame fromView:self.sourceEditView.superview];
    UIImage *editViewImage = [self screenshotView:self.sourceEditView];
    UIImageView *mockedEditView = [[UIImageView alloc] initWithImage:editViewImage];
    mockedEditView.userInteractionEnabled = YES;
    mockedEditView.frame = editingViewFrame;
    [self.view addSubview:mockedEditView];
    self.mockedEditView = mockedEditView;

    // Wrap textField textbox.
    [self.editingHelper wrapEditingView:mockedEditView contentInsets:originalTextBoxView.contentInsets
                                  white:self.white animated:NO];
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

@end
