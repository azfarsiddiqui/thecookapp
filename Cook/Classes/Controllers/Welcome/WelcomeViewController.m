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
#import "WelcomeCollectionViewLayout.h"
#import "PageHeaderView.h"
#import "CKSignInButtonView.h"
#import "EventHelper.h"

@interface WelcomeViewController () <SignupViewControllerDelegate, WelcomeCollectionViewLayoutDataSource,
    CKSignInButtonViewDelegate>

@property (nonatomic, assign) id<WelcomeViewControllerDelegate> delegate;
@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) CKPagingView *pagingView;
@property (nonatomic, strong) SignupViewController *signupViewController;
@property (nonatomic, strong) CKSignInButtonView *signUpButton;
@property (nonatomic, strong) CKSignInButtonView *signInButton;
@property (nonatomic, assign) BOOL animating;
@property (nonatomic, assign) BOOL enabled;

@property (nonatomic, strong) UIView *welcomePageView;
@property (nonatomic, strong) UIView *createPageView;
@property (nonatomic, strong) UIView *collectPageView;
@property (nonatomic, strong) UIView *welcomeImageView;
@property (nonatomic, strong) UIView *welcomeImageView2;
@property (nonatomic, strong) UIView *createImageView;
@property (nonatomic, strong) UIView *collectImageView;
@property (nonatomic, strong) UIView *collectImageView2;

@end

@implementation WelcomeViewController

#define kAdornmentCellId    @"AdornmentCellId"
#define kPageHeaderId       @"PageHeaderId"
#define kNumPages           4
#define kButtonWidth        150.0
#define kButtonGap          10.0
#define kWelcomeSection     0
#define kCreateSection      1
#define kCollectSection     2
#define kSignUpSection      3
#define kAdornmentTag       470
#define kLabelTitleFont     [UIFont fontWithName:@"BrandonGrotesque-Medium" size:67.0]
#define kLabelSubtitleFont  [UIFont fontWithName:@"BrandonGrotesque-Medium" size:28.0]
#define kPageHeaderSize     CGSizeMake(500.0, 500.0)
#define kLabelGap           10.0

- (id)initWithDelegate:(id<WelcomeViewControllerDelegate>)delegate {
    if (self = [super initWithCollectionViewLayout:[[WelcomeCollectionViewLayout alloc] initWithDataSource:self]]) {
        self.delegate = delegate;
        self.enabled = YES;
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
    overlayView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.38];
    [self.view insertSubview:overlayView belowSubview:self.collectionView];
    self.overlayView = overlayView;
    
    // Coffee cup.
    UIView *coffeeCupView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_login_coffeecup.png"]];
    coffeeCupView.frame = CGRectMake(-100.0, -140.0, coffeeCupView.frame.size.width, coffeeCupView.frame.size.height);
    [self.view insertSubview:coffeeCupView belowSubview:overlayView];
    
    [self initCollectionView];
    
    // Register login successful.
    [EventHelper registerLoginSucessful:self selector:@selector(loggedIn:)];
}

- (void)enable:(BOOL)enable {
    if (self.enabled == enable) {
        return;
    }
    
    self.enabled = enable;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:kWelcomeSection],
         [NSIndexPath indexPathForItem:1 inSection:kWelcomeSection]]];
    });
}

#pragma mark - Properties

- (SignupViewController *)signupViewController {
    if (!_signupViewController) {
        _signupViewController = [[SignupViewController alloc] initWithDelegate:self];
        _signupViewController.view.hidden = NO;
    }
    return _signupViewController;
}

- (CKPagingView *)pagingView {
    if (!_pagingView) {
        _pagingView = [[CKPagingView alloc] initWithNumPages:kNumPages type:CKPagingViewTypeHorizontal];
        _pagingView.frame = CGRectMake(0.0, 0.0, _pagingView.frame.size.width, _pagingView.frame.size.height);
    }
    return _pagingView;
}

