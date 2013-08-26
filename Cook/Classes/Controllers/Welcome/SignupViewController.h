//
//  SignupViewController.h
//  Cook
//
//  Created by Jeff Tan-Ang on 27/05/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SignupViewControllerDelegate <NSObject>

- (UIView *)signupViewControllerSnapshotRequested;
- (void)signupViewControllerDismissRequested;
- (void)signupViewControllerFocused:(BOOL)focused;
- (void)signUpViewControllerModalRequested:(BOOL)modal;

@end

@interface SignupViewController : UIViewController

- (id)initWithDelegate:(id<SignupViewControllerDelegate>)delegate;
- (void)enableSignUpMode:(BOOL)signUp;
- (void)enableSignUpMode:(BOOL)signUp animated:(BOOL)animated;
- (void)loadSnapshot:(UIView *)snapshotView;

@end
