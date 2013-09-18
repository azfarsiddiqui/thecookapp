//
//  BookPagingStackViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 12/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookNavigationStackViewController.h"
#import "CKBook.h"
#import "CKRecipe.h"
#import "CKUser.h"
#import "CKServerManager.h"
#import "BookPagingStackLayout.h"
#import "BookProfileViewController.h"
#import "BookTitleViewController.h"
#import "BookHeaderView.h"
#import "BookProfileHeaderView.h"
#import "BookNavigationView.h"
#import "MRCEnumerable.h"
#import "CKBookCover.h"
#import "BookContentViewController.h"
#import "ViewHelper.h"
#import "BookContentImageView.h"
#import "NSString+Utilities.h"
#import "EventHelper.h"
#import "BookContentCell.h"
#import "CKPhotoManager.h"
#import "CardViewHelper.h"

@interface BookNavigationStackViewController () <BookPagingStackLayoutDelegate, BookTitleViewControllerDelegate,
    BookContentViewControllerDelegate, BookNavigationViewDelegate, BookPageViewControllerDelegate,
    UIGestureRecognizerDelegate>

@property (nonatomic, strong) CKBook *book;
@property (nonatomic, strong) CKUser *user;
@property (nonatomic, strong) CKRecipe *featuredRecipe;
@property (nonatomic, strong) CKRecipe *saveOrUpdatedRecipe;
@property (nonatomic, strong) NSString *saveOrUpdatedPage;
@property (nonatomic, assign) id<BookNavigationViewControllerDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *pages;
@property (nonatomic, strong) NSMutableArray *recipes;
@property (nonatomic, strong) NSMutableDictionary *pageRecipes;
@property (nonatomic, strong) NSMutableDictionary *pagesContainingUpdatedRecipes;
@property (nonatomic, strong) NSMutableDictionary *contentControllers;
@property (nonatomic, strong) NSMutableDictionary *contentControllerOffsets;
@property (nonatomic, strong) NSMutableDictionary *pageHeaderViews;
@property (nonatomic, strong) NSMutableDictionary *pageCoverRecipes;
@property (nonatomic, assign) BOOL justOpened;
@property (nonatomic, assign) BOOL lightStatusBar;
@property (nonatomic, strong) UIView *bookOutlineView;
@property (nonatomic, strong) UIView *bookBindingView;
@property (nonatomic, strong) NSDate *bookLastAccessedDate;

@property (nonatomic, strong) BookNavigationView *bookNavigationView;

// Edit mode.
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, assign) BOOL editMode;

// Left/right book edges.
@property (nonatomic, strong) UIView *benchtopSnapshotView;
@property (nonatomic, strong) UIView *leftOutlineView;
@property (nonatomic, strong) UIView *rightOutlineView;

// Content VCs
@property (nonatomic, strong) BookProfileViewController *profileViewController;
@property (nonatomic, strong) BookTitleViewController *titleViewController;
@property (nonatomic, strong) BookPageViewController *currentEditViewController;

@property (copy) BookNavigationUpdatedBlock bookUpdatedBlock;

@end

@implementation BookNavigationStackViewController

#define kCellId                     @"CellId"
#define kProfileSection             0
#define kIndexSection               1
#define kProfileCellId              @"ProfileCellId"
#define kIndexCellId                @"IndexCellId"
#define kContentCellId              @"ContentCellId"
#define kContentHeaderId            @"ContentHeaderId"
#define kProfileHeaderId            @"ProfileHeaderId"
#define kNavigationHeaderId         @"NavigationHeaderId"
#define kBookOutlineHeaderId        @"BookOutlineHeaderId"
#define kContentViewTag             460
#define kBookOutlineOffset          (UIOffset){-64.0, -26.0}
#define kBookOutlineSnapshotWidth   400.0
#define kEditButtonInsets           (UIEdgeInsets){ 20.0, 5.0, 0.0, 5.0 }
#define kIndexSectionTag            950
#define kProfileSectionTag          951

- (id)initWithBook:(CKBook *)book delegate:(id<BookNavigationViewControllerDelegate>)delegate {
    if (self = [super initWithCollectionViewLayout:[[BookPagingStackLayout alloc] initWithDelegate:self]]) {
        self.delegate = delegate;
        self.book = book;
        self.user = book.user;
        self.profileViewController = [[BookProfileViewController alloc] initWithBook:book];
        self.profileViewController.bookPageDelegate = self;
        self.titleViewController = [[BookTitleViewController alloc] initWithBook:book delegate:self];
        self.titleViewController.bookPageDelegate = self;
        
        // Forget about dismissed states.
        [[CardViewHelper sharedInstance] clearDismissedStates];
        
    }
    return self;
}

- (id)init {
    if (self = [super initWithCollectionViewLayout:[[BookPagingStackLayout alloc] initWithDelegate:self]]) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.userInteractionEnabled = YES; // To block touches filtering down.
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    // Mark as just opened.
    self.justOpened = YES;
    [self initBookOutlineView];
    [self initCollectionView];
    [self loadData];
    
    // Register pinch
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinched:)];
    [self.view addGestureRecognizer:pinchGesture];
    
    // Register left screen edge for shortcut to home.
    UIScreenEdgePanGestureRecognizer *leftEdgeGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self
                                                                                                          action:@selector(screenEdgePanned:)];
    leftEdgeGesture.delegate = self;
    leftEdgeGesture.edges = UIRectEdgeLeft;
    [self.collectionView addGestureRecognizer:leftEdgeGesture];
}

- (void)setActive:(BOOL)active {
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         
                         // Fade the book navigation view.
                         self.bookNavigationView.alpha = active ? 1.0 : 0.0;
                         
                         // Fade the cells.
                         NSArray *visibleCells = [self.collectionView visibleCells];
                         for (UICollectionViewCell *cell in visibleCells) {
                             cell.alpha = active ? 1.0 : 0.0;
                         }
                         
                     }
                     completion:^(BOOL finished) {
                     }];
}