- (CKSignInButtonView *)signUpButton {
    if (!_signUpButton) {
        UIImage *buttonImage = [[UIImage imageNamed:@"cook_login_btn_signup.png"]
                                resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 25.0, 0.0, 25.0)];
        _signUpButton = [[CKSignInButtonView alloc] initWithWidth:kButtonWidth image:buttonImage text:@"SIGN UP" activity:NO delegate:self];
    }
    return _signUpButton;
}

- (CKSignInButtonView *)signInButton {
    if (!_signInButton) {
        UIImage *buttonImage = [[UIImage imageNamed:@"cook_login_btn_signup.png"]
                                resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 25.0, 0.0, 25.0)];
        _signInButton = [[CKSignInButtonView alloc] initWithWidth:kButtonWidth image:buttonImage text:@"SIGN IN" activity:NO delegate:self];
    }
    return _signInButton;
}

- (UIView *)welcomeImageView {
    if (!_welcomeImageView) {
        _welcomeImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_login_recipes_left.png"]];
    }
    return _welcomeImageView;
}

- (UIView *)welcomeImageView2 {
    if (!_welcomeImageView2) {
        _welcomeImageView2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_login_recipes_right.png"]];
    }
    return _welcomeImageView2;
}

- (UIView *)createImageView {
    if (!_createImageView) {
        _createImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_login_mybook.png"]];
    }
    return _createImageView;
}

- (UIView *)collectImageView {
    if (!_collectImageView) {
        _collectImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_login_friendsbooks_left.png"]];
    }
    return _collectImageView;
}

- (UIView *)collectImageView2 {
    if (!_collectImageView2) {
        _collectImageView2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_login_friendsbooks_right.png"]];
    }
    return _collectImageView2;
}

- (UIView *)welcomePageView {
    if (!_welcomePageView) {
        CGSize size = [self sizeOfPageHeaderForPage:kWelcomeSection
                                          indexPath:[NSIndexPath indexPathForItem:0 inSection:kWelcomeSection]];
        _welcomePageView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, size.width, size.height)];
        _welcomePageView.backgroundColor = [UIColor clearColor];
        _welcomePageView.autoresizingMask = UIViewAutoresizingNone;
        
        // Title
        UILabel *titleLabel = [self createLabelWithFont:[UIFont fontWithName:@"BrandonGrotesque-Bold" size:67.0]
                                                   text:@"WELCOME" textAlignment:NSTextAlignmentCenter
                                          availableSize:size lineSpacing:-20.0];
        titleLabel.frame = CGRectMake(floorf((size.width - titleLabel.frame.size.width) / 2.0),
                                      0.0,
                                      titleLabel.frame.size.width,
                                      titleLabel.frame.size.height);
        [_welcomePageView addSubview:titleLabel];
        
        // Subtitle
        UILabel *subtitleLabel = [self createSubtitleLabelWithText:@"It's time to create your very\u2028own Cookbook for iPad."
                                                     textAlignment:NSTextAlignmentCenter availableSize:size];
        subtitleLabel.frame = CGRectMake(floorf((size.width - subtitleLabel.frame.size.width) / 2.0),
                                         titleLabel.frame.origin.y + titleLabel.frame.size.height + 40.0,
                                         subtitleLabel.frame.size.width,
                                         subtitleLabel.frame.size.height);
        [_welcomePageView addSubview:subtitleLabel];
        
        // SubSubtitle
        UILabel *subSubtitleLabel = [self createSubtitleLabelWithText:@"Gather all those scattered\u2028recipes love and bring\u2028them together in one place..."
                                                    textAlignment:NSTextAlignmentCenter availableSize:size];
        subSubtitleLabel.frame = CGRectMake(floorf((size.width - subSubtitleLabel.frame.size.width) / 2.0),
                                            subtitleLabel.frame.origin.y + subtitleLabel.frame.size.height + kLabelGap,
                                            subSubtitleLabel.frame.size.width,
                                            subSubtitleLabel.frame.size.height);
        [_welcomePageView addSubview:subSubtitleLabel];
        
    }
    return _welcomePageView;
}

