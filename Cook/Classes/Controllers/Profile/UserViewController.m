//
//  UserViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 20/10/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "UserViewController.h"
#import "CKUserInfoView.h"

@interface UserViewController ()

@property (nonatomic, strong) CKUser *user;
@property (nonatomic, strong) CKUserInfoView *userInfoView;

@end

@implementation UserViewController

- (id)initWithUser:(CKUser *)user {
    if (self = [super init]) {
        self.user = user;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    
    self.userInfoView.frame = (CGRect){
        floorf((self.view.bounds.size.width - self.userInfoView.frame.size.width) / 2.0),
        floorf((self.view.bounds.size.height - self.userInfoView.frame.size.height) / 2.0),
        self.userInfoView.frame.size.width,
        self.userInfoView.frame.size.height
    };
    [self.view addSubview:self.userInfoView];
}

#pragma mark - Properties

- (CKUserInfoView *)userInfoView {
    if (!_userInfoView) {
        _userInfoView = [[CKUserInfoView alloc] initWithUser:self.user];
    }
    return _userInfoView;
}

#pragma mark - Private methods


@end
