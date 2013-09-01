//
//  ModalOverlayHelper.m
//  Cook
//
//  Created by Jeff Tan-Ang on 1/09/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "ModalOverlayHelper.h"

@implementation ModalOverlayHelper

+ (void)showModalOverlayForViewController:(UIViewController *)viewController show:(BOOL)show
                               parentView:(UIView *)parentView completion:(void (^)())completion {
    
    [self showModalOverlayForViewController:viewController show:show parentView:parentView animation:nil
                                 completion:completion];
}

+ (void)showModalOverlayForViewController:(UIViewController *)viewController show:(BOOL)show
                               parentView:(UIView *)parentView animation:(void (^)())animation
                               completion:(void (^)())completion {
    
    if (show) {
        viewController.view.frame = parentView.bounds;
        viewController.view.alpha = 0.0;
        [parentView addSubview:viewController.view];
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
    
    [self showModalOverlayForViewController:viewController show:NO parentView:nil animation:animation
                                 completion:completion];
}

@end
