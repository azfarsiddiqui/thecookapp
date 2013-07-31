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
#import "ViewHelper.h"
#import "Theme.h"
#import "CKUserProfilePhotoView.h"
#import "ThemeTabView.h"

@interface SettingsViewController ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *logoutButtonView;
@property (nonatomic, strong) UISwitch *notificationsSwitch;
@property (nonatomic, strong) UILabel *themeLabel;
@property (nonatomic, strong) ThemeTabView *themeTabView;

@end

@implementation SettingsViewController

#define kSettingsHeight     160.0
#define kNumPages           2
#define kLogoutSize         (CGSize){ 100.0, 70.0 }

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
    [self createLogoutButton];
    
    [EventHelper registerLoginSucessful:self selector:@selector(loggedIn:)];
    [EventHelper registerLogout:self selector:@selector(loggedOut:)];
}

#pragma mark - Properties

- (UIView *)logoutButtonView {
    if (!_logoutButtonView) {
        _logoutButtonView = [[UIView alloc] initWithFrame:(CGRect){
            self.scrollView.bounds.size.width - kLogoutSize.width - 15.0,
            floorf((self.scrollView.bounds.size.height - kLogoutSize.height) / 2.0),
            kLogoutSize.width,
            kLogoutSize.height
        }];
        _logoutButtonView.backgroundColor = [UIColor clearColor];
        
        CKUser *currentUser = [CKUser currentUser];
        CKUserProfilePhotoView *photoView = [[CKUserProfilePhotoView alloc] initWithUser:currentUser placeholder:NO profileSize:ProfileViewSizeSmall border:YES];
        photoView.frame = (CGRect){
            floorf((_logoutButtonView.bounds.size.width - photoView.frame.size.width) / 2.0),
            _logoutButtonView.bounds.origin.y,
            photoView.frame.size.width,
            photoView.frame.size.height
        };
        [_logoutButtonView addSubview:photoView];
        
        UILabel *profileLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        profileLabel.autoresizingMask = UIViewAutoresizingNone;
        profileLabel.backgroundColor = [UIColor clearColor];
        profileLabel.font = [Theme settingsProfileFont];
        profileLabel.textColor = [UIColor whiteColor];
        profileLabel.shadowColor = [UIColor blackColor];
        profileLabel.shadowOffset = CGSizeMake(0.0, -1.0);
//        profileLabel.text = [currentUser.name uppercaseString];
        profileLabel.text = @"LOGOUT";
        [profileLabel sizeToFit];
        profileLabel.frame = (CGRect){
            floorf((_logoutButtonView.bounds.size.width - profileLabel.frame.size.width) / 2.0),
            photoView.frame.origin.y + photoView.frame.size.height + 15.0,
            profileLabel.frame.size.width,
            profileLabel.frame.size.height
        };
        [_logoutButtonView addSubview:profileLabel];

        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(logoutTapped:)];
        [_logoutButtonView addGestureRecognizer:tapGesture];
        
    }
    return _logoutButtonView;
}

- (UISwitch *)notificationsSwitch {
    if (!_notificationsSwitch) {
        _notificationsSwitch = [[UISwitch alloc] init];
        _notificationsSwitch.tintColor = [UIColor greenColor];
        _notificationsSwitch.on = YES;
        _notificationsSwitch.frame = (CGRect){
            280.0,
            82.0,
            _notificationsSwitch.frame.size.width,
            _notificationsSwitch.frame.size.height
        };
    }
    return _notificationsSwitch;
}

- (UILabel *)themeLabel {
    if (!_themeLabel) {
        _themeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _themeLabel.backgroundColor = [UIColor clearColor];
        _themeLabel.font = [Theme settingsThemeFont];
        _themeLabel.textColor = [UIColor whiteColor];
        _themeLabel.shadowColor = [UIColor blackColor];
        _themeLabel.shadowOffset = CGSizeMake(0.0, -1.0);
        _themeLabel.text = @"DASH THEME";
        [_themeLabel sizeToFit];
        _themeLabel.frame = (CGRect){
            self.themeTabView.frame.origin.x + floorf((self.themeTabView.frame.size.width - _themeLabel.frame.size.width) / 2.0),
            self.themeTabView.frame.origin.y - _themeLabel.frame.size.height - 15.0,
            _themeLabel.frame.size.width,
            _themeLabel.frame.size.height
        };
    }
    return _themeLabel;
}

- (ThemeTabView *)themeTabView {
    if (!_themeTabView) {
        _themeTabView = [[ThemeTabView alloc] init];
        _themeTabView.frame = (CGRect){
            407.0,
            82.0,
            _themeTabView.frame.size.width,
            _themeTabView.frame.size.height
        };
    }
    return _themeTabView;
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
    
    // Notifications switch
    [self.scrollView addSubview:self.notificationsSwitch];
    
    // Theme
    [self.scrollView addSubview:self.themeLabel];
    [self.scrollView addSubview:self.themeTabView];
}

- (void)createLogoutButton {
    CKUser *currentUser = [CKUser currentUser];
    if ([currentUser isSignedIn]) {
        [self.scrollView addSubview:self.logoutButtonView];
    }
}

- (void)logoutTapped:(id)sender {
    
    // TODO Uncomment for it to work.
    return;
    
    [CKUser logoutWithCompletion:^{
        // Post logout.
        [EventHelper postLogout];
    } failure:^(NSError *error) {
    }];
}

- (void)loggedIn:(NSNotification *)notification {
    BOOL success = [EventHelper loginSuccessfulForNotification:notification];
    if (success) {
        [self createLogoutButton];
    }
}

- (void)loggedOut:(NSNotification *)notification {
    [self.logoutButtonView removeFromSuperview];
}

@end
