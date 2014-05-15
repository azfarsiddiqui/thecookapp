//
//  BookTitleViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 12/04/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookTitleViewController.h"
#import "CKBook.h"
#import "CKBookCover.h"
#import "Theme.h"
#import "BookTitlePhotoView.h"
#import "CKRecipe.h"
#import "CKUser.h"
#import "ImageHelper.h"
#import "BookTitleCell.h"
#import "UIColor+Expanded.h"
#import "UICollectionView+Draggable.h"
#import "BookTitleLayout.h"
#import "MRCEnumerable.h"
#import "AppHelper.h"
#import "ViewHelper.h"
#import "CKActivityIndicatorView.h"
#import "CKPhotoManager.h"
#import "CKEditViewController.h"
#import "CKEditingViewHelper.h"
#import "CKPageTitleEditViewController.h"
#import "CardViewHelper.h"
#import "NSString+Utilities.h"
#import "EventHelper.h"
#import "CKProgressView.h"
#import "CKPhotoView.h"
#import "CKError.h"
#import "CardViewHelper.h"

@interface BookTitleViewController () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource_Draggable,
    CKEditViewControllerDelegate, BooKTitlePhotoViewDelegate>

@property (nonatomic, strong) NSMutableArray *pages;
@property (nonatomic, assign) BOOL fullImageLoaded;
@property (nonatomic, assign) BOOL didScrollBack;
@property (nonatomic, strong) CKRecipe *heroRecipe;

//@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) CKPhotoView *photoView;
@property (nonatomic, strong) UIImageView *topShadowView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) BookTitlePhotoView *bookTitleView;
@property (nonatomic, strong) CKActivityIndicatorView *activityView;
@property (nonatomic, strong) CKProgressView *progressView;

// Directional arrows.
@property (nonatomic, strong) UIImageView *leftArrowImageView;
@property (nonatomic, strong) UIImageView *rightArrowImageView;

// Editing.
@property (nonatomic, strong) CKEditingViewHelper *editingHelper;
@property (nonatomic, strong) CKPageTitleEditViewController *editViewController;
@property (nonatomic, strong) NSString *editingPageName;

@end

@implementation BookTitleViewController

#define kCellId                 @"BookTitleCellId"
#define kAddCellId              @"BookTitleAddCellId"
#define kHeaderId               @"BookTitleHeaderId"
#define kIndexWidth             240.0
#define kImageIndexGap          10.0
#define kTitleIndexTopOffset    40.0
#define kBorderInsets           (UIEdgeInsets){ 16.0, 10.0, 12.0, 10.0 }
#define kTitleAnimateOffset     50.0
#define kTitleHeaderTag         460
#define kStartUpOffset          75.0
#define kArrowAnimationDuration 0.3
#define kHeaderHeight           420.0
#define kHeaderCellGap          135.0
#define BLUR_TINT_COLOUR        0.58

- (void)dealloc {
    [self.photoView cleanImageViews]; self.photoView = nil;
    self.topShadowView.image = nil;
    [EventHelper unregisterPhotoLoading:self];
    [EventHelper unregisterPhotoLoadingProgress:self];
}

