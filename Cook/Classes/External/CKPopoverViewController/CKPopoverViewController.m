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
@property (nonatomic, assign) CKPopoverViewControllerDirection direction;
@property (nonatomic, assign) CGPoint anchorOffset;
@property (nonatomic, assign) id<CKPopoverViewControllerDelegate> delegate;
@property (nonatomic, strong) UIView *popoverContainerView;
@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) UIView *parentView;

@end

@implementation CKPopoverViewController

#define kOverlayViewAlpha           0.5
#define kOverlayViewFadeInDuration  0.3
#define kOverlayViewFadeOutDuration 0.3
#define kPopoverFadeInDuration      0.2
#define kPopoverFadeInDelay         0.0
#define kPopoverFadeOutDuration     0.2
#define kPopoverFadeOutDelay        0.0
#define kPopoverShiftOffset         10.0

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
    self.direction = direction;
    self.parentView = view;
    self.view.frame = self.parentView.bounds;
    [self.parentView addSubview:self.view];
    
    // Inform delegate that we're about to appear and schedule overlayView to come in 0.1s in.
    [self.delegate popoverViewController:self willAppear:YES];
    
    // Prepare contentView within the popover.
    UIEdgeInsets contentInsets = [self contentInsetsForDirection:direction];
    UIView *contentView = self.contentViewController.view;
    UIImageView *popoverContainerView = [[UIImageView alloc] initWithImage:[self popoverBackgroundImageForDirection:direction]];
    popoverContainerView.backgroundColor = [UIColor clearColor];
    popoverContainerView.userInteractionEnabled = YES;
    popoverContainerView.frame = [self popoverContainerFrameForDirection:direction point:point];
    contentView.frame = CGRectMake(contentInsets.left,
                                   contentInsets.top,
                                   contentView.frame.size.width,
                                   contentView.frame.size.height);
    [popoverContainerView addSubview:contentView];
    popoverContainerView.transform = [self popoverContainerTransformForDirection:direction show:NO];
    popoverContainerView.alpha = 0.0;
    [self.view addSubview:popoverContainerView];
    self.popoverContainerView = popoverContainerView;
    
    [UIView animateWithDuration:kPopoverFadeInDuration
                          delay:kPopoverFadeInDelay
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         [self showOverlay:YES animated:NO];
                         popoverContainerView.transform = [self popoverContainerTransformForDirection:direction show:YES];
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
    
    [UIView animateWithDuration:kPopoverFadeOutDuration
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         [self showOverlay:NO animated:NO];
                         self.popoverContainerView.transform = [self popoverContainerTransformForDirection:self.direction show:NO];
                         self.popoverContainerView.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         
                         // Remove from superview.
                         [self.view removeFromSuperview];
                         [self.delegate popoverViewController:self didAppear:NO];
                     }];
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGPoint tapPoint = [touch locationInView:self.view];
    UIEdgeInsets insets = [self popoverBackgroundImageInsetsForDirection:self.direction];
    CGRect popoverFrame = (CGRect){
        self.popoverContainerView.frame.origin.x + insets.left,
        self.popoverContainerView.frame.origin.y + insets.top,
        self.popoverContainerView.frame.size.width - insets.left - insets.right,
        self.popoverContainerView.frame.size.height - insets.top - insets.bottom
    };
    
    return !CGRectContainsPoint(popoverFrame, tapPoint);
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

- (void)showOverlay:(BOOL)show animated:(BOOL)animated {
    
    if (show) {
        UIView *overlayView = [[UIView alloc] initWithFrame:self.view.bounds];
        overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        overlayView.backgroundColor = [UIColor blackColor];
        overlayView.alpha = 0.0;
        [self.view insertSubview:overlayView belowSubview:self.popoverContainerView];
        self.overlayView = overlayView;
    }
    
    if (animated) {
        [UIView animateWithDuration:show ? kOverlayViewFadeInDuration : kOverlayViewFadeOutDuration
                              delay:0.0
                            options:show ? UIViewAnimationOptionCurveEaseOut : UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.overlayView.alpha = show ? kOverlayViewAlpha : 0.0;
                         }
                         completion:^(BOOL finished) {
                             if (!show) {
                                 [self.overlayView removeFromSuperview];
                                 self.overlayView = nil;
                             }
                         }];
    } else {
        if (show) {
            self.overlayView.alpha = kOverlayViewAlpha;
        } else {
            [self.overlayView removeFromSuperview];
            self.overlayView = nil;
        }
    }
}



- (void)overlayTapped:(UITapGestureRecognizer *)tapGesture {
    [self hide];
}

