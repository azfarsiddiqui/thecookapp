//
//  CKModalView.m
//  Cook
//
//  Created by Jeff Tan-Ang on 27/09/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKModalView.h"

@interface CKModalView ()

@property (nonatomic, assign) id<CKModalViewContentDelegate> delegate;
@property (nonatomic, strong) UIViewController *contentViewController;
@property (nonatomic, strong) UIView *backgroundOverlay;
@property (nonatomic, assign) CGSize contentSize;
@property (nonatomic, assign) BOOL animating;

- (void)backgroundTapped:(UITapGestureRecognizer *)tapGesture;

@end

@implementation CKModalView

#define kModalViewTag      170

+ (CKModalView *)modalViewInView:(UIView *)view; {
    CKModalView *modalView = nil;
    UIView *targetView = [view viewWithTag:kModalViewTag];
    if (targetView && [targetView isKindOfClass:[CKModalView class]]) {
        modalView = (CKModalView *)modalView;
    }
    return modalView;
}

- (id)initWithViewController:(UIViewController *)contentViewController delegate:(id<CKModalViewContentDelegate>)delegate
                        size:(CGSize)contentSize {

    if (self = [super init]) {
        self.contentViewController = contentViewController;
        self.contentSize = contentSize;
        self.backgroundColor = [UIColor clearColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    }
    return self;
}

- (void)showInView:(UIView *)view {
    [self showAlertInView:view];
}

- (void)showInView:(UIView *)view animation:(CKModalViewShowAnimation)showAnimation {
    [self showAlertInView:view animation:showAnimation];
}

- (void)hide {
    [self hide:CKModalViewHideAnimationDown];
}

- (void)hide:(CKModalViewHideAnimation)animation {
    [self hide:animation completion:^{}];
}

- (void)hide:(CKModalViewHideAnimation)animation completion:(void (^)())completion {
    if (self.animating) {
        return;
    }
    
    if (CKModalViewHideAnimationNone == animation) {
        
        self.animating = NO;
        self.contentViewController = nil;
        [self.delegate modalViewDidHide];
        [self removeFromSuperview];
        completion();
        
    } else {
        
        self.animating = YES;
        UIView *contentView = self.contentViewController.view;
        
        // Slide out the contentView
        [UIView animateWithDuration:0.4
                              delay:0.0
                            options:UIViewAnimationCurveEaseIn
                         animations:^{
                             
                             // Combine identity and hideTransform so that it could scale evenly when keyboard is up.
                             contentView.transform = CGAffineTransformConcat(contentView.transform,
                                                                             [self hideTransformFor:animation]);
                             
                             // Set the alpha accordingly.
                             contentView.alpha = [self hideAlphaFor:animation];
                             self.backgroundOverlay.alpha = 0.0;
                         }
                         completion:^(BOOL finished) {
                             self.animating = NO;
                             self.contentViewController = nil;
                             [self.delegate modalViewDidHide];
                             [self removeFromSuperview];
                             completion();
                         }];
        
    }
}

#pragma mark - Private methods

- (void)backgroundTapped:(UITapGestureRecognizer *)tapGesture {
    [self hide];
}

- (CGAffineTransform)hideTransformFor:(CKModalViewHideAnimation)animation {
    CGAffineTransform transform = CGAffineTransformIdentity;
    switch (animation) {
        case CKModalViewHideAnimationDown:
            transform = CGAffineTransformMakeTranslation(0.0, self.superview.bounds.size.height);
            break;
        case CKModalViewHideAnimationFadeAndScale:
            transform = CGAffineTransformMakeScale(0.90, 0.90);
            break;
        case CKModalViewHideAnimationNone:
            transform = CGAffineTransformIdentity;
            break;
        default:
            transform = CGAffineTransformIdentity;
            break;
    }
    return transform;
}

- (CGFloat)hideAlphaFor:(CKModalViewHideAnimation)animation {
    CGFloat alpha = 1.0;
    switch (animation) {
        case CKModalViewHideAnimationDown:
            alpha = 1.0;
            break;
        case CKModalViewHideAnimationFadeAndScale:
            alpha = 0.0;
            break;
        case CKModalViewHideAnimationNone:
            alpha = 0.0;
            break;
        default:
            alpha = 0.0;
            break;
    }
    return alpha;
}

- (CGAffineTransform)showTransformFor:(CKModalViewShowAnimation)animation {
    CGAffineTransform transform = CGAffineTransformIdentity;
    switch (animation) {
        case CKModalViewShowAnimationUp:
            transform = CGAffineTransformMakeTranslation(0.0, self.superview.bounds.size.height);
            break;
        default:
            transform = CGAffineTransformIdentity;
            break;
    }
    return transform;
}

- (CGFloat)showAlphaFor:(CKModalViewShowAnimation)animation {
    CGFloat alpha = 1.0;
    switch (animation) {
        case CKModalViewShowAnimationUp:
            alpha = 1.0;
            break;
        default:
            alpha = 1.0;
            break;
    }
    return alpha;
}

- (void)showAlertInView:(UIView *)view {
    [self showAlertInView:view animation:CKModalViewShowAnimationUp];
}

- (void)showAlertInView:(UIView *)view animation:(CKModalViewShowAnimation)showAnimation {
    if (self.animating) {
        return;
    }
    
    self.animating = YES;
    self.frame = view.bounds;
    self.tag = kModalViewTag;
    [view addSubview:self];
    
    // Register tap on container.
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(backgroundTapped:)];
    tapGesture.delegate = self;
    [self addGestureRecognizer:tapGesture];
    
    // Prepare the background overlay.
    UIView *backgroundOverlay = [[UIView alloc] initWithFrame:self.bounds];
    backgroundOverlay.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight;
    backgroundOverlay.backgroundColor = [UIColor blackColor];
    backgroundOverlay.alpha = 0.0;
    [self addSubview:backgroundOverlay];
    self.backgroundOverlay = backgroundOverlay;
    
    // Prepare the contentView.
    UIView *contentView = self.contentViewController.view;
    contentView.frame = CGRectMake(floorf((self.bounds.size.width - self.contentSize.width) / 2),
                                   floorf((self.bounds.size.height - self.contentSize.height) / 2),
                                   self.contentSize.width,
                                   self.contentSize.height);
    [self addSubview:contentView];
    contentView.transform = [self showTransformFor:showAnimation];
    contentView.alpha = [self showAlphaFor:showAnimation];
    
    // Fade in the background.
    [UIView animateWithDuration:0.1
                          delay:0.0
                        options:UIViewAnimationCurveLinear
                     animations:^{
                         self.backgroundOverlay.alpha = 0.7;
                         contentView.transform = CGAffineTransformIdentity;
                         contentView.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                         self.animating = NO;
                         [self.delegate modalViewDidShow];
                     }];
}

@end
