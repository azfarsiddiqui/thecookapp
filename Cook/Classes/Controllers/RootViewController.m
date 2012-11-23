//
//  RootViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 26/09/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "RootViewController.h"
#import "CKUser.h"
#import "AppHelper.h"
#import "BenchtopViewController.h"
#import "StoreViewController.h"

@interface RootViewController () <BenchtopViewControlelrDelegate, StoreViewControllerDelegate>

@property (nonatomic, strong) BenchtopViewController *benchtopViewController;
@property (nonatomic, strong) StoreViewController *storeViewController;

@end

#define RADIANS(degrees)    ((degrees * (float)M_PI) / 180.0f)

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
}

- (void)viewDidAppear:(BOOL)animated {
    
    // Prepare for the dashboard to be transitioned in.
    self.benchtopViewController = [[BenchtopViewController alloc] initWithDelegate:self];
    self.benchtopViewController.view.frame = self.view.bounds;
    [self.view addSubview:self.benchtopViewController.view];
    
    // If this was a new install/upgrade (it checks versions) then slide up intro screen.
    if ([[AppHelper sharedInstance] newInstall]) {
        CKIntroViewController *introViewController = [[CKIntroViewController alloc] initWithDelegate:self];
        CKModalView *modalView = [[CKModalView alloc] initWithViewController:introViewController
                                                                    delegate:self
                                                                 dismissable:NO];
        [modalView showInView:self.view];
    } else {
        [self showDashboard];
    }
}

#pragma mark - Rotation methods

- (BOOL)shouldAutomaticallyForwardRotationMethods {
    return NO;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

#pragma mark - CKModalViewContentDelegate methods

- (void)modalViewDidShow {
}

- (void)modalViewDidHide {
}

#pragma mark - CKIntroViewControllerDelegate methods

- (void)introViewDismissRequested {
    CKModalView *modalView = [CKModalView modalViewInView:self.view];
    [modalView hideWithCompletion:^{
        [self showDashboard];
    }];
}

#pragma mark - BenchtopViewControlelrDelegate methods

- (void)benchtopViewControllerStoreRequested {
    DLog();
    [self showStoreMode:YES];
}

#pragma mark - StoreViewControllerDelegate methods

- (void)storeViewControllerCloseRequested {
    DLog();
    [self showStoreMode:NO];
}

#pragma mark - Private methods

- (void)showDashboard {
    DLog();
    [self.benchtopViewController show];
}

- (void)showStoreMode:(BOOL)show {  
    if (show) {
        StoreViewController *storeViewController = [[StoreViewController alloc] initWithDelegate:self];
        storeViewController.view.frame = CGRectMake(self.view.bounds.origin.x,
                                                    -self.view.bounds.size.height,
                                                    self.view.bounds.size.width,
                                                    self.view.bounds.size.height);
        [self.view addSubview:storeViewController.view];
        self.storeViewController = storeViewController;
    }
    
    CGAffineTransform transform = show ? CGAffineTransformMakeTranslation(0.0, self.view.bounds.size.height) : CGAffineTransformIdentity;
    
    if (show) {
        
        // Disable benchtop first then shift to store mode.
        [self.benchtopViewController enable:NO completion:^{
            
            [UIView animateWithDuration:0.4
                                  delay:0.0
                                options:UIViewAnimationCurveEaseIn
                             animations:^{
                                 self.storeViewController.view.transform = transform;
                                 self.benchtopViewController.view.transform = transform;
                             }
                             completion:^(BOOL finished) {
                                 [self.storeViewController enable:YES];
                             }];
        }];
        
    } else {
        
        // Disable store first then shift to benchtop mode.
        [self.storeViewController enable:NO completion:^{
            
            [UIView animateWithDuration:0.4
                                  delay:0.0
                                options:UIViewAnimationCurveEaseIn
                             animations:^{
                                 self.storeViewController.view.transform = transform;
                                 self.benchtopViewController.view.transform = transform;
                             }
                             completion:^(BOOL finished) {
                                 [self.benchtopViewController enable:YES];
                                 [self.storeViewController.view removeFromSuperview];
                                 self.storeViewController = nil;
                             }];
        }];
        
    }

    
}

@end
