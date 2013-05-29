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

@interface WelcomeViewController () <SignupViewControllerDelegate, WelcomeCollectionViewLayoutDataSource>

@property (nonatomic, assign) id<WelcomeViewControllerDelegate> delegate;
@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) CKPagingView *pagingView;
@property (nonatomic, strong) SignupViewController *signupViewController;
@property (nonatomic, strong) UIButton *signUpButton;
@property (nonatomic, strong) UIButton *signInButton;
@property (nonatomic, strong) UILabel *signUpLabel;
@property (nonatomic, strong) UILabel *signInLabel;
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
#define kLabelTitleFont     [UIFont fontWithName:@"BrandonGrotesque-Bold" size:52.0]
#define kLabelSubtitleFont  [UIFont fontWithName:@"BrandonGrotesque-Medium" size:26.0]
#define kPageHeaderSize     CGSizeMake(500.0, 500.0)
#define kLabelGap           10.0

- (id)initWithDelegate:(id<WelcomeViewControllerDelegate>)delegate {
    if (self = [super initWithCollectionViewLayout:[[WelcomeCollectionViewLayout alloc] initWithDataSource:self]]) {
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
//    [self.view addSubview:self.signUpButton];
    [self.signInButton addSubview:self.signInLabel];
//    [self.view addSubview:self.signInButton];
}

- (void)enable:(BOOL)enable {
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

- (UIButton *)signUpButton {
    if (!_signUpButton) {
        UIImage *buttonImage = [[UIImage imageNamed:@"cook_login_btn_signup.png"]
                                resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 25.0, 0.0, 25.0)];
        _signUpButton = [ViewHelper buttonWithImage:buttonImage target:self selector:@selector(signUpButtonTapped:)];
        _signUpButton.frame = CGRectMake(0.0, 0.0, kButtonWidth, buttonImage.size.height);
    }
    return _signUpButton;
}

- (UIButton *)signInButton {
    if (!_signInButton) {
        UIImage *buttonImage = [[UIImage imageNamed:@"cook_login_btn_signup.png"]
                                resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 25.0, 0.0, 25.0)];
        _signInButton = [ViewHelper buttonWithImage:buttonImage target:self selector:@selector(signInButtonTapped:)];
        _signInButton.frame = CGRectMake(0.0, 0.0, kButtonWidth, buttonImage.size.height);
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
        UILabel *titleLabel = [self createTitleLabelWithText:@"WELCOME" textAlignment:NSTextAlignmentCenter availableSize:size];
        titleLabel.frame = CGRectMake(floorf((size.width - titleLabel.frame.size.width) / 2.0),
                                      0.0,
                                      titleLabel.frame.size.width,
                                      titleLabel.frame.size.height);
        [_welcomePageView addSubview:titleLabel];
        
        // Subtitle
        UILabel *subtitleLabel = [self createSubtitleLabelWithText:@"Cook helps you create your very own\u2028Cookbook for iPad"
                                                     textAlignment:NSTextAlignmentCenter availableSize:size];
        subtitleLabel.frame = CGRectMake(floorf((size.width - subtitleLabel.frame.size.width) / 2.0),
                                         titleLabel.frame.origin.y + titleLabel.frame.size.height + kLabelGap,
                                         subtitleLabel.frame.size.width,
                                         subtitleLabel.frame.size.height);
        [_welcomePageView addSubview:subtitleLabel];
        
        // SubSubtitle
        UILabel *subSubtitleLabel = [self createSubtitleLabelWithText:@"Gather all those scattered recipes\u2028you love and bring them\u2028together in one place..."
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
        UILabel *titleLabel = [self createTitleLabelWithText:@"CREATE YOUR\u2028COOKBOOK"
                                               textAlignment:NSTextAlignmentLeft availableSize:size];
        titleLabel.frame = CGRectMake(0.0,
                                      0.0,
                                      titleLabel.frame.size.width,
                                      titleLabel.frame.size.height);
        [_createPageView addSubview:titleLabel];
        
        // Subtitle
        UILabel *subtitleLabel = [self createSubtitleLabelWithText:@"Forget Jame or Delia, add all your\u2028favourite recipes, then customise the\u2028cover of your book and it's ready to share\nwith your friends"
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
        UILabel *titleLabel = [self createTitleLabelWithText:@"COLLECT YOUR\u2028FRIENDS' BOOKS"
                                               textAlignment:NSTextAlignmentCenter availableSize:size];
        titleLabel.frame = CGRectMake(floorf((size.width - titleLabel.frame.size.width) / 2.0),
                                      0.0,
                                      titleLabel.frame.size.width,
                                      titleLabel.frame.size.height);
        [_collectPageView addSubview:titleLabel];
        
        // Subtitle
        UILabel *subtitleLabel = [self createSubtitleLabelWithText:@"Check out your friends' books, see their cooking tips and make their best dishes or\u2028browse the library and discover new\u2028friends from around the world."
                                                     textAlignment:NSTextAlignmentCenter availableSize:size];
        subtitleLabel.frame = CGRectMake(floorf((size.width - subtitleLabel.frame.size.width) / 2.0),
                                         titleLabel.frame.origin.y + titleLabel.frame.size.height + kLabelGap,
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
    self.collectionView.scrollEnabled = !focused;
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

- (void)signUpButtonTapped:(id)sender {
    if (self.animating) {
        return;
    }
    [self.signupViewController enableSignUpMode:YES animated:YES];
    [self scrollToPage:kSignUpSection];
}

- (void)signInButtonTapped:(id)sender {
    if (self.animating) {
        return;
    }
    [self.signupViewController enableSignUpMode:NO animated:YES];
    [self scrollToPage:kSignUpSection];
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
    shadow.shadowOffset = CGSizeMake(0.0, 1.0);

    return [NSDictionary dictionaryWithObjectsAndKeys:
            font, NSFontAttributeName,
            [UIColor whiteColor], NSForegroundColorAttributeName,
            paragraphStyle, NSParagraphStyleAttributeName,
            shadow, NSShadowAttributeName,
            nil];
}


@end
