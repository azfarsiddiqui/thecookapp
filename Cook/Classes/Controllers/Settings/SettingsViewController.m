//
//  SettingsViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 26/10/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "SettingsViewController.h"
#import "CKUser.h"
#import "EventHelper.h"

@interface SettingsViewController ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIButton *logoutButton;

@end

@implementation SettingsViewController

#define kSettingsHeight     160.0
#define kNumPages           2

- (void)dealloc {
    [EventHelper unregisterLoginSucessful:self];
    [EventHelper unregisterLogout:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_dash_bg_settings.png"]];
    self.view.frame = CGRectMake(0.0, 0.0, backgroundView.frame.size.width, kSettingsHeight);
    self.view.clipsToBounds = NO;   // So that background extends below.
    [self.view addSubview:backgroundView];
    
    [self initSettingsContent];
    [self initLogoutButton];
    
    [EventHelper registerLoginSucessful:self selector:@selector(loggedIn:)];
    [EventHelper registerLogout:self selector:@selector(loggedOut:)];
}

#pragma mark - Private methods

- (void)initSettingsContent {
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.contentSize = CGSizeMake(self.view.bounds.size.width * kNumPages, self.view.bounds.size.height);
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.pagingEnabled = YES;
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;
    
    CGFloat offset = 0.0;
    for (NSUInteger pageNumber = 0; pageNumber < kNumPages; pageNumber++) {
        UIImageView *contentView = [[UIImageView alloc] initWithImage:
                                    [UIImage imageNamed:[NSString stringWithFormat:@"cook_dash_settingsplaceholder%d.png", pageNumber + 1]]];
        contentView.frame = CGRectMake(offset, 0.0, contentView.frame.size.width, contentView.frame.size.height);
        [scrollView addSubview:contentView];
        offset += contentView.frame.size.width;
    }
    
}

- (void)initLogoutButton {
    CKUser *currentUser = [CKUser currentUser];
    if ([currentUser isSignedIn]) {
        UIButton *logoutButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [logoutButton setTitle:@"Logout" forState:UIControlStateNormal];
        [logoutButton addTarget:self action:@selector(logoutTapped:) forControlEvents:UIControlEventTouchUpInside];
        [logoutButton sizeToFit];
        logoutButton.frame = CGRectMake(665.0, 75.0, logoutButton.frame.size.width, logoutButton.frame.size.height);
        [self.scrollView addSubview:logoutButton];
        self.logoutButton = logoutButton;
    }
}

- (void)logoutTapped:(id)sender {
    [CKUser logoutWithCompletion:^{
        // Post logout.
        [EventHelper postLogout];
    } failure:^(NSError *error) {
    }];
}

- (void)loggedIn:(NSNotification *)notification {
    BOOL success = [EventHelper loginSuccessfulForNotification:notification];
    if (success) {
        [self initLogoutButton];
    }
}

- (void)loggedOut:(NSNotification *)notification {
    [self.logoutButton removeFromSuperview];
    self.logoutButton = nil;
}

@end