- (UIView *)createPageView {
    if (!_createPageView) {
        CGSize size = [self sizeOfPageHeaderForPage:kCreateSection
                                          indexPath:[NSIndexPath indexPathForItem:0 inSection:kCreateSection]];
        _createPageView = [[UIView alloc] initWithFrame:CGRectZero];
        _createPageView.backgroundColor = [UIColor clearColor];
        _createPageView.autoresizingMask = UIViewAutoresizingNone;

        // Title
        UILabel *titleLabel = [self createLabelWithFont:[UIFont fontWithName:@"BrandonGrotesque-Bold" size:56.0]
                                                   text:@"CREATE YOUR\u2028COOKBOOK" textAlignment:NSTextAlignmentLeft
                                          availableSize:size lineSpacing:-15.0];
        titleLabel.frame = CGRectMake(0.0,
                                      50.0,
                                      titleLabel.frame.size.width,
                                      titleLabel.frame.size.height);
        [_createPageView addSubview:titleLabel];
        
        // Subtitle
        UILabel *subtitleLabel = [self createSubtitleLabelWithText:@"Forget Jamie or Delia, add all your\u2028favourite recipes, then customise \u2028the cover of your book and it's\u2028ready to share with your friends..."
                                                     textAlignment:NSTextAlignmentLeft availableSize:size];
        subtitleLabel.frame = CGRectMake(0.0,
                                         titleLabel.frame.origin.y + titleLabel.frame.size.height + kLabelGap,
                                         subtitleLabel.frame.size.width,
                                         subtitleLabel.frame.size.height);
        [_createPageView addSubview:subtitleLabel];
    }
    return _createPageView;
}

- (UIView *)collectPageView {
    if (!_collectPageView) {
        CGSize size = [self sizeOfPageHeaderForPage:kCollectSection
                                          indexPath:[NSIndexPath indexPathForItem:0 inSection:kCollectSection]];
        _collectPageView = [[UIView alloc] initWithFrame:CGRectZero];
        _collectPageView.backgroundColor = [UIColor clearColor];
        _collectPageView.autoresizingMask = UIViewAutoresizingNone;
        
        // Title
        UILabel *titleLabel = [self createLabelWithFont:[UIFont fontWithName:@"BrandonGrotesque-Bold" size:52.0]
                                                   text:@"COLLECT YOUR\u2028FRIENDS' BOOKS" textAlignment:NSTextAlignmentCenter
                                          availableSize:size lineSpacing:-15.0];
        titleLabel.frame = CGRectMake(floorf((size.width - titleLabel.frame.size.width) / 2.0),
                                      10.0,
                                      titleLabel.frame.size.width,
                                      titleLabel.frame.size.height);
        [_collectPageView addSubview:titleLabel];
        
        // Subtitle
        UILabel *subtitleLabel = [self createSubtitleLabelWithText:@"Check out your friends'\u2028books, see their cooking tips\u2028and make their best dishes.\u2028\u2028Or browse the library and\u2028discover new friends from\u2028around the world."
                                                     textAlignment:NSTextAlignmentCenter availableSize:size];
        subtitleLabel.frame = CGRectMake(floorf((size.width - subtitleLabel.frame.size.width) / 2.0),
                                         titleLabel.frame.origin.y + titleLabel.frame.size.height + kLabelGap + 5.0,
                                         subtitleLabel.frame.size.width,
                                         subtitleLabel.frame.size.height);
        [_collectPageView addSubview:subtitleLabel];
        
    }
    return _collectPageView;
}

#pragma mark - WelcomeCollectionViewLayoutDataSource methods

- (NSInteger)numberOfPagesForWelcomeLayout {
    return kNumPages;
}

- (NSInteger)numberOfAdornmentsForPage:(NSInteger)page {
    NSInteger numAdornments = 0;
    switch (page) {
        case kWelcomeSection:
            numAdornments = self.enabled ? 2 : 0;
            break;
        case kCreateSection:
            numAdornments = 1;
            break;
        case kCollectSection:
            numAdornments = 2;
            break;
        case kSignUpSection:
            break;
        default:
            break;
    }
    return numAdornments;
}

