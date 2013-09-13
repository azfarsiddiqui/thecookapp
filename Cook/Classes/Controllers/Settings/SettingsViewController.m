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
#import "ImageHelper.h"
#import <MessageUI/MessageUI.h>

@interface SettingsViewController () <MFMailComposeViewControllerDelegate>

@property (nonatomic, weak) id<SettingsViewControllerDelegate> delegate;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *loginLogoutButtonView;
@property (nonatomic, strong) UILabel *themeLabel;

@property (nonatomic, strong) UIView *linkButtonContainerView;

@property (nonatomic, strong) UIButton *aboutButton;
@property (nonatomic, strong) UIButton *supportButton;
@property (nonatomic, strong) UIButton *facebookButton;
@property (nonatomic, strong) UIButton *twitterButton;

@property (nonatomic, strong) ThemeTabView *themeTabView;

@end

@implementation SettingsViewController

#define kSettingsHeight     160.0
#define kNumPages           2
#define kLogoutSize         (CGSize){ 100.0, 70.0 }
#define kLoginSize          (CGSize){ 100.0, 82.0 }

- (void)dealloc {
    [EventHelper unregisterLoginSucessful:self];
    [EventHelper unregisterLogout:self];
}

- (id)initWithDelegate:(id<SettingsViewControllerDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[ImageHelper imageFromDiskNamed:@"cook_dash_bg_settings" type:@"png"]];
    self.view.frame = CGRectMake(0.0, 0.0, backgroundView.frame.size.width, kSettingsHeight);
    self.view.clipsToBounds = NO;   // So that background extends below.
    [self.view addSubview:backgroundView];
    
    [self initSettingsContent];
    [self createLoginLogoutButton];
    
    [EventHelper registerLoginSucessful:self selector:@selector(loggedIn:)];
    [EventHelper registerLogout:self selector:@selector(loggedOut:)];
}

#pragma mark - Properties

