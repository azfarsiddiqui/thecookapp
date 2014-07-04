//
//  UserViewController.h
//  Cook
//
//  Created by Jeff Tan-Ang on 20/10/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "OverlayViewController.h"

@class CKUser;

@protocol AccountViewControllerDelegate <NSObject>

- (void)accountViewControllerDismissRequested;
- (UIImage *)accountViewControllerBlurredImageForDash;

@end

@interface AccountViewController : OverlayViewController

- (id)initWithUser:(CKUser *)user delegate:(id<AccountViewControllerDelegate>)delegate;

@end