- (id)initWithBook:(CKBook *)book delegate:(id<BookTitleViewControllerDelegate>)delegate {
    if (self = [super init]) {
        self.book = book;
        self.delegate = delegate;
        self.editingHelper = [[CKEditingViewHelper alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithHexString:@"f2f2f2"];
    self.view.frame = [[AppHelper sharedInstance] fullScreenFrame];
    
    [self initBackgroundView];
    [self initCollectionView];
    
    // Attempt to load a cached title image.
    UIImage *cachedTitleImage = [[CKPhotoManager sharedInstance] cachedTitleImageForBook:self.book];
    if (cachedTitleImage) {
        
        // Display cached full image.
        [self.photoView setThumbnailImage:cachedTitleImage];
        
        // On-demand blur it - this will get replaced later when a hero recipe is assigned.
        UIColor *tintColour = [[CKBookCover bookContentTintColourForCover:self.book.cover] colorWithAlphaComponent:BLUR_TINT_COLOUR];
        [[CKPhotoManager sharedInstance] blurredImageForRecipeWithImage:cachedTitleImage
                                                              tintColor:tintColour
                                                             completion:^(UIImage *blurredImage) {
                                                                 [self.photoView setBlurredImage:blurredImage];
                                                             }];

        // Apply top shadow.
        self.topShadowView.image = [ViewHelper topShadowImageSubtle:NO];

    } else {
        
        // The coloured grid backgroound.
        [self.photoView setThumbnailImage:[CKBookCover recipeEditBackgroundImageForCover:self.book.cover]];
    }
    
    [self addCloseButtonLight:YES];
}

- (void)configureLoading:(BOOL)loading {
    
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(0.5, 0.5);
    
    if (loading) {
        if (![self.activityView isAnimating]) {
            [self.activityView startAnimating];
        }
        if (!self.activityView.superview) {
            self.activityView.alpha = 0.0;
            self.activityView.transform = scaleTransform;
            [self.view addSubview:self.activityView];
            
            [UIView animateWithDuration:0.2
                                  delay:0.0
                                options:UIViewAnimationCurveEaseIn
                             animations:^{
                                 self.activityView.alpha = 1.0;
                                 self.activityView.transform = CGAffineTransformIdentity;
                             }
                             completion:^(BOOL finished) {
                             }];
            
        }
    } else {
        
        [UIView animateWithDuration:0.15
                              delay:0.0
                            options:UIViewAnimationCurveEaseIn
                         animations:^{
                             self.activityView.alpha = 0.0;
//                             self.activityView.transform = scaleTransform;
//                             self.activityView.transform = CGAffineTransformConcat(scaleTransform, CGAffineTransformMakeTranslation(0.0, kStartUpOffset));
//                             self.activityView.transform = CGAffineTransformMakeTranslation(0.0, kStartUpOffset);
                         }
                         completion:^(BOOL finished) {
                             if ([self.activityView isAnimating]) {
                                 [self.activityView stopAnimating];
                             }
                             [self.activityView removeFromSuperview];
                         }];
    }
}

- (void)configureError:(NSError *)error {
    [self configureLoading:NO];
    
    // No connection?
    if ([CKError noConnectionError:error]) {
        [[CardViewHelper sharedInstance] showNoConnectionCard:YES view:self.view center:(CGPoint) { self.view.center.x, 100.0 }];
    }
    
}

- (void)configurePages:(NSArray *)pages {
    
    // Make sure view is available when this is invoked.
    self.view.hidden = NO;
    
    [self configureLoading:NO];
    
    BOOL reload = (self.pages != nil);
    self.pages = [NSMutableArray arrayWithArray:pages];
    
    if (reload) {
        
        [self.collectionView performBatchUpdates:^{
            [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
        } completion:^(BOOL finished){
            [self showIntroCard:([pages count] <= 1)];
            if ([self profileCardRequired]) {
                [self showProfileHintCard:YES];
            }
        }];
        
    } else {
        NSMutableArray *pageIndexPaths = [NSMutableArray arrayWithArray:[self.pages collectWithIndex:^id(NSString *page, NSUInteger pageIndex) {
            return [NSIndexPath indexPathForItem:pageIndex inSection:0];
        }]];
        
        // Add cell.
        if ([self.book isOwner]) {
            [pageIndexPaths addObject:[NSIndexPath indexPathForItem:[pageIndexPaths count] inSection:0]];
        }
        
        // Load title cells.
        [self.collectionView performBatchUpdates:^{
            [self.collectionView insertItemsAtIndexPaths:pageIndexPaths];
        } completion:^(BOOL finished){
            
            [UIView animateWithDuration:0.25
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 self.collectionView.transform = CGAffineTransformIdentity;
                             }
                             completion:^(BOOL finished){
                                 
                                 // Clip it now.
                                 self.collectionView.clipsToBounds = YES;
                                 
                                 [self showIntroCard:([pages count] <= 1)];
                                 if ([self profileCardRequired]) {
                                     [self showProfileHintCard:YES];
                                 }
                                 
                                 // Open ze gates.
                                 [self openGates];

                             }];
        }];
    }
}

- (void)configureHeroRecipe:(CKRecipe *)recipe {
    self.fullImageLoaded = NO;
    self.heroRecipe = recipe;
    
    // Make sure view is available when this is invoked.
    self.view.hidden = NO;
    
    if ([recipe hasPhotos]) {
        
        // iOS 7.1 has a different UIProgressView padding.
        CGFloat progressOffset = [[AppHelper sharedInstance] systemVersionAtLeast:@"7.1"] ? 60.0 : 20.0;
        
        // Add progress.
        self.progressView.frame = (CGRect){
            floorf((self.view.bounds.size.width - self.progressView.frame.size.width) / 2.0),
            progressOffset,
            self.progressView.frame.size.width,
            self.progressView.frame.size.height
        };
        [self.view addSubview:self.progressView];
        [self.progressView setProgress:0.1 animated:YES];
        
        __weak BookTitleViewController *weakSelf = self;
        [[CKPhotoManager sharedInstance] featuredImageForRecipe:recipe
                                                           size:self.view.frame.size
                                                       progress:^(CGFloat progressRatio, NSString *name) {
                                                           NSString *recipePhotoName = [[CKPhotoManager sharedInstance] photoNameForRecipe:self.heroRecipe];
                                                           if ([recipePhotoName isEqualToString:name]) {
                                                               [weakSelf.progressView setProgress:progressRatio animated:YES];
                                                           }
                                                       }
                                                thumbCompletion:^(UIImage *thumbImage, NSString *name) {
                                                    NSString *recipePhotoName = [[CKPhotoManager sharedInstance] photoNameForRecipe:self.heroRecipe];
                                                    if ([recipePhotoName isEqualToString:name]) {
                                                        [weakSelf configureHeroRecipeImage:thumbImage thumb:YES];
                                                    }
                                                }
                                                     completion:^(UIImage *image, NSString *name) {
                                                         [weakSelf configureHeroRecipeImage:image thumb:NO];
                                                     }];
    }
}

- (void)refresh {
    [self.collectionView reloadData];
}

- (BOOL)profileCardRequired {
    //Only show profile hint if:
    // - Hasn't seen it before
    // - Has a page and a recipe
    // - Has no bio
    // - Has no Profile Photo or Profile Background
    BOOL hasShown = [[[NSUserDefaults standardUserDefaults] objectForKey:kHasSeenProfileHintKey] boolValue];
    BOOL hasPhoto = (![self.book hasCoverPhoto] || ![self.book.user hasProfilePhoto]);
    return (hasPhoto && ([self.pages count] > 1) && !hasShown);
}

#pragma mark - BookPageViewController methods

- (void)showIntroCard:(BOOL)show {
    if (![self.book isOwner]) {
        return;
    }
    
    NSString *cardTag = @"GetStartedCard";
    
    if (show) {
        
        CGSize cardSize = [CardViewHelper cardViewSize];
        [[CardViewHelper sharedInstance] showCardViewWithTag:cardTag
                                                        icon:[UIImage imageNamed:@"cook_intro_icon_title.png"]
                                                       title:@"GET STARTED"
                                                    subtitle:@"CREATE A NEW PAGE FOR YOUR RECIPES, CALL IT ANYTHING YOU LIKE..."
                                                        view:self.collectionView
                                                      anchor:CardViewAnchorMidLeft
                                                      center:(CGPoint){
                                                          90.0 + ([BookTitleCell cellSize].width+ 20.0) * 2 + floorf(cardSize.width / 2.0),
                                                          self.view.bounds.size.height - [BookTitleCell cellSize].height + 58.0,
                                                      }];
    } else {
        [[CardViewHelper sharedInstance] hideCardViewWithTag:cardTag];
    }
    
}

- (void)showProfileHintCard:(BOOL)show {
    if (![self.book isOwner]) {
        return;
    }
    NSString *cardTag = @"YourProfile";
    
    if (show) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kHasSeenProfileHintKey];
        CGSize cardSize = [CardViewHelper cardViewSize];
        [[CardViewHelper sharedInstance] showCardViewWithTag:cardTag
                                                        icon:[UIImage imageNamed:@"cook_intro_icon_profile.png"]
                                                       title:@"YOUR PROFILE"
                                                    subtitle:@"SWIPE RIGHT TO VIEW AND EDIT YOUR PROFILE"
                                                        view:self.view
                                                      anchor:CardViewAnchorMidLeft
                                                      center:(CGPoint){
                                                          floorf(cardSize.width / 2.0) + 20.0,
                                                          floorf(cardSize.height / 2.0) + 30.0
                                                      }];
    } else {
        [[CardViewHelper sharedInstance] hideCardViewWithTag:cardTag];
    }
    
}

