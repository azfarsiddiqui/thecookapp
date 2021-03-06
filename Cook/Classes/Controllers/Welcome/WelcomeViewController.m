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
#import "WelcomeCollectionViewLayout.h"
#import "PageHeaderView.h"
#import "PagingBenchtopBackgroundView.h"
#import "CKBookCover.h"
#import "ImageHelper.h"
#import "DataHelper.h"
#import "NSString+Utilities.h"
#import "Theme.h"
#import "StoreTabView.h"
#import "StoreUnitTabView.h"

@interface WelcomeViewController () <WelcomeCollectionViewLayoutDataSource>

@property (nonatomic, weak) id<WelcomeViewControllerDelegate> delegate;
@property (nonatomic, strong) UIScrollView *backdropScrollView;
@property (nonatomic, strong) PagingBenchtopBackgroundView *blendedView;
@property (nonatomic, strong) UIView *backgroundTextureView;
@property (nonatomic, strong) CKPagingView *pagingView;
@property (nonatomic, assign) BOOL animating;
@property (nonatomic, assign) BOOL enabled;

// Pages
@property (nonatomic, strong) UIView *welcomePageView;
@property (nonatomic, strong) UIView *createPageView;
@property (nonatomic, strong) UIView *collectPageView;
@property (nonatomic, strong) UIView *libraryPageView;
@property (nonatomic, strong) UIView *signUpPageView;

// Adornments
@property (nonatomic, strong) UIView *welcomeImageView;
@property (nonatomic, strong) UIView *welcomeImageView2;
@property (nonatomic, strong) UIView *createImageView;
@property (nonatomic, strong) UILabel *createLabel;
@property (nonatomic, strong) UIView *collectImageView;
@property (nonatomic, strong) UIView *collectImageView2;
@property (nonatomic, strong) UIView *libraryImageView;
@property (nonatomic, strong) StoreTabView *storeTabView;

@end

@implementation WelcomeViewController

#define kAdornmentCellId        @"AdornmentCellId"
#define kPageHeaderId           @"PageHeaderId"
#define kNumPages               5
#define kButtonWidth            150.0
#define kButtonGap              10.0
#define kWelcomeSection         0
#define kCreateSection          1
#define kCollectSection         2
#define kLibrarySection         3
#define kSignUpSection          4
#define kAdornmentTag           470
#define kLabelSubtitleFont      [UIFont fontWithName:@"BrandonGrotesque-Light" size:26.0]
#define kPageHeaderSize         CGSizeMake(500.0, 500.0)
#define kWelcomePageHeaderSize  CGSizeMake(550.0, 500.0)
#define kLabelGap               10.0
#define kBorderInsets           (UIEdgeInsets){ 16.0, 10.0, 12.0, 10.0 }

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
    self.view.clipsToBounds = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initCollectionView];
    [self initBackdropScrollView];
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

- (CKPagingView *)pagingView {
    if (!_pagingView) {
        _pagingView = [[CKPagingView alloc] initWithNumPages:kNumPages type:CKPagingViewTypeHorizontal];
        _pagingView.frame = CGRectMake(0.0, 0.0, _pagingView.frame.size.width, _pagingView.frame.size.height);
    }
    return _pagingView;
}

- (UIView *)welcomeImageView {
    if (!_welcomeImageView) {
        _welcomeImageView = [[UIImageView alloc] initWithImage:[ImageHelper imageFromDiskNamed:@"cook_login_leftstack" type:@"png"]];
    }
    return _welcomeImageView;
}

- (UIView *)welcomeImageView2 {
    if (!_welcomeImageView2) {
        _welcomeImageView2 = [[UIImageView alloc] initWithImage:[ImageHelper imageFromDiskNamed:@"cook_login_rightstack" type:@"png"]];
    }
    return _welcomeImageView2;
}

