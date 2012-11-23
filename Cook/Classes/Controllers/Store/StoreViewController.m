//
//  StoreViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 21/11/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "StoreViewController.h"
#import "ViewHelper.h"
#import "StoreCollectionViewController.h"

@interface StoreViewController ()

@property (nonatomic, assign) id<StoreViewControllerDelegate> delegate;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, strong) StoreCollectionViewController *featuredViewController;
@property (nonatomic, strong) StoreCollectionViewController *friendsViewController;

@end

@implementation StoreViewController

#define kStoreBookCellId    @"StoreBookCell"
#define kMenuHeight         80.0
#define kMenuGap            20.0
#define kSideGap            20.0
#define kVerticalInset      80.0

- (id)initWithDelegate:(id<StoreViewControllerDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight;
    [self initBackground];
    [self initButtons];
    [self initCollectionViews];
    
}

- (void)enable:(BOOL)enable {
    [self enable:enable completion:^{}];
}

- (void)enable:(BOOL)enable completion:(void (^)())completion {
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options:UIViewAnimationCurveEaseIn
                     animations:^{
                         [self showOverlay:enable animated:NO];
                     }
                     completion:^(BOOL finished) {
                         self.enabled = enable;
                         
                         if (enable) {
                             [self loadData];
                         } else {
                             [self unloadData];
                         }
                         
                         // Run completion block.
                         completion();
                     }];
}

- (void)showOverlay:(BOOL)show animated:(BOOL)animated {
    if (show && !self.overlayView) {
        self.overlayView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_dash_bg_overlay.png"]];
        self.overlayView.autoresizingMask = UIViewAutoresizingNone;
        self.overlayView.alpha = 0.0;
        [self.view addSubview:self.overlayView];
    }
    
    if (animated) {
        [UIView animateWithDuration:0.4
                              delay:0.0
                            options:UIViewAnimationCurveEaseIn
                         animations:^{
                             self.overlayView.alpha = show ? 1.0 : 0.0;
                         }
                         completion:^(BOOL finished) {
                         }];
    } else {
        self.overlayView.alpha = show ? 1.0 : 0.0;
    }
}


#pragma - Private methods

- (void)initBackground {
    
    // Tiled background
    UIView *backgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    backgroundView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight;
    backgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"cook_dash_bg_tile.png"]];
    [self.view addSubview:backgroundView];
    self.backgroundView = backgroundView;
}

- (void)initButtons {
    UIButton *closeButton = [ViewHelper buttonWithImage:[UIImage imageNamed:@"cook_customise_btns_cancel.png"]
                                                      target:self
                                                    selector:@selector(closeTapped:)];
    closeButton.frame = CGRectMake(kSideGap,
                                   floorf((kMenuHeight - closeButton.frame.size.height) / 2.0),
                                   closeButton.frame.size.width,
                                   closeButton.frame.size.height);
    [self.view addSubview:closeButton];
}

- (void)initCollectionViews {
    
    // First row.
    StoreCollectionViewController *featuredViewController = [[StoreCollectionViewController alloc] init];
    featuredViewController.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
    featuredViewController.view.frame = CGRectMake(0.0,
                                                   kVerticalInset,
                                                   self.view.bounds.size.width,
                                                   featuredViewController.view.frame.size.height);
    [self.view addSubview:featuredViewController.view];
    self.featuredViewController = featuredViewController;
    
    // Second row.
    StoreCollectionViewController *friendsViewController = [[StoreCollectionViewController alloc] init];
    friendsViewController.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    friendsViewController.view.frame = CGRectMake(0.0,
                                                  self.view.bounds.size.height - friendsViewController.view.frame.size.height - kVerticalInset,
                                                  self.view.bounds.size.width,
                                                  friendsViewController.view.frame.size.height);
    [self.view addSubview:friendsViewController.view];
    self.friendsViewController = friendsViewController;
    
}

- (void)closeTapped:(id)sender {
    [self.delegate storeViewControllerCloseRequested];
}

- (void)loadData {
    
}

- (void)unloadData {
    
}

@end
