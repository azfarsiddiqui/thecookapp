//
//  ProfileViewController.h
//  Cook
//
//  Created by Jeff Tan-Ang on 4/10/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKNavigationController.h"
#import "OverlayViewController.h"

@class CKUser;

@interface ProfileViewController : OverlayViewController <CKNavigationControllerSupport>

- (id)initWithUser:(CKUser *)user;

@end
