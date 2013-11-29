//
//  CKNavigationController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 4/10/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKNavigationController.h"
#import "RecipeDetailsViewController.h"
#import "BookCoverPhotoViewController.h"
#import "ModalOverlayHelper.h"
#import "ViewHelper.h"

@interface CKNavigationController ()

@property (nonatomic, strong) UIView *underlayView;
@property (nonatomic, strong) NSMutableArray *viewControllers;
@property (nonatomic, assign) BOOL animating;
@property (nonatomic, strong) UIViewController *contextModalViewController;
@property (nonatomic, strong) UIView *backgroundImageTopShadowView;

@end

@implementation CKNavigationController

- (id)initWithRootViewController:(UIViewController *)viewController {
    return [self initWithRootViewController:viewController delegate:nil];
}

- (id)initWithRootViewController:(UIViewController *)viewController delegate:(id<CKNavigationControllerDelegate>)delegate {
    if (self = [super init]) {
        
        // Sets myself on the viewController so it can call push/pops.
        if ([viewController conformsToProtocol:@protocol(CKNavigationControllerSupport)]) {
            [viewController performSelector:@selector(setCookNavigationController:) withObject:self];
        }
        
        self.viewControllers = [NSMutableArray arrayWithObject:viewController];
        
        self.delegate = delegate;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    // Underlay view.
    [self.view addSubview:self.underlayView];
    
    UIViewController *rootViewController = [self.viewControllers firstObject];
    rootViewController.view.frame = self.view.bounds;
    [self.view addSubview:rootViewController.view];
    
    // Inform view didAppear on all lifecycle events.
    if ([rootViewController respondsToSelector:@selector(cookNavigationControllerViewWillAppear:)]) {
        [rootViewController performSelector:@selector(cookNavigationControllerViewWillAppear:) withObject:@(YES)];
    }
    if ([rootViewController respondsToSelector:@selector(cookNavigationControllerViewAppearing:)]) {
        [rootViewController performSelector:@selector(cookNavigationControllerViewAppearing:) withObject:@(YES)];
    }
    if ([rootViewController respondsToSelector:@selector(cookNavigationControllerViewDidAppear:)]) {
        [rootViewController performSelector:@selector(cookNavigationControllerViewDidAppear:) withObject:@(YES)];
    }
    
    // Register left screen edge for shortcut to home.
    UIScreenEdgePanGestureRecognizer *leftEdgeGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self
                                                                                                          action:@selector(screenEdgePanned:)];
    leftEdgeGesture.edges = UIRectEdgeLeft;
    [self.view addGestureRecognizer:leftEdgeGesture];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (!viewController) {
        return;
    }
    
    if (animated && self.animating) {
        return;
    }
    
    // Sets myself on the viewController so it can call push/pops.
    if ([viewController conformsToProtocol:@protocol(CKNavigationControllerSupport)]) {
        [viewController performSelector:@selector(setCookNavigationController:) withObject:self];
    }
    
    // Get current viewController.
    UIViewController *currentViewController = [self currentViewController];
    
    if (animated) {
        
        self.animating = YES;
        
        // Prep the VC to be slid in from the right.
        viewController.view.frame = self.view.bounds;
        viewController.view.transform = CGAffineTransformMakeTranslation(self.view.bounds.size.width, 0.0);
        [self.view addSubview:viewController.view];
        
        // Inform view will appear.
        if ([viewController respondsToSelector:@selector(cookNavigationControllerViewWillAppear:)]) {
            [viewController performSelector:@selector(cookNavigationControllerViewWillAppear:) withObject:@(YES)];
        }
        
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             
                             // Slide outgoing to the left.
                             currentViewController.view.transform = CGAffineTransformMakeTranslation(-self.view.bounds.size.width, 0.0);
                             
                             // Slide incoming from the right.
                             viewController.view.transform = CGAffineTransformIdentity;
                             
                             // Inform view appearing animating.
                             if ([viewController respondsToSelector:@selector(cookNavigationControllerViewAppearing:)]) {
                                 [viewController performSelector:@selector(cookNavigationControllerViewAppearing:) withObject:@(YES)];
                             }
                             
                         }
                         completion:^(BOOL finished) {
                             
                             // Hide current one.
                             currentViewController.view.hidden = YES;
                             
                             // Add to list of pushed controllers.
                             [self.viewControllers addObject:viewController];
                             
                             // Inform view didAppear.
                             if ([viewController respondsToSelector:@selector(cookNavigationControllerViewDidAppear:)]) {
                                 [viewController performSelector:@selector(cookNavigationControllerViewDidAppear:) withObject:@(YES)];
                             }
                             
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
        
        // Inform view didAppear.
        if ([viewController respondsToSelector:@selector(cookNavigationControllerViewDidAppear:)]) {
            [viewController performSelector:@selector(cookNavigationControllerViewDidAppear:) withObject:@(YES)];
        }
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

        // Inform viewControllers of popping.
        if ([poppedViewController respondsToSelector:@selector(cookNavigationControllerViewWillAppear:)]) {
            [poppedViewController performSelector:@selector(cookNavigationControllerViewWillAppear:) withObject:@(NO)];
        }
        if ([previousViewController respondsToSelector:@selector(cookNavigationControllerViewWillAppear:)]) {
            [previousViewController performSelector:@selector(cookNavigationControllerViewWillAppear:) withObject:@(YES)];
        }
        
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             
                             // Slide outgoing to the right.
                             poppedViewController.view.transform = CGAffineTransformMakeTranslation(self.view.bounds.size.width, 0.0);
                             
                             // Slide incoming from the left.
                             previousViewController.view.transform = CGAffineTransformIdentity;
                             
                             // Inform view disappear animating.
                             if ([poppedViewController respondsToSelector:@selector(cookNavigationControllerViewAppearing:)]) {
                                 [poppedViewController performSelector:@selector(cookNavigationControllerViewAppearing:) withObject:@(NO)];
                             }
                             if ([previousViewController respondsToSelector:@selector(cookNavigationControllerViewAppearing:)]) {
                                 [previousViewController performSelector:@selector(cookNavigationControllerViewAppearing:) withObject:@(YES)];
                             }
                             
                             
                         }
                         completion:^(BOOL finished) {
                             
                             // Inform view didAppear NO.
                             if ([poppedViewController respondsToSelector:@selector(cookNavigationControllerViewDidAppear:)]) {
                                 [poppedViewController performSelector:@selector(cookNavigationControllerViewDidAppear:) withObject:@(NO)];
                             }
                             if ([previousViewController respondsToSelector:@selector(cookNavigationControllerViewDidAppear:)]) {
                                 [previousViewController performSelector:@selector(cookNavigationControllerViewDidAppear:) withObject:@(YES)];
                             }
                             
                             // Remove the poppedViewController's view.
                             [poppedViewController.view removeFromSuperview];
                             
                             // Remove from list of pushed controllers.
                             [self.viewControllers removeLastObject];
                             
                             self.animating = NO;
                             
                         }];
        
    } else {
        
        // Inform view didAppear NO.
        if ([poppedViewController respondsToSelector:@selector(cookNavigationControllerViewDidAppear:)]) {
            [poppedViewController performSelector:@selector(cookNavigationControllerViewDidAppear:) withObject:@(NO)];
        }
        if ([previousViewController respondsToSelector:@selector(cookNavigationControllerViewDidAppear:)]) {
            [previousViewController performSelector:@selector(cookNavigationControllerViewDidAppear:) withObject:@(YES)];
        }
        
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

- (UIViewController *)topViewController {
    return [self.viewControllers firstObject];
}

- (BOOL)isTopViewController:(UIViewController *)viewController {
    return (viewController == [self topViewController]);
}

- (BOOL)isTop {
    return [self isTopViewController:[self currentViewController]];
}

- (void)showContextWithRecipe:(CKRecipe *)recipe {
    RecipeDetailsViewController *recipeDetailsViewController = [[RecipeDetailsViewController alloc] initWithRecipe:recipe];
    recipeDetailsViewController.hideNavigation = YES;
    recipeDetailsViewController.disableStatusBarUpdate = YES;
    [self showContextModalViewController:recipeDetailsViewController];
}

- (void)showContextWithBook:(CKBook *)book {
    BookCoverPhotoViewController *bookCoverPhotoViewController = [[BookCoverPhotoViewController alloc] initWithBook:book];
    [self showContextModalViewController:bookCoverPhotoViewController];
}

- (void)hideContext {
    [self.contextModalViewController performSelector:@selector(bookModalViewControllerWillAppear:)
                                          withObject:[NSNumber numberWithBool:NO]];
    [self.contextModalViewController performSelector:@selector(bookModalViewControllerDidAppear:)
                                          withObject:[NSNumber numberWithBool:NO]];
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options:UIViewAnimationCurveEaseIn
                     animations:^{
                         self.contextModalViewController.view.alpha = 0.0;
                         self.backgroundImageView.alpha = 0.0;
                     }
                     completion:^(BOOL finished)  {
                         [self.contextModalViewController.view removeFromSuperview];
                         self.contextModalViewController = nil;
                         
                         self.backgroundImageView.image = nil;
                         [self.backgroundImageView removeFromSuperview];
                     }];
}

