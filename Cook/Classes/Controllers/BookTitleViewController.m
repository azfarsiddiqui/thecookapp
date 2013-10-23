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
#import "BookTitleView.h"
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
#import "CKCommentEditViewController.h"
#import "CardViewHelper.h"
#import "NSString+Utilities.h"
#import "EventHelper.h"
#import "CKProgressView.h"

@interface BookTitleViewController () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource_Draggable,
    CKEditViewControllerDelegate>

@property (nonatomic, strong) CKBook *book;
@property (nonatomic, strong) NSMutableArray *pages;
@property (nonatomic, assign) BOOL fullImageLoaded;
@property (nonatomic, assign) BOOL snapshot;
@property (nonatomic, strong) CKRecipe *heroRecipe;
@property (nonatomic, weak) id<BookTitleViewControllerDelegate> delegate;

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *topShadowView;
@property (nonatomic, strong) UIImageView *blurredImageView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) BookTitleView *bookTitleView;
@property (nonatomic, strong) CKActivityIndicatorView *activityView;
@property (nonatomic, strong) CKProgressView *progressView;

// Editing.
@property (nonatomic, strong) CKEditingViewHelper *editingHelper;
@property (nonatomic, strong) CKCommentEditViewController *editViewController;
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

#define kHeaderHeight           420.0
#define kHeaderCellGap          135.0

- (void)dealloc {
    [EventHelper unregisterPhotoLoading:self];
    [EventHelper unregisterPhotoLoadingProgress:self];
}

- (id)initWithBook:(CKBook *)book delegate:(id<BookTitleViewControllerDelegate>)delegate {
    
    return [self initWithBook:book snapshot:NO delegate:delegate];
}

- (id)initWithBook:(CKBook *)book snapshot:(BOOL)snapshot delegate:(id<BookTitleViewControllerDelegate>)delegate {
    if (self = [super init]) {
        self.book = book;
        self.snapshot = snapshot;
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
    
    if (!self.snapshot) {
        [self initActivityView];
    }
    
    [self addCloseButtonLight:YES];
    
    // Register photo loading events.
    [EventHelper registerPhotoLoading:self selector:@selector(photoLoadingReceived:)];
    [EventHelper registerPhotoLoadingProgress:self selector:@selector(photoLoadingProgress:)];
}

- (void)configurePages:(NSArray *)pages {
    
    // Make sure view is available when this is invoked.
    self.view.hidden = NO;
    
    [self.activityView stopAnimating];
    [self.activityView removeFromSuperview];
    
    BOOL reload = (self.pages != nil);
    self.pages = [NSMutableArray arrayWithArray:pages];
    
    if (reload) {
        
        [self.collectionView performBatchUpdates:^{
            [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
        } completion:^(BOOL finished){
            [self showIntroCard:([pages count] == 0)];
        }];
        
    } else {
        NSMutableArray *pageIndexPaths = [NSMutableArray arrayWithArray:[self.pages collectWithIndex:^id(NSString *page, NSUInteger pageIndex) {
            return [NSIndexPath indexPathForItem:pageIndex inSection:0];
        }]];
        
        // Add cell.
        if ([self.book isOwner]) {
            [pageIndexPaths addObject:[NSIndexPath indexPathForItem:[pageIndexPaths count] inSection:0]];
        }
        
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
                                 [self showIntroCard:([pages count] == 0)];
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
        
        // Add progress.
        self.progressView.frame = (CGRect){
            floorf((self.view.bounds.size.width - self.progressView.frame.size.width) / 2.0),
            20.0,
            self.progressView.frame.size.width,
            self.progressView.frame.size.height
        };
        [self.view addSubview:self.progressView];
        [self.progressView setProgress:0.1 animated:YES];
        
        [[CKPhotoManager sharedInstance] imageForRecipe:recipe size:self.imageView.bounds.size];
    }
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
                                                          90.0 + [BookTitleCell cellSize].width + floorf(cardSize.width / 2.0) + 20.0,
                                                          self.view.bounds.size.height - [BookTitleCell cellSize].height + 58.0,
                                                      }];
    } else {
        [[CardViewHelper sharedInstance] hideCardViewWithTag:cardTag];
    }
    
}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self applyOffset:scrollView.contentOffset.y distance:200.0 view:self.blurredImageView];
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
    
    NSString *text = value;
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

