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

@end

@implementation CKLoginBookCell

- (id)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        [self initLoginView];
    }
    return self;
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
    UIImageView *loginBanner = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_signin_banner.png"]];
    loginBanner.userInteractionEnabled = YES;
    loginBanner.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    loginBanner.center = self.contentView.center;
    loginBanner.frame = CGRectMake(floorf(loginBanner.frame.origin.x),
                                   floorf(loginBanner.frame.origin.y),
                                   loginBanner.frame.size.width,
                                   loginBanner.frame.size.height);
    [self.contentView addSubview:loginBanner];
    self.loginBannerView = loginBanner;
    
    CKLoginView *loginView = [[CKLoginView alloc] initWithDelegate:self];
    CGRect loginFrame = loginView.frame;
    loginFrame.origin = CGPointMake(floorf((loginBanner.bounds.size.width - loginFrame.size.width) / 2.0),
                                    loginBanner.bounds.size.height - loginFrame.size.height - 52.0);
    loginView.frame = loginFrame;
    [loginBanner addSubview:loginView];
    self.loginView = loginView;
}
     
- (void)performLogin {
    
    // Now tries and log the user in.
    [[CKUser currentUser] loginWithFacebookCompletion:^{
        
        [self.loginView loginDone];
        
        // Re-enable the benchtop
        [EventHelper postBenchtopFreeze:NO];
        
    } failure:^(NSError *error) {
        DLog(@"Error logging in: %@", [error localizedDescription]);
        
        // Reset the facebook button.
        [self.loginView loginFailed];
        
        // Re-enable the benchtop
        [EventHelper postBenchtopFreeze:NO];
        
    }];
}
@end
