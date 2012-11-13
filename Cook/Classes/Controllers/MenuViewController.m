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

#define kMenuHeight 80.0
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
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth;
    self.view.frame = CGRectMake(0.0, 0.0, [ViewHelper screenSize].width, kMenuHeight);
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
    self.settingsButton = settingsButton;
    
    // Edit cancel button.
    UIButton *editCancelButton = [ViewHelper buttonWithImage:[UIImage imageNamed:@"cook_customise_btns_cancel.png"]
                                                      target:self
                                                    selector:@selector(editCancelTapped:)];
    [editCancelButton addTarget:self action:@selector(editCancelTapped:) forControlEvents:UIControlEventTouchUpInside];
    editCancelButton.frame = CGRectMake(kSideGap,
                                        floorf((kMenuHeight - settingsButton.frame.size.height) / 2.0),
                                        editCancelButton.frame.size.width,
                                        editCancelButton.frame.size.height);
    editCancelButton.hidden = YES;
    [self.view addSubview:editCancelButton];
    self.editCancelButton = editCancelButton;
    
    // Edit done button.
    UIButton *editDoneButton = [ViewHelper buttonWithImage:[UIImage imageNamed:@"cook_customise_btns_done.png"]
                                                        target:self
                                                        selector:@selector(editDoneTapped:)];
    [editDoneButton addTarget:self action:@selector(editDoneTapped:) forControlEvents:UIControlEventTouchUpInside];
    editDoneButton.frame = CGRectMake(self.view.bounds.size.width - editDoneButton.frame.size.width - kSideGap,
                                      floorf((kMenuHeight - editDoneButton.frame.size.height) / 2.0),
                                      editDoneButton.frame.size.width,
                                      editDoneButton.frame.size.height);
    editDoneButton.hidden = YES;
    [self.view addSubview:editDoneButton];
    self.editDoneButton = editDoneButton;
}

- (void)setEditMode:(BOOL)editMode animated:(BOOL)animated {
    if (editMode) {
        self.editCancelButton.alpha = 0.0;
        self.editDoneButton.alpha = 0.0;
        self.editCancelButton.hidden = NO;
        self.editDoneButton.hidden = NO;
    } else {
        self.settingsButton.alpha = 0.0;
        self.settingsButton.hidden = NO;
    }
    if (animated) {
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationCurveEaseIn
                         animations:^{
                             self.settingsButton.alpha = editMode ? 0.0 : 1.0;
                             self.editCancelButton.alpha = editMode ? 1.0 : 0.0;
                             self.editDoneButton.alpha = editMode ? 1.0 : 0.0;
                         }
                         completion:^(BOOL finished) {
                             self.editCancelButton.hidden = editMode ? NO : YES;
                             self.editDoneButton.hidden = editMode ? NO : YES;
                             self.settingsButton.hidden = editMode ? YES : NO;
                         }];
    } else {
        self.settingsButton.alpha = editMode ? 0.0 : 1.0;
        self.editCancelButton.alpha = editMode ? 1.0 : 0.0;
        self.editDoneButton.alpha = editMode ? 1.0 : 0.0;
    }
}

#pragma mark - Private

- (void)settingsTapped:(id)sender {
    [self.delegate menuViewControllerSettingsRequested];
}

- (void)editCancelTapped:(id)sender {
    [self.delegate menuViewControllerCancelRequested];
}

- (void)editDoneTapped:(id)sender {
    [self.delegate menuViewControllerDoneRequested];
}

@end
