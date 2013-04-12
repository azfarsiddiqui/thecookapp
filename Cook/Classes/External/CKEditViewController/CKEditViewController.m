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
#import <QuartzCore/QuartzCore.h>

@interface CKEditViewController () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *originalEditView;
@property (nonatomic, strong) UIView *mockedEditView;
@property (nonatomic, strong) UIView *targetEditView;
@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) CKEditingViewHelper *editingHelper;
@property (nonatomic, assign) id<CKEditViewControllerDelegate> delegate;
@property (nonatomic, strong) UIColor *editingViewBackgroundOriginalColour;
@property (nonatomic, assign) CGRect startTextBoxFrame;

@end

@implementation CKEditViewController

#define kOverlayAlpha   0.5

- (id)initWithEditView:(UIView *)editView delegate:(id<CKEditViewControllerDelegate>)delegate
         editingHelper:(CKEditingViewHelper *)editingHelper {
    if (self = [super init]) {
        self.originalEditView = editView;
        self.editingHelper = editingHelper;
        self.delegate = delegate;
        self.editingViewBackgroundOriginalColour = editView.backgroundColor;
        self.editingBackgroundColour = [UIColor whiteColor];
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
        
        // Capture the editing view as a mock image on the editing view. Editing view needs to be opaque.
        self.originalEditView.backgroundColor = self.editingBackgroundColour;
        CGRect editingViewFrame = [rootView convertRect:self.originalEditView.frame fromView:self.originalEditView.superview];
        UIImage *editViewImage = [self screenshotView:self.originalEditView];
        UIImageView *mockedEditView = [[UIImageView alloc] initWithImage:editViewImage];
        mockedEditView.userInteractionEnabled = YES;
        mockedEditView.frame = editingViewFrame;
        [self.view addSubview:mockedEditView];
        self.mockedEditView = mockedEditView;
        
        // Get orignal textbox to fade out.
        CKEditingTextBoxView *originalTextBoxView = [self.editingHelper textBoxViewForEditingView:self.originalEditView];
        
        // Wrap textField textbox.
        [self.editingHelper wrapEditingView:mockedEditView wrap:YES animated:NO];
        CKEditingTextBoxView *textBoxView = [self.editingHelper textBoxViewForEditingView:mockedEditView];
        
        // Remember the start frame for the textbox so that we can transition back.
        self.startTextBoxFrame = textBoxView.frame;
        
        // Animate into fullscreen edit mode.
        [UIView animateWithDuration:0.3
                              delay:0.1
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             
                             // Fade out mocked editing field and box.
                             self.mockedEditView.alpha = 0.0;
                             originalTextBoxView.alpha = 0.0;
                             
                             // Bring in the overlay.
                             self.overlayView.alpha = kOverlayAlpha;
                             
                             // Hide the pencil icon.
                             [textBoxView showEditingIcon:NO animated:NO];
                         }
                         completion:^(BOOL finished) {
                             
                             // Transition to fullscreen editView.
                             [self transitionToEditView];
                             
                         }];
    } else {
        
        // Target textbox to hide.
        CKEditingTextBoxView *targetTextBoxView = [self.editingHelper textBoxViewForEditingView:self.targetEditView];
        targetTextBoxView.hidden = YES;

        // Get mocked textbox to scale back.
        CKEditingTextBoxView *mockedTextBoxView = [self.editingHelper textBoxViewForEditingView:self.mockedEditView];
        mockedTextBoxView.hidden = NO;
        
        // Get original textbox to fade in.
        CKEditingTextBoxView *originalTextBoxView = [self.editingHelper textBoxViewForEditingView:self.originalEditView];
        
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             
                             // Resize the original textbox back to its original frame.
                             mockedTextBoxView.frame = self.startTextBoxFrame;
                             
                             // Fade out the overlay view.
                             self.overlayView.alpha = 0.0;
                             
                         }
                         completion:^(BOOL finished) {
                             
                             // Restore the background colour the editing view.
                             self.originalEditView.backgroundColor = self.editingViewBackgroundOriginalColour;
                             
                             [UIView animateWithDuration:0.2
                                                   delay:0.0
                                                 options:UIViewAnimationOptionCurveLinear
                                              animations:^{
                                                  
                                                  // Fade mock out.
                                                  mockedTextBoxView.alpha = 0.0;
                                                  
                                                  // Fade original in.
                                                  originalTextBoxView.alpha = 1.0;
                                                  
                                              }
                                              completion:^(BOOL finished) {
                                                  
                                                  mockedTextBoxView.hidden = YES;
                                                  
                                                  // Clean up editing helper.
                                                  [self.editingHelper wrapEditingView:self.mockedEditView wrap:NO animated:NO];
                                                  [self.editingHelper wrapEditingView:self.targetEditView wrap:NO animated:NO];
                                                  
                                                  // Remove myself from the parent.
                                                  [self.view removeFromSuperview];
                                                  
                                                  // Inform delegate.
                                                  [self.delegate editViewControllerDidAppear:NO];
                                                  
                                              }];
                             
                         }];
    }
}

// Subclasses to implement.
- (UIView *)createTargetEditView {
    return nil;
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}

#pragma mark - Private methods.

- (void)initOverlay {
    
    // Black overlay.
    UIView *overlayView = [[UIView alloc] initWithFrame:self.view.bounds];
    overlayView.backgroundColor = [UIColor blackColor];
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

- (void)transitionToEditView {
    
    // Original textBoxView.
    CKEditingTextBoxView *originalTextBoxView = [self.editingHelper textBoxViewForEditingView:self.mockedEditView];
    
    // Create target editing view.
    UIView *targetEditView = [self createTargetEditView];
    targetEditView.hidden = YES;
    [self.view addSubview:targetEditView];
    self.targetEditView = targetEditView;

    // Wrap target textField textbox.
    [self.editingHelper wrapEditingView:targetEditView wrap:YES animated:NO];
    CKEditingTextBoxView *targetTextBoxView = [self.editingHelper textBoxViewForEditingView:targetEditView];
    [targetTextBoxView showEditingIcon:NO animated:NO];
    targetTextBoxView.hidden = YES;
    
    // Animate into fullscreen edit mode.
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         
                         // Move the original textbox to the target textbox
                         originalTextBoxView.frame = targetTextBoxView.frame;
                         
                     }
                     completion:^(BOOL finished) {
                         
                         // Hide original textbox view.
                         targetTextBoxView.hidden = NO;
                         originalTextBoxView.hidden = YES;
                         
                     }];
}

@end
