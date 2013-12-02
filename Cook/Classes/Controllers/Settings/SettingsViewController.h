//
//  SettingsViewController.h
//  Cook
//
//  Created by Jeff Tan-Ang on 26/10/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SettingsViewControllerDelegate <NSObject>

- (void)settingsViewControllerSignInRequested;

@end

@interface SettingsViewController : UIViewController

@property (nonatomic, strong) UIView *overlayView;
- (id)initWithDelegate:(id<SettingsViewControllerDelegate>)delegate;

@end
