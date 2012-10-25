//
//  MenuViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 25/10/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "MenuViewController.h"
#import "ViewHelper.h"

@interface MenuViewController ()

@property (nonatomic, assign) id<MenuViewControllerDelegate> delegate;

@end

#define kMenuHeight 60.0
#define kMenuGap    20.0
#define kSideGap    20.0

@implementation MenuViewController

- (id)initWithDelegate:(id<MenuViewControllerDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth;
    self.view.backgroundColor = [UIColor clearColor];
    
    // Settings button.
    UIButton *settingsButton = [ViewHelper buttonWithImage:[UIImage imageNamed:@"cook_dash_icons_settings.png"]
                                                    target:self
                                                  selector:@selector(settingsTapped:)];
    settingsButton.frame = CGRectMake(kSideGap,
                                      floorf((kMenuHeight - settingsButton.frame.size.height) / 2.0),
                                      settingsButton.frame.size.width,
                                      settingsButton.frame.size.height);
    settingsButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    [self.view addSubview:settingsButton];
    
    // Store button.
    UIButton *storeButton = [ViewHelper buttonWithImage:[UIImage imageNamed:@"cook_dash_icons_friends.png"]
                                                    target:self
                                                  selector:@selector(storeTapped:)];
    storeButton.frame = CGRectMake(settingsButton.frame.origin.x + settingsButton.frame.size.width + kMenuGap,
                                   floorf((kMenuHeight - storeButton.frame.size.height) / 2.0),
                                   storeButton.frame.size.width,
                                   storeButton.frame.size.height);
    storeButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    [self.view addSubview:storeButton];
    
    self.view.frame = CGRectMake(0.0, 0.0, storeButton.frame.origin.x + storeButton.frame.size.width + kSideGap, kMenuHeight);
}

#pragma mark - Private

- (void)settingsTapped:(id)sender {
    [self.delegate menuViewControllerSettingsRequested];
}

- (void)storeTapped:(id)sender {
    [self.delegate menuViewControllerStoreRequested];
}

@end
