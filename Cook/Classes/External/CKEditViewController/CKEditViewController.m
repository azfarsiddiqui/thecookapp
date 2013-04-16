//
//  CKEditViewController.m
//  CKEditViewControllerDemo
//
//  Created by Jeff Tan-Ang on 12/04/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKEditViewController.h"
#import "CKEditingViewHelper.h"
#import "CKEditingTextBoxView.h"
#import "UIColor+Expanded.h"
#import <QuartzCore/QuartzCore.h>

@interface CKEditViewController () <UIGestureRecognizerDelegate, CKEditingTextBoxViewDelegate>

@property (nonatomic, strong) UIView *mockedEditView;
@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, assign) id<CKEditViewControllerDelegate> delegate;
@property (nonatomic, strong) UIColor *editingViewBackgroundOriginalColour;
@property (nonatomic, assign) CGRect startTextBoxFrame;
@property (nonatomic, assign) BOOL white;

@end

@implementation CKEditViewController

#define kOverlayAlpha   0.5

- (id)initWithEditView:(UIView *)editView delegate:(id<CKEditViewControllerDelegate>)delegate
         editingHelper:(CKEditingViewHelper *)editingHelper white:(BOOL)white {
    if (self = [super init]) {
        self.originalEditView = editView;
        self.editingHelper = editingHelper;
        self.delegate = delegate;
        self.white = white;
        self.editingViewBackgroundOriginalColour = editView.backgroundColor;
        self.dismissableOverlay = YES;
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
        CKEditingTextBoxView *originalTextBoxView = [self.editingHelper textBoxViewForEditingView:self.originalEditView];
        
        // Get mocked textbox to be scaled up.
        CKEditingTextBoxView *mockedTextBoxView = [self.editingHelper textBoxViewForEditingView:self.mockedEditView];
        
        // Remember the start frame for the textbox so that we can transition back.
        self.startTextBoxFrame = mockedTextBoxView.frame;
        
        // Also hide it too.
        self.originalEditView.hidden = YES;
        
        // Lifecycle start event.
        [self targetTextEditingViewWillAppear:YES];
        
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
                             
                             // Create target editing view.
                             UIView *targetEditView = [self createTargetEditView];
                             targetEditView.alpha = 0.0;
                             [self.view addSubview:targetEditView];
                             self.targetEditView = targetEditView;
                             
                             // Wrap target textField textbox.
                             [self.editingHelper wrapEditingView:targetEditView delegate:self white:self.white animated:NO];
                             CKEditingTextBoxView *targetTextBoxView = [self.editingHelper textBoxViewForEditingView:targetEditView];
                             [targetTextBoxView showEditingIcon:NO animated:NO];
                             targetTextBoxView.hidden = YES;
                             
                             // Animate into fullscreen edit mode.
                             [UIView animateWithDuration:0.2
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
                                                                       [targetTextBoxView showSaveIcon:YES animated:NO];
                                                                       
                                                                   }
                                                                   completion:^(BOOL finished) {
                                                                       
                                                                       // Lifecycle event.
                                                                       [self targetTextEditingViewDidAppear:YES];
                                                                       
                                                                   }];
                                              }];
                         }];
    } else {
        
        // Target textbox to hide.
        CKEditingTextBoxView *targetTextBoxView = [self.editingHelper textBoxViewForEditingView:self.targetEditView];

        // Get mocked textbox to scale back.
        CKEditingTextBoxView *mockedTextBoxView = [self.editingHelper textBoxViewForEditingView:self.mockedEditView];
        mockedTextBoxView.hidden = NO;
        
        // Get original textbox to fade in.
        CKEditingTextBoxView *originalTextBoxView = [self.editingHelper textBoxViewForEditingView:self.originalEditView];
        
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
                             
                             [UIView animateWithDuration:0.3
                                                   delay:0.0
                                                 options:UIViewAnimationOptionCurveEaseOut
                                              animations:^{
                                                  
                                                  // Resize the original textbox back to its original frame.
                                                  mockedTextBoxView.frame = self.startTextBoxFrame;
                                                  
                                              }
                                              completion:^(BOOL finished) {
                                                  
                                                  // Restore the background colour the editing view.
                                                  self.originalEditView.hidden = NO;
                                                  self.originalEditView.alpha = 1.0;
                                                  self.originalEditView.backgroundColor = self.editingViewBackgroundOriginalColour;
                                                  
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
    if ([self.originalEditView isKindOfClass:[UILabel class]]) {
        textValue = ((UILabel *)self.originalEditView).text;
    }
    return textValue;
}

- (NSString *)updatedTextValue {
    NSString *textValue = nil;
    if ([self.targetEditView isKindOfClass:[UITextField class]]) {
        textValue = ((UITextField *)self.targetEditView).text;
    }
    return textValue;
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

#pragma mark - Lifecycle events

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

#pragma mark - System Notification events

- (void)keyboardWillShow:(NSNotification *)notification {
    CGRect keyboardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [self targetEditingViewKeyboardWillAppear:YES keyboardFrame:keyboardFrame];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    CGRect keyboardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [self targetEditingViewKeyboardWillAppear:NO keyboardFrame:keyboardFrame];
}

#pragma mark - CKEditingTextBoxViewDelegate methods

// Note that editingView is actually the targetEditingView (e.g.UITextField)
- (void)editingTextBoxViewSaveTappedForEditingView:(UIView *)editingView {
    
    // Tell original editingView to update with new value.
    [self.delegate editViewControllerUpdateEditView:self.originalEditView value:[self updatedTextValue]];
    
    // Remove current mock and its wrapper.
    [self.editingHelper unwrapEditingView:self.mockedEditView];
    [self.mockedEditView removeFromSuperview];
    self.mockedEditView = nil;
    
    // Recreate mock and corresponding textbox.
    self.originalEditView.hidden = NO;
    [self mockAndWrapOriginalEditingView];
    
    // Get mocked textbox and prepare for transition.
    CKEditingTextBoxView *mockedTextBoxView = [self.editingHelper textBoxViewForEditingView:self.mockedEditView];
    
    // Get current targetTextbox to obtain its current frame.
    CKEditingTextBoxView *targetTextBoxView = [self.editingHelper textBoxViewForEditingView:self.targetEditView];
    
    // Remember the start frame for the textbox so that we can transition back.
    self.startTextBoxFrame = mockedTextBoxView.frame;

    // Prepare for transitions back.
    self.mockedEditView.alpha = 0.0;
    self.originalEditView.alpha = 0.0;
    mockedTextBoxView.frame = targetTextBoxView.frame;
    
    // Transition back.
    [self performEditing:NO];
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
    [self.delegate editViewControllerDismissRequested];
}

- (void)mockAndWrapOriginalEditingView {
    UIView *rootView = [self rootView];
    
    // Get original textbox view to obtain its contentInsets.
    CKEditingTextBoxView *originalTextBoxView = [self.editingHelper textBoxViewForEditingView:self.originalEditView];
    
    // Capture the editing view as a mock image on the editing view. Editing view needs to be opaque.
    self.originalEditView.backgroundColor = [self editingBackgroundColour];
    
    // Wrap up the mock edit view in a textbox.
    CGRect editingViewFrame = [rootView convertRect:self.originalEditView.frame fromView:self.originalEditView.superview];
    UIImage *editViewImage = [self screenshotView:self.originalEditView];
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
}

@end
