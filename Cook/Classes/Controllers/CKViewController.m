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

@interface CKViewController ()

@end

@implementation CKViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    if ([[CKAppHelper sharedInstance] newInstall]) {
        
        CKIntroViewController *introViewController = [[CKIntroViewController alloc] initWithDelegate:self];
        CKModalView *modalView = [[CKModalView alloc] initWithViewController:introViewController
                                                                    delegate:self
                                                                 dismissable:NO];
        [modalView showInView:self.view];
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
    [modalView hide];
}

@end