- (UIView *)loginLogoutButtonView {
    if (!_loginLogoutButtonView) {
        CKUser *currentUser = [CKUser currentUser];
        CGSize size = (currentUser == nil) ? kLoginSize : kLogoutSize;
        
        _loginLogoutButtonView = [[UIView alloc] initWithFrame:(CGRect){
            self.scrollView.bounds.size.width - size.width - 15.0,
            floorf((self.scrollView.bounds.size.height - size.height) / 2.0),
            size.width,
            size.height
        }];
        _loginLogoutButtonView.backgroundColor = [UIColor clearColor];
        
        CGFloat yOffset = 0.0;
        if (currentUser) {
            CKUserProfilePhotoView *photoView = [[CKUserProfilePhotoView alloc] initWithUser:currentUser placeholder:NO
                                                                                 profileSize:ProfileViewSizeMini border:YES];
            photoView.frame = (CGRect){
                floorf((_loginLogoutButtonView.bounds.size.width - photoView.frame.size.width) / 2.0),
                _loginLogoutButtonView.bounds.origin.y,
                photoView.frame.size.width,
                photoView.frame.size.height
            };
            [_loginLogoutButtonView addSubview:photoView];
            yOffset = photoView.frame.origin.y + photoView.frame.size.height + 15.0;
            
        } else {
            
            UIImageView *loginImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_dash_settings_login.png"]];
            loginImageView.frame = (CGRect){
                floorf((_loginLogoutButtonView.bounds.size.width - loginImageView.frame.size.width) / 2.0),
                _loginLogoutButtonView.bounds.origin.y,
                loginImageView.frame.size.width,
                loginImageView.frame.size.height
            };
            [_loginLogoutButtonView addSubview:loginImageView];
            yOffset = loginImageView.frame.origin.y + loginImageView.frame.size.height + 8.0;
        }
        
        UILabel *profileLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        profileLabel.autoresizingMask = UIViewAutoresizingNone;
        profileLabel.backgroundColor = [UIColor clearColor];
        profileLabel.font = [Theme settingsProfileFont];
        profileLabel.textColor = [UIColor whiteColor];
        profileLabel.shadowColor = [UIColor blackColor];
        profileLabel.shadowOffset = CGSizeMake(0.0, -1.0);
        profileLabel.text = (currentUser == nil) ? @"SIGN IN" : @"LOGOUT";
        [profileLabel sizeToFit];
        profileLabel.frame = (CGRect){
            floorf((_loginLogoutButtonView.bounds.size.width - profileLabel.frame.size.width) / 2.0),
            yOffset,
            profileLabel.frame.size.width,
            profileLabel.frame.size.height
        };
        [_loginLogoutButtonView addSubview:profileLabel];

        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loginLogoutTapped:)];
        [_loginLogoutButtonView addGestureRecognizer:tapGesture];
        
    }
    return _loginLogoutButtonView;
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
            42.0,
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
    
    UIImageView *content1ImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_dash_settings_firstscreen_bg.png"]];
    UIImageView *content2ImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_dash_settings_secondscreen_bg.png"]];
    UIView *content1View = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, content1ImageView.frame.size.width, content1ImageView.frame.size.height)];
    UIView *content2View = [[UIView alloc] initWithFrame:CGRectMake(content1ImageView.frame.size.width, 0.0, content2ImageView.frame.size.width, content2ImageView.frame.size.height)];
    [content1View addSubview:content1ImageView];
    [content2View addSubview:content2ImageView];
    [scrollView addSubview:content1View];
    [scrollView addSubview:content2View];
    
    // Theme
    UIView *themeChooserContainerView = [UIView new];
    themeChooserContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    [themeChooserContainerView addSubview:self.themeLabel];
    [themeChooserContainerView addSubview:self.themeTabView];
    [content1View addSubview:themeChooserContainerView];
    
    // Link buttons
    UIView *linkButtonContainerView = [UIView new];
    linkButtonContainerView.translatesAutoresizingMaskIntoConstraints = NO;

    self.aboutButton = [UIButton new];
    [self.aboutButton addTarget:self action:@selector(aboutPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.aboutButton setBackgroundImage:[UIImage imageNamed:@"cook_dash_settings_icon_web"] forState:UIControlStateNormal];
    [self.aboutButton setBackgroundImage:[UIImage imageNamed:@"cook_dash_settings_icon_web_onpress"] forState:UIControlStateHighlighted];
    self.aboutButton.translatesAutoresizingMaskIntoConstraints = NO;
    UILabel *aboutLabel = [UILabel new];
    aboutLabel.text = @"ABOUT";
    aboutLabel.textAlignment = NSTextAlignmentCenter;
    aboutLabel.backgroundColor = [UIColor clearColor];
    aboutLabel.font = [Theme settingsProfileFont];
    aboutLabel.textColor = [UIColor whiteColor];
    aboutLabel.shadowColor = [UIColor blackColor];
    aboutLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    aboutLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [linkButtonContainerView addSubview:self.aboutButton];
    [linkButtonContainerView addSubview:aboutLabel];
    
    self.supportButton = [UIButton new];
    [self.supportButton addTarget:self action:@selector(supportPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.supportButton setBackgroundImage:[UIImage imageNamed:@"cook_dash_settings_icon_support"] forState:UIControlStateNormal];
    [self.supportButton setBackgroundImage:[UIImage imageNamed:@"cook_dash_settings_icon_support_onpress"] forState:UIControlStateHighlighted];
    self.supportButton.translatesAutoresizingMaskIntoConstraints = NO;
    UILabel *supportLabel = [UILabel new];
    supportLabel.text = @"SUPPORT";
    supportLabel.textAlignment = NSTextAlignmentCenter;
    supportLabel.backgroundColor = [UIColor clearColor];
    supportLabel.font = [Theme settingsProfileFont];
    supportLabel.textColor = [UIColor whiteColor];
    supportLabel.shadowColor = [UIColor blackColor];
    supportLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    supportLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [linkButtonContainerView addSubview:supportLabel];
    [linkButtonContainerView addSubview:self.supportButton];
    
    self.facebookButton = [UIButton new];
    [self.facebookButton addTarget:self action:@selector(facebookPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.facebookButton setBackgroundImage:[UIImage imageNamed:@"cook_dash_settings_icon_facebook"] forState:UIControlStateNormal];
    [self.facebookButton setBackgroundImage:[UIImage imageNamed:@"cook_dash_settings_icon_facebook_onpress"] forState:UIControlStateHighlighted];
    self.facebookButton.translatesAutoresizingMaskIntoConstraints = NO;
    UILabel *facebookLabel = [UILabel new];
    facebookLabel.text = @"FACEBOOK";
    facebookLabel.textAlignment = NSTextAlignmentCenter;
    facebookLabel.backgroundColor = [UIColor clearColor];
    facebookLabel.font = [Theme settingsProfileFont];
    facebookLabel.textColor = [UIColor whiteColor];
    facebookLabel.shadowColor = [UIColor blackColor];
    facebookLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    facebookLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [linkButtonContainerView addSubview:facebookLabel];
    [linkButtonContainerView addSubview:self.facebookButton];
    
    self.twitterButton = [UIButton new];
    [self.twitterButton addTarget:self action:@selector(twitterPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.twitterButton setBackgroundImage:[UIImage imageNamed:@"cook_dash_settings_icon_twitter"] forState:UIControlStateNormal];
    [self.twitterButton setBackgroundImage:[UIImage imageNamed:@"cook_dash_settings_icon_twitter_onpress"] forState:UIControlStateHighlighted];
    self.twitterButton.translatesAutoresizingMaskIntoConstraints = NO;
    UILabel *twitterLabel = [UILabel new];
    twitterLabel.text = @"TWITTER";
    twitterLabel.textAlignment = NSTextAlignmentCenter;
    twitterLabel.backgroundColor = [UIColor clearColor];
    twitterLabel.font = [Theme settingsProfileFont];
    twitterLabel.textColor = [UIColor whiteColor];
    twitterLabel.shadowColor = [UIColor blackColor];
    twitterLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    twitterLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [linkButtonContainerView addSubview:twitterLabel];
    [linkButtonContainerView addSubview:self.twitterButton];
    
    { //Setting up constraints to space link buttons
        NSDictionary *metrics = @{@"height":@52.0, @"width":@52.0, @"labelWidth":@72, @"spacing":@20.0};
        NSDictionary *views = @{@"about" : self.aboutButton,
                                @"aboutLabel" : aboutLabel,
                                @"support" : self.supportButton,
                                @"supportLabel" : supportLabel,
                                @"facebook" : self.facebookButton,
                                @"facebookLabel" : facebookLabel,
                                @"twitter" : self.twitterButton,
                                @"twitterLabel" : twitterLabel};
        NSString *buttonConstraints = @"|-40.0-[about(width)]-spacing-[support(about)]-spacing-[facebook(about)]-spacing-[twitter(about)]-(>=20)-|";
        NSString *labelConstraints = @"|-30.0-[aboutLabel(labelWidth)][supportLabel(labelWidth)][facebookLabel(labelWidth)][twitterLabel(labelWidth)]";
        [linkButtonContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:buttonConstraints options:NSLayoutFormatAlignAllCenterY metrics:metrics views:views]];
        [linkButtonContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:labelConstraints options:NSLayoutFormatAlignAllCenterY metrics:metrics views:views]];
        [linkButtonContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-40-[about(height)]-5-[aboutLabel(16.0)]" options:NSLayoutFormatAlignAllCenterX metrics:metrics views:views]];
//        [middleContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(>=20)-[title(400)]-(>=20)-|" options:NSLayoutFormatAlignAllTop metrics:metrics views:views]];
    }
    [content1View addSubview:linkButtonContainerView];
    { //Setting up constraints to space container views
        NSDictionary *metrics = @{@"themeWidth":@258,
                                  @"linkWidth":@345,
                                  @"spacing":@2.0};
        NSDictionary *views = @{@"theme" : themeChooserContainerView,
                                @"links" : linkButtonContainerView};
        NSString *containerConstraints = @"|-285.0-[theme(themeWidth)][links(linkWidth)]";
        [content1View addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:containerConstraints
                                                                                        options:NSLayoutFormatAlignAllCenterY
                                                                                        metrics:metrics
                                                                                          views:views]];
        [content1View addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[theme]|"
                                                                                        options:0
                                                                                        metrics:metrics
                                                                                          views:views]];
        [content1View addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[links]|"
                                                                             options:0
                                                                             metrics:metrics
                                                                               views:views]];
    }
}