- (CGSize)sizeOfPageHeaderForPage:(NSInteger)page indexPath:(NSIndexPath *)indexPath {
    CGSize size = kPageHeaderSize;
    switch (page) {
        case kWelcomeSection:
            
            switch (indexPath.item) {
                case 0:
                    break;
                case 1:
                    size = self.signUpButton.frame.size;
                    break;
                case 2:
                    size = self.signInButton.frame.size;
                    break;
                case 3:
                    size = self.pagingView.frame.size;
                    break;
                default:
                    break;
            }
            
            break;
        case kCreateSection:
            break;
        case kCollectSection:
            break;
        case kSignUpSection:
            size = self.signupViewController.view.frame.size;
            break;
        default:
            break;
    }
    return size;
}

- (CGSize)sizeOfAdornmentForIndexPath:(NSIndexPath *)indexPath {
    CGSize size = CGSizeZero;
    switch (indexPath.section) {
        case kWelcomeSection:
            switch (indexPath.item) {
                case 0:
                    size = self.welcomeImageView.frame.size;
                    break;
                case 1:
                    size = self.welcomeImageView2.frame.size;
                    break;
                default:
                    break;
            }
            break;
        case kCreateSection:
            switch (indexPath.item) {
                case 0:
                    size = self.createImageView.frame.size;
                    break;
                default:
                    break;
            }
            break;
        case kCollectSection:
            switch (indexPath.item) {
                case 0:
                    size = self.collectImageView.frame.size;
                    break;
                case 1:
                    size = self.collectImageView2.frame.size;
                    break;
                default:
                    break;
            }
            break;
        case kSignUpSection:
            break;
        default:
            break;
    }
    
    return size;
}

#pragma mark - UIScrollViewDelegate

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
    return [self numberOfPagesForWelcomeLayout];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self numberOfAdornmentsForPage:section];
}

