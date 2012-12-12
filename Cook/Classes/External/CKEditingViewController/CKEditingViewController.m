//
//  CKEditingViewController.m
//  CKEditingViewControllerDemo
//
//  Created by Jeff Tan-Ang on 10/12/12.
//  Copyright (c) 2012 Cook App Pty Ltd. All rights reserved.
//

#import "CKEditingViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface CKEditingViewController ()

@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, assign) CGRect targetEditingFrame;
@property (nonatomic, assign) BOOL saveMode;

@end

@implementation CKEditingViewController

#define kOverlayAlpha           0.7
#define kEnableFadeDuration     0.1
#define kEnableScaleDuration    0.2
#define kDisableScaleDuration   0.2
#define kDisableFadeDuration    0.1
#define kTargetMidAlpha         1.0

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (id)initWithDelegate:(id<CKEditingViewControllerDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)enableEditing:(BOOL)enable completion:(void (^)())completion {
    
    if (enable) {
        
        // Add overlay to be faded in.
        UIView *overlayView = [[UIView alloc] initWithFrame:self.view.bounds];
        overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        overlayView.backgroundColor = [UIColor blackColor];
        overlayView.alpha = 0.0;
        [self.view addSubview:overlayView];
        [self.view sendSubviewToBack:overlayView];
        self.overlayView = overlayView;
        
        // Register taps for dimiss.
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
        [overlayView addGestureRecognizer:tapGesture];
        
        // If we have a source editing view, then prepare for it to be transitioned into edit mode.
        if (self.sourceEditingView) {
            
            // Create the target editing view and remember its intended frame, then
            UIView *targetEditingView = [self createTargetEditingView];
            self.targetEditingFrame = targetEditingView.frame;
            targetEditingView.alpha = 0.0;
            [self.view addSubview:targetEditingView];
            self.targetEditingView = targetEditingView;

            // Now get the frame of the source relative to the overlay.
            CGRect relativeFrame = [self.sourceEditingView.superview convertRect:self.sourceEditingView.frame toView:self.view];
            self.targetEditingView.frame = relativeFrame;

        }
        
    } else {
        
        // Save the result.
        self.result = [self editingResult];
    }
    
    // Inform of editing appear.
    [self editingViewWillAppear:enable];
    
    // Fade overlay.
    [UIView animateWithDuration:enable ? kEnableFadeDuration + kEnableScaleDuration : kDisableScaleDuration + kDisableFadeDuration
                          delay:0.0
                        options:UIViewAnimationCurveEaseIn
                     animations:^{
                         
                         // Fade in the overlay.
                         self.overlayView.alpha = enable ? kOverlayAlpha : 0.0;
                         
                     }
                     completion:^(BOOL finished) {
                         
                         if (!enable) {
                             [self.overlayView removeFromSuperview];
                             self.overlayView = nil;
                         }
                         
                     }];
    
    if (enable) {
        
        [UIView animateWithDuration:kEnableFadeDuration
                              delay:0.0
                            options:UIViewAnimationCurveEaseIn
                         animations:^{
                             
                             // First fade in/out the source and target.
                             self.sourceEditingView.alpha = 0.0;
                             self.targetEditingView.alpha = kTargetMidAlpha;
                             
                         }
                         completion:^(BOOL finished) {
                             
                             [UIView animateWithDuration:kEnableScaleDuration
                                                   delay:0.0
                                                 options:UIViewAnimationCurveEaseIn
                                              animations:^{
                                                  
                                                  // Scale the target to its intended frame.
                                                  self.targetEditingView.frame = self.targetEditingFrame;
                                                  self.targetEditingView.alpha = 1.0;
                                                  
                                              }
                                              completion:^(BOOL finished) {
                                                  
                                                  [self editingViewDidAppear:YES];
                                                  
                                              }];
                             
                         }];
    } else {
        
        [UIView animateWithDuration:kDisableScaleDuration
                              delay:0.0
                            options:UIViewAnimationCurveEaseIn
                         animations:^{
                             
                             // Scale the target to its intended frame.
                             self.targetEditingView.frame = [self.sourceEditingView.superview convertRect:self.sourceEditingView.frame toView:self.view];
                             self.targetEditingView.alpha = kTargetMidAlpha;
                             
                         }
                         completion:^(BOOL finished) {
                             
                             [UIView animateWithDuration:kDisableFadeDuration
                                                   delay:0.0
                                                 options:UIViewAnimationCurveEaseIn
                                              animations:^{
                                                  
                                                  // Now fade return.
                                                  self.targetEditingView.alpha = 0.0;
                                                  self.sourceEditingView.alpha = 1.0;
                                                  
                                              }
                                              completion:^(BOOL finished) {
                                                  
                                                  [self editingViewDidAppear:NO];
                                                  
                                              }];
                             
                         }];
        
        
    }
    
}

- (id)editingResult {
    // Subclasses to provide the result of the editing.
    return nil;
}

- (UIView *)createTargetEditingView {
    // Subclasses to provide a target editing view to transition to.
    return nil;
}

- (UIImage *)imageForView:(UIView *)view {
    return [self imageForView:view opaque:YES];
}

- (UIImage *)imageForView:(UIView *)view opaque:(BOOL)opaque {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (UIEdgeInsets)contentEdgeInsets {
    return UIEdgeInsetsMake(20.0, 20.0, 20.0, 20.0);
}

- (void)editingViewWillAppear:(BOOL)appear {
    [self.delegate editingViewWillAppear:appear];
}

- (void)editingViewDidAppear:(BOOL)appear {
    [self.delegate editingViewDidAppear:appear];
}

- (void)editingViewKeyboardWillAppear:(BOOL)appear keyboardFrame:(CGRect)keyboardFrame {
    // Subclasses to implement.
    self.keyboardVisible = appear;
}

- (UIButton *)doneButton {
    if (_doneButton == nil) {
        _doneButton = [self buttonWithImage:[UIImage imageNamed:@"cook_customise_btns_done.png"]
                                     target:self selector:@selector(doneTapped)];
    }
    return _doneButton;
}

- (void)doneTapped {
    
    self.saveMode = YES;
    
    // If keyboard was visible, dismiss it first.
    if (self.keyboardVisible) {
        [self.view endEditing:YES];
        return;
    }
    
    // Perform save
    [self performSave];
}

- (void)performSave {
    self.saveMode = NO;
    [self enableEditing:NO completion:NULL];
}

- (UIButton *)buttonWithImage:(UIImage *)image target:(id)target selector:(SEL)selector {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    [button setFrame:CGRectMake(0.0, 0.0, image.size.width, image.size.height)];
    button.userInteractionEnabled = (target != nil && selector != nil);
    button.autoresizingMask = UIViewAutoresizingNone;
    return button;
}

#pragma mark - Private methods

- (void)tapped:(UITapGestureRecognizer *)tapGesture {
    
    // If keyboard was visible, dismiss it first.
    if (self.keyboardVisible) {
        [self.view endEditing:YES];
        return;
    }

    [self enableEditing:NO completion:NULL];
}

- (void)keyboardShow:(NSNotification *)notification {
    CGRect keyboardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [self editingViewKeyboardWillAppear:YES keyboardFrame:keyboardFrame];
}

- (void)keyboardHide:(NSNotification *)notification {
    CGRect keyboardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [self editingViewKeyboardWillAppear:NO keyboardFrame:keyboardFrame];
    
    if (self.saveMode) {
        [self performSave];
    }
}

@end