- (void)updateBinderAlpha:(CGFloat)alpha {
    if (!self.bookBindingView) {
        self.bookBindingView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_book_edge_overlay_bind.png"]];
        self.bookBindingView.frame = self.bookOutlineView.frame;
        [self.view addSubview:self.bookBindingView];
    }
    self.bookBindingView.alpha = alpha;
}

- (void)updateWithRecipe:(CKRecipe *)recipe completion:(BookNavigationUpdatedBlock)completion {
    DLog(@"Updating layout with recipe [%@][%@]", recipe.name, recipe.page);
    
    // Check if this was a new recipe, in which case add it to the front of recipes list
    CKRecipe *foundRecipe = [self.recipes detect:^BOOL(CKRecipe *existingRecipe) {
        return [existingRecipe.objectId isEqualToString:recipe.objectId];
    }];
    if (!foundRecipe) {
        
        // Add to the list of recipes.
        [self.recipes insertObject:recipe atIndex:0];
        
    } else {
        
        // Swap it around.
        [self.recipes removeObject:foundRecipe];
        [self.recipes insertObject:recipe atIndex:0];
        
    }
    
    // Remember the recipe that was actioned.
    self.saveOrUpdatedRecipe = recipe;
    
    // Remember the block, which will be invoked in the prepareLayoutDidFinish method after layout completes.
    self.bookUpdatedBlock = completion;
    
    // Load recipes to rebuild the layout.
    [self loadRecipes];
}

- (void)updateWithDeletedRecipe:(CKRecipe *)recipe completion:(BookNavigationUpdatedBlock)completion {
    DLog(@"Updating layout with deleted recipe [%@][%@]", recipe.name, recipe.page);
    
    // Remove the recipes.
    [self.recipes removeObject:recipe];
    
    // Remember the recipe that was actioned.
    self.saveOrUpdatedRecipe = recipe;
    
    // Remember the block, which will be invoked in the prepareLayoutDidFinish method after layout completes.
    self.bookUpdatedBlock = completion;
    
    // Load recipes to rebuild the layout.
    [self loadRecipes];
}

- (void)updateWithDeletedPage:(NSString *)page completion:(BookNavigationUpdatedBlock)completion {
    DLog(@"Updating layout with deleted page [%@]", page);
    
    // Remove the recipes in the page.
    self.recipes = [NSMutableArray arrayWithArray:[self.recipes reject:^BOOL(CKRecipe *recipe) {
        return [recipe.page CK_equalsIgnoreCase:page];
    }]];
    
    // Remember the block, which will be invoked in the prepareLayoutDidFinish method after layout completes.
    self.bookUpdatedBlock = completion;
    
    // Load recipes to rebuild the layout.
    [self loadRecipes];
}

- (void)updateWithRenamedPage:(NSString *)page fromPage:(NSString *)fromPage
                   completion:(BookNavigationUpdatedBlock)completion {
    
    DLog(@"Updating layout with renamed page [%@] fromPage[%@]", page, fromPage);
    
    // Rename the page in existing recipes..
    NSArray *recipesToRename = [self.recipes select:^BOOL(CKRecipe *recipe) {
        return [recipe.page CK_equalsIgnoreCase:fromPage];
    }];
    
    // Renaming the recipes locally, as server-side has already occured.
    DLog(@"Renaming [%d] recipes to [%@]", [recipesToRename count], page);
    [recipesToRename each:^(CKRecipe *recipe) {
        recipe.page = page;
    }];
    
    // Remember the recipe that was actioned.
    self.saveOrUpdatedPage = page;
    
    // Remember the block, which will be invoked in the prepareLayoutDidFinish method after layout completes.
    self.bookUpdatedBlock = completion;
    
    // Load recipes to rebuild the layout.
    [self loadRecipes];
}

- (void)updateStatusBar {
    CGRect visibleFrame = [ViewHelper visibleFrameForCollectionView:self.collectionView];
    if (visibleFrame.origin.x < (self.collectionView.bounds.size.width * 2.0) - floorf(self.collectionView.bounds.size.width / 2.0)) {
        if (!self.lightStatusBar) {
            self.lightStatusBar = YES;
            [EventHelper postStatusBarChangeForLight:self.lightStatusBar];
        }
    } else {
        if (self.lightStatusBar) {
            self.lightStatusBar = NO;
            [EventHelper postStatusBarChangeForLight:self.lightStatusBar];
        }
    }
}

- (void)updatePageOverlays {
    CGRect visibleFrame = [ViewHelper visibleFrameForCollectionView:self.collectionView];
    BookPagingStackLayout *layout = [self currentLayout];
    
    NSArray *visibleIndexPaths = [self.collectionView indexPathsForVisibleItems];
    NSArray *pageIndexPaths = [visibleIndexPaths select:^BOOL(NSIndexPath *indexPath) {
        return (indexPath.section >= [self stackContentStartSection] - 1);
    }];
    
    if ([pageIndexPaths count] > 0) {
        
        NSSortDescriptor *pageSorter = [[NSSortDescriptor alloc] initWithKey:@"section" ascending:YES];
        pageIndexPaths = [pageIndexPaths sortedArrayUsingDescriptors:@[pageSorter]];
        NSIndexPath *topIndexPath = [pageIndexPaths firstObject];
        NSInteger topPageIndex = topIndexPath.section - [self stackContentStartSection];
        
        // See if there's a next page.
        NSInteger nextPageIndex = topPageIndex + 1;
        if (nextPageIndex < [self.pages count]) {
            
            CGFloat currentPageOffset = [layout pageOffsetForIndexPath:topIndexPath];
            NSString *nextPage = [self.pages objectAtIndex:nextPageIndex];
            
            CGFloat distance = ABS(visibleFrame.origin.x - currentPageOffset);
            CGFloat overlayAlpha = 1.0 - (distance / visibleFrame.size.width);
//            DLog(@"PAGE [%@] distance[%f] overlay [%f]", nextPage, distance, overlayAlpha);
            
            BookContentViewController *pageViewController = [self.contentControllers objectForKey:nextPage];
            if (pageViewController) {
                [pageViewController applyOverlayAlpha:overlayAlpha];
            }
        }
    }
    
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    return YES;
}