#pragma mark - Background image with motion effects.

- (void)loadBackgroundImage:(UIImage *)backgroundImage {
    [self loadBackgroundImage:backgroundImage animation:^{}];
}

- (void)loadBackgroundImage:(UIImage *)backgroundImage animation:(void (^)())animation {
    
    if (!self.backgroundImageView.superview) {
        self.backgroundImageView.alpha = 0.0;
        [self.view insertSubview:self.backgroundImageView aboveSubview:self.underlayView];
    }
    
    if (!self.backgroundImageTopShadowView) {
        self.backgroundImageTopShadowView = [ViewHelper topShadowViewForView:self.backgroundImageView];
        [self.backgroundImageView addSubview:self.backgroundImageTopShadowView];
    }
    
    if (self.backgroundImageView.image) {
        
        // Just replace over the top if there was a prior image (thumbnail).
        self.backgroundImageView.alpha = 1.0;
        self.backgroundImageView.image = backgroundImage;
        
    } else {
        
        // Fade it in.
        self.backgroundImageView.alpha = 0.0;
        self.backgroundImageView.image = backgroundImage;
        [UIView animateWithDuration:0.6
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.backgroundImageView.alpha = 1.0;
                             animation();
                         }
                         completion:^(BOOL finished) {
                         }];
    }
}

