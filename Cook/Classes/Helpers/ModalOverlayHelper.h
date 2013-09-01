//
//  ModalOverlayHelper.h
//  Cook
//
//  Created by Jeff Tan-Ang on 1/09/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ModalOverlayHelper : NSObject

+ (UIColor *)modalOverlayBackgroundColour;
+ (UIColor *)modalOverlayBackgroundColourWithAlpha:(CGFloat)alpha;

+ (void)showModalOverlayForViewController:(UIViewController *)viewController show:(BOOL)show
                               completion:(void (^)())completion;
+ (void)showModalOverlayForViewController:(UIViewController *)viewController show:(BOOL)show
                                animation:(void (^)())animation completion:(void (^)())completion;

+ (void)hideModalOverlayForViewController:(UIViewController *)viewController completion:(void (^)())completion;
+ (void)hideModalOverlayForViewController:(UIViewController *)viewController animation:(void (^)())animation
                               completion:(void (^)())completion;

@end
