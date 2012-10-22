//
//  CKViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 26/09/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKViewController.h"
#import "CKUser.h"
#import "CKAppHelper.h"
#import "BenchtopViewController.h"

@interface CKViewController ()

@property (nonatomic, strong) BenchtopViewController *benchtopViewController;

- (void)showDashboard;

@end

#define RADIANS(degrees)    ((degrees * (float)M_PI) / 180.0f)

@implementation CKViewController

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
    if ([[CKAppHelper sharedInstance] newInstall]) {
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

- (void)showDashboard {
    DLog();
    CKUser *currentUser = [CKUser currentUser];
    DLog(@"Current User: %@", currentUser);
    
    [self.benchtopViewController enable:YES];
}

@end