- (UIView *)createImageView {
    if (!_createImageView) {
        _createImageView = [[UIImageView alloc] initWithImage:[ImageHelper imageFromDiskNamed:@"cook_login_mybook" type:@"png"]];
        self.createLabel.frame = (CGRect) {
            floorf((_createImageView.bounds.size.width - self.createLabel.frame.size.width) / 2.0) + 1.0,
            53.0,
            self.createLabel.frame.size.width,
            self.createLabel.frame.size.height
        };
        [_createImageView addSubview:self.createLabel];
    }
    return _createImageView;
}

- (UILabel *)createLabel {
    if (!_createLabel) {
        _createLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _createLabel.autoresizingMask = UIViewAutoresizingNone;
        _createLabel.backgroundColor = [UIColor clearColor];
        _createLabel.font = [Theme bookCoverViewModeTitleFont];
        _createLabel.textColor = [UIColor whiteColor];
        _createLabel.userInteractionEnabled = NO;
        _createLabel.textAlignment = NSTextAlignmentCenter;
        _createLabel.text = NSLocalizedString(@"RECIPES FROM ALL OVER THE WORLD", nil);
        [_createLabel sizeToFit];
    }
    
    return _createLabel;
}

- (UIView *)collectImageView {
    if (!_collectImageView) {
        _collectImageView = [[UIImageView alloc] initWithImage:[ImageHelper imageFromDiskNamed:@"cook_login_friendsbooks_left" type:@"png"]];
    }
    return _collectImageView;
}

- (UIView *)collectImageView2 {
    if (!_collectImageView2) {
        _collectImageView2 = [[UIImageView alloc] initWithImage:[ImageHelper imageFromDiskNamed:@"cook_login_friendsbooks_right" type:@"png"]];
    }
    return _collectImageView2;
}

- (UIView *)libraryImageView {
    if (!_libraryImageView) {
        _libraryImageView = [[UIImageView alloc] initWithImage:[ImageHelper imageFromDiskNamed:@"cook_login_library" type:@"png"]];
        self.storeTabView.frame = (CGRect){
            floorf((_libraryImageView.bounds.size.width - self.storeTabView.frame.size.width) / 2.0),
            38.0,
            self.storeTabView.frame.size.width,
            self.storeTabView.frame.size.height
        };
        self.storeTabView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        [_libraryImageView addSubview:self.storeTabView];
    }
    return _libraryImageView;
}

- (StoreTabView *)storeTabView {
    if (!_storeTabView) {
        NSArray *tabViews = @[
                              [[StoreUnitTabView alloc] initWithText:NSLocalizedString(@"COLLECTIONS", nil)
                                                                icon:[UIImage imageNamed:@"cook_library_icons_categories.png"]
                                                             offIcon:[UIImage imageNamed:@"cook_library_icons_categories_off.png"]],
                              [[StoreUnitTabView alloc] initWithText:NSLocalizedString(@"FEATURED", nil)
                                                                icon:[UIImage imageNamed:@"cook_library_icons_featured.png"]
                                                             offIcon:[UIImage imageNamed:@"cook_library_icons_featured_off.png"]],
                              [[StoreUnitTabView alloc] initWithText:NSLocalizedString(@"WORLD", nil)
                                                                icon:[UIImage imageNamed:@"cook_library_icons_world.png"]
                                                             offIcon:[UIImage imageNamed:@"cook_library_icons_world_off.png"]]
                              ];
        _storeTabView = [[StoreTabView alloc] initWithUnitTabViews:tabViews delegate:nil];
        [_storeTabView selectTabAtIndex:1];
        _storeTabView.userInteractionEnabled = NO;
    }
    return _storeTabView;
}

