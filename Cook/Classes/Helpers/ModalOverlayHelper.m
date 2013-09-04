//
//  ModalOverlayHelper.m
//  Cook
//
//  Created by Jeff Tan-Ang on 1/09/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "ModalOverlayHelper.h"
#import "AppHelper.h"

@implementation ModalOverlayHelper

+ (UIColor *)modalOverlayBackgroundColour {
    return [self modalOverlayBackgroundColourWithAlpha:0.8];
}

+ (UIColor *)modalOverlayBackgroundColourWithAlpha:(CGFloat)alpha {
    return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:alpha];
}

+ (void)showModalOverlayForViewController:(UIViewController *)viewController show:(BOOL)show
                               completion:(void (^)())completion {
    
    [self showModalOverlayForViewController:viewController show:show animation:nil completion:completion];
}

+ (void)showModalOverlayForViewController:(UIViewController *)viewController show:(BOOL)show
                                animation:(void (^)())animation completion:(void (^)())completion {
    
    if (show) {
        UIView *rootView = [[AppHelper sharedInstance] rootView];
        viewController.view.frame = rootView.bounds;
        viewController.view.alpha = 0.0;
        [rootView addSubview:viewController.view];
    }
    [UIView animateWithDuration:show? 0.3 : 0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         viewController.view.alpha = show ? 1.0 : 0.0;
                         
                         // Run any provided in-flight animation block.
                         if (animation != nil) {
                             animation();
                         }
                     }
                     completion:^(BOOL finished) {
                         if (!show) {
                             [viewController.view removeFromSuperview];
                         }
                         if (completion != nil) {
                             completion();
                         }
                     }];
}

+ (void)hideModalOverlayForViewController:(UIViewController *)viewController completion:(void (^)())completion {
    
    [self hideModalOverlayForViewController:viewController animation:nil completion:completion];
}

+ (void)hideModalOverlayForViewController:(UIViewController *)viewController animation:(void (^)())animation
                               completion:(void (^)())completion {
    
    [self showModalOverlayForViewController:viewController show:NO animation:animation completion:completion];
}

@end
