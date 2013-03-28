//
//  CKPopoverViewController.m
//  CKPopoverViewController
//
//  Created by Jeff Tan-Ang on 28/03/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKPopoverViewController.h"

@interface CKPopoverViewController () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIViewController *contentViewController;
@property (nonatomic, assign) CGPoint anchorOffset;
@property (nonatomic, assign) id<CKPopoverViewControllerDelegate> delegate;
@property (nonatomic, strong) UIView *popoverContainerView;
@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) UIView *parentView;

@end

@implementation CKPopoverViewController

#define kOverlayViewAlpha           0.5
#define kOverlayViewFadeInDuration  0.2
#define kOverlayViewFadeOutDuration 0.2
#define kPopoverFadeInDuration      0.3
#define kPopoverFadeInDelay         0.0
#define kPopoverFadeOutDuration     0.3
#define kPopoverFadeOutDelay        0.0

- (id)initWithContentViewController:(UIViewController *)contentViewController
                           delegate:(id<CKPopoverViewControllerDelegate>)delegate {
    return [self initWithContentViewController:contentViewController anchorOffset:CGPointZero delegate:delegate];
}

- (id)initWithContentViewController:(UIViewController *)contentViewController anchorOffset:(CGPoint)anchorOffset
                           delegate:(id<CKPopoverViewControllerDelegate>)delegate {
    if (self = [super init]) {
        self.contentViewController = contentViewController;
        self.anchorOffset = anchorOffset;
        self.delegate = delegate;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
}

- (void)showInView:(UIView *)view direction:(CKPopoverViewControllerDirection)direction atPoint:(CGPoint)point {
    self.parentView = view;
    self.view.frame = self.parentView.bounds;
    [self.parentView addSubview:self.view];
    
    // Inform delegate that we're about to appear and schedule overlayView to come in 0.1s in.
    [self.delegate popoverViewController:self willAppear:YES];
    [self showOverlay:YES delay:0.1 completion:^{}];
    
    // Prepare contentView within the popover.
    UIEdgeInsets contentInsets = [self contentInsetsForDirection:direction];
    CGPoint anchorPoint = [self anchorPointForDirection:direction];
    UIView *contentView = self.contentViewController.view;
    UIImageView *popoverContainerView = [[UIImageView alloc] initWithImage:[self popoverBackgroundImageForDirection:direction]];
    popoverContainerView.userInteractionEnabled = YES;
    popoverContainerView.frame = CGRectMake(point.x - anchorPoint.x,
                                            point.y - anchorPoint.y,
                                            contentInsets.left + contentView.frame.size.width + contentInsets.right,
                                            contentInsets.top + contentView.frame.size.height + contentInsets.bottom);
    contentView.frame = CGRectMake(contentInsets.left, contentInsets.top, contentView.frame.size.width, contentView.frame.size.height);
    [popoverContainerView addSubview:contentView];
    //popoverContainerView.alpha = 0.0;
    [self.view addSubview:popoverContainerView];
    self.popoverContainerView = popoverContainerView;
    
    [UIView animateWithDuration:kPopoverFadeInDuration
                          delay:kPopoverFadeInDelay
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         popoverContainerView.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                         [self.delegate popoverViewController:self didAppear:YES];
                     }];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(overlayTapped:)];
    tapGesture.delegate = self;
    [self.view addGestureRecognizer:tapGesture];
}

- (void)hide {
    
    [self showOverlay:NO delay:0.0 completion:^{
        
        // Remove from superview.
        [self.view removeFromSuperview];
        [self.delegate popoverViewController:self didAppear:NO];
        
    }];
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGPoint tapPoint = [touch locationInView:self.view];
    return !CGRectContainsPoint(self.contentViewController.view.frame, tapPoint);
}

#pragma mark - Private methods

- (void)showOverlay:(BOOL)show {
    [self showOverlay:show delay:0.0 completion:^{}];
}

- (void)showOverlay:(BOOL)show delay:(NSTimeInterval)delay completion:(void (^)())completion {
    if (show) {
        UIView *overlayView = [[UIView alloc] initWithFrame:self.view.bounds];
        overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        overlayView.backgroundColor = [UIColor blackColor];
        overlayView.alpha = 0.0;
        [self.view addSubview:overlayView];
        self.overlayView = overlayView;
    }
    
    [UIView animateWithDuration:show ? kOverlayViewFadeInDuration : kOverlayViewFadeOutDuration
                          delay:delay
                        options:show ? UIViewAnimationOptionCurveEaseOut : UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.overlayView.alpha = show ? kOverlayViewAlpha : 0.0;
                     }
                     completion:^(BOOL finished) {
                         if (!show) {
                             [self.overlayView removeFromSuperview];
                             self.overlayView = nil;
                         }
                         completion();
                     }];
}

- (void)overlayTapped:(UITapGestureRecognizer *)tapGesture {
    [self hide];
}

// TODO for Top, Bottom and Right directions.
- (UIImage *)popoverBackgroundImageForDirection:(CKPopoverViewControllerDirection)direction {
    UIImage *popoverImage = nil;
    switch (direction) {
        case CKPopoverViewControllerTop:
        case CKPopoverViewControllerLeft:
        case CKPopoverViewControllerBottom:
        case CKPopoverViewControllerRight:
        default:
            popoverImage = [[UIImage imageNamed:@"cook_popover_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(80.0, 45.0, 80.0, 45.0)];
            break;
    }
    return popoverImage;
}

- (UIEdgeInsets)contentInsetsForDirection:(CKPopoverViewControllerDirection)direction {
    UIEdgeInsets insets = UIEdgeInsetsZero;
    switch (direction) {
        case CKPopoverViewControllerTop:
        case CKPopoverViewControllerLeft:
        case CKPopoverViewControllerBottom:
        case CKPopoverViewControllerRight:
        default:
            insets = UIEdgeInsetsMake(46.0, 56.0, 59.0, 56.0);
            break;
    }
    return insets;
}

- (CGPoint)anchorPointForDirection:(CKPopoverViewControllerDirection)direction {
    CGPoint anchorPoint = CGPointZero;
    switch (direction) {
        case CKPopoverViewControllerTop:
        case CKPopoverViewControllerLeft:
        case CKPopoverViewControllerBottom:
        case CKPopoverViewControllerRight:
        default:
            anchorPoint = CGPointMake(24.0, 58.0);
            break;
    }
    return anchorPoint;
}

@end
