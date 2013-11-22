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

typedef void(^ProfileCloseBlock)(BOOL isClosed);

@interface ProfileViewController : OverlayViewController <CKNavigationControllerSupport>

@property (nonatomic, copy) ProfileCloseBlock closeBlock;

- (id)initWithUser:(CKUser *)user;
- (void)showOverlayOnViewController:(UIViewController *)parentController;

@end