//Called when BookNav has scrolled to Profile, able to dismiss hints if shown
- (void)didScrollToProfile {
    [self showProfileHintCard:NO];
}

#pragma mark - BooKTitlePhotoViewDelegate methods

- (void)bookTitlePhotoViewProfileTapped {
    [self.delegate bookTitleProfileRequested];
}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self applyOffset:scrollView.contentOffset.y distance:200.0 view:self.photoView.blurredImageView];
}

#pragma mark - UICollectionViewDelegateFlowLayout methods

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    
    CGFloat headerCellGap = kHeaderCellGap;
    if (self.pages) {
        headerCellGap -= kStartUpOffset - 4.0;
    }
    return (UIEdgeInsets) { headerCellGap, 90.0, 90.0, 90.0 };
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
    minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    
    return 34.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    
    return 20.0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
referenceSizeForHeaderInSection:(NSInteger)section {
    
    CGFloat headerHeight = kHeaderHeight;
    if (self.pages) {
        headerHeight += kStartUpOffset - 20.0;
    }
    return (CGSize){ self.collectionView.bounds.size.width, headerHeight };
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return [BookTitleCell cellSize];
}

#pragma mark - UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.item < [self.pages count]) {
        [self.delegate bookTitleSelectedPage:[self.pages objectAtIndex:indexPath.item]];
    } else {
        [self addPage];
    }
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    NSInteger numItems = 0;
    
    // Number of pages.
    if (self.pages) {
        
        numItems += [self.pages count];
        
        // Add cell if I'm the owner.
        if ([self.book isOwner]) {
            numItems += 1; // Plus add cell.
        }
    }
    
    return numItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = nil;
    
    if (indexPath.item < [self.pages count]) {
        
        BookTitleCell *titleCell = (BookTitleCell *)[self.collectionView dequeueReusableCellWithReuseIdentifier:kCellId
                                                                                                   forIndexPath:indexPath];
        NSString *page = [self.pages objectAtIndex:indexPath.item];
        [titleCell configurePage:page numRecipes:[self.delegate bookTitleNumRecipesForPage:page]
          containNewRecipes:[self.delegate bookTitleIsNewForPage:page] book:self.book];
        
        // Load featured recipe for the category.
        CKRecipe *featuredRecipe = [self.delegate bookTitleFeaturedRecipeForPage:page];
        [titleCell configureCoverRecipe:featuredRecipe];
        cell = titleCell;
        
    } else {
        
        // Add cell.
        BookTitleCell *titleCell = (BookTitleCell *)[self.collectionView dequeueReusableCellWithReuseIdentifier:kAddCellId
                                                                                                   forIndexPath:indexPath];
        [titleCell configureAsAddCellForBook:self.book];
        cell = titleCell;
    }
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *supplementaryView = nil;
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        supplementaryView = [self.collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                    withReuseIdentifier:kHeaderId forIndexPath:indexPath];
        
        if (![supplementaryView viewWithTag:kTitleHeaderTag]) {
            self.bookTitleView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin;
            self.bookTitleView.frame = (CGRect){
                floorf((supplementaryView.bounds.size.width - self.bookTitleView.frame.size.width) / 2.0),
                supplementaryView.bounds.size.height - self.bookTitleView.frame.size.height,
                self.bookTitleView.frame.size.width,
                self.bookTitleView.frame.size.height
            };
            self.bookTitleView.tag = kTitleHeaderTag;
            [supplementaryView addSubview:self.bookTitleView];
        }
    }
    
    return supplementaryView;
}

