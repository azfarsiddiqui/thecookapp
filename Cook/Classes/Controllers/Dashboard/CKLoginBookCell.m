//
//  CKLoginBookCell.m
//  Cook
//
//  Created by Jeff Tan-Ang on 10/10/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKLoginBookCell.h"
#import "EventHelper.h"
#import "CKUser.h"

@interface CKLoginBookCell ()

@property (nonatomic, strong) CKLoginView *loginView;
@property (nonatomic, strong) UIView *loginBannerView;
@property (nonatomic, strong) UIView *loginBackgroundView;
@property (nonatomic, strong) UIView *rightCornerView;
@property (nonatomic, strong) UIView *rightOverlayView;
@property (nonatomic, strong) UIView *leftCornerView;
@property (nonatomic, strong) UIView *leftOverlayView;

@end

@implementation CKLoginBookCell

- (id)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        [self initLoginView];
    }
    return self;
}

- (void)revealWithCompletion:(void (^)())completion {
    
    // Hide right corner first.
    self.rightCornerView.hidden = YES;
    
    // Transition banner background left, and fade out right overlay.
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationCurveEaseIn
                     animations:^{
                         self.loginBackgroundView.transform = CGAffineTransformMakeTranslation(-self.loginBackgroundView.frame.size.width, 0.0);
                         self.rightOverlayView.alpha = 0.0;
                         self.leftCornerView.alpha = 0.0;
                         self.leftOverlayView.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         [self.rightCornerView removeFromSuperview];
                         [self.rightOverlayView removeFromSuperview];
                         [self.loginBackgroundView removeFromSuperview];
                         [self.leftCornerView removeFromSuperview];
                         [self.leftOverlayView removeFromSuperview];
                         completion();
                     }];
}

#pragma mark - CKLoginViewDelegate

- (void)loginViewTapped {
    
    // Spin the facebook button.
    [self.loginView loginStarted];
    
    // Disable the benchtop while we login.
    [EventHelper postBenchtopFreeze:YES];
    
    // Dispatch login after one second.
    [self performSelector:@selector(performLogin) withObject:nil afterDelay:1.0];
}

#pragma mark - Private

- (void)initLoginView {
    
    // Login banner background image.
    UIImageView *loginBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_signin_banner.png"]];
    loginBackgroundView.userInteractionEnabled = YES;
    
    // Container to house all the banner elements
    UIView *loginBannerContainer = [[UIView alloc] initWithFrame:loginBackgroundView.frame];
    loginBannerContainer.center = self.contentView.center;
    loginBannerContainer.frame = CGRectMake(floorf(loginBannerContainer.frame.origin.x),
                                            floorf(loginBannerContainer.frame.origin.y),
                                            loginBannerContainer.frame.size.width,
                                            loginBannerContainer.frame.size.height);
    loginBannerContainer.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    loginBannerContainer.clipsToBounds = YES;   // To ensure left transition of background clips.
    
    // Position the left/right corners and overlays first.
    UIImageView *leftCornerView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_signin_banner_leftback.png"]];
    [loginBannerContainer addSubview:leftCornerView];
    self.leftCornerView = leftCornerView;
    UIImageView *rightCornerView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_signin_banner_rightback.png"]];
    [loginBannerContainer addSubview:rightCornerView];
    self.rightCornerView = rightCornerView;
    
    // Now position the background over.
    [loginBannerContainer addSubview:loginBackgroundView];
    self.loginBackgroundView = loginBackgroundView;
    
    // Followed by the left/right overlays.
    UIImageView *leftOverlayView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_signin_banner_leftoverlay.png"]];
    [loginBackgroundView addSubview:leftOverlayView];
    self.leftOverlayView = leftOverlayView;
    UIImageView *rightOverlayView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_signin_banner_rightoverlay.png"]];
    [loginBackgroundView addSubview:rightOverlayView];
    self.rightOverlayView = rightOverlayView;
    
    // Add the container to the cell.
    [self.contentView addSubview:loginBannerContainer];
    self.loginBannerView = loginBannerContainer;
    
    // Facebook button ontop of the background.
    CKLoginView *loginView = [[CKLoginView alloc] initWithDelegate:self];
    CGRect loginFrame = loginView.frame;
    loginFrame.origin = CGPointMake(floorf((loginBackgroundView.bounds.size.width - loginFrame.size.width) / 2.0),
                                    loginBackgroundView.bounds.size.height - loginFrame.size.height - 52.0);
    loginView.frame = loginFrame;
    [loginBackgroundView addSubview:loginView];
    self.loginView = loginView;
}
     
- (void)performLogin {
    
    // Now tries and log the user in.
    [CKUser loginWithFacebookCompletion:^{
        
        CKUser *user = [CKUser currentUser];
        if ([user isAdmin]) {
            [self.loginView loginAdminDone];
        } else {
            [self.loginView loginLoadingFriends:[user.friendIds count]];
        }
        
        [self informLoginSuccessful:YES];
        
    } failure:^(NSError *error) {
        DLog(@"Error logging in: %@", [error localizedDescription]);
        
        // Reset the facebook button.
        [self.loginView loginFailed];
        
        [self informLoginSuccessful:NO];
    }];
}

- (void)informLoginSuccessful:(BOOL)success {
    [EventHelper postLoginSuccessful:success];
}

@end
