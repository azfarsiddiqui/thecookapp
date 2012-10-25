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

@interface RootViewController ()

@property (nonatomic, strong) BenchtopViewController *benchtopViewController;
@property (nonatomic, strong) MenuViewController *menuViewController;


@end

#define RADIANS(degrees)    ((degrees * (float)M_PI) / 180.0f)

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
}

- (void)viewDidAppear:(BOOL)animated {
    
    // Prepare for the dashboard to be transitioned in.
    self.benchtopViewController = [[BenchtopViewController alloc] init];
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
        [self showMenu:YES];
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

#pragma mark - MenuViewControllerDelegate methods

- (void)menuViewControllerSettingsRequested {
    DLog();
}

- (void)menuViewControllerStoreRequested {
    DLog();
}

#pragma mark - Private methods

- (void)showDashboard {
    DLog();
    CKUser *currentUser = [CKUser currentUser];
    DLog(@"Current User: %@", currentUser);
    
    [self.benchtopViewController enable:YES];
}

- (void)showMenu:(BOOL)show {
    if (!self.menuViewController) {
        self.menuViewController = [[MenuViewController alloc] initWithDelegate:self];
        self.menuViewController.view.alpha = 0.0;
        [self.view addSubview:self.menuViewController.view];
    }
    
    // Fade it in
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationCurveEaseIn
                     animations:^{
                         self.menuViewController.view.alpha = show ? 1.0 : 0.0;
                     }
                     completion:^(BOOL finished) {
                     }];
}

@end
