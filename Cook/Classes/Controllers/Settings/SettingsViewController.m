//
//  SettingsViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 26/10/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

#define kSettingsHeight     160.0
#define kNumPages           2

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_dash_bg_settings.png"]];
    self.view.frame = CGRectMake(0.0, 0.0, backgroundView.frame.size.width, kSettingsHeight);
    self.view.clipsToBounds = NO;   // So that background extends below.
    [self.view addSubview:backgroundView];
    
    [self initSettingsContent];
}

#pragma mark - Private methods

- (void)initSettingsContent {
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.contentSize = CGSizeMake(self.view.bounds.size.width * kNumPages, self.view.bounds.size.height);
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.pagingEnabled = YES;
    [self.view addSubview:scrollView];
    
    CGFloat offset = 0.0;
    for (NSUInteger pageNumber = 0; pageNumber < kNumPages; pageNumber++) {
        UIImageView *contentView = [[UIImageView alloc] initWithImage:
                                    [UIImage imageNamed:[NSString stringWithFormat:@"cook_dash_settingsplaceholder%d.png", pageNumber + 1]]];
        contentView.frame = CGRectMake(offset, 0.0, contentView.frame.size.width, contentView.frame.size.height);
        [scrollView addSubview:contentView];
        offset += contentView.frame.size.width;
    }
}

@end