- (void)createLoginLogoutButton {
    [self.loginLogoutButtonView removeFromSuperview];
    _loginLogoutButtonView = nil;
    [self.scrollView addSubview:self.loginLogoutButtonView];
}

#pragma mark - Action handlers

- (void)aboutPressed:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.thecookapp.com/about"]];
}

- (void)supportPressed:(id)sender {
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailDialog = [[MFMailComposeViewController alloc] init];
        NSString *shareBody = @"SUPPORT STUFF";
        [mailDialog setSubject:@"Support for Cook"];
        [mailDialog setMessageBody:shareBody isHTML:NO];
        mailDialog.mailComposeDelegate = self;
        [self presentViewController:mailDialog animated:YES completion:nil];
    }
    else
        [[[UIAlertView alloc] initWithTitle:@"Mail" message:@"Please set up a mail account in Settings" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

- (void)facebookPressed:(id)sender {
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"fb://"]])
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"fb://profile/275459582557565"]];
    else
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://on.fb.me/13WDgDW"]];
}

- (void)twitterPressed:(id)sender {
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://"]])
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitter://user?screen_name=thecookapp"]];
    else
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.twitter.com/thecookapp"]];
}

- (void)loginLogoutTapped:(id)sender {
    
    if ([CKUser isLoggedIn]) {
        
        [CKUser logoutWithCompletion:^{
            // Post logout.
            [EventHelper postLogout];
        } failure:^(NSError *error) {
        }];
        
    } else {
        [self.delegate settingsViewControllerSignInRequested];
    }
    
}

- (void)loggedIn:(NSNotification *)notification {
    [self createLoginLogoutButton];
}

- (void)loggedOut:(NSNotification *)notification {
    [self createLoginLogoutButton];
}

#pragma mark - MFMailViewController delegate method
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    DLog(@"Support mail finished");
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
