//
//  DashboardTutorialViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 16/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "DashboardTutorialViewController.h"
#import "CKUserProfilePhotoView.h"
#import "CKUser.h"
#import "ImageHelper.h"

@interface DashboardTutorialViewController ()

@property (nonatomic, weak) id<DashboardTutorialViewControllerDelegate> delegate;
@property (nonatomic, strong) UIImageView *tutorialView;

@end

@implementation DashboardTutorialViewController

- (id)initWithDelegate:(id<DashboardTutorialViewControllerDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.tutorialView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [self.view addGestureRecognizer:tapGesture];
}

#pragma mark - Properties

- (UIImageView *)tutorialView {
    if (!_tutorialView) {
        _tutorialView = [[UIImageView alloc] initWithImage:[ImageHelper imageFromDiskNamed:@"cook_overlay_tutorial_dash" type:@"png"]];
        
        CKUserProfilePhotoView *photoView = [[CKUserProfilePhotoView alloc] initWithUser:[CKUser currentUser]
                                                                             placeholder:[UIImage imageNamed:@"cook_default_profile.png"]
                                                                             profileSize:ProfileViewSizeLargeIntro];
        photoView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin;
        photoView.frame = (CGRect){
            floorf((_tutorialView.bounds.size.width - photoView.frame.size.width) / 2.0) + 3.0,
            floorf((_tutorialView.bounds.size.height - photoView.frame.size.height) / 2.0) - 82.0,
            photoView.frame.size.width,
            photoView.frame.size.height
        };
        [_tutorialView addSubview:photoView];
    }
    return _tutorialView;
}

#pragma mark - Private methods

- (void)tapped:(UITapGestureRecognizer *)tapGesture {
    [self.delegate dashboardTutorialViewControllerDismissRequested];
}

@end