- (UIView *)welcomePageView {
    if (!_welcomePageView) {
        CGSize size = [self sizeOfPageHeaderForPage:kWelcomeSection
                                          indexPath:[NSIndexPath indexPathForItem:0 inSection:kWelcomeSection]];
        _welcomePageView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, size.width, size.height)];
        _welcomePageView.backgroundColor = [UIColor clearColor];
        _welcomePageView.autoresizingMask = UIViewAutoresizingNone;
        
        // Title
        UILabel *titleLabel = [self createLabelWithFont:[UIFont fontWithName:@"BrandonGrotesque-Thin" size:80.0]
                                                   text:[NSLocalizedString(@"WELCOME", nil) uppercaseString] textAlignment:NSTextAlignmentCenter
                                          availableSize:size paragraphBefore:-10.0];
        titleLabel.frame = CGRectMake(floorf((size.width - titleLabel.frame.size.width) / 2.0),
                                      148.0,
                                      titleLabel.frame.size.width,
                                      titleLabel.frame.size.height);
        [_welcomePageView addSubview:titleLabel];
        
        // Subtitle
        UILabel *subtitleLabel = [self createSubtitleLabelWithText:[NSString stringWithFormat:NSLocalizedString(@"Cook is the place to create and share %@your recipes with the world.", nil), [NSString CK_lineBreakString]]
                                                     textAlignment:NSTextAlignmentCenter availableSize:size];
        subtitleLabel.frame = CGRectMake(floorf((size.width - subtitleLabel.frame.size.width) / 2.0),
                                         titleLabel.frame.origin.y + titleLabel.frame.size.height - 8.0,
                                         subtitleLabel.frame.size.width,
                                         subtitleLabel.frame.size.height);
        [_welcomePageView addSubview:subtitleLabel];
        
    }
    return _welcomePageView;
}

- (UIView *)createPageView {
    if (!_createPageView) {
        CGSize size = [self sizeOfPageHeaderForPage:kCreateSection
                                          indexPath:[NSIndexPath indexPathForItem:0 inSection:kCreateSection]];
        _createPageView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, size.width, size.height)];
        _createPageView.backgroundColor = [UIColor clearColor];
        _createPageView.autoresizingMask = UIViewAutoresizingNone;

        // Title
        UILabel *titleLabel = [self createLabelWithFont:[UIFont fontWithName:@"BrandonGrotesque-Thin" size:70.0]
                                                   text:[NSString stringWithFormat:NSLocalizedString(@"YOUR%@COOKBOOK", nil), [NSString CK_lineBreakString]]
                                          textAlignment:NSTextAlignmentLeft
                                          availableSize:size paragraphBefore:-22.0];
        titleLabel.frame = CGRectMake(0.0,
                                      68.0,
                                      titleLabel.frame.size.width,
                                      titleLabel.frame.size.height);
        [_createPageView addSubview:titleLabel];
        
        // Subtitle
        UILabel *subtitleLabel = [self createSubtitleLabelWithText:[NSString stringWithFormat:NSLocalizedString(@"Customize the cover of your book then%@add your cherished family recipes, the%@meals you cook regularly, tips, tricks,%@anything food related.", nil), [NSString CK_lineBreakString], [NSString CK_lineBreakString], [NSString CK_lineBreakString]]
                                                     textAlignment:NSTextAlignmentLeft availableSize:size];
        subtitleLabel.frame = CGRectMake(0.0,
                                         titleLabel.frame.origin.y + titleLabel.frame.size.height + 2.0,
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
        _collectPageView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, size.width, size.height)];
        _collectPageView.backgroundColor = [UIColor clearColor];
        _collectPageView.autoresizingMask = UIViewAutoresizingNone;
        
        // Title
        UILabel *titleLabel = [self createLabelWithFont:[UIFont fontWithName:@"BrandonGrotesque-Thin" size:70.0]
                                                   text:NSLocalizedString(@"SHARE YOUR RECIPES", nil)
                                          textAlignment:NSTextAlignmentCenter
                                          availableSize:size paragraphBefore:-22.0];
        titleLabel.frame = CGRectMake(floorf((size.width - titleLabel.frame.size.width) / 2.0),
                                      138.0,
                                      titleLabel.frame.size.width,
                                      titleLabel.frame.size.height);
        [_collectPageView addSubview:titleLabel];
        
        // Subtitle
        UILabel *subtitleLabel = [self createSubtitleLabelWithText:[NSString stringWithFormat:NSLocalizedString(@"Make your recipes public and share them%@with everyone or keep them just for%@close friends, the choice is yours.", nil), [NSString CK_lineBreakString], [NSString CK_lineBreakString]]
                                                     textAlignment:NSTextAlignmentCenter availableSize:size];
        subtitleLabel.frame = CGRectMake(floorf((size.width - subtitleLabel.frame.size.width) / 2.0),
                                         titleLabel.frame.origin.y + titleLabel.frame.size.height + 2.0,
                                         subtitleLabel.frame.size.width,
                                         subtitleLabel.frame.size.height);
        [_collectPageView addSubview:subtitleLabel];
        
    }
    return _collectPageView;
}

