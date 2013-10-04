//
//  CKNavigationController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 4/10/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKNavigationController.h"

@interface CKNavigationController ()

@property (nonatomic, strong) NSMutableArray *viewControllers;
@property (nonatomic, assign) BOOL animating;

@end

@implementation CKNavigationController

- (id)initWithRootViewController:(UIViewController *)viewController {
    if (self = [super init]) {
        
        if (!viewController || ![viewController conformsToProtocol:@protocol(CKNavigationControllerSupport)]) {
            return nil;
        }
        
        // Sets myself on the viewController so it can call push/pops.
        [viewController performSelector:@selector(setCookNavigationController:) withObject:self];
        
        self.viewControllers = [NSMutableArray arrayWithObject:viewController];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    UIViewController *rootViewController = [self.viewControllers firstObject];
    rootViewController.view.frame = self.view.bounds;
    [self.view addSubview:rootViewController.view];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (!viewController || ![viewController conformsToProtocol:@protocol(CKNavigationControllerSupport)]) {
        return;
    }
    
    if (animated && self.animating) {
        return;
    }
    
    // Sets myself on the viewController so it can call push/pops.
    [viewController performSelector:@selector(setCookNavigationController:) withObject:self];
    
    // Get current viewController.
    UIViewController *currentViewController = [self currentViewController];
    
    if (animated) {
        
        self.animating = YES;
        
        // Prep the VC to be slid in from the right.
        viewController.view.frame = self.view.bounds;
        viewController.view.transform = CGAffineTransformMakeTranslation(self.view.bounds.size.width, 0.0);
        [self.view addSubview:viewController.view];
        
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             
                             // Slide outgoing to the left.
                             currentViewController.view.transform = CGAffineTransformMakeTranslation(-self.view.bounds.size.width, 0.0);
                             
                             // Slide incoming from the right.
                             viewController.view.transform = CGAffineTransformIdentity;
                         }
                         completion:^(BOOL finished) {
                             
                             // Hide current one.
                             currentViewController.view.hidden = YES;
                             
                             // Add to list of pushed controllers.
                             [self.viewControllers addObject:viewController];
                             
                             self.animating = NO;
                             
                         }];
        
    } else {
        
        // Hide current one.
        currentViewController.view.hidden = YES;
        
        // Just add to the view hierarchy.
        viewController.view.frame = self.view.bounds;
        [self.view addSubview:viewController.view];
        
        // Add to list of pushed controllers.
        [self.viewControllers addObject:viewController];
        
    }
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    UIViewController *poppedViewController = [self currentViewController];
    UIViewController *previousViewController = [self previousViewController];
    
    // Return immediately if we're still animating.
    if (animated && self.animating) {
        return nil;
    }
    
    if (animated) {
        
        self.animating = YES;
        
        // Unhide previous view controller be slid back in.
        previousViewController.view.hidden = NO;

        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             
                             // Slide outgoing to the right.
                             poppedViewController.view.transform = CGAffineTransformMakeTranslation(self.view.bounds.size.width, 0.0);
                             
                             // Slide incoming from the left.
                             previousViewController.view.transform = CGAffineTransformIdentity;
                         }
                         completion:^(BOOL finished) {
                             
                             // Remove the poppedViewController's view.
                             [poppedViewController.view removeFromSuperview];
                             
                             // Remove from list of pushed controllers.
                             [self.viewControllers removeLastObject];
                             
                             self.animating = NO;
                             
                         }];
        
    } else {
        
        // Remove the poppedViewController's view.
        [poppedViewController.view removeFromSuperview];
        
        // Show the previous view controller.
        previousViewController.view.transform = CGAffineTransformIdentity;
        previousViewController.view.hidden = NO;
        
        // Remove from list of pushed controllers.
        [self.viewControllers removeLastObject];
        
    }
    
    return poppedViewController;
}

- (UIViewController *)currentViewController {
    return [self.viewControllers lastObject];
}

#pragma mark - Private methods

- (UIViewController *)previousViewController {
    UIViewController *viewController = nil;
    
    if ([self.viewControllers count] > 1) {
        viewController = [self.viewControllers objectAtIndex:([self.viewControllers count] - 2)];
    }
    
    return viewController;
}

@end
