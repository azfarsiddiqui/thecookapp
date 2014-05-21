//
//  ProfileViewController.h
//  Cook
//
//  Created by Jeff Tan-Ang on 4/10/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OverlayViewController.h"

@class CKUser;

@protocol ProfileViewControllerDelegate <NSObject>

- (void)profileViewControllerCloseRequested;

@end

@interface ProfileViewController : OverlayViewController

@property (nonatomic, assign) BOOL useBackButton;

- (id)initWithUser:(CKUser *)user;
- (id)initWithUser:(CKUser *)user delegate:(id<ProfileViewControllerDelegate>)delegate;

@end