- (BookTitleView *)bookTitleView {
    if (!_bookTitleView) {
        _bookTitleView = [[BookTitleView alloc] initWithBook:self.book];
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

#pragma mark - Private methods

- (void)initBackgroundView {
    
    UIOffset motionOffset = [ViewHelper standardMotionOffset];
    UIView *imageContainerView = [[UIView alloc] initWithFrame:self.view.bounds];
    imageContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    imageContainerView.clipsToBounds = YES;
    [self.view addSubview:imageContainerView];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[ImageHelper imageFromDiskNamed:@"cook_edit_bg_blank" type:@"png"]];
    imageView.frame = (CGRect) {
        imageContainerView.bounds.origin.x - motionOffset.horizontal,
        imageContainerView.bounds.origin.y - motionOffset.vertical,
        imageContainerView.bounds.size.width + (motionOffset.horizontal * 2.0),
        imageContainerView.bounds.size.height + (motionOffset.vertical * 2.0)
    };
    imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    imageView.backgroundColor = [Theme categoryHeaderBackgroundColour];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [imageContainerView addSubview:imageView];
    self.imageView = imageView;
    
    self.blurredImageView = [[UIImageView alloc] initWithFrame:imageView.bounds];
    self.blurredImageView.alpha = 0.0;
    [self.imageView addSubview:self.blurredImageView];
    
    // Apply top shadow.
    UIImageView *topShadowView = [ViewHelper topShadowViewForView:self.view subtle:YES];
    [self.view insertSubview:topShadowView aboveSubview:self.imageView];
    self.topShadowView = topShadowView;
    
    // Motion effects.
    [ViewHelper applyDraggyMotionEffectsToView:self.imageView];
    
    UIImage *borderImage = [[UIImage imageNamed:@"cook_book_inner_title_border.png"] resizableImageWithCapInsets:(UIEdgeInsets){14.0, 18.0, 14.0, 18.0 }];
    UIImageView *borderImageView = [[UIImageView alloc] initWithImage:borderImage];
    borderImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleHeight;
    borderImageView.frame = (CGRect){
        kBorderInsets.left,
        kBorderInsets.top,
        self.view.bounds.size.width - kBorderInsets.left - kBorderInsets.right,
        self.view.bounds.size.height - kBorderInsets.top - kBorderInsets.bottom
    };
    [self.view addSubview:borderImageView];
    
    // Binder
    if (self.snapshot) {
        UIImageView *bindImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_book_edge_overlay_bind.png"]];
        bindImageView.frame = (CGRect){
            floorf((self.view.bounds.size.width - bindImageView.frame.size.width) / 2.0),
            self.view.bounds.origin.y,
            bindImageView.frame.size.width,
            bindImageView.frame.size.height
        };
        bindImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        [self.view addSubview:bindImageView];
    }
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
}

- (void)initActivityView {
    CKActivityIndicatorView *activityView = [[CKActivityIndicatorView alloc] initWithStyle:CKActivityIndicatorViewStyleLarge];
    activityView.frame = (CGRect){
        floorf((self.view.bounds.size.width - activityView.frame.size.width) / 2.0),
        self.view.bounds.size.height - 205.0,
        activityView.frame.size.width,
        activityView.frame.size.height
    };
    activityView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    [self.view addSubview:activityView];
    self.activityView = activityView;
    [activityView startAnimating];
}

- (void)addPage {
    [self enableAddMode:YES];
    [self performAddPageWithName:nil];
}

- (void)enableAddMode:(BOOL)addMode {
    self.collectionView.scrollEnabled = !addMode;
    [self.bookPageDelegate bookPageViewControllerPanEnable:!addMode];
}

- (void)configureHeroRecipeImage:(UIImage *)image {
    self.progressView.hidden = self.fullImageLoaded;
    
    [ImageHelper configureImageView:self.imageView image:image];
    self.topShadowView.image = [ViewHelper topShadowImageSubtle:NO];
    
    UIColor *tintColour = [[CKBookCover backdropColourForCover:self.book.cover] colorWithAlphaComponent:0.58];
    [ImageHelper blurredImage:image tintColour:tintColour radius:10.0 completion:^(UIImage *blurredImage) {
        self.blurredImageView.image = blurredImage;
    }];
    
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
    CKCommentEditViewController *editViewController = [[CKCommentEditViewController alloc] initWithEditView:nil
                                                                                                       delegate:self
                                                                                                  editingHelper:self.editingHelper
                                                                                                          white:YES
                                                                                                          title:@"Page Name"
                                                                                                 characterLimit:14];
    editViewController.showTitle = YES;
    editViewController.forceUppercase = YES;
    editViewController.font = [UIFont fontWithName:@"BrandonGrotesque-Regular" size:48.0];
    [editViewController performEditing:YES headless:YES transformOffset:(UIOffset){ 0.0, 20.0 }];
    self.editViewController = editViewController;
}

- (void)photoLoadingReceived:(NSNotification *)notification {
    NSString *name = [EventHelper nameForPhotoLoading:notification];
    BOOL thumb = [EventHelper thumbForPhotoLoading:notification];
    NSString *recipePhotoName = [[CKPhotoManager sharedInstance] photoNameForRecipe:self.heroRecipe];
    
    if ([recipePhotoName isEqualToString:name]) {
        
        // If full image is not loaded yet, then keep setting it until it has been flagged as fully loaded.
        if (!self.fullImageLoaded) {
            
            if ([EventHelper hasImageForPhotoLoading:notification]) {
                UIImage *image = [EventHelper imageForPhotoLoading:notification];
                self.fullImageLoaded = !thumb;
                [self configureHeroRecipeImage:image];
            } else {
                self.progressView.hidden = YES;
            }
        }
        
    }
}

- (void)photoLoadingProgress:(NSNotification *)notification {
    NSString *name = [EventHelper nameForPhotoLoading:notification];
    NSString *recipePhotoName = [[CKPhotoManager sharedInstance] photoNameForRecipe:self.heroRecipe];
    
    if ([recipePhotoName isEqualToString:name]) {
        CGFloat progress = [EventHelper progressForPhotoLoading:notification];
        [self.progressView setProgress:progress animated:YES];
    }
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
}

@end