#pragma mark - UICollectionViewDataSource_Draggable methods

- (BOOL)collectionView:(LSCollectionViewHelper *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.book isOwner]) {
        if ([self.delegate bookTitleHasLikes]) {
            return (indexPath.item < [self.pages count] - 1);
        } else {
            return (indexPath.item < [self.pages count]);
        }
    } else {
        return NO;
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath
           toIndexPath:(NSIndexPath *)toIndexPath {
    if ([self.book isOwner]) {
        if ([self.delegate bookTitleHasLikes]) {
            return (toIndexPath.item < [self.pages count] - 1);
        } else {
            return (toIndexPath.item < [self.pages count]);
        }
    } else {
        return NO;
    }
}

- (void)collectionView:(LSCollectionViewHelper *)collectionView moveItemAtIndexPath:(NSIndexPath *)fromIndexPath
           toIndexPath:(NSIndexPath *)toIndexPath {
    
    id page = [self.pages objectAtIndex:fromIndexPath.item];
    [self.pages removeObjectAtIndex:fromIndexPath.item];
    [self.pages insertObject:page atIndex:toIndexPath.item];
    
    // Inform book to relayout.
    [self.delegate bookTitleUpdatedOrderOfPages:self.pages];
}

#pragma mark - CKEditViewControllerDelegate methods

- (void)editViewControllerWillAppear:(BOOL)appear {
}

- (void)editViewControllerDidAppear:(BOOL)appear {
    if (!appear) {
        [self.editViewController.view removeFromSuperview];
        self.editViewController = nil;
    }
}

- (void)editViewControllerDismissRequested {
    [self.editViewController performEditing:NO];
    [self enableAddMode:NO];
}

- (void)editViewControllerEditRequested {
}

- (void)editViewControllerUpdateEditView:(UIView *)editingView value:(id)value {
}

- (void)editViewControllerHeadlessUpdatedWithValue:(id)value {
    
    NSString *text = [value uppercaseString];
    if ([text CK_containsText]) {
        [self addPageWithName:text];
    } else {
        [self enableAddMode:NO];
    }
    
}

- (id)editViewControllerInitialValueForEditView:(UIView *)editingView {
    return self.editingPageName;
}

- (BOOL)editViewControllerCanSaveFor:(CKEditViewController *)editViewController {
    BOOL canSave = YES;
    if ([editViewController headless]) {
        
        NSString *text = [[editViewController updatedValue] CK_whitespaceTrimmed];
        
        if ([self.pages detect:^BOOL(NSString *page) {
            return [[page uppercaseString] isEqualToString:[text uppercaseString]];
        }]) {
            
            // Existing page.
            canSave = NO;
            [editViewController updateTitle:@"PAGE ALREADY EXISTS" toast:YES];
        }

    }
    return canSave;
}

#pragma mark - Properties

- (BookTitlePhotoView *)bookTitleView {
    if (!_bookTitleView) {
        _bookTitleView = [[BookTitlePhotoView alloc] initWithBook:self.book delegate:self];
    }
    return _bookTitleView;
}

- (CKProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[CKProgressView alloc] initWithWidth:300.0];
        _progressView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
    }
    return _progressView;
}

