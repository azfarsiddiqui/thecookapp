//
//  MenuViewController.h
//  Cook
//
//  Created by Jeff Tan-Ang on 25/10/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MenuViewControllerDelegate

- (void)menuViewControllerSettingsRequested;
- (void)menuViewControllerStoreRequested;

@end

@interface MenuViewController : UIViewController

@property (nonatomic, strong) UIButton *settingsButton;
@property (nonatomic, strong) UIButton *storeButton;
@property (nonatomic, strong) UIButton *editCancelButton;
@property (nonatomic, strong) UIButton *editDoneButton;

- (id)initWithDelegate:(id<MenuViewControllerDelegate>)delegate;

@end