#pragma mark - BookPageViewControllerDelegate methods

- (void)bookPageViewControllerCloseRequested {
    [self closeBook];
}

- (void)bookPageViewControllerShowRecipe:(CKRecipe *)recipe {
    [self showRecipe:recipe];
}

- (void)bookPageViewControllerPanEnable:(BOOL)enable {
    self.collectionView.scrollEnabled = enable;
}

- (void)bookPageViewController:(BookPageViewController *)bookPageViewController editModeRequested:(BOOL)editMode {
    self.currentEditViewController = bookPageViewController;
    [self enableEditMode:editMode];
}

- (void)bookPageViewController:(BookPageViewController *)bookPageViewController editing:(BOOL)editing {
    [self updateButtonsWithAlpha:editing ? 0.0 : 1.0];
}

- (NSArray *)bookPageViewControllerAllPages {
    return self.pages;
}

#pragma mark - BookNavigationViewDelegate methods

- (void)bookNavigationViewCloseTapped {
    [self closeBook];
}

- (void)bookNavigationViewHomeTapped {
    [self scrollToHome];
}

- (void)bookNavigationViewAddTapped {
    if ([self.book isOwner]) {
        [self showAddView:YES];
    }
}

- (void)bookNavigationViewEditTapped {
    if ([self.book isOwner]) {
        
        [self enableEditMode:YES];

        // Get current page.
        NSString *page = [self currentPage];
        BookContentViewController *categoryController = [self.contentControllers objectForKey:page];
        [categoryController enableEditMode:YES];
        self.currentEditViewController = categoryController;
        
    }
}

- (UIColor *)bookNavigationColour {
    return [CKBookCover textColourForCover:self.book.cover];
}

#pragma mark - BookContentViewControllerDelegate methods

- (NSArray *)recipesForBookContentViewControllerForPage:(NSString *)page {
    return [self.pageRecipes objectForKey:page];
}

- (CKRecipe *)featuredRecipeForBookContentViewControllerForPage:(NSString *)page {
    return [self coverRecipeForPage:page];
}

- (void)bookContentViewControllerScrolledOffset:(CGFloat)offset page:(NSString *)page {
    BookContentImageView *contentHeaderView = [self.pageHeaderViews objectForKey:page];
    [contentHeaderView applyOffset:offset];
}

#pragma mark - BookTitleViewControllerDelegate methods

- (CKRecipe *)bookTitleFeaturedRecipeForPage:(NSString *)page {
    return [self coverRecipeForPage:page];
}

- (NSInteger)bookTitleNumRecipesForPage:(NSString *)page {
    NSArray *pageRecipes = [self.pageRecipes objectForKey:page];
    return [pageRecipes count];
}

- (void)bookTitleSelectedPage:(NSString *)page {
    self.collectionView.userInteractionEnabled = NO;
    [self scrollToPage:page animated:YES];
}

- (void)bookTitleUpdatedOrderOfPages:(NSArray *)pages {
    BOOL orderChanged = [self orderChangedForPages:pages];
    DLog(@"Pages order changed: %@", [NSString CK_stringForBoolean:orderChanged]);
    if (orderChanged) {
        
        self.pages = [NSMutableArray arrayWithArray:pages];
        self.book.pages = pages;
        [self.book saveInBackground];
        
        // Now relayout the content pages.
        [[self currentLayout] setNeedsRelayout:YES];
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndexesInRange:(NSRange){
            [self stackContentStartSection], [self.pages count]
        }]];
        
    }
}

- (void)bookTitleAddedPage:(NSString *)page {
    
    [self.pages addObject:page];
    [self.pageRecipes setObject:[NSMutableArray array] forKey:page];
    self.book.pages = self.pages;
    
    // Mark layout needs to be re-generated.
    [[self currentLayout] setNeedsRelayout:YES];
    [self.collectionView reloadData];
    
    // Save the book in the background.
    [self.book saveInBackground];
}

- (BOOL)bookTitleIsNewForPage:(NSString *)page {
    
    if ([self.book isOwner]) {
        return NO;
    } else {
        return ([self.pagesContainingUpdatedRecipes objectForKey:page] != nil);
    }
    
}

#pragma mark - BookPagingStackLayoutDelegate methods

- (void)stackPagingLayoutDidFinish {
    DLog();
    
    if (self.bookUpdatedBlock != nil) {
        
        // If we have an actioned recipe, then navigate there.
        if (self.saveOrUpdatedRecipe) {
            
            // Get the index of the page within the book.
            NSString *page = self.saveOrUpdatedRecipe.page;
            [self scrollToPage:page animated:NO];
            
        } else if (self.saveOrUpdatedPage != nil) {
        
            // Do nothing, stay at the page.
        
        } else {
            
            // Go to home; this is the case when page is deleted.
            [self scrollToHomeAnimated:NO];
            
        }
        
        // Invoked from recipe edit/added block.
        self.bookUpdatedBlock();
        self.bookUpdatedBlock = nil;
        
        // Clear breadcrumb flags.
        self.saveOrUpdatedRecipe = nil;
        self.saveOrUpdatedPage = nil;
        
    } else if (self.justOpened) {
        
        self.justOpened = NO;
        
        // Start on page 1.
        [self peekTheBook];
        
    }
    
    // Left book edge always on the left.
    [self applyLeftBookEdgeOutline];
    
    // Right book edge only after it has been opened.
    if ([self numberOfSectionsInCollectionView:self.collectionView] >= [self stackContentStartSection]) {
        [self applyRightBookEdgeOutline];
    }
}

- (BookPagingStackLayoutType)stackPagingLayoutType {
    return BookPagingStackLayoutTypeSlideOneWay;
}

- (NSInteger)stackContentStartSection {
    return kIndexSection + 1;
}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateStatusBar];
    [self updatePageOverlays];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    self.collectionView.userInteractionEnabled = YES;
}

#pragma mark - UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    DLog();
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    NSInteger numSections = 0;
    
    numSections += 1;                       // Profile page.
    numSections += 1;                       // Index page.
    numSections += [self.pages count];      // Content pages.
    
    return numSections;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    
    // One page per section.
    return 1;
    
}