#pragma mark - Properties

- (UIView *)underlayView {
    if (!_underlayView) {
        _underlayView = [[UIView alloc] initWithFrame:self.view.bounds];
        _underlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _underlayView.backgroundColor = [ModalOverlayHelper modalOverlayBackgroundColour];
    }
    return _underlayView;
}

- (UIImageView *)backgroundImageView {
    if (!_backgroundImageView) {
        UIOffset motionOffset = [ViewHelper standardMotionOffset];
        _backgroundImageView = [[UIImageView alloc] initWithImage:nil];
        _backgroundImageView.frame = (CGRect) {
            self.view.bounds.origin.x - motionOffset.horizontal,
            self.view.bounds.origin.y - motionOffset.vertical,
            self.view.bounds.size.width + (motionOffset.horizontal * 2.0),
            self.view.bounds.size.height + (motionOffset.vertical * 2.0)
        };
        _backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
        _backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        
        // Motion effects.
        [ViewHelper applyDraggyMotionEffectsToView:_backgroundImageView];
    }
    return _backgroundImageView;
}

#pragma mark - Private methods

- (UIViewController *)previousViewController {
    UIViewController *viewController = nil;
    
    if ([self.viewControllers count] > 1) {
        viewController = [self.viewControllers objectAtIndex:([self.viewControllers count] - 2)];
    }
    
    return viewController;
}

- (void)screenEdgePanned:(UIScreenEdgePanGestureRecognizer *)edgeGesture {
    
    // If detected, then close the recipe.
    if (edgeGesture.state == UIGestureRecognizerStateBegan) {
        if ([self isTop]) {
            if ([self.delegate respondsToSelector:@selector(cookNavigationControllerCloseRequested)]) {
                [self.delegate cookNavigationControllerCloseRequested];
            }
        } else {
            [self popViewControllerAnimated:YES];
        }
    }
}

- (void)showContextModalViewController:(UIViewController *)modalViewController {
    self.contextModalViewController = modalViewController;
    
    // Add overlay view so we can splice in under an overlay.
    self.view.backgroundColor = [UIColor clearColor];
    
    // Modal view controller has to be a UIViewController and confirms to BookModalViewControllerDelegate
    if (![modalViewController conformsToProtocol:@protocol(BookModalViewController)]) {
        DLog(@"Must conform to BookModalViewController protocol.");
        return;
    }
    
    // Prepare the modalVC to be transitioned.
    modalViewController.view.frame = self.view.bounds;
    modalViewController.view.alpha = 0.0;
    [self.view insertSubview:modalViewController.view belowSubview:self.underlayView];
    
    // Sets the modal view delegate for close callbacks.
    [modalViewController performSelector:@selector(setModalViewControllerDelegate:) withObject:self];
    
    // Inform will appear.
    [modalViewController performSelector:@selector(bookModalViewControllerWillAppear:)
                              withObject:[NSNumber numberWithBool:YES]];
    
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options:UIViewAnimationCurveEaseIn
                     animations:^{
                         modalViewController.view.alpha = 1.0;
                     }
                     completion:^(BOOL finished)  {
                         [modalViewController performSelector:@selector(bookModalViewControllerDidAppear:)
                                                   withObject:[NSNumber numberWithBool:YES]];
                     }];
}

@end
