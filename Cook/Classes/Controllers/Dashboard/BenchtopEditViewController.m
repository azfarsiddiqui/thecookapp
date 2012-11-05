//
//  BenchtopEditViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 5/11/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "BenchtopEditViewController.h"
#import "IllustrationViewController.h"

@interface BenchtopEditViewController ()

@property (nonatomic, assign) id<BenchtopEditViewControllerDelegate> delegate;
@property (nonatomic, strong) UIView *colourMenuView;
@property (nonatomic, strong) IllustrationViewController *illustrationViewController;

@end

@implementation BenchtopEditViewController

#define kSideGap    20.0
#define kMenuHeight 60.0

- (id)initWithDelegate:(id<BenchtopEditViewControllerDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}

- (void)viewDidLoad {
    [self initColourMenu];
    [self initIllustrationMenu];
}

- (void)showEditPalette:(BOOL)show animated:(BOOL)animated {
    DLog();
    CGAffineTransform colourMenuTransform = show ? CGAffineTransformMakeTranslation(0.0, self.colourMenuView.frame.size.height) : CGAffineTransformIdentity;
    CGAffineTransform illustrationTransform = show ? CGAffineTransformMakeTranslation(0.0, -self.illustrationViewController.view.frame.size.height) : CGAffineTransformIdentity;
    if (animated) {
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationCurveEaseOut
                         animations:^{
                             self.colourMenuView.alpha = show ? 1.0 : 0.0;
                             self.illustrationViewController.view.alpha = show ? 1.0 : 0.0;
                             self.colourMenuView.transform = colourMenuTransform;
                             self.illustrationViewController.view.transform = illustrationTransform;
                         }
                         completion:^(BOOL finished) {
                         }];
    } else {
        self.colourMenuView.alpha = show ? 1.0 : 0.0;
        self.illustrationViewController.view.alpha = show ? 1.0 : 0.0;
        self.colourMenuView.transform = colourMenuTransform;
        self.illustrationViewController.view.transform = illustrationTransform;
    }
}

#pragma mark - Private methods

- (void)initColourMenu {
    
    UIView *colourMenuView = [[UIView alloc] initWithFrame:CGRectMake(0.0, -kMenuHeight, self.view.bounds.size.width, kMenuHeight)];
    colourMenuView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth;
    colourMenuView.backgroundColor = [UIColor clearColor];
    
    // Edit cancel button.
    UIButton *editCancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [editCancelButton addTarget:self action:@selector(editCancelTapped:) forControlEvents:UIControlEventTouchUpInside];
    [editCancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [editCancelButton sizeToFit];
    editCancelButton.frame = CGRectMake(kSideGap,
                                        floorf((kMenuHeight - editCancelButton.frame.size.height) / 2.0),
                                        editCancelButton.frame.size.width,
                                        editCancelButton.frame.size.height);
    editCancelButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
    [colourMenuView addSubview:editCancelButton];
    
    // Edit done button.
    UIButton *editDoneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [editDoneButton addTarget:self action:@selector(editDoneTapped:) forControlEvents:UIControlEventTouchUpInside];
    [editDoneButton setTitle:@"Done" forState:UIControlStateNormal];
    [editDoneButton sizeToFit];
    editDoneButton.frame = CGRectMake(colourMenuView.bounds.size.width - editDoneButton.frame.size.width - kSideGap,
                                      floorf((kMenuHeight - editDoneButton.frame.size.height) / 2.0),
                                      editDoneButton.frame.size.width,
                                      editDoneButton.frame.size.height);
    editDoneButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin;
    [colourMenuView addSubview:editDoneButton];
    
    [self.view addSubview:colourMenuView];
    self.colourMenuView = colourMenuView;
}

- (void)initIllustrationMenu {
    IllustrationViewController *illustrationViewController = [[IllustrationViewController alloc] init];
    illustrationViewController.view.frame = CGRectMake(0.0,
                                                       self.view.bounds.size.height,
                                                       self.view.bounds.size.width,
                                                       illustrationViewController.view.frame.size.height);
    illustrationViewController.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:illustrationViewController.view];
    self.illustrationViewController = illustrationViewController;
}

#pragma mark - Private methods

- (void)editCancelTapped:(id)sender {
    [self.delegate editViewControllerCancelRequested];
}

- (void)editDoneTapped:(id)sender {
    [self.delegate editViewControllerDoneRequested];
}

@end