- (UICollectionReusableView *)collectionView: (UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionReusableView *headerView = nil;
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        
        if (indexPath.section == kProfileSection) {
            headerView = [self profileHeaderViewAtIndexPath:indexPath];
        } else if (indexPath.section >= [self stackContentStartSection]) {
            headerView = [self contentHeaderViewAtIndexPath:indexPath];
        }
        
    } else if ([kind isEqualToString:[BookPagingStackLayout bookPagingNavigationElementKind]]) {
        
        headerView = [self navigationHeaderViewAtIndexPath:indexPath];
        
    }
    
    return headerView;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = nil;
    
    if (indexPath.section == kProfileSection) {
        cell = [self profileCellAtIndexPath:indexPath];
    } else if (indexPath.section == kIndexSection) {
        cell = [self indexCellAtIndexPath:indexPath];
    } else {
        cell = [self contentCellAtIndexPath:indexPath];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryView:(UICollectionReusableView *)view
      forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section >= [self stackContentStartSection]) {
        
        // Remove a reference to the content image view.
        if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
            NSInteger pageIndex = indexPath.section - [self stackContentStartSection];
            if (pageIndex < [self.pages count]) {
                NSString *page = [self.pages objectAtIndex:pageIndex];
                [self.pageHeaderViews removeObjectForKey:page];
            }
        }
    }
    
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section >= [self stackContentStartSection]) {
        
        // Remove reference to BookContentVC and remember its vertical scroll offset.
        NSInteger pageIndex = indexPath.section - [self stackContentStartSection];
        if (pageIndex < [self.pages count]) {
            NSString *page = [self.pages objectAtIndex:pageIndex];
            
            BookContentViewController *contentViewController = [self.contentControllers objectForKey:page];
            if (contentViewController) {
                
                // Remember its current offset so we can restore later.
                [self.contentControllerOffsets setObject:[NSValue valueWithCGPoint:[contentViewController currentScrollOffset]]
                                                  forKey:page];
                [self.contentControllers removeObjectForKey:page];
                contentViewController = nil;
            }
            
        }
    }
    
}

#pragma mark - Properties

- (UIView *)benchtopSnapshotView {
    if (!_benchtopSnapshotView) {
        _benchtopSnapshotView = [self.delegate bookNavigationSnapshot];
    }
    return _benchtopSnapshotView;
}

- (UIView *)leftOutlineView {
    if (!_leftOutlineView) {
        
        // Dashboard.
        _leftOutlineView = [self.benchtopSnapshotView resizableSnapshotViewFromRect:(CGRect) {
            0.0,
            0.0,
            kBookOutlineSnapshotWidth,
            self.benchtopSnapshotView.frame.size.height
        }  afterScreenUpdates:YES withCapInsets:UIEdgeInsetsZero];
        
        // Book edge.
        UIView *leftBookEdgeView = [self.view resizableSnapshotViewFromRect:(CGRect){
            kBookOutlineOffset.horizontal,
            self.view.bounds.origin.y,
            -kBookOutlineOffset.horizontal,
            self.view.bounds.size.height
        } afterScreenUpdates:YES withCapInsets:UIEdgeInsetsZero];
        
        CGRect leftBookFrame = leftBookEdgeView.frame;
        leftBookFrame.origin.x = _leftOutlineView.bounds.size.width - leftBookFrame.size.width;
        leftBookEdgeView.frame = leftBookFrame;
        [_leftOutlineView addSubview:leftBookEdgeView];
        
    }
    return _leftOutlineView;
}

- (UIView *)rightOutlineView {
    if (!_rightOutlineView) {
        
        // Dashboard.
        _rightOutlineView = [self.benchtopSnapshotView resizableSnapshotViewFromRect:(CGRect) {
            self.benchtopSnapshotView.frame.size.width - kBookOutlineSnapshotWidth,
            0.0,
            kBookOutlineSnapshotWidth,
            self.benchtopSnapshotView.frame.size.height
        } afterScreenUpdates:YES withCapInsets:UIEdgeInsetsZero];
        
        // Book edge.
        UIView *rightBookEdgeView = [self.view resizableSnapshotViewFromRect:(CGRect){
            self.view.bounds.size.width,
            self.view.bounds.origin.y,
            -kBookOutlineOffset.horizontal,
            self.view.bounds.size.height
        } afterScreenUpdates:YES withCapInsets:UIEdgeInsetsZero];
        
        CGRect rightBookFrame = rightBookEdgeView.frame;
        rightBookFrame.origin.x = rightBookFrame.origin.x;
        rightBookEdgeView.frame = rightBookFrame;
        [_rightOutlineView addSubview:rightBookEdgeView];

    }
    return _rightOutlineView;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [ViewHelper cancelButtonWithTarget:self selector:@selector(cancelTapped:)];
        _cancelButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
        [_cancelButton setFrame:CGRectMake(kEditButtonInsets.left,
                                           kEditButtonInsets.top,
                                           _cancelButton.frame.size.width,
                                           _cancelButton.frame.size.height)];
    }
    return _cancelButton;
}

- (UIButton *)saveButton {
    if (!_saveButton) {
        _saveButton = [ViewHelper okButtonWithTarget:self selector:@selector(saveTapped:)];
        _saveButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin;
        [_saveButton setFrame:CGRectMake(self.view.bounds.size.width - _saveButton.frame.size.width - kEditButtonInsets.right,
                                         kEditButtonInsets.top,
                                         _saveButton.frame.size.width,
                                         _saveButton.frame.size.height)];
    }
    return _saveButton;
}

#pragma mark - Private methods