- (UIView *)libraryPageView {
    if (!_libraryPageView) {
        
        CGSize size = [self sizeOfPageHeaderForPage:kLibrarySection
                                          indexPath:[NSIndexPath indexPathForItem:0 inSection:kLibrarySection]];
        _libraryPageView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, size.width, size.height)];
        _libraryPageView.backgroundColor = [UIColor clearColor];
        _libraryPageView.autoresizingMask = UIViewAutoresizingNone;
        
        // Title
        UILabel *titleLabel = [self createLabelWithFont:[UIFont fontWithName:@"BrandonGrotesque-Thin" size:70.0]
                                                   text:NSLocalizedString(@"A WORLD OF RECIPES", nil) textAlignment:NSTextAlignmentCenter
                                          availableSize:size paragraphBefore:-22.0];
        titleLabel.frame = CGRectMake(floorf((size.width - titleLabel.frame.size.width) / 2.0),
                                      334.0,
                                      titleLabel.frame.size.width,
                                      titleLabel.frame.size.height);
        [_libraryPageView addSubview:titleLabel];
        
        // Subtitle
        UILabel *subtitleLabel = [self createSubtitleLabelWithText:[NSString stringWithFormat:NSLocalizedString(@"Pull down on your bench to reveal the%@Library with Cookbooks and recipes%@from all over the world.", nil), [NSString CK_lineBreakString], [NSString CK_lineBreakString]]
                                                     textAlignment:NSTextAlignmentCenter availableSize:size];
        subtitleLabel.frame = CGRectMake(floorf((size.width - subtitleLabel.frame.size.width) / 2.0),
                                         titleLabel.frame.origin.y + titleLabel.frame.size.height - 9.0,
                                         subtitleLabel.frame.size.width,
                                         subtitleLabel.frame.size.height);
        [_libraryPageView addSubview:subtitleLabel];
    }
    return _libraryPageView;
}

- (UIView *)signUpPageView {
    if (!_signUpPageView) {
        CGSize size = self.collectionView.bounds.size;
        
        // Title
        UILabel *titleLabel = [self createLabelWithFont:[UIFont fontWithName:@"BrandonGrotesque-Thin" size:70.0]
                                                   text:NSLocalizedString(@"LET'S GET STARTED...", nil) textAlignment:NSTextAlignmentCenter
                                          availableSize:size paragraphBefore:-22.0];
        _signUpPageView = titleLabel;
    }
    return _signUpPageView;
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
        case kLibrarySection:
            numAdornments = 1;
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
                    size = kWelcomePageHeaderSize;
                    break;
                case 1:
                    size = self.pagingView.frame.size;
                    break;
                default:
                    break;
            }
            
            break;
        case kCreateSection:
            break;
        case kCollectSection:
            size = (CGSize) { self.collectionView.bounds.size.width, kPageHeaderSize.height };
            break;
        case kLibrarySection:
            size = (CGSize) { self.collectionView.bounds.size.width, kPageHeaderSize.height };
            break;
        case kSignUpSection:
            size = self.signUpPageView.frame.size;
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
            size = self.createImageView.frame.size;
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
        case kLibrarySection:
            size = self.libraryImageView.frame.size;
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
    
    if (scrollView == self.collectionView) {
        
        self.backdropScrollView.contentOffset = self.collectionView.contentOffset;
        
    } else if (scrollView == self.backdropScrollView) {
        
        // Adjust the blended view.
        CGRect blendedFrame = self.blendedView.frame;
        if (scrollView.contentOffset.x < 0) {
            blendedFrame.origin.x = scrollView.contentOffset.x;
        } else if (scrollView.contentOffset.x > self.blendedView.frame.size.width - self.collectionView.bounds.size.width) {
            blendedFrame.origin.x = scrollView.contentOffset.x - (self.blendedView.frame.size.width - self.collectionView.bounds.size.width);
        } else {
            blendedFrame.origin.x = 0.0;
        }
        self.blendedView.frame = blendedFrame;

        // Texture to stay in place in viewport.
        CGRect textureFrame = self.backgroundTextureView.frame;
        textureFrame.origin.x = scrollView.contentOffset.x + floorf((scrollView.bounds.size.width - self.backgroundTextureView.frame.size.width) / 2.0);
        textureFrame.origin.y = scrollView.contentOffset.y +floorf((scrollView.bounds.size.height - self.backgroundTextureView.frame.size.height) / 2.0);
        self.backgroundTextureView.frame = textureFrame;
    }
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.animating = NO;
    [self updatePagingView];
    [self processGetStarted];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        self.animating = NO;
        [self processGetStarted];
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
        case kLibrarySection:
            contentView = self.libraryPageView;
            break;
        case kSignUpSection:
            contentView = self.signUpPageView;
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
        case kLibrarySection:
            contentView = self.libraryImageView;
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

