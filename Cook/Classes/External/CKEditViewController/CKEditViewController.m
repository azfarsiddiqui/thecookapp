//
//  CKEditViewController.m
//  CKEditViewControllerDemo
//
//  Created by Jeff Tan-Ang on 12/04/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKEditViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface CKEditViewController () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *editView;
@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, assign) UIEdgeInsets contentInsets;

@property (nonatomic, strong) UIColor *editingViewBackgroundOriginalColour;

@end

@implementation CKEditViewController

#define kOverlayAlpha   0.7

- (id)initWithEditView:(UIView *)editView {
    return [self initWithEditView:editView contentInsets:UIEdgeInsetsMake(20.0, 20.0, 20.0, 20.0)];
}

- (id)initWithEditView:(UIView *)editView contentInsets:(UIEdgeInsets)contentInsets {
    if (self = [super init]) {
        self.editView = editView;
        self.editingViewBackgroundOriginalColour = editView.backgroundColor;
        self.editingBackgroundColour = [UIColor whiteColor];
        self.contentInsets = contentInsets;
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
        
        // Capture the editing view as a mock image on the editing view. Editing view needs to be opaque.
        self.editView.backgroundColor = self.editingBackgroundColour;
        CGRect editingViewFrame = [rootView convertRect:self.editView.frame fromView:self.editView.superview];
        UIImage *editViewImage = [self screenshotView:self.editView];
        UIImageView *editingViewImageView = [[UIImageView alloc] initWithImage:editViewImage];
        editingViewImageView.frame = editingViewFrame;
        [self.view addSubview:editingViewImageView];
        
        [UIView animateWithDuration:0.3
                              delay:0.1
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             overlayView.alpha = kOverlayAlpha;
                         }
                         completion:^(BOOL finished) {
                         }];
    } else {
        
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             
                             // Restore the background colour the editing view.
                             self.editView.backgroundColor = self.editingViewBackgroundOriginalColour;
                             
                             self.overlayView.alpha = 0.0;
                         }
                         completion:^(BOOL finished) {
                             
                             [self.view removeFromSuperview];
                         }];
    }
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}

#pragma mark - Private methods.

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
    [self performEditing:NO];
}

@end