- (void)initBookOutlineView {
    
    // Book overlay.
    UIImageView *bookOutlineOverlayView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_book_edge_overlay.png"]];
    bookOutlineOverlayView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin;
    
    // Outline container.
    UIView *outlineContainerView = [[UIView alloc] initWithFrame:CGRectZero];
    outlineContainerView.backgroundColor = [UIColor clearColor];
    outlineContainerView.frame = (CGRect){
        kBookOutlineOffset.horizontal,
        kBookOutlineOffset.vertical,
        bookOutlineOverlayView.frame.size.width,
        bookOutlineOverlayView.frame.size.height
    };
    [self.view insertSubview:outlineContainerView belowSubview:self.collectionView];
    
    // Left cover outline.
    UIImage *leftOutlineImage = [CKBookCover outlineImageForCover:self.book.cover left:YES];
    UIImageView *leftBookOutlineView = [[UIImageView alloc] initWithImage:leftOutlineImage];
    [outlineContainerView addSubview:leftBookOutlineView];
    
    // Right cover outline.
    UIImage *rightOutlineImage = [CKBookCover outlineImageForCover:self.book.cover left:NO];
    UIImageView *rightBookOutlineView = [[UIImageView alloc] initWithImage:rightOutlineImage];
    CGRect rightBookOutlineFrame = rightBookOutlineView.frame;
    rightBookOutlineFrame.origin.x = outlineContainerView.bounds.size.width - rightBookOutlineFrame.size.width;
    rightBookOutlineView.frame = rightBookOutlineFrame;
    [outlineContainerView addSubview:rightBookOutlineView];
    
    // Overlay.
    [outlineContainerView addSubview:bookOutlineOverlayView];
    self.bookOutlineView = outlineContainerView;
}

- (void)initCollectionView {
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.pagingEnabled = YES;
    self.collectionView.alwaysBounceVertical = NO;
    self.collectionView.alwaysBounceHorizontal = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    
    // Headers
    [self.collectionView registerClass:[BookProfileHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kProfileHeaderId];
    [self.collectionView registerClass:[BookContentImageView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kContentHeaderId];
    [self.collectionView registerClass:[BookNavigationView class] forSupplementaryViewOfKind:[BookPagingStackLayout bookPagingNavigationElementKind] withReuseIdentifier:kNavigationHeaderId];
    
    // Profile, Index, Category.
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kProfileCellId];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kIndexCellId];
    [self.collectionView registerClass:[BookContentCell class] forCellWithReuseIdentifier:kContentCellId];
}

- (void)loadData {
    DLog();
    
    // Fetch all recipes for the book, and categorise them.
    [self.book fetchRecipesSuccess:^(PFObject *parseBook, NSArray *recipes, NSDate *lastAccessedDate) {
        if (parseBook) {
            self.book = [CKBook bookWithParseObject:parseBook];
        }
        self.bookLastAccessedDate = lastAccessedDate;
        [self processRecipes:recipes];
        
    } failure:^(NSError *error) {
        
        DLog(@"Error %@", [error localizedDescription]);
    }];
}

- (void)processRecipes:(NSArray *)recipes {
    self.recipes = [NSMutableArray arrayWithArray:recipes];
    [self loadRecipes];
}

- (void)loadRecipes {
    self.pageRecipes = [NSMutableDictionary dictionary];
    self.pagesContainingUpdatedRecipes = [NSMutableDictionary dictionary];
    self.pageHeaderViews = [NSMutableDictionary dictionary];
    
    // Keep a reference of pages.
    self.pages = [NSMutableArray arrayWithArray:self.book.pages];
    
    // Loop through and gather recipes for each page.
    for (CKRecipe *recipe in self.recipes) {
        
        NSString *page = recipe.page;
        
        // Collect recipes into their corresponding pages.
        NSMutableArray *pageRecipes = [self.pageRecipes objectForKey:page];
        if (!pageRecipes) {
            pageRecipes = [NSMutableArray array];
            [self.pageRecipes setObject:pageRecipes forKey:page];
        }
        [pageRecipes addObject:recipe];
        
        // Is this a new recipe?
        if (self.bookLastAccessedDate
            && ([recipe.updatedDateTime compare:self.bookLastAccessedDate] == NSOrderedDescending)) {
            
            // Mark the page as new.
            [self.pagesContainingUpdatedRecipes setObject:@YES forKey:page];
        }
    }
    
    // Process rankings.
    [self processRanks];
    
    // Initialise the categoryControllers
    self.contentControllers = [NSMutableDictionary dictionaryWithCapacity:[self.pages count]];
    self.contentControllerOffsets = [NSMutableDictionary dictionaryWithCapacity:[self.pages count]];
    
    // Refresh title page.
    [self loadTitlePage];
    
    // Now relayout the category pages.
    [[self currentLayout] setNeedsRelayout:YES];
    [self.collectionView reloadData];
}

- (void)loadTitlePage {
    
    // Load the pages.
    [self.titleViewController configurePages:self.pages];
    
    // Load the hero recipe.
    if ([self.pages count] > 0) {
        [self.titleViewController configureHeroRecipe:self.featuredRecipe];
    }
}

- (UICollectionViewCell *)profileCellAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *profileCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:kProfileCellId forIndexPath:indexPath];;
    if (![profileCell.contentView viewWithTag:kProfileSectionTag]) {
        self.profileViewController.view.frame = profileCell.contentView.bounds;
        self.profileViewController.view.tag = kProfileSectionTag;
        [profileCell.contentView addSubview:self.profileViewController.view];
    }
    return profileCell;
}

- (UICollectionViewCell *)indexCellAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *indexCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:kIndexCellId forIndexPath:indexPath];
    if (![indexCell.contentView viewWithTag:kIndexSectionTag]) {
        self.titleViewController.view.frame = indexCell.contentView.bounds;
        self.titleViewController.view.tag = kIndexSectionTag;
        [indexCell.contentView addSubview:self.titleViewController.view];
    }
    return indexCell;
}

- (UICollectionViewCell *)contentCellAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *categoryCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:kContentCellId
                                                                                        forIndexPath:indexPath];
    NSInteger pageIndex = indexPath.section - [self stackContentStartSection];
    NSString *page = [self.pages objectAtIndex:pageIndex];
    
    [self loadContentForPage:page cell:(BookContentCell *)categoryCell];
    
    return categoryCell;
}

