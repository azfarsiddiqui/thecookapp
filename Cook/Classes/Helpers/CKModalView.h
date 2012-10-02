//
//  CKModalView.h
//  Cook
//
//  Created by Jeff Tan-Ang on 27/09/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    CKModalViewHideAnimationFadeAndScale,
    CKModalViewHideAnimationDown,
    CKModalViewHideAnimationNone
} CKModalViewHideAnimation;

typedef enum {
    CKModalViewShowAnimationUp,
    CKModalViewShowAnimationNone
} CKModalViewShowAnimation;

@protocol CKModalViewContentDelegate

- (void)modalViewDidShow;
- (void)modalViewDidHide;

@end

@interface CKModalView : UIView

+ (CKModalView *)modalViewInView:(UIView *)view;

- (id)initWithViewController:(UIViewController *)contentViewController delegate:(id<CKModalViewContentDelegate>)delegate;
- (id)initWithViewController:(UIViewController *)contentViewController delegate:(id<CKModalViewContentDelegate>)delegate
                 dismissable:(BOOL)dismissable;
- (void)showInView:(UIView *)view;
- (void)showInView:(UIView *)view animation:(CKModalViewShowAnimation)showAnimation;
- (void)hide;
- (void)hideWithCompletion:(void (^)())completion;
- (void)hide:(CKModalViewHideAnimation)animation;
- (void)hide:(CKModalViewHideAnimation)animation completion:(void (^)())completion;


@end
