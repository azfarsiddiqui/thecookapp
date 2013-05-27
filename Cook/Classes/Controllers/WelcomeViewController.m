//
//  WelcomeViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 25/05/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "WelcomeViewController.h"
#import "AppHelper.h"
#import "CKPagingView.h"
#import "SignupViewController.h"

@interface WelcomeViewController () <SignupViewControllerDelegate>

@property (nonatomic, assign) id<WelcomeViewControllerDelegate> delegate;
@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) CKPagingView *pagingView;
@property (nonatomic, strong) SignupViewController *signupViewController;

@end

@implementation WelcomeViewController

#define kWelcomeCellId  @"WelcomeCellId"
#define kSignupCellId   @"SignupCellId"
#define kNumPages       4

- (id)initWithDelegate:(id<WelcomeViewControllerDelegate>)delegate {
    if (self = [super initWithCollectionViewLayout:[[UICollectionViewFlowLayout alloc] init]]) {
        self.delegate = delegate;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.frame = [[AppHelper sharedInstance] fullScreenFrame];
    self.view.backgroundColor = [UIColor clearColor];
    
    // Underlay.
    UIView *overlayView = [[UIView alloc] initWithFrame:self.view.bounds];
    overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    overlayView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
    [self.view insertSubview:overlayView belowSubview:self.collectionView];
    self.overlayView = overlayView;
    
    [self initCollectionView];
    [self initPagingView];
}

#pragma mark - Properties

- (SignupViewController *)signupViewController {
    if (!_signupViewController) {
        _signupViewController = [[SignupViewController alloc] initWithDelegate:self];
    }
    return _signupViewController;
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return kNumPages;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = nil;
    if (indexPath.item == 0) {
        cell = [self signupCellAtIndexPath:indexPath];
    } else {
        cell = [self welcomeCellAtIndexPath:indexPath];
    }
    return cell;
}

#pragma mark - UICollectionViewDelegate methods

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma mark - UICollectionViewDelegateFlowLayout methods

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return self.view.bounds.size;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    
    return UIEdgeInsetsZero;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    
    // Between rows
    return 0.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    
    // Between columns
    return 0.0;
}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self updatePagingView];
}

#pragma mark - SignupViewControllerDelegate methods

- (void)signupViewControllerFocused:(BOOL)focused {
    self.collectionView.scrollEnabled = !focused;
}

#pragma mark - Private methods

- (void)initCollectionView {
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.pagingEnabled = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kWelcomeCellId];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kSignupCellId];
}

- (void)initPagingView {
    CKPagingView *pagingView = [[CKPagingView alloc] initWithNumPages:kNumPages type:CKPagingViewTypeHorizontal];
    pagingView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    pagingView.frame = CGRectMake(floorf((self.view.bounds.size.width - pagingView.frame.size.width) / 2.0),
                                  self.view.bounds.size.height - 100.0,
                                  pagingView.frame.size.width,
                                  pagingView.frame.size.height);
    [self.view addSubview:pagingView];
    self.pagingView = pagingView;
}

- (void)updatePagingView {
    CGFloat pageSpan = self.collectionView.contentOffset.x;
    NSInteger page = (pageSpan / self.collectionView.bounds.size.width);
    [self.pagingView setPage:page];
}

- (UICollectionViewCell *)signupCellAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *signupCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:kSignupCellId
                                                                                      forIndexPath:indexPath];;
    if (!self.signupViewController.view.superview) {
        self.signupViewController.view.frame = signupCell.contentView.bounds;
        [signupCell.contentView addSubview:self.signupViewController.view];
    }
    return signupCell;
}

- (UICollectionViewCell *)welcomeCellAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *welcomeCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:kWelcomeCellId
                                                                                       forIndexPath:indexPath];;
    return welcomeCell;
}

@end