- (void)loadContentForPage:(NSString *)page cell:(BookContentCell *)cell {
    
    // Load or create categoryController.
    BookContentViewController *categoryController = [self.contentControllers objectForKey:page];
    if (!categoryController) {
        categoryController = [[BookContentViewController alloc] initWithBook:self.book page:page delegate:self];
        categoryController.bookPageDelegate = self;
        
        // Remember this so that we can unset it on disEndDisplayingCell
        [self.contentControllers setObject:categoryController forKey:page];
        
    } else {
        DLog(@"Reusing page VC for [%@]", page);
    }
    
    // Add the contentVC to the cell.
    cell.contentViewController = categoryController;
    
    // Scroll offset?
    CGPoint scrollOffset = [[self.contentControllerOffsets objectForKey:page] CGPointValue];
    [categoryController setScrollOffset:scrollOffset];
}

- (void)clearFastForwardContentForPage:(NSString *)page cell:(BookContentCell *)cell {
    cell.contentViewController = nil;
}

- (NSString *)currentPage {
    NSString *page = nil;
    CGRect visibleFrame = [ViewHelper visibleFrameForCollectionView:self.collectionView];
    BookPagingStackLayout *layout = [self currentLayout];
    
    NSArray *visibleIndexPaths = [self.collectionView indexPathsForVisibleItems];
    if ([visibleIndexPaths count] > 0) {
        
        // This only returns cells not supplementary/decoration views.
        for (NSIndexPath *indexPath in visibleIndexPaths) {
            if (indexPath.section >= [self stackContentStartSection]) {
                
                NSInteger pageIndex = indexPath.section - [self stackContentStartSection];
                
                // Look for an indexPath that equals the visibleFrame, i.e. current category page in view.
                CGFloat pageOffset = [layout pageOffsetForIndexPath:indexPath];
                if (pageOffset == visibleFrame.origin.x) {
                    if (pageIndex < [self.pages count]) {
                        page = [self.pages objectAtIndex:pageIndex];
                    }
                }
            }
        }
        
    }
    return page;
}

- (NSArray *)recipesWithPhotos:(NSArray *)recipes {
    return [recipes select:^BOOL(CKRecipe *recipe) {
        return [recipe hasPhotos];
    }];
}

- (CKRecipe *)coverRecipeForPage:(NSString *)page {
    return [self.pageCoverRecipes objectForKey:page];
}

- (void)closeTapped:(id)sender {
    [self closeBook];
}

- (void)configureImageForHeaderView:(BookContentImageView *)contentHeaderView recipe:(CKRecipe *)recipe
                          indexPath:(NSIndexPath *)indexPath {
    DLog(@"Content Image for %d", indexPath.section);
    
    [contentHeaderView configureImage:[CKBookCover recipeEditBackgroundImageForCover:self.book.cover]
                          placeholder:YES book:self.book];
    
    if ([recipe hasPhotos]) {
        [[CKPhotoManager sharedInstance] imageForRecipe:recipe size:[contentHeaderView imageSizeWithMotionOffset]
                                                   name:recipe.objectId
                                               progress:^(CGFloat progressRatio, NSString *name) {
                                               } thumbCompletion:^(UIImage *thumbImage, NSString *name) {
                                                   if ([name isEqualToString:recipe.objectId]) {
                                                       [contentHeaderView configureImage:thumbImage placeholder:NO book:self.book];
                                                   }
                                               } completion:^(UIImage *image, NSString *name) {
                                                   if ([name isEqualToString:recipe.objectId]) {
                                                       [contentHeaderView configureImage:image placeholder:NO book:self.book];
                                                   }
                                               }];
    }
}

- (void)showRecipe:(CKRecipe *)recipe {
    [self.delegate bookNavigationControllerRecipeRequested:recipe];
}

- (void)showAddView:(BOOL)show {
    [self.delegate bookNavigationControllerAddRecipeRequestedForPage:[self currentPage]];
}

- (UICollectionReusableView *)profileHeaderViewAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *headerView = [self.collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                                   withReuseIdentifier:kProfileHeaderId
                                                                                          forIndexPath:indexPath];
    BookProfileHeaderView *profileHeaderView = (BookProfileHeaderView *)headerView;
    [profileHeaderView configureBookSummaryView:self.profileViewController.summaryView];
    return headerView;
}

- (UICollectionReusableView *)contentHeaderViewAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *headerView = [self.collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                                   withReuseIdentifier:kContentHeaderId
                                                                                          forIndexPath:indexPath];
    BookContentImageView *categoryHeaderView = (BookContentImageView *)headerView;
    
    NSInteger pageIndex = indexPath.section - [self stackContentStartSection];
    NSString *page = [self.pages objectAtIndex:pageIndex];
    
    // Get the corresponding categoryVC to retrieve current scroll offset.
    CGPoint contentOffset = [[self.contentControllerOffsets objectForKey:page] CGPointValue];
    [categoryHeaderView applyOffset:contentOffset.y];
    
    // Load featured recipe image.
    CKRecipe *coverRecipe = [self coverRecipeForPage:page];
    [categoryHeaderView configureFeaturedRecipe:coverRecipe book:self.book];
//    [self configureImageForHeaderView:categoryHeaderView recipe:coverRecipe indexPath:indexPath];
    
    // Keep track of category views keyed on page name.
    [self.pageHeaderViews setObject:categoryHeaderView forKey:page];
    
    return headerView;
}

- (UICollectionReusableView *)navigationHeaderViewAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *headerView = [self.collectionView dequeueReusableSupplementaryViewOfKind:[BookPagingStackLayout bookPagingNavigationElementKind]
                                                                                   withReuseIdentifier:kNavigationHeaderId
                                                                                          forIndexPath:indexPath];
    BookNavigationView *navigationView = (BookNavigationView *)headerView;
    navigationView.delegate = self;
    [navigationView setTitle:[self.book author] editable:[self.book isOwner] book:self.book];
    [navigationView setDark:NO];
    self.bookNavigationView = navigationView;
    
    return headerView;
}

