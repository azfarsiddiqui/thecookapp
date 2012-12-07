//
//  LoginViewController.h
//  Cook
//
//  Created by Jeff Tan-Ang on 7/12/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LoginViewControllerDelegate

- (void)loginViewControllerSuccessful:(BOOL)success;

@end

@interface LoginViewController : UIViewController

- (id)initWithDelegate:(id<LoginViewControllerDelegate>)delegate;

@end
