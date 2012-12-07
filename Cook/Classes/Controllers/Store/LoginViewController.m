//
//  LoginViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 7/12/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "LoginViewController.h"
#import "CKLoginView.h"
#import "EventHelper.h"
#import "CKUser.h"

@interface LoginViewController () <CKLoginViewDelegate>

@property (nonatomic, assign) id<LoginViewControllerDelegate> delegate;
@property (nonatomic, strong) UIView *loginOverlayView;
@property (nonatomic, strong) UIView *loginBannerView;
@property (nonatomic, strong) UIView *rightShadowView;
@property (nonatomic, strong) UIView *leftShadowView;
@property (nonatomic, strong) CKLoginView *loginButton;

@end

@implementation LoginViewController

- (id)initWithDelegate:(id<LoginViewControllerDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initLoginView];
}

#pragma mark - CKLoginViewDelegate

- (void)loginViewTapped {
    
    // Spin the facebook button.
    [self.loginButton loginStarted];
    
    // Dispatch login after one second.
    [self performSelector:@selector(performLogin) withObject:nil afterDelay:1.0];
}

#pragma mark - Private methods

- (void)initLoginView {
    // Login overlay.
    UIImageView *loginOverlayView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_library_signin_banner_overlay.png"]];
    self.view.frame = loginOverlayView.frame;
    loginOverlayView.userInteractionEnabled = YES;
    [self.view addSubview:loginOverlayView];
    self.loginOverlayView = loginOverlayView;
    
    // Banner.
    UIImageView *loginBannerView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_library_signin_banner.png"]];
    loginBannerView.frame = CGRectMake(floorf((self.view.bounds.size.width - loginBannerView.frame.size.width) / 2.0),
                                       floorf((self.view.frame.size.height - loginBannerView.frame.size.height) / 2.0) + 70.0,
                                       loginBannerView.frame.size.width,
                                       loginBannerView.frame.size.height);
    //        loginBannerView.alpha = 0.5;
    loginBannerView.userInteractionEnabled = YES;
    [self.view addSubview:loginBannerView];
    self.loginBannerView = loginBannerView;
    
    // Right/Left shadows.
    UIImageView *rightShadowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_library_signin_banner_right.png"]];
    rightShadowView.userInteractionEnabled = YES;
    [loginBannerView addSubview:rightShadowView];
    self.rightShadowView = rightShadowView;
    UIImageView *leftShadowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_library_signin_banner_left.png"]];
    leftShadowView.userInteractionEnabled = YES;
    [loginBannerView addSubview:leftShadowView];
    self.leftShadowView = leftShadowView;
    
    // Login button
    CKLoginView *loginButton = [[CKLoginView alloc] initWithDelegate:self];
    loginButton.frame = CGRectMake(560.0,
                                   150.0,
                                   loginButton.frame.size.width,
                                   loginButton.frame.size.height);
    [loginBannerView addSubview:loginButton];
    self.loginButton = loginButton;
}

- (void)performLogin {
    
    // Now tries and log the user in.
    [CKUser loginWithFacebookCompletion:^{
        
        CKUser *user = [CKUser currentUser];
        if (user.admin) {
            [self.loginButton loginAdminDone];
        } else {
            [self.loginButton loginLoadingFriends:[user numFollows]];
        }
        
        [self informLoginSuccessful:YES];
        
    } failure:^(NSError *error) {
        DLog(@"Error logging in: %@", [error localizedDescription]);
        
        // Reset the facebook button.
        [self.loginButton loginFailed];
        
        [self informLoginSuccessful:NO];
    }];
}

- (void)informLoginSuccessful:(BOOL)success {
    
    if (success) {
        [self reveal];
    }
    
    // Inform login result.
    [EventHelper postLoginSuccessful:success];
}

- (void)reveal {
    
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationCurveEaseIn
                     animations:^{
                         
                         // Move right shadow off to the right.
                         self.rightShadowView.transform = CGAffineTransformMakeTranslation(self.rightShadowView.frame.size.width, 0.0);
                         
                     }
                     completion:^(BOOL finished) {
        
                         [UIView animateWithDuration:0.4
                                               delay:0.0
                                             options:UIViewAnimationCurveEaseIn
                                          animations:^{
                                              
                                              // Fade out the loginOverlay view.
                                              self.loginOverlayView.alpha = 0.0;
                                              
                                              // Move login banner off to the left.
                                              self.loginBannerView.transform = CGAffineTransformMakeTranslation(-self.loginBannerView.frame.size.width, 0.0);
                                              
                                          }
                                          completion:^(BOOL finished) {
                                              
                                              [self.delegate loginViewControllerSuccessful:YES];
                                              
                                          }];
                     }];
    
}

@end