- (UIImageView *)leftArrowImageView {
    if (!_leftArrowImageView) {
        _leftArrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_title_arrow_left_fr1.png"] ];
        _leftArrowImageView.animationDuration = kArrowAnimationDuration;
        _leftArrowImageView.animationRepeatCount = 1;
    }
    return _leftArrowImageView;
}

- (UIImageView *)rightArrowImageView {
    if (!_rightArrowImageView) {
        _rightArrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_title_arrow_right_fr1.png"] ];
        _rightArrowImageView.animationDuration = kArrowAnimationDuration;
        _rightArrowImageView.animationRepeatCount = 1;
    }
    return _rightArrowImageView;
}

- (CKActivityIndicatorView *)activityView {
    if (!_activityView) {
        _activityView = [[CKActivityIndicatorView alloc] initWithStyle:CKActivityIndicatorViewStyleLarge];
        _activityView.frame = (CGRect){
            floorf((self.view.bounds.size.width - _activityView.frame.size.width) / 2.0),
            self.view.bounds.size.height - 205.0,
            _activityView.frame.size.width,
            _activityView.frame.size.height
        };
        _activityView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    }
    return _activityView;
}

- (UIImageView *)topShadowView {
    if (!_topShadowView) {
        _topShadowView = [ViewHelper topShadowViewForView:self.view subtle:YES];
    }
    return _topShadowView;
}

#pragma mark - Private methods

- (void)initBackgroundView {
    
    UIOffset motionOffset = [ViewHelper standardMotionOffset];
    UIView *imageContainerView = [[UIView alloc] initWithFrame:self.view.bounds];
    imageContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    imageContainerView.clipsToBounds = YES;
    [self.view addSubview:imageContainerView];
    
    self.photoView = [[CKPhotoView alloc] initWithFrame:(CGRect) {
        imageContainerView.bounds.origin.x - motionOffset.horizontal,
        imageContainerView.bounds.origin.y - motionOffset.vertical,
        imageContainerView.bounds.size.width + (motionOffset.horizontal * 2.0),
        imageContainerView.bounds.size.height + (motionOffset.vertical * 2.0)
    }];
    [imageContainerView addSubview:self.photoView];
    
    // Apply top shadow.
    [self.view insertSubview:self.topShadowView aboveSubview:self.photoView];
    
    // Motion effects.
    [ViewHelper applyDraggyMotionEffectsToView:self.photoView];
    
    // Borders.
    [self initBorders];
}

