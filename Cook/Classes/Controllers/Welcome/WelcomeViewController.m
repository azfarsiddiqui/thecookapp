//
//  WelcomeViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 25/05/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "WelcomeViewController.h"
#import "AppHelper.h"
#import "ViewHelper.h"
#import "CKPagingView.h"
#import "SignupViewController.h"

@interface WelcomeViewController () <SignupViewControllerDelegate>

@property (nonatomic, assign) id<WelcomeViewControllerDelegate> delegate;
@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) CKPagingView *pagingView;
@property (nonatomic, strong) SignupViewController *signupViewController;
@property (nonatomic, strong) UIButton *signUpButton;
@property (nonatomic, strong) UIButton *signInButton;
@property (nonatomic, strong) UILabel *signUpLabel;
@property (nonatomic, strong) UILabel *signInLabel;
@property (nonatomic, assign) BOOL animating;

@end

@implementation WelcomeViewController

#define kWelcomeCellId  @"WelcomeCellId"
#define kSignupCellId   @"SignupCellId"
#define kNumPages       4
#define kButtonWidth    150.0
#define kButtonGap      10.0

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
    
    // Coffee cup.
    UIView *coffeeCupView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_login_coffeecup.png"]];
    coffeeCupView.frame = CGRectMake(-100.0, -140.0, coffeeCupView.frame.size.width, coffeeCupView.frame.size.height);
    [self.view insertSubview:coffeeCupView belowSubview:overlayView];
    
    [self initCollectionView];
    [self initPagingView];
    
    // Buttons.
    [self.signUpButton addSubview:self.signUpLabel];
    [self.view addSubview:self.signUpButton];
    [self.signInButton addSubview:self.signInLabel];
    [self.view addSubview:self.signInButton];
}

#pragma mark - Properties

- (SignupViewController *)signupViewController {
    if (!_signupViewController) {
        _signupViewController = [[SignupViewController alloc] initWithDelegate:self];
        _signupViewController.view.hidden = NO;
    }
    return _signupViewController;
}

- (UIButton *)signUpButton {
    if (!_signUpButton) {
        UIImage *buttonImage = [[UIImage imageNamed:@"cook_login_btn_signup.png"]
                                resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 25.0, 0.0, 25.0)];
        _signUpButton = [ViewHelper buttonWithImage:buttonImage target:self selector:@selector(signUpButtonTapped:)];
        _signUpButton.frame = CGRectMake(floorf((self.view.bounds.size.width - (kButtonWidth * 2.0) - kButtonGap) / 2.0),
                                         self.view.bounds.size.height - buttonImage.size.height - 100.0,
                                         kButtonWidth,
                                         buttonImage.size.height);
    }
    return _signUpButton;
}

- (UIButton *)signInButton {
    if (!_signInButton) {
        UIImage *buttonImage = [[UIImage imageNamed:@"cook_login_btn_signup.png"]
                                resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 25.0, 0.0, 25.0)];
        _signInButton = [ViewHelper buttonWithImage:buttonImage target:self selector:@selector(signInButtonTapped:)];
        _signInButton.frame = CGRectMake(self.signUpButton.frame.origin.x + self.signUpButton.frame.size.width + kButtonGap,
                                         self.signUpButton.frame.origin.y,
                                         kButtonWidth,
                                         buttonImage.size.height);
    }
    return _signInButton;
}

- (UILabel *)signUpLabel {
    if (!_signUpLabel) {
        _signUpLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _signUpLabel.font = [UIFont fontWithName:@"BrandonGrotesque-Bold" size:16];
        _signUpLabel.textColor = [UIColor whiteColor];
        _signUpLabel.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
        _signUpLabel.shadowOffset = CGSizeMake(0.0, 1.0);
        _signUpLabel.backgroundColor = [UIColor clearColor];
        _signUpLabel.text = @"SIGN UP";
        [_signUpLabel sizeToFit];
        _signUpLabel.frame = CGRectMake(floorf((self.signUpButton.bounds.size.width - _signUpLabel.frame.size.width) / 2.0),
                                        floorf((self.signUpButton.bounds.size.height - _signUpLabel.frame.size.height) / 2.0) - 2.0,
                                        _signUpLabel.frame.size.width,
                                        _signUpLabel.frame.size.height);
    }
    return _signUpLabel;
}

- (UILabel *)signInLabel {
    if (!_signInLabel) {
        _signInLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _signInLabel.font = [UIFont fontWithName:@"BrandonGrotesque-Bold" size:16];
        _signInLabel.textColor = [UIColor whiteColor];
        _signInLabel.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
        _signInLabel.shadowOffset = CGSizeMake(0.0, 1.0);
        _signInLabel.backgroundColor = [UIColor clearColor];
        _signInLabel.text = @"SIGN IN";
        [_signInLabel sizeToFit];
        _signInLabel.frame = CGRectMake(floorf((self.signInButton.bounds.size.width - _signInLabel.frame.size.width) / 2.0),
                                        floorf((self.signInButton.bounds.size.height - _signInLabel.frame.size.height) / 2.0) - 2.0,
                                        _signInLabel.frame.size.width,
                                        _signInLabel.frame.size.height);
    }
    return _signInLabel;
}

#pragma mark - UIScrollViewDelegate {

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    self.animating = YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.animating = NO;
    [self updatePagingView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        self.animating = NO;
    }
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
    if (indexPath.item == 3) {
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

- (void)signUpButtonTapped:(id)sender {
    if (self.animating) {
        return;
    }
    [self.signupViewController enableSignUpMode:YES animated:YES];
    [self scrollToPage:3];
}

- (void)signInButtonTapped:(id)sender {
    if (self.animating) {
        return;
    }
    [self.signupViewController enableSignUpMode:NO animated:YES];
    [self scrollToPage:3];
}

- (void)scrollToPage:(NSInteger)page {
    [self.collectionView setContentOffset:CGPointMake(self.collectionView.bounds.size.width * page,
                                                      self.collectionView.contentOffset.y)
                                 animated:YES];
    [self.pagingView setPage:page];
}

@end