#pragma mark - Private methods

- (void)initCollectionView {
    self.collectionView.clipsToBounds = NO;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.pagingEnabled = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kAdornmentCellId];
    [self.collectionView registerClass:[PageHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:kPageHeaderId];
}

- (void)initBackdropScrollView {
    UIOffset motionOffset = [ViewHelper standardMotionOffset];
    
    // Backdrop scrollview to back the collectionView.
    self.backdropScrollView = [[UIScrollView alloc] initWithFrame:self.collectionView.frame];
    self.backdropScrollView.clipsToBounds = NO;
    self.backdropScrollView.delegate = self;
    [self.view insertSubview:self.backdropScrollView belowSubview:self.collectionView];
    
    // Blended benchtop.
    PagingBenchtopBackgroundView *pagingBenchtopView = [[PagingBenchtopBackgroundView alloc] initWithFrame:(CGRect){
        self.backdropScrollView.bounds.origin.x - motionOffset.horizontal,
        self.backdropScrollView.bounds.origin.y - motionOffset.vertical,
        (self.backdropScrollView.bounds.size.width * [self numberOfPagesForWelcomeLayout]) + (motionOffset.horizontal * 2.0),
        self.backdropScrollView.bounds.size.height  + (motionOffset.vertical * 2.0)
    } pageWidth:self.backdropScrollView.bounds.size.width];
    [self.backdropScrollView addSubview:pagingBenchtopView];
    
    // Add motion effects on the scrollView.
    [ViewHelper applyDraggyMotionEffectsToView:self.backdropScrollView];
    
    // Colours
    pagingBenchtopView.leftEdgeColour = [CKBookCover backdropColourForCover:@"Red"];
    [pagingBenchtopView addColour:[CKBookCover backdropColourForCover:@"Red"]];
    [pagingBenchtopView addColour:[CKBookCover backdropColourForCover:@"Blue"]];
    [pagingBenchtopView addColour:[CKBookCover backdropColourForCover:@"Green"]];
    [pagingBenchtopView addColour:[CKBookCover backdropColourForCover:@"Red"]];
    [pagingBenchtopView addColour:[CKBookCover backdropColourForCover:@"Blue"]];
    pagingBenchtopView.rightEdgeColour = [CKBookCover backdropColourForCover:@"Blue"];
    self.blendedView = pagingBenchtopView;
    
    // Background texture goes over the gradient.
    UIImageView *backgroundTextureView = [[UIImageView alloc] initWithImage:[ImageHelper imageFromDiskNamed:@"cook_dash_background" type:@"png"]];
    backgroundTextureView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    CGRect textureFrame = backgroundTextureView.frame;
    textureFrame.origin.x = floorf((self.backdropScrollView.bounds.size.width - backgroundTextureView.frame.size.width) / 2.0);
    textureFrame.origin.y = floorf((self.backdropScrollView.bounds.size.height - backgroundTextureView.frame.size.height) / 2.0);
    backgroundTextureView.frame = textureFrame;
    [self.backdropScrollView addSubview:backgroundTextureView];
    self.backgroundTextureView = backgroundTextureView;
    
    // Black overlay over the texture.
    UIView *blackOverlay = [[UIView alloc] initWithFrame:self.backdropScrollView.bounds];
    blackOverlay.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:.38];
    [self.view insertSubview:blackOverlay belowSubview:self.collectionView];
    
    // Start blending.
    pagingBenchtopView.alpha = 0.0;
    [pagingBenchtopView blendWithCompletion:^{
        
        [UIView animateWithDuration:0.5
                              delay:0.0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             pagingBenchtopView.alpha = 0.88;
                         }
                         completion:^(BOOL finished) {
                         }];
    }];
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