- (void)initCollectionView {
    UICollectionViewFlowLayout *flowLayout = [[BookTitleLayout alloc] init];
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds
                                                          collectionViewLayout:flowLayout];
    collectionView.draggable = YES;
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.alwaysBounceVertical = YES;
    collectionView.alwaysBounceHorizontal = NO;
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:collectionView];
    self.collectionView = collectionView;
    
    [collectionView registerClass:[BookTitleCell class] forCellWithReuseIdentifier:kCellId];
    [collectionView registerClass:[BookTitleCell class] forCellWithReuseIdentifier:kAddCellId];
    [collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
              withReuseIdentifier:kHeaderId];
    
    // Start slightly lower.
    self.collectionView.transform = CGAffineTransformMakeTranslation(0.0, kStartUpOffset);
    
    // Don't clip so that title card can move past.
    self.collectionView.clipsToBounds = NO;
}

- (void)addPage {
    [self enableAddMode:YES];
    [self performAddPageWithName:nil];
}

- (void)enableAddMode:(BOOL)addMode {
    self.collectionView.scrollEnabled = !addMode;
    [self.bookPageDelegate bookPageViewControllerPanEnable:!addMode];
}

- (void)configureHeroRecipeImage:(UIImage *)image thumb:(BOOL)isThumb {
    
    if (isThumb) {
        [self.photoView setThumbnailImage:image];
        
        UIColor *tintColour = [[CKBookCover bookContentTintColourForCover:self.book.cover] colorWithAlphaComponent:BLUR_TINT_COLOUR];
        
        __weak BookTitleViewController *weakSelf = self;
        [[CKPhotoManager sharedInstance] blurredImageForRecipe:self.heroRecipe
                                                     tintColor:tintColour
                                                    thumbImage:image
                                                    completion:^(UIImage *thumbImage, NSString *name) {
            [weakSelf.photoView setBlurredImage:thumbImage];
        }];
        
    } else {
        
        // Hide progress view.
        self.progressView.hidden = YES;
        
        // Show the full image.
        [self.photoView setFullImage:image];
        
        // Cache title image as book.
        [[CKPhotoManager sharedInstance] cacheTitleImage:image book:self.book];
        
        self.fullImageLoaded = YES;
    }
    
    // Add top shadow.
    self.topShadowView.image = [ViewHelper topShadowImageSubtle:NO];
}

- (void)applyOffset:(CGFloat)offset distance:(CGFloat)distance view:(UIView *)view {
    CGFloat alpha = 0.0;
    if (offset <= 0.0) {
        alpha = 0.0;
    } else {
        
        CGFloat ratio = offset / distance;
        alpha = MIN(ratio, 1.0);
    }
    
    [self applyAlpha:alpha view:view];
}

- (void)applyAlpha:(CGFloat)alpha view:(UIView *)view {
    //    NSLog(@"Alpha %f", alpha);
    if (alpha > 0) {
        view.hidden = NO;
        view.alpha = alpha;
    } else {
        view.hidden = YES;
    }
}

- (void)performAddPageWithName:(NSString *)name {
    CKPageTitleEditViewController *editViewController = [[CKPageTitleEditViewController alloc] initWithEditView:nil
                                                                                                       delegate:self
                                                                                                  editingHelper:self.editingHelper
                                                                                                          white:YES
                                                                                                          title:@"ADD PAGE"
                                                                                                 characterLimit:16];
    editViewController.showTitle = YES;
    editViewController.forceUppercase = YES;
    editViewController.font = [UIFont fontWithName:@"BrandonGrotesque-Regular" size:48.0];
    [editViewController performEditing:YES headless:YES transformOffset:(UIOffset){ 0.0, 20.0 }];
    self.editViewController = editViewController;
}

