//
//  SignupViewController.h
//  Cook
//
//  Created by Jeff Tan-Ang on 27/05/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SignupViewControllerDelegate <NSObject>

- (void)signupViewControllerFocused:(BOOL)focused;

@end

@interface SignupViewController : UIViewController

- (id)initWithDelegate:(id<SignupViewControllerDelegate>)delegate;

@end