- (UILabel *)createSubtitleLabelWithText:(NSString *)text textAlignment:(NSTextAlignment)textAlignment
                        availableSize:(CGSize)availableSize {
    
    return [self createLabelWithFont:kLabelSubtitleFont text:text textAlignment:textAlignment availableSize:availableSize
                     paragraphBefore:-2.0];
}

- (UILabel *)createLabelWithFont:(UIFont *)font text:(NSString *)text textAlignment:(NSTextAlignment)textAlignment
                   availableSize:(CGSize)availableSize paragraphBefore:(CGFloat)paragraphBefore {
    
    // Paragraph attributes.
    NSDictionary *textAttributes = [self textAttributesForFont:font paragraphBefore:paragraphBefore textAlignment:textAlignment];
    NSAttributedString *textDisplay = [[NSAttributedString alloc] initWithString:text attributes:textAttributes];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.attributedText = textDisplay;
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    CGSize size = [label sizeThatFits:availableSize];
    label.frame = CGRectIntegral(CGRectMake(0.0, 0.0, size.width, size.height));
    
    return label;
}

- (NSDictionary *)textAttributesForFont:(UIFont *)font textAlignment:(NSTextAlignment)textAlignment {
    
    return [self textAttributesForFont:font paragraphBefore:0.0 textAlignment:textAlignment];
}

- (NSDictionary *)textAttributesForFont:(UIFont *)font paragraphBefore:(CGFloat)paragraphBefore
                          textAlignment:(NSTextAlignment)textAlignment {
    
    NSLineBreakMode lineBreakMode = NSLineBreakByWordWrapping;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = lineBreakMode;
    paragraphStyle.paragraphSpacingBefore = paragraphBefore;
    paragraphStyle.alignment = textAlignment;
    
    NSShadow *shadow = [NSShadow new];
    shadow.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.08];
    shadow.shadowOffset = CGSizeMake(0.0, 1.0);
    shadow.shadowBlurRadius = 3.0;
    
    return [NSDictionary dictionaryWithObjectsAndKeys:
            font, NSFontAttributeName,
            [UIColor whiteColor], NSForegroundColorAttributeName,
            paragraphStyle, NSParagraphStyleAttributeName,
            shadow, NSShadowAttributeName,
            nil];
}

- (void)processGetStarted {
    WelcomeCollectionViewLayout *layout = (WelcomeCollectionViewLayout *)self.collectionView.collectionViewLayout;
    CGFloat getStartedOffset = [layout pageOffsetForPage:kSignUpSection];
    if (self.collectionView.contentOffset.x == getStartedOffset) {
        
        // Lock the welcome screen and initiate dismissal.
        self.collectionView.scrollEnabled = NO;
        
        CGAffineTransform transform = CGAffineTransformMakeScale(0.95, 0.95);
//        CGAffineTransform transform = CGAffineTransformMakeScale(1.05, 1.05);
        
        // Fade the paging view.
        [UIView animateWithDuration:0.3
                              delay:0.3
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.signUpPageView.transform = transform;
                             self.signUpPageView.alpha = 0.0;
                             self.pagingView.alpha = 0.0;
                         }
                         completion:^(BOOL finished) {
                             [self.delegate welcomeViewControllerGetStartedReached];
                         }];
    }
}

@end