- (UICollectionReusableView *)collectionView: (UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionReusableView *reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                                withReuseIdentifier:kPageHeaderId
                                                                                       forIndexPath:indexPath];
    PageHeaderView *pageHeaderView = (PageHeaderView *)reusableView;
    pageHeaderView.backgroundColor = [UIColor clearColor];
    UIView *contentView = nil;
    
    switch (indexPath.section) {
        case kWelcomeSection:
            
            switch (indexPath.item) {
                case 0:
                    contentView = self.welcomePageView;
                    break;
                case 1:
                    contentView = self.signUpButton;
                    break;
                case 2:
                    contentView = self.signInButton;
                    break;
                case 3:
                    contentView = self.pagingView;
                    break;
                default:
                    break;
            }
            break;
        case kCreateSection:
            contentView = self.createPageView;
            break;
        case kCollectSection:
            contentView = self.collectPageView;
            break;
        case kSignUpSection:
            contentView = self.signupViewController.view;
            break;
        default:
            break;
    }
    
    [pageHeaderView setContentView:contentView];
    return pageHeaderView;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UIView *contentView = nil;
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kAdornmentCellId forIndexPath:indexPath];
    [[cell.contentView viewWithTag:kAdornmentTag] removeFromSuperview];
    
    switch (indexPath.section) {
        case kWelcomeSection:
            switch (indexPath.item) {
                case 0:
                    contentView = self.welcomeImageView;
                    break;
                case 1:
                    contentView = self.welcomeImageView2;
                    break;
                default:
                    break;
            }
            break;
        case kCreateSection:
            contentView = self.createImageView;
            break;
        case kCollectSection:
            switch (indexPath.item) {
                case 0:
                    contentView = self.collectImageView;
                    break;
                case 1:
                    contentView = self.collectImageView2;
                    break;
                default:
                    break;
            }
            break;
        case kSignUpSection:
            break;
        default:
            break;
    }
    
    if (contentView)  {
        contentView.tag = kAdornmentTag;
        [cell.contentView addSubview:contentView];
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate methods

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma mark - SignupViewControllerDelegate methods

- (void)signupViewControllerFocused:(BOOL)focused {
    [self signUpViewControllerModalRequested:focused];
}

- (void)signUpViewControllerModalRequested:(BOOL)modal {
    self.collectionView.scrollEnabled = !modal;
    self.pagingView.alpha = modal ? 0.0 : 1.0;
}

#pragma mark - CKSignInButtonViewDelegate methods

- (void)signInTappedForButtonView:(CKSignInButtonView *)buttonView {
    if (self.animating) {
        return;
    }
    
    [self.signupViewController enableSignUpMode:(self.signUpButton == buttonView) animated:YES];
    [self scrollToPage:kSignUpSection];
}

#pragma mark - Private methods

- (void)initCollectionView {
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.pagingEnabled = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kAdornmentCellId];
    [self.collectionView registerClass:[PageHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:kPageHeaderId];
}

- (void)updatePagingView {
    CGFloat pageSpan = self.collectionView.contentOffset.x;
    NSInteger page = (pageSpan / self.collectionView.bounds.size.width);
    [self.pagingView setPage:page];
}

- (void)scrollToPage:(NSInteger)page {
    [self.collectionView setContentOffset:CGPointMake(self.collectionView.bounds.size.width * page,
                                                      self.collectionView.contentOffset.y)
                                 animated:YES];
    [self.pagingView setPage:page];
}

- (UILabel *)createTitleLabelWithText:(NSString *)text textAlignment:(NSTextAlignment)textAlignment
                        availableSize:(CGSize)availableSize {
    
    return [self createLabelWithFont:kLabelTitleFont text:text textAlignment:textAlignment availableSize:availableSize
                         lineSpacing:-20.0];
}

- (UILabel *)createSubtitleLabelWithText:(NSString *)text textAlignment:(NSTextAlignment)textAlignment
                        availableSize:(CGSize)availableSize {
    
    return [self createLabelWithFont:kLabelSubtitleFont text:text textAlignment:textAlignment availableSize:availableSize
                         lineSpacing:-8.0];
}

- (UILabel *)createLabelWithFont:(UIFont *)font text:(NSString *)text textAlignment:(NSTextAlignment)textAlignment
                   availableSize:(CGSize)availableSize lineSpacing:(CGFloat)lineSpacing {
    
    // Paragraph attributes.
    NSDictionary *textAttributes = [self textAttributesForFont:font lineSpacing:lineSpacing textAlignment:textAlignment];
    NSAttributedString *textDisplay = [[NSAttributedString alloc] initWithString:text attributes:textAttributes];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.attributedText = textDisplay;
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    CGSize size = [label sizeThatFits:availableSize];
    label.frame = CGRectMake(0.0, 0.0, size.width, size.height);
    
    return label;
}

- (NSDictionary *)textAttributesForFont:(UIFont *)font lineSpacing:(CGFloat)lineSpacing
                               textAlignment:(NSTextAlignment)textAlignment {
    
    NSLineBreakMode lineBreakMode = NSLineBreakByWordWrapping;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = lineBreakMode;
    paragraphStyle.lineSpacing = lineSpacing;
    paragraphStyle.alignment = textAlignment;
    
    NSShadow *shadow = [NSShadow new];
    shadow.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
    shadow.shadowOffset = CGSizeMake(0.0, 2.0);
    shadow.shadowBlurRadius = 4.0;

    return [NSDictionary dictionaryWithObjectsAndKeys:
            font, NSFontAttributeName,
            [UIColor whiteColor], NSForegroundColorAttributeName,
            paragraphStyle, NSParagraphStyleAttributeName,
            shadow, NSShadowAttributeName,
            nil];
}

- (void)loggedIn:(NSNotification *)notification {
    BOOL success = [EventHelper loginSuccessfulForNotification:notification];
    if (success) {
        [self.delegate welcomeViewControllerLoggedIn];
    }
}

@end