- (void)applyLeftBookEdgeOutline {
    self.leftOutlineView.frame = (CGRect){
        -self.leftOutlineView.frame.size.width,
        self.collectionView.bounds.origin.y,
        self.leftOutlineView.frame.size.width,
        self.collectionView.bounds.size.height
    };
    if (!self.leftOutlineView.superview) {
        [self.collectionView addSubview:self.leftOutlineView];
    }
}

- (void)applyRightBookEdgeOutline {
    CGSize contentSize = [[self currentLayout] collectionViewContentSize];
    self.rightOutlineView.frame = (CGRect){
        contentSize.width,
        self.collectionView.bounds.origin.y,
        self.rightOutlineView.frame.size.width,
        self.collectionView.bounds.size.height
    };
    if (!self.rightOutlineView.superview) {
        [self.collectionView addSubview:self.rightOutlineView];
    }
}

- (void)pinched:(UIPinchGestureRecognizer *)pinchGesture {
    
    if (pinchGesture.state == UIGestureRecognizerStateBegan
        || pinchGesture.state == UIGestureRecognizerStateChanged) {
        
        [self pinchScaleWithCurrentScale:pinchGesture.scale minTrueScale:0.5 maxMinScale:0.9 maxTrueScale:1.5 maxMaxScale:1.1];
        [self pinchBinderWithCurrentScale:pinchGesture.scale minTrueScale:0.5 maxMinScale:0.0 maxTrueScale:1.0 maxMaxScale:1.0];
        
	} else if (pinchGesture.state == UIGestureRecognizerStateEnded) {
        
        // Pinch close when smaller than 0.5.
        [self pinchClose:(pinchGesture.scale <= 0.5)];
        
    }
    
}

- (void)pinchScaleWithCurrentScale:(CGFloat)scale minTrueScale:(CGFloat)minTrueScale
                  maxMinScale:(CGFloat)maxMinScale maxTrueScale:(CGFloat)maxTrueScale maxMaxScale:(CGFloat)maxMaxScale {
    
    CGFloat resolvedScale = [self resolvedScaleWithCurrentScale:scale minTrueScale:minTrueScale maxMinScale:maxMinScale
                                                   maxTrueScale:maxTrueScale maxMaxScale:maxMaxScale];
    self.view.transform = CGAffineTransformMakeScale(resolvedScale, resolvedScale);
}

- (void)pinchBinderWithCurrentScale:(CGFloat)scale minTrueScale:(CGFloat)minTrueScale
                        maxMinScale:(CGFloat)maxMinScale maxTrueScale:(CGFloat)maxTrueScale
                        maxMaxScale:(CGFloat)maxMaxScale {
    
    CGFloat resolvedScale = 1.0 - [self resolvedScaleWithCurrentScale:scale minTrueScale:minTrueScale maxMinScale:maxMinScale
                                                         maxTrueScale:maxTrueScale maxMaxScale:maxMaxScale];
    [self updateBinderAlpha:resolvedScale];
}

- (CGFloat)resolvedScaleWithCurrentScale:(CGFloat)scale minTrueScale:(CGFloat)minTrueScale
                             maxMinScale:(CGFloat)maxMinScale maxTrueScale:(CGFloat)maxTrueScale
                             maxMaxScale:(CGFloat)maxMaxScale {
    if (scale >= maxTrueScale) {
        scale = maxMaxScale;
    } else if (scale >= 1.0) {
        scale = 1.0 + ((maxMaxScale - 1.0) * ((scale - 1.0) / 0.5));
    } else if (scale < minTrueScale) {
        scale = maxMinScale;
    } else  {
        scale = maxMinScale + ((1.0 - maxMinScale) * ((scale - minTrueScale) / minTrueScale));
    }
    return scale;
}

- (void)pinchClose:(BOOL)close {
    if (close) {
        [self closeBookWithPinch:YES];
    } else {
        [UIView animateWithDuration:0.15
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.view.transform = CGAffineTransformIdentity;
                             self.bookBindingView.alpha = 0.0;
                         }
                         completion:^(BOOL finished) {
                             [self.bookBindingView removeFromSuperview];
                             self.bookBindingView = nil;
                         }];
    }
}

- (void)screenEdgePanned:(UIScreenEdgePanGestureRecognizer *)edgeGesture {
    CGRect visibleFrame = [ViewHelper visibleFrameForCollectionView:self.collectionView];
    
    // If we're past the category pages, then this shortcuts back to home.
    if (edgeGesture.state == UIGestureRecognizerStateBegan) {
        self.collectionView.panGestureRecognizer.enabled = NO;
        if (visibleFrame.origin.x >= ([self stackContentStartSection] * self.collectionView.bounds.size.width)) {
            [self scrollToHome];
        }
    } else {
        self.collectionView.panGestureRecognizer.enabled = YES;
    }
}

- (BOOL)orderChangedForPages:(NSArray *)pages {
    __block BOOL orderChanged = NO;
    
    [self.book.pages enumerateObjectsUsingBlock:^(NSString *page, NSUInteger pageIndex, BOOL *stop) {
        
        // Abort if no matching index found in received categories.
        if (pageIndex < [pages count] - 1) {
            stop = YES;
        }
        
        // Check objectIds to determine if order is maintained.
        NSString *updatedPage = [pages objectAtIndex:pageIndex];
        DLog(@"Comparing page[%@] with updated [%@]", page, updatedPage);
        if (![page isEqualToString:updatedPage]) {
            orderChanged = YES;
            stop = YES;
        }
        
    }];
    
    return orderChanged;
}

- (BookPagingStackLayout *)currentLayout {
    return (BookPagingStackLayout *)self.collectionView.collectionViewLayout;
}

- (void)closeBook {
    [self closeBookWithPinch:NO];
}

- (void)closeBookWithPinch:(BOOL)pinch {
    if (pinch) {
        [self.delegate bookNavigationControllerCloseRequested];
    } else {
        [self.delegate bookNavigationControllerCloseRequestedWithBinder];
    }
}