// TODO for Bottom and Right directions.
- (UIImage *)popoverBackgroundImageForDirection:(CKPopoverViewControllerDirection)direction {
    UIImage *popoverImage = nil;
    switch (direction) {
        case CKPopoverViewControllerTop:
            popoverImage = [[UIImage imageNamed:@"cook_popover_social_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(43.0, 0.0, 43.0, 0.0)];
            break;
        case CKPopoverViewControllerLeft:
        case CKPopoverViewControllerBottom:
        case CKPopoverViewControllerRight:
        default:
            popoverImage = [[UIImage imageNamed:@"cook_popover_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(80.0, 45.0, 80.0, 45.0)];
            break;
    }
    return popoverImage;
}

- (UIEdgeInsets)popoverBackgroundImageInsetsForDirection:(CKPopoverViewControllerDirection)direction {
    UIEdgeInsets insets = UIEdgeInsetsZero;
    
    switch (direction) {
        case CKPopoverViewControllerTop:
            insets = (UIEdgeInsets){ 39.0, 27.0, 39.0, 27.0 };
            break;
        case CKPopoverViewControllerLeft:
            insets = (UIEdgeInsets){ 28.0, 41.0, 40.0, 41.0 };
            break;
        case CKPopoverViewControllerBottom:
        case CKPopoverViewControllerRight:
        default:
            break;
    }
    
    return insets;
}

- (CGRect)popoverContainerFrameForDirection:(CKPopoverViewControllerDirection)direction
                                      point:(CGPoint)point {
    CGPoint anchorPoint = [self anchorPointForDirection:direction];
    UIEdgeInsets contentInsets = [self contentInsetsForDirection:direction];
    UIView *contentView = self.contentViewController.view;
    CGRect frame = CGRectZero;
    switch (direction) {
        case CKPopoverViewControllerTop:
            frame = CGRectMake(point.x - floorf((contentInsets.left + contentView.frame.size.width + contentInsets.right) / 2.0) - anchorPoint.x,
                               point.y - anchorPoint.y,
                               contentInsets.left + contentView.frame.size.width + contentInsets.right,
                               contentInsets.top + contentView.frame.size.height + contentInsets.bottom);
            break;
        case CKPopoverViewControllerLeft:
            frame = CGRectMake(point.x - anchorPoint.x,
                               point.y - anchorPoint.y,
                               contentInsets.left + contentView.frame.size.width + contentInsets.right,
                               contentInsets.top + contentView.frame.size.height + contentInsets.bottom);
            break;
        case CKPopoverViewControllerBottom:
            break;
        case CKPopoverViewControllerRight:
            break;
        default:
            break;
    }
    return frame;
}

- (UIEdgeInsets)contentInsetsForDirection:(CKPopoverViewControllerDirection)direction {
    UIEdgeInsets insets = UIEdgeInsetsZero;
    switch (direction) {
        case CKPopoverViewControllerTop:
            insets = UIEdgeInsetsMake(46.0, 56.0, 59.0, 56.0);
        case CKPopoverViewControllerLeft:
            insets = UIEdgeInsetsMake(46.0, 56.0, 59.0, 56.0);
            break;
        case CKPopoverViewControllerBottom:
        case CKPopoverViewControllerRight:
        default:
            break;
    }
    return insets;
}

- (CGPoint)anchorPointForDirection:(CKPopoverViewControllerDirection)direction {
    CGPoint anchorPoint = CGPointZero;
    switch (direction) {
        case CKPopoverViewControllerTop:
            anchorPoint = CGPointMake(-2.0, 30.0);
            break;
        case CKPopoverViewControllerLeft:
            anchorPoint = CGPointMake(24.0, 58.0);
            break;
        case CKPopoverViewControllerBottom:
        case CKPopoverViewControllerRight:
        default:
            break;
    }
    return anchorPoint;
}

- (CGAffineTransform)popoverContainerTransformForDirection:(CKPopoverViewControllerDirection)direction show:(BOOL)show {
    CGAffineTransform transform = CGAffineTransformIdentity;
    if (show) {
        return transform;
    }
    
    switch (direction) {
        case CKPopoverViewControllerTop:
            transform = CGAffineTransformMakeTranslation(0.0, -kPopoverShiftOffset);
            break;
        case CKPopoverViewControllerLeft:
            transform = CGAffineTransformMakeTranslation(-kPopoverShiftOffset, 00.0);
            break;
        case CKPopoverViewControllerBottom:
        case CKPopoverViewControllerRight:
        default:
            break;
    }
    
    return transform;
}

@end