- (void)addPageWithName:(NSString *)page {
    if ([self.delegate bookTitleHasLikes]) {
        [self.pages insertObject:page atIndex:[self.pages count] - 1];
        [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:[self.pages count] - 2 inSection:0]]];
    } else {
        [self.pages addObject:page];
        [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:[self.pages count] - 1 inSection:0]]];
    }
    [self.delegate bookTitleAddedPage:page];
    [self enableAddMode:NO];
    [self showIntroCard:NO];
    self.didScrollBack = YES;
    if ([self profileCardRequired]) {
        [self showProfileHintCard:YES];
    }
}

- (void)initBorders {
    
    // Left animation arrow.
    self.leftArrowImageView.frame = (CGRect){
        kBorderInsets.left - 1.0,
        floorf((self.view.bounds.size.height - self.leftArrowImageView.frame.size.height) / 2.0),
        self.leftArrowImageView.frame.size.width,
        self.leftArrowImageView.frame.size.height
    };
    self.leftArrowImageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:self.leftArrowImageView];
    
    // Right animation arrow.
    self.rightArrowImageView.frame = (CGRect){
        self.view.bounds.size.width - kBorderInsets.right - self.rightArrowImageView.frame.size.width - 1.0,
        floorf((self.view.bounds.size.height - self.rightArrowImageView.frame.size.height) / 2.0),
        self.rightArrowImageView.frame.size.width,
        self.rightArrowImageView.frame.size.height
    };
    self.rightArrowImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:self.rightArrowImageView];
    
    UIImage *topBorderImage = [[UIImage imageNamed:@"cook_book_inner_title_border_top.png"]
                               resizableImageWithCapInsets:(UIEdgeInsets){14.0, 18.0, 14.0, 18.0 }];
    UIImageView *topBorderImageView = [[UIImageView alloc] initWithImage:topBorderImage];
    topBorderImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight;
    topBorderImageView.frame = (CGRect){
        kBorderInsets.left,
        kBorderInsets.top,
        self.view.bounds.size.width - kBorderInsets.left - kBorderInsets.right,
        floorf(self.view.bounds.size.height / 2.0) - kBorderInsets.top - 30.0
    };
    [self.view addSubview:topBorderImageView];
    
    UIImage *bottomBorderImage = [[UIImage imageNamed:@"cook_book_inner_title_border_bottom.png"]
                                  resizableImageWithCapInsets:(UIEdgeInsets){14.0, 18.0, 14.0, 18.0 }];
    UIImageView *bottomBorderImageView = [[UIImageView alloc] initWithImage:bottomBorderImage];
    bottomBorderImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleHeight;
    bottomBorderImageView.frame = (CGRect){
        kBorderInsets.left,
        floorf(self.view.bounds.size.height / 2.0) - kBorderInsets.bottom + 40.0,
        self.view.bounds.size.width - kBorderInsets.left - kBorderInsets.right,
        floorf(self.view.bounds.size.height / 2.0) - kBorderInsets.bottom - 28.0,
    };
    [self.view addSubview:bottomBorderImageView];
}

- (NSArray *)animationImagesWithBaseName:(NSString *)baseName frameCount:(NSUInteger)frameCount {
    NSMutableArray *animationImages = [NSMutableArray arrayWithCapacity:frameCount];
    for (NSUInteger frameIndex = 1; frameIndex <= frameCount; frameIndex++) {
        UIImage *frameImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@%d.png", baseName, (unsigned int)frameIndex]];
        [animationImages addObject:frameImage];
    }
    return animationImages;
}

- (void)openGates {
    if (![self.leftArrowImageView isAnimating]) {
        self.leftArrowImageView.animationImages = [self animationImagesWithBaseName:@"cook_title_arrow_left_fr" frameCount:9];
        self.leftArrowImageView.image = [self.leftArrowImageView.animationImages lastObject];
        [self.leftArrowImageView startAnimating];
    }
    
    if (![self.rightArrowImageView isAnimating] && [self hasPages]) {
        self.rightArrowImageView.animationImages = [self animationImagesWithBaseName:@"cook_title_arrow_right_fr" frameCount:9];
        self.rightArrowImageView.image = [self.rightArrowImageView.animationImages lastObject];
        [self.rightArrowImageView startAnimating];
    }
}

- (BOOL)hasPages {
    return [self.collectionView numberOfItemsInSection:0];
}

@end