- (void)scrollToPage:(NSString *)page animated:(BOOL)animated {
    DLog(@"page [%@]", page);
    NSInteger pageIndex = [self.pages indexOfObject:page];
    pageIndex += [self stackContentStartSection];
    
    [self fastForwardToPageIndex:pageIndex];
    
//    [self.collectionView setContentOffset:(CGPoint){
//        pageIndex * self.collectionView.bounds.size.width,
//        self.collectionView.contentOffset.y
//    } animated:animated];
}

- (void)scrollToHome {
    [self fastForwardToPageIndex:kIndexSection];
}

- (void)fastForwardToPageIndex:(NSUInteger)pageIndex {
    NSInteger numPeekPages = 10;
    NSInteger currentPageIndex = [self currentPageIndex];
    
    BOOL customJump = (abs(currentPageIndex - pageIndex) > numPeekPages);
    
    // Then jump direct to the page before.
    if (customJump) {
        
        [self.collectionView setContentOffset:(CGPoint){
            pageIndex * self.collectionView.bounds.size.width,
            self.collectionView.contentOffset.y
        } animated:NO];
        
    } else {
        
        [self.collectionView setContentOffset:(CGPoint){
            pageIndex * self.collectionView.bounds.size.width,
            self.collectionView.contentOffset.y
        } animated:YES];
        
    }
}

- (void)scrollToHomeAnimated:(BOOL)animated {
    [self.collectionView setContentOffset:(CGPoint){
        kIndexSection * self.collectionView.bounds.size.width,
        self.collectionView.contentOffset.y
    } animated:animated];
}

- (void)peekTheBook {
    [self scrollToHomeAnimated:NO];
}

- (void)cancelTapped:(id)sender {
    [self enableEditMode:NO];
    [self.currentEditViewController enableEditMode:NO completion:^{
        [self.currentEditViewController contentPerformSave:NO];
    }];
}

- (void)saveTapped:(id)sender {
    [self enableEditMode:NO];
    [self.currentEditViewController enableEditMode:NO completion:^{
        [self.currentEditViewController contentPerformSave:YES];
    }];
}

- (void)enableEditMode:(BOOL)editMode {
    self.editMode = editMode;
    [self updateButtonsWithAlpha:1.0];
    [self.currentEditViewController enableEditMode:editMode animated:YES completion:nil];
}

- (void)updateButtons {
    [self updateButtonsWithAlpha:1.0];
}

- (void)updateButtonsWithAlpha:(CGFloat)alpha {
    if (self.editMode && !self.cancelButton.superview && !self.saveButton.superview) {
        self.cancelButton.alpha = 0.0;
        self.saveButton.alpha = 0.0;
        self.cancelButton.transform = CGAffineTransformMakeTranslation(0.0, -self.cancelButton.frame.size.height);
        self.saveButton.transform = CGAffineTransformMakeTranslation(0.0, -self.saveButton.frame.size.height);
        [self.view addSubview:self.cancelButton];
        [self.view addSubview:self.saveButton];
    }
    
    // Lock scrolling in editMode.
    self.collectionView.scrollEnabled = !self.editMode;
    
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         
                         // Hide away the navigation bar.
                         self.bookNavigationView.alpha = self.editMode ? 0.0 : 1.0;
                         
                         self.cancelButton.alpha = self.editMode ? alpha : 0.0;
                         self.saveButton.alpha = self.editMode ? alpha : 0.0;
                         self.cancelButton.transform = self.editMode ? CGAffineTransformIdentity : CGAffineTransformMakeTranslation(0.0, -self.cancelButton.frame.size.height);
                         self.saveButton.transform = self.editMode ? CGAffineTransformIdentity : CGAffineTransformMakeTranslation(0.0, -self.saveButton.frame.size.height);
                     }
                     completion:^(BOOL finished)  {
                         if (!self.editMode) {
                             [self.cancelButton removeFromSuperview];
                             [self.saveButton removeFromSuperview];
                         }
                     }];
}

- (void)processRanks {
    self.pageCoverRecipes = [NSMutableDictionary dictionary];
    
    // Gather the highest ranked recipes for each page.
    [self.pageRecipes each:^(NSString *page, NSArray *recipes) {
        
        if ([recipes count] > 0) {
            
            // Get the highest ranked recipe with photos, then fallback to without.
            CKRecipe *highestRankedRecipe = [self highestRankedRecipeForPage:page hasPhotos:YES];
            if (!highestRankedRecipe) {
                highestRankedRecipe = [self highestRankedRecipeForPage:page hasPhotos:NO];
            }
            [self.pageCoverRecipes setObject:highestRankedRecipe forKey:page];
            
        }
        
    }];
    
    // Get the highest ranked recipe among the highest ranked recipes.
    self.featuredRecipe = nil;
    [self.pageCoverRecipes each:^(NSString *page, CKRecipe *recipe) {
        
        if (self.featuredRecipe) {
            if ([self rankForRecipe:recipe] > [self rankForRecipe:self.featuredRecipe]) {
                self.featuredRecipe = recipe;
            }
        } else {
            self.featuredRecipe = recipe;
        }
        
    }];
    
}

- (CKRecipe *)highestRankedRecipeForPage:(NSString *)page hasPhotos:(BOOL)hasPhotos {
    NSArray *recipes = [self.pageRecipes objectForKey:page];
    if (hasPhotos) {
        recipes = [recipes select:^BOOL(CKRecipe *recipe) {
            return [recipe hasPhotos];
        }];
    }
    
    __block CKRecipe *highestRankedRecipe = nil;
    [recipes each:^(CKRecipe *recipe) {
        if (highestRankedRecipe) {
            if ([self rankForRecipe:recipe] > [self rankForRecipe:highestRankedRecipe]) {
                highestRankedRecipe = recipe;
            }
        } else {
            highestRankedRecipe = recipe;
        }
        
    }];
    
    return highestRankedRecipe;
}

- (CGFloat)rankForRecipe:(CKRecipe *)recipe {
    return recipe.numViews + recipe.numComments + (recipe.numLikes * 2.0);
}

- (NSInteger)currentPageIndex {
    CGFloat pageSpan = self.collectionView.contentOffset.x;
    NSInteger pageIndex = (pageSpan / self.collectionView.bounds.size.width);
    return pageIndex;
}

@end
