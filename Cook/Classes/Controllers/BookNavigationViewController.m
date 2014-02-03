//
//  BookPagingStackViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 12/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookNavigationViewController.h"
#import "CKBook.h"
#import "CKRecipe.h"
#import "CKRecipePin.h"
#import "CKUser.h"
#import "CKServerManager.h"
#import "BookNavigationLayout.h"
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
#import "CKSocialManager.h"
#import "AnalyticsHelper.h"
#import "CKSupplementaryContainerView.h"
#import "CKBookManager.h"

@interface BookNavigationViewController () <BookNavigationLayoutDelegate, BookTitleViewControllerDelegate,
    BookContentViewControllerDelegate, BookNavigationViewDelegate, BookPageViewControllerDelegate,
    UIGestureRecognizerDelegate>

@property (nonatomic, strong) CKBook *book;
@property (nonatomic, strong) CKUser *user;
@property (nonatomic, strong) CKUser *currentUser;
@property (nonatomic, strong) CKRecipe *featuredRecipe;
@property (nonatomic, strong) CKRecipe *saveOrUpdatedRecipe;
@property (nonatomic, strong) NSString *saveOrUpdatedPage;
@property (nonatomic, assign) id<BookNavigationViewControllerDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *pages;
@property (nonatomic, strong) NSMutableArray *likedRecipes;
@property (nonatomic, strong) NSMutableDictionary *pageRecipeCount;
@property (nonatomic, strong) NSMutableDictionary *pageRecipes;
@property (nonatomic, strong) NSMutableDictionary *pageBatches;
@property (nonatomic, strong) NSDictionary *pageRankings;
@property (nonatomic, strong) NSMutableDictionary *pageCurrentBatches;
@property (nonatomic, strong) NSMutableDictionary *pagesContainingUpdatedRecipes;
@property (nonatomic, strong) NSMutableDictionary *contentControllers;
@property (nonatomic, strong) NSMutableDictionary *contentControllerOffsets;
@property (nonatomic, strong) NSMutableDictionary *pageHeaderViews;
@property (nonatomic, strong) NSMutableDictionary *pageCoverRecipes;
@property (nonatomic, assign) BOOL justOpened;
@property (nonatomic, assign) BOOL lightStatusBar;
@property (nonatomic, assign) BOOL fastForward;
@property (nonatomic, assign) BOOL navBarAnimating;
@property (nonatomic, strong) UIView *bookOutlineView;
@property (nonatomic, strong) UIView *bookBindingView;
@property (nonatomic, strong) NSDate *bookLastAccessedDate;
@property (nonatomic, assign) NSUInteger numRetries;

@property (nonatomic, strong) BookNavigationView *bookNavigationView;

// Jump to cell
@property NSArray *destinationIndexes;

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

// Likes
@property (nonatomic, strong) CKRecipe *featuredLikedRecipe;
@property (nonatomic, assign) BOOL enableLikes;
@property (nonatomic, strong) NSString *likesPageName;

// Update execution block.
@property (copy) BookNavigationUpdatedBlock bookUpdatedBlock;

@end

@implementation BookNavigationViewController

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
#define MAX_NUM_RETRIES             5

- (id)initWithBook:(CKBook *)book titleViewController:(BookTitleViewController *)titleViewController
          delegate:(id<BookNavigationViewControllerDelegate>)delegate {
    
    if (self = [super initWithCollectionViewLayout:[[BookNavigationLayout alloc] initWithDelegate:self]]) {
        self.delegate = delegate;
        self.book = book;
        self.user = book.user;
        self.currentUser = [CKUser currentUser];
        self.profileViewController = [[BookProfileViewController alloc] initWithBook:book];
        self.profileViewController.bookPageDelegate = self;
        
        // Init the titleVC, which could be shared between RootVC and BookNavigationVC.
        if (!titleViewController) {
            self.titleViewController = [[BookTitleViewController alloc] initWithBook:book delegate:self];
        } else {
            self.titleViewController = titleViewController;
        }
        self.titleViewController.delegate = self;
        self.titleViewController.bookPageDelegate = self;
        self.enableLikes = YES;
        self.destinationIndexes = @[@([self contentStartSection])]; //Start with first page
        
        // Forget about dismissed states.
        [[CardViewHelper sharedInstance] clearDismissedStates];
        
    }
    return self;
}

- (id)init {
    if (self = [super initWithCollectionViewLayout:[[BookNavigationLayout alloc] initWithDelegate:self]]) {
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
    DLog();
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
    
    if (alpha == 0) {
        [self.bookBindingView removeFromSuperview];
        self.bookBindingView = nil;
    } else {
        self.bookBindingView.alpha = alpha;
    }
}

- (void)updateWithRecipe:(CKRecipe *)recipe completion:(BookNavigationUpdatedBlock)completion {
    DLog(@"Updating layout with recipe [%@][%@]", recipe.name, recipe.page);
    
    NSString *page = recipe.page;
    
    NSMutableArray *recipes = [self.pageRecipes objectForKey:page];;
    
    // Check if this was a new/updated recipe.
    NSInteger foundIndex = [recipes findIndexWithBlock:^BOOL(CKRecipe *existingRecipe) {
        return [existingRecipe.objectId isEqualToString:recipe.objectId];
    }];
    
    if (foundIndex != -1) {
        
        // Replace the recipe if it's only been updated.
        [recipes replaceObjectAtIndex:foundIndex withObject:recipe];
        
    } else {
        
        // Add to the front of the list if this was a new recipe.
        [recipes insertObject:recipe atIndex:0];
        
        // Increment the recipe count.
        [self incrementCountForPage:page];
    }
    
    // If recipe has changed pages, then remove it from the old page.
    NSString *currentPage = [self currentPage];
    if (![currentPage isEqualToString:page]) {
        NSMutableArray *recipes = [self.pageRecipes objectForKey:currentPage];
        
        // Look for the recipe to remove from the old page.
        NSInteger foundIndex = [recipes findIndexWithBlock:^BOOL(CKRecipe *existingRecipe) {
            return [existingRecipe.objectId isEqualToString:recipe.objectId];
        }];
        
        if (foundIndex != -1) {
            
            // Remove the recipe from the old page.
            [recipes removeObjectAtIndex:foundIndex];
            
            // Decrement the recipe count for previous page.
            [self decrementCountForPage:currentPage];
        }
    }
    
    // Re-sort the recipes.
    [self sortRecipes:recipes];
    
    // Remember the recipe that was actioned.
    self.saveOrUpdatedRecipe = recipe;
    
    // Remember the block, which will be invoked in the prepareLayoutDidFinish method after layout completes.
    self.bookUpdatedBlock = completion;
    
    // Load recipes to rebuild the layout.
    [self loadRecipes];
}

- (void)updateWithDeletedRecipe:(CKRecipe *)recipe completion:(BookNavigationUpdatedBlock)completion {
    DLog(@"Updating layout with deleted recipe [%@][%@]", recipe.name, recipe.page);
    
    // Remove the recipe.
    NSString *page = recipe.page;
    NSMutableArray *recipes = [self.pageRecipes objectForKey:page];
    [recipes removeObject:recipe];
    
    // Decrement the recipe.
    [self decrementCountForPage:page];
    
    // Remember the recipe that was actioned.
    self.saveOrUpdatedRecipe = recipe;
    
    // Remember the block, which will be invoked in the prepareLayoutDidFinish method after layout completes.
    self.bookUpdatedBlock = completion;
    
    // Load recipes to rebuild the layout.
    [self loadRecipes];
}

- (void)updateWithUnpinnedRecipe:(CKRecipePin *)recipePin completion:(BookNavigationUpdatedBlock)completion {
    DLog(@"Updating layout with unpinned recipe [%@]", recipePin.recipe.objectId);
    
    // Remove references to the pinned recipe.
    NSString *page = recipePin.page;
    NSMutableArray *recipes = [self.pageRecipes objectForKey:page];
    recipes = [NSMutableArray arrayWithArray:[recipes reject:^BOOL(CKRecipe *recipe) {
        return [recipePin.recipe.objectId isEqualToString:recipe.objectId];
    }]];
    [self.pageRecipes setObject:recipes forKey:page];
    
    // Remember the page.
    self.saveOrUpdatedPage = recipePin.page;
    
    // Decrement the unpinned recipe.
    [self decrementCountForPage:recipePin.page];
    
    // Remember the block, which will be invoked in the prepareLayoutDidFinish method after layout completes.
    self.bookUpdatedBlock = completion;
    
    // Load recipes to rebuild the layout.
    [self loadRecipes];
}

- (void)updateWithPinnedRecipe:(CKRecipePin *)recipePin completion:(BookNavigationUpdatedBlock)completion {
    DLog(@"Updating layout with pinned recipe [%@]", recipePin.recipe.objectId);
    
    // Add pinned recipe to the page in the book.
    NSString *page = recipePin.page;
    NSMutableArray *recipes = [self.pageRecipes objectForKey:page];
    [recipes addObject:recipePin.recipe];
    
    // Re-sort the recipes.
    [self sortRecipes:recipes];
    
    // Remember the page.
    self.saveOrUpdatedPage = recipePin.page;
    
    // Decrement the unpinned recipe.
    [self incrementCountForPage:page];
    
    // Remember the block, which will be invoked in the prepareLayoutDidFinish method after layout completes.
    self.bookUpdatedBlock = completion;
    
    // Load recipes to rebuild the layout.
    [self loadRecipes];
}

- (void)updateWithLikedRecipe:(CKRecipe *)recipe completion:(BookNavigationUpdatedBlock)completion {
   
    NSMutableArray *likedRecipes = [self.pageRecipes objectForKey:self.likesPageName];
    
    // Look for the liked recipe if it was there from before.
    NSInteger foundIndex = [likedRecipes findIndexWithBlock:^BOOL(CKRecipe *existingRecipe) {
        return [existingRecipe.objectId isEqualToString:recipe.objectId];
    }];
    
    if (foundIndex == -1) {
        
        // Add the recipe to the likes page.
        [likedRecipes addObject:recipe];
        
        // Re-sort liked recipes.
        [self sortRecipes:likedRecipes];
        
        // Inrement the recipe count for likes page.
        [self incrementCountForPage:self.likesPageName];
        
        // Stay on the current page.
        self.saveOrUpdatedPage = [self currentPage];
        
        // Update the likes page.
        BookContentViewController *pageViewController = [self.contentControllers objectForKey:self.likesPageName];
        if (pageViewController) {
            [pageViewController loadData];
        }
        
        // Update book title page.
        [self.titleViewController refresh];

    }

}

- (void)updateWithUnlikedRecipe:(CKRecipe *)recipe completion:(BookNavigationUpdatedBlock)completion {
    
    NSMutableArray *likedRecipes = [self.pageRecipes objectForKey:self.likesPageName];
    
    // Look for the liked recipe if it was there from before.
    NSInteger foundIndex = [likedRecipes findIndexWithBlock:^BOOL(CKRecipe *existingRecipe) {
        return [existingRecipe.objectId isEqualToString:recipe.objectId];
    }];
    
    if (foundIndex != -1) {
        
        // Remove the recipe from the likes page.
        [likedRecipes removeObjectAtIndex:foundIndex];
        
        // Decrement the recipe count for previous page.
        [self decrementCountForPage:self.likesPageName];
        
        // Stay on the current page.
        self.saveOrUpdatedPage = [self currentPage];
        
        // Update the likes page.
        BookContentViewController *pageViewController = [self.contentControllers objectForKey:self.likesPageName];
        if (pageViewController) {
            [pageViewController loadData];
        }
        
        // Update book title page.
        [self.titleViewController refresh];
        
    }
}

- (void)updateWithDeletedPage:(NSString *)page completion:(BookNavigationUpdatedBlock)completion {
    DLog(@"Updating layout with deleted page [%@]", page);
    
    // Remove the recipes in the page.
    [self.pageRecipes removeObjectForKey:page];
    [self.pageBatches removeObjectForKey:page];
    [self.pageRecipeCount removeObjectForKey:page];
    [self.pageCurrentBatches removeObjectForKey:page];
    
    // Remember the block, which will be invoked in the prepareLayoutDidFinish method after layout completes.
    self.bookUpdatedBlock = completion;
    
    // Load recipes to rebuild the layout.
    [self loadRecipes];
}

- (void)updateWithRenamedPage:(NSString *)page fromPage:(NSString *)fromPage
                   completion:(BookNavigationUpdatedBlock)completion {
    
    DLog(@"Updating layout with renamed page [%@] fromPage[%@]", page, fromPage);
    
    // Rename the page in existing recipes..
    NSMutableArray *recipesToRename = [self.pageRecipes objectForKey:fromPage];
    
    // Renaming the recipes locally, as server-side has already occured.
    DLog(@"Renaming [%d] recipes to [%@]", [recipesToRename count], page);
    [recipesToRename each:^(CKRecipe *recipe) {
        recipe.page = page;
    }];
    
    // Rename the data.
    if (recipesToRename && [recipesToRename count] > 0) {
        [self.pageRecipes setObject:recipesToRename forKey:page];
    }
    [self.pageRecipes removeObjectForKey:fromPage];
    [self.pageBatches setObject:[self.pageBatches objectForKey:fromPage] forKey:page];
    [self.pageBatches removeObjectForKey:fromPage];
    [self.pageRecipeCount setObject:[self.pageRecipeCount objectForKey:fromPage] forKey:page];
    [self.pageRecipeCount removeObjectForKey:fromPage];
    [self.pageCurrentBatches setObject:[self.pageCurrentBatches objectForKey:fromPage] forKey:page];
    [self.pageCurrentBatches removeObjectForKey:fromPage];
    
    // Remember the recipe that was actioned.
    self.saveOrUpdatedPage = page;
    
    // Remember the block, which will be invoked in the prepareLayoutDidFinish method after layout completes.
    self.bookUpdatedBlock = completion;
    
    // Load recipes to rebuild the layout.
    [self loadRecipes];
}

- (void)updateStatusBarBetweenPages {
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

- (void)updatePagingContent {
    
    CGRect visibleFrame = [ViewHelper visibleFrameForCollectionView:self.collectionView];
    BookNavigationLayout *layout = [self currentLayout];
    
    NSArray *visibleIndexPaths = [self.collectionView indexPathsForVisibleItems];
    NSArray *pageIndexPaths = [visibleIndexPaths select:^BOOL(NSIndexPath *indexPath) {
        return (indexPath.section >= [self contentStartSection] - 1);
    }];
    
    if ([pageIndexPaths count] > 0) {
        
        NSSortDescriptor *pageSorter = [[NSSortDescriptor alloc] initWithKey:@"section" ascending:YES];
        pageIndexPaths = [pageIndexPaths sortedArrayUsingDescriptors:@[pageSorter]];
        NSIndexPath *firstIndexPath = [pageIndexPaths firstObject];
        
        // See if there's a next page, only going to the right, then apply overlay adjustments.
        NSInteger topPageIndex = firstIndexPath.section - [self contentStartSection];
        NSInteger nextPageIndex = topPageIndex + 1;
        if (nextPageIndex < [self.pages count]) {
            
            // Calculate the required alpha for the content overlay.
            CGFloat currentPageOffset = [layout pageOffsetForIndexPath:firstIndexPath];
            NSString *nextPage = [self.pages objectAtIndex:nextPageIndex];
            NSString *currentPage = nil;
            if (topPageIndex >= 0) {
                currentPage = [self.pages objectAtIndex:topPageIndex];
            }
            CGFloat distance = ABS(visibleFrame.origin.x - currentPageOffset);
            CGFloat overlayAlpha = 1.0 - (distance / visibleFrame.size.width);
//            DLog(@"currentPage [%@] nextPage[%@] distance[%f] overlay [%f]", currentPage, nextPage, distance, overlayAlpha);
            
            // Get the next page and apply the appropriate paging effects.
            BookContentViewController *pageViewController = [self.contentControllers objectForKey:nextPage];
            if (pageViewController) {
                [pageViewController applyOverlayAlpha:overlayAlpha];
            }
        }
        
    }
    
}

- (void)capEdgeScrollPoints {
    
    // Cap the scroll point.
    CGRect scrollBounds = self.collectionView.bounds;
    if (self.collectionView.contentOffset.x <= self.leftOutlineView.frame.origin.x) {
        scrollBounds.origin.x = self.leftOutlineView.frame.origin.x;
        self.collectionView.bounds = scrollBounds;
    } else if (self.collectionView.contentSize.width > 0.0
               && self.collectionView.contentOffset.x >= self.collectionView.contentSize.width - scrollBounds.size.width + self.rightOutlineView.frame.size.width) {
        scrollBounds.origin.x = self.rightOutlineView.frame.origin.x + self.rightOutlineView.frame.size.width - scrollBounds.size.width;
        self.collectionView.bounds = scrollBounds;
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
    if ([self.book isOwner] && ![self onLikesPage]) {
        [self showAddView:YES];
    }
}

- (void)bookNavigationViewEditTapped {
    if ([self.book isOwner] && ![self onLikesPage]) {
        
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
    NSArray *pageRecipes = [self.pageRecipes objectForKey:page];
    return pageRecipes;
}

- (CKRecipe *)featuredRecipeForBookContentViewControllerForPage:(NSString *)page {
    return [self coverRecipeForPage:page];
}

- (void)bookContentViewControllerScrolledOffset:(CGFloat)offset page:(NSString *)page
                              distanceTravelled:(CGFloat)distance {
   
    // Apply blurring/tinting offset to content image.
    BookContentImageView *contentHeaderView = [self.pageHeaderViews objectForKey:page];
    [contentHeaderView applyOffset:offset];
    
    // Update navigation title.
    [self updateNavigationTitleWithPage:page offset:offset];
    
    // Show or hide navigation view.
    // [self showOrHideNavigationViewWithOffset:offset page:page];
}

- (BOOL)bookContentViewControllerAddSupportedForPage:(NSString *)page {
    return (![page isEqualToString:self.likesPageName]);
}

- (void)bookContentViewControllerShowNavigationView:(BOOL)show {
    [self showNavigationView:show slide:YES];
}

- (NSInteger)bookContentViewControllerNumBatchesForPage:(NSString *)page {
    return [[self.pageBatches objectForKey:page] integerValue];
}

- (NSInteger)bookContentViewControllerCurrentBatchIndexForPage:(NSString *)page {
    return [[self.pageCurrentBatches objectForKey:page] integerValue];
}

- (BOOL)bookContentViewControllerLoadMoreEnabledForPage:(NSString *)page {
    NSInteger numBatches = [[self.pageBatches objectForKey:page] integerValue];
    NSInteger currentBatchIndex = [[self.pageCurrentBatches objectForKey:page] integerValue];
    NSInteger requestedBatchIndex = currentBatchIndex + 1;
    
    // Enabled if the requested batch index is within the number of batches.
    return (requestedBatchIndex < numBatches);
}

- (void)bookContentViewControllerLoadMoreForPage:(NSString *)page {
    NSInteger numBatches = [[self.pageBatches objectForKey:page] integerValue];
    NSInteger currentBatchIndex = [[self.pageCurrentBatches objectForKey:page] integerValue];
    NSInteger requestedBatchIndex = currentBatchIndex + 1;
    
    // Load if the requested batch index is within the number of batches.
    if (requestedBatchIndex < numBatches) {
        
        DLog(@"Loading more for page[%@]", page);
        [self.book recipesForPage:page batchIndex:requestedBatchIndex
                          success:^(CKBook *book, NSString *page, NSInteger batchIndex, NSArray *recipes) {
                              
                              // Append to the list of recipes.
                              NSMutableArray *pageRecipes = [self.pageRecipes objectForKey:page];
                              [pageRecipes addObjectsFromArray:recipes];
                              
                              // Update the batch index.
                              [self.pageCurrentBatches setObject:@(requestedBatchIndex) forKey:page];
                              
                              // Update the BookContentVC
                              BookContentViewController *contentViewController = [self.contentControllers objectForKey:page];
                              [contentViewController loadMoreRecipes:recipes];

                          }
                          failure:^(NSError *error) {
                          }];
    }
    
}

#pragma mark - BookTitleViewControllerDelegate methods

- (CKRecipe *)bookTitleFeaturedRecipeForPage:(NSString *)page {
    return [self coverRecipeForPage:page];
}

- (NSInteger)bookTitleNumRecipesForPage:(NSString *)page {
    return [[self.pageRecipeCount objectForKey:page] integerValue];
}

- (void)bookTitleSelectedPage:(NSString *)page {
    self.collectionView.userInteractionEnabled = NO;
    // Dirty dirty hack to stop double tap bug. Delay allows only latest tap to be read
    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self scrollToPage:page animated:YES];
    });
}

- (void)bookTitleUpdatedOrderOfPages:(NSArray *)pages {
    BOOL orderChanged = [self orderChangedForPages:pages];
    DLog(@"Pages order changed: %@", [NSString CK_stringForBoolean:orderChanged]);
    if (orderChanged) {
        
        self.pages = [NSMutableArray arrayWithArray:pages];
        if ([self.pages containsObject:self.likesPageName]) {
            self.book.pages = [self.pages subarrayWithRange:(NSRange){ 0, [self.pages count] - 1 }];
        } else {
            self.book.pages = pages;
        }
        [self.book saveInBackground];
        
        // Now relayout the content pages.
        [[self currentLayout] setNeedsRelayout:YES];
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndexesInRange:(NSRange){
            [self contentStartSection], [self.pages count]
        }]];
        
    }
}

- (void)bookTitleAddedPage:(NSString *)page {
    [self addPage:page];
    [self scrollToPage:page animated:YES];
}

- (BOOL)bookTitleIsNewForPage:(NSString *)page {
    
    if ([self.book isOwner]) {
        return NO;
    } else {
        return ([self.pagesContainingUpdatedRecipes objectForKey:page] != nil);
    }
    
}

- (BOOL)bookTitleHasLikes {
    return ([self.likesPageName length] > 0);
}

- (void)bookTitleProfileRequested {
    [self.collectionView setContentOffset:CGPointZero animated:YES];
}

#pragma mark - BookPagingStackLayoutDelegate methods

- (void)bookNavigationLayoutDidFinish {
    DLog();
    
    if (self.bookUpdatedBlock != nil) {
        
        // If we have an actioned recipe, then navigate there.
        if (self.saveOrUpdatedRecipe) {
            
            // Get the index of the page within the book.
            NSString *page = self.saveOrUpdatedRecipe.page;
            [self scrollToPage:page animated:NO];
            //if change of page, dont need to scroll to recipe
            if (self.saveOrUpdatedPage != nil) {
                self.saveOrUpdatedRecipe = nil;
            }
            
        } else if (self.saveOrUpdatedPage != nil) {
        
            // Get the index of the page within the book.
            NSString *page = self.saveOrUpdatedPage;
            [self scrollToPage:page animated:NO];
        
        } else {
            
            // Go to home; this is the case when page is deleted.
            [self scrollToHomeAnimated:NO];
            
        }
        
        // Invoked from recipe edit/added block.
        self.bookUpdatedBlock();
        self.bookUpdatedBlock = nil;
        
        // Clear breadcrumb flags.
//        self.saveOrUpdatedRecipe = nil;
        self.saveOrUpdatedPage = nil;
        
    } else if (self.justOpened) {
        
        self.justOpened = NO;
        
        // Start on page 1.
        [self peekTheBook];
        
        //analytics
        NSDictionary *dimensions = @{@"isOwnBook" : [NSString stringWithFormat:@"%i",([CKUser currentUser].objectId == self.user.objectId)]};
        [AnalyticsHelper trackEventName:@"Book opened" params:dimensions];
    }
    
    // Left/right edges.
    [self applyLeftBookEdgeOutline];
    [self applyRightBookEdgeOutline];
}

- (BookNavigationLayoutType)bookNavigationLayoutType {
    return BookNavigationLayoutTypeSlideOneWay;
}

- (NSInteger)bookNavigationLayoutContentStartSection {
    return [self contentStartSection];
}

- (CGFloat)alphaForBookNavigationView {
    return self.bookNavigationView ? self.bookNavigationView.alpha : 1.0;
}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self capEdgeScrollPoints];
    [self updateStatusBarBetweenPages];
    [self updatePagingContent];
    
    // Restore navbar on any side-scroll.
    [self showNavigationView:YES slide:NO];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    // Tells all cells to load content, don't need to worry about performance with manual scrolling
    if ([self.collectionView numberOfSections] > 2 && [self currentPageIndex] < [self.collectionView numberOfSections])
    {
        NSMutableArray *destinationArray = [NSMutableArray new];
        for (int i = 2; i < [self.collectionView numberOfSections]; i++)
        {
            [destinationArray addObject:[NSNumber numberWithInt:i]];
        }
        self.destinationIndexes = destinationArray;
        
//
//  TODO G - Do we need this?
//        [self activatePageContent];
//
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self updateNavigationButtons];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self updateNavigationButtons];
    
    //Tell headers images to load content now
    if ([self.collectionView numberOfSections] > 2 && [self currentPageIndex] < [self.collectionView numberOfSections])
    {
        NSInteger *pageIndex = [self currentPageIndex]-2 >= 0 ? [self currentPageIndex]-2 : 0;
        NSString *page = [self.pages objectAtIndex:pageIndex];
        BookContentImageView *headerView = [self.pageHeaderViews objectForKey:page];
        [headerView reloadWithBook:self.book];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    
    // Re-activate the content for the resulting content page after a scrolling animation there.
    [self activatePageContent];
    
    [self updateNavigationButtons];
    
    self.collectionView.userInteractionEnabled = YES;
    self.fastForward = NO;
}

- (void)activatePageContent {
    NSInteger currentPageIndex = [self currentPageIndex];
    
    // Load the current page content.
    if (currentPageIndex >= [self contentStartSection] && currentPageIndex < [self.collectionView numberOfSections]) {
        
        NSIndexPath *activeIndex = [NSIndexPath indexPathForItem:0 inSection:currentPageIndex];
        BookContentCell *contentCell = (BookContentCell *)[self.collectionView cellForItemAtIndexPath:activeIndex];
        if ([self.destinationIndexes containsObject:[NSNumber numberWithInt:currentPageIndex]]) {
            [contentCell.contentViewController loadPageContent];
            
            NSString *page = [self.pages objectAtIndex:currentPageIndex - [self contentStartSection]];
            BookContentImageView *headerView = [self.pageHeaderViews objectForKey:page];
            [headerView reloadWithBook:self.book];
        }
    }
}

#pragma mark - UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
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
        } else if (indexPath.section >= [self contentStartSection]) {
            headerView = [self contentHeaderViewAtIndexPath:indexPath];
        }
        
    } else if ([kind isEqualToString:[BookNavigationLayout bookNavigationLayoutElementKind]]) {
        
        headerView = [self navigationHeaderViewAtIndexPath:indexPath];
        
    }
    
    return headerView;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = nil;
    
    if (indexPath.section == kProfileSection) {
        cell = [self profileCellAtIndexPath:indexPath];
        [self.titleViewController didScrollToProfile];
    } else if (indexPath.section == kIndexSection) {
        cell = [self indexCellAtIndexPath:indexPath];
    } else {
        cell = [self contentCellAtIndexPath:indexPath];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryView:(UICollectionReusableView *)view
      forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section >= [self contentStartSection]) {
        
        // Remove a reference to the content image view.
        if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
            NSInteger pageIndex = indexPath.section - [self contentStartSection];
            if (pageIndex < [self.pages count]) {
                NSString *page = [self.pages objectAtIndex:pageIndex];
                [self.pageHeaderViews removeObjectForKey:page];
            }
        }
    }
    
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section >= [self contentStartSection]) {
        
        // Remove reference to BookContentVC and remember its vertical scroll offset.
        NSInteger pageIndex = indexPath.section - [self contentStartSection];
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
        
        // Dashboard left snapsthot.
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
        
        // Dashboard right snapshot.
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
        rightBookFrame.origin.x = self.collectionView.contentSize.width;
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
    [self.collectionView registerClass:[CKSupplementaryContainerView class] forSupplementaryViewOfKind:[BookNavigationLayout bookNavigationLayoutElementKind] withReuseIdentifier:kNavigationHeaderId];
    
    // Profile, Index, Category.
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kProfileCellId];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kIndexCellId];
    [self.collectionView registerClass:[BookContentCell class] forCellWithReuseIdentifier:kContentCellId];
}

- (void)loadData {
    
    // Spin the title page.
    [self.titleViewController configureLoading:YES];
    
    // Fetch all recipes for the book, and categorise them.
    [self.book bookRecipesSuccess:^(PFObject *parseBook, NSDictionary *pageRecipes, NSDictionary *pageBatches,
                                    NSDictionary *pageRecipeCount, NSDictionary *pageRankings, NSArray *likedRecipes,
                                    NSDate *lastAccessedDate) {
        
        if (parseBook && self.book) {
            CKBook *refreshedBook = [CKBook bookWithParseObject:parseBook];
            self.book = refreshedBook;
            // Refresh the book on the dash as it could be stale, e.g. pages.
            [self.delegate bookNavigationControllerRefreshedBook:refreshedBook];
            
            //Refresh books in profile viewcontroller as well
            self.profileViewController.book = refreshedBook;
            self.titleViewController.book = refreshedBook;
        }
        self.bookLastAccessedDate = lastAccessedDate;
        
        [self processRecipes:pageRecipes pageBatches:pageBatches pageCounts:pageRecipeCount pageRankings:pageRankings
                likedRecipes:likedRecipes];
        
    } failure:^(NSError *error) {
        DLog(@"Error %@", [error localizedDescription]);
        
        // Attempt to reload data.
        if (self.numRetries < MAX_NUM_RETRIES) {
            self.numRetries += 1;
            [self performSelector:@selector(loadData) withObject:nil afterDelay:1.0];
        }
    }];
}

- (void)processRecipes:(NSDictionary *)pageRecipes pageBatches:(NSDictionary *)pageBatches
            pageCounts:(NSDictionary *)pageCounts pageRankings:(NSDictionary *)pageRankings
          likedRecipes:(NSArray *)likedRecipes {
    
    // Loop through to initialise each recipe.
    self.pageRecipes = [NSMutableDictionary new];
    self.pageBatches = [NSMutableDictionary dictionaryWithDictionary:pageBatches];
    self.pageRecipeCount = [NSMutableDictionary dictionaryWithDictionary:pageCounts];
    self.pageRankings = pageRankings;
    self.pageCurrentBatches = [NSMutableDictionary new];
    
    for (NSString *page in pageRecipes) {
        NSMutableArray *recipes = [NSMutableArray arrayWithArray:[pageRecipes objectForKey:page]];
        [self.pageRecipes setObject:recipes forKey:page];
        //Initialise pageCurrentBatches
        [self.pageCurrentBatches setObject:@0 forKey:page];
    }
    
    self.pageRecipes = [NSMutableDictionary dictionaryWithDictionary:pageRecipes];
    self.likedRecipes = [NSMutableArray arrayWithArray:likedRecipes];
    [self loadRecipes];
}

- (void)loadRecipes {
    self.pagesContainingUpdatedRecipes = [NSMutableDictionary dictionary];
    self.pageHeaderViews = [NSMutableDictionary dictionary];
    
    // Reset social manager.
    [[CKSocialManager sharedInstance] reset];
    
    // Keep a reference of pages.
    self.pages = [NSMutableArray arrayWithArray:self.book.pages];
    
    // If not my book, reject empty pages.
    if (![self.book isOwner]) {
        self.pages = [NSMutableArray arrayWithArray:[self.pages reject:^BOOL(NSString *page) {
            return ([[self.pageRecipes objectForKey:page] count] == 0);
        }]];
    }
    NSMutableArray *uppercaseArray = [NSMutableArray new];
    [self.pages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [uppercaseArray addObject:[obj uppercaseString]];
    }];
    self.pages = uppercaseArray;
    
    // Loop through to initialise each recipe.
    for (NSString *page in self.pageRecipes) {
        
        NSArray *recipes = [self.pageRecipes objectForKey:page];
        for (CKRecipe *recipe in recipes) {
            
            // Update social cache.
            [[CKSocialManager sharedInstance] configureRecipe:recipe];
            
            // Is this a new recipe?
            if (self.bookLastAccessedDate
                && ([recipe.recipeUpdatedDateTime compare:self.bookLastAccessedDate] == NSOrderedDescending)) {
                
                // Mark the page as new.
                [self.pagesContainingUpdatedRecipes setObject:@YES forKey:page];
            }
        }
    }
    
    // Add likes if we have at least one page.
    [self processLikes];
    
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
    NSInteger pageIndex = indexPath.section - [self contentStartSection];
    NSString *page = [self.pages objectAtIndex:pageIndex];
    
    [self loadContentForPage:page cell:(BookContentCell *)categoryCell indexPath:indexPath];
    
    return categoryCell;
}

- (void)loadContentForPage:(NSString *)page cell:(BookContentCell *)cell indexPath:(NSIndexPath *)indexPath {
    
    // Load or create categoryController.
    BookContentViewController *categoryController = [self.contentControllers objectForKey:page];
    if (!categoryController) {
        categoryController = [[BookContentViewController alloc] initWithBook:self.book page:page delegate:self];
        categoryController.bookPageDelegate = self;
        
        // Remember this so that we can unset it on disEndDisplayingCell
        [self.contentControllers setObject:categoryController forKey:page];
        
        //if have a saved recipe, scroll to it
        if (self.saveOrUpdatedRecipe) {
            [categoryController scrollToRecipe:self.saveOrUpdatedRecipe];
//            self.saveOrUpdatedRecipe = nil;
        }
        
    } else {
        DLog(@"Reusing page VC for [%@]", page);
    }
    if ([self.destinationIndexes containsObject:[NSNumber numberWithInt:indexPath.section]])
    {
        categoryController.isFastForward = NO;
    }
    else
    {
        categoryController.isFastForward = YES;
    }
    
    // Add the contentVC to the cell.
    cell.contentViewController = categoryController;
    
    // Scroll offset?
    CGPoint scrollOffset = [[self.contentControllerOffsets objectForKey:page] CGPointValue];
    [categoryController setScrollOffset:scrollOffset];
    BookContentImageView *contentHeaderView = [self.pageHeaderViews objectForKey:page];
    [contentHeaderView applyOffset:scrollOffset.y];
    self.saveOrUpdatedRecipe = nil;
    
    // Update navigation title.
    [self updateNavigationTitleWithPage:page offset:scrollOffset.y];
}

- (void)clearFastForwardContentForPage:(NSString *)page cell:(BookContentCell *)cell {
    cell.contentViewController = nil;
}

- (NSString *)currentPage {
    NSString *page = nil;
    CGRect visibleFrame = [ViewHelper visibleFrameForCollectionView:self.collectionView];
    BookNavigationLayout *layout = [self currentLayout];
    
    NSArray *visibleIndexPaths = [self.collectionView indexPathsForVisibleItems];
    if ([visibleIndexPaths count] > 0) {
        
        // This only returns cells not supplementary/decoration views.
        for (NSIndexPath *indexPath in visibleIndexPaths) {
            if (indexPath.section >= [self contentStartSection]) {
                
                NSInteger pageIndex = indexPath.section - [self contentStartSection];
                
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

- (void)showRecipe:(CKRecipe *)recipe {
    
    // Always show status bar when viewing recipe.
    [self showNavigationView:YES slide:NO];
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
    
    NSInteger pageIndex = indexPath.section - [self contentStartSection];
    NSString *page = [self.pages objectAtIndex:pageIndex];
    
    // Get the corresponding categoryVC to retrieve current scroll offset.
    CGPoint contentOffset = [[self.contentControllerOffsets objectForKey:page] CGPointValue];
    [categoryHeaderView applyOffset:contentOffset.y];
    
    // Load featured recipe image.
    CKRecipe *coverRecipe = [self coverRecipeForPage:page];
    
    //Only do a full load if the panel is the final destination
    if ([self.destinationIndexes containsObject:[NSNumber numberWithInt:indexPath.section]])
    {
        categoryHeaderView.isFullLoad = YES;
    }
    else
    {
        categoryHeaderView.isFullLoad = NO;
    }
    [categoryHeaderView configureFeaturedRecipe:coverRecipe book:self.book];
    
    // Keep track of category views keyed on page name.
    [self.pageHeaderViews setObject:categoryHeaderView forKey:page];
    return headerView;
}

- (UICollectionReusableView *)navigationHeaderViewAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *headerView = [self.collectionView dequeueReusableSupplementaryViewOfKind:[BookNavigationLayout bookNavigationLayoutElementKind]
                                                                                   withReuseIdentifier:kNavigationHeaderId
                                                                                          forIndexPath:indexPath];
    CKSupplementaryContainerView *containerView = (CKSupplementaryContainerView *)headerView;
    if (!self.bookNavigationView) {
        self.bookNavigationView = [[BookNavigationView alloc] initWithFrame:containerView.bounds];
        self.bookNavigationView.delegate = self;
        [self.bookNavigationView setTitle:[self bookNavigationAuthorName] editable:[self.book isOwner] book:self.book];
        [self.bookNavigationView setDark:NO];
    }
    [containerView configureContentView:self.bookNavigationView];
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
    if (pinchGesture.state == UIGestureRecognizerStateBegan) {
        [self.delegate bookNavigationWillPeekDash:YES];
    }
    
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
//        [self.delegate bookNavigationWillPeekDash:NO];
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
                             [self.delegate bookNavigationWillPeekDash:NO];
                         }];
    }
}

- (void)screenEdgePanned:(UIScreenEdgePanGestureRecognizer *)edgeGesture {
    CGRect visibleFrame = [ViewHelper visibleFrameForCollectionView:self.collectionView];
    
    // If we're past the category pages, then this shortcuts back to home.
    if (edgeGesture.state == UIGestureRecognizerStateBegan) {
        self.collectionView.panGestureRecognizer.enabled = NO;
        if (visibleFrame.origin.x >= ([self contentStartSection] * self.collectionView.bounds.size.width)) {
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

- (BookNavigationLayout *)currentLayout {
    return (BookNavigationLayout *)self.collectionView.collectionViewLayout;
}

- (void)closeBook {
    [self closeBookWithPinch:NO];
}

- (void)closeBookWithPinch:(BOOL)pinch {
    self.book = nil;
    if (pinch) {
        [self.delegate bookNavigationControllerCloseRequested];
    } else {
        [self.delegate bookNavigationControllerCloseRequestedWithBinder];
    }
}

- (void)scrollToPage:(NSString *)page animated:(BOOL)animated {
    NSInteger pageIndex = [self.pages indexOfObject:page];
    pageIndex += [self contentStartSection];
    
    [self fastForwardToPageIndex:pageIndex];
}

- (void)scrollToHome {
    [self fastForwardToPageIndex:kIndexSection];
}

- (void)fastForwardToPageIndex:(NSUInteger)pageIndex {
    self.destinationIndexes = @[@(pageIndex)];

    [self.contentControllerOffsets removeAllObjects]; //Clear offsets when fast forwarding
    NSInteger numPeekPages = 3;
    NSInteger currentPageIndex = [self currentPageIndex];
    self.fastForward = (abs(currentPageIndex - pageIndex) > numPeekPages);
    
    // Clear offset at target page.
    if (pageIndex >= [self contentStartSection]) {
        NSString *page = [self.pages objectAtIndex:pageIndex - [self contentStartSection]];
        BookContentImageView *contentHeaderView = [self.pageHeaderViews objectForKey:page];
        [contentHeaderView applyOffset:0.0];
    }
    
    // Fast forward to the intended page.
    if (self.fastForward && pageIndex > currentPageIndex) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:pageIndex - [self contentStartSection]]
                                    atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                            animated:NO];
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:pageIndex]
                                    atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                            animated:YES];
        
    } else if (self.fastForward && pageIndex < currentPageIndex) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:pageIndex + [self contentStartSection]]
                                    atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                            animated:NO];
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:pageIndex]
                                    atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                            animated:YES];
    } else {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:pageIndex]
                                    atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                            animated:YES];
    }
}

- (void)scrollToHomeAnimated:(BOOL)animated {
    [self.collectionView setContentOffset:(CGPoint){
        kIndexSection * self.collectionView.bounds.size.width,
        self.collectionView.contentOffset.y
    } animated:animated];
}

- (void)peekTheBook {
    
    // Start at home without making delegate callbacks, which has side effects on scrollViewDidScroll.
    CGRect bounds = self.collectionView.bounds;
    bounds.origin.x = kIndexSection * self.collectionView.bounds.size.width;
    self.collectionView.bounds = bounds;
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
    
    if (!editMode) {
        
        // Restore status bar after edit mode.
        [EventHelper postStatusBarChangeForLight:self.lightStatusBar];
    }
    
    [self updateButtonsWithAlpha:1.0];
    [self.currentEditViewController enableEditMode:editMode animated:YES completion:nil];
}

- (void)updateButtons {
    [self updateButtonsWithAlpha:1.0];
}

- (void)updateButtonsWithAlpha:(CGFloat)alpha {
    DLog();
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

- (void)processLikes {
    if (self.enableLikes && [self.book isOwner]) {
        self.likesPageName = [self resolveLikesPageName];
        [self.pages addObject:self.likesPageName];
        [self.pageRecipes setObject:self.likedRecipes forKey:self.likesPageName];
        [self.pageRecipeCount setObject:@([self.likedRecipes count]) forKey:self.likesPageName];
    }
}

- (void)processRanks {
    [self processRanksForAllPages];
    [self processRanksForBook];
}

- (void)processRanksForAllPages {
    self.pageCoverRecipes = [NSMutableDictionary dictionary];
    
    // Gather the highest ranked recipes for each page.
    [[self.pageRecipes allKeys] each:^(NSString *page) {
        [self processRanksForPage:page];
    }];
}

- (void)processRanksForPage:(NSString *)page {
    NSArray *pageRecipes = [self.pageRecipes objectForKey:page];
    if ([pageRecipes count] > 0) {
        
        // Get the highest ranked recipe.
        CKRecipe *highestRankedRecipe = [self highestRankedRecipeForPage:page excludeOthers:YES];
        
        // If none found, then include pins.
        if (!highestRankedRecipe) {
            highestRankedRecipe = [self highestRankedRecipeForPage:page excludeOthers:NO];
        }
        
        // Set only if found.
        if (highestRankedRecipe) {
            [self.pageCoverRecipes setObject:highestRankedRecipe forKey:page];
        }
    }
}

- (void)processRanksForBook {
    
    // Get book title recipe if any.
    if (self.book.titleRecipe) {
        self.featuredRecipe = self.book.titleRecipe;
    }
    
    // Get the highest ranked recipe among the highest ranked recipes.
    if (!self.featuredRecipe) {
        
        self.featuredRecipe = [self highestRankedRecipeForBookIncludeOthers:NO];
        
        // If still not found, try including pins.
        if (!self.featuredRecipe) {
            self.featuredRecipe = [self highestRankedRecipeForBookIncludeOthers:YES];
        }
    }
}

- (CKRecipe *)highestRankedRecipeForBookIncludeOthers:(BOOL)includeOthers {
    __block CKRecipe *bookRecipe = nil;
    
    for (NSString *page in self.pageCoverRecipes) {
        
        // Bypass the likes page if specified.
        if (!includeOthers && [page isEqualToString:self.likesPageName]) {
            continue;
        }
        
        // Get the highest ranked recipe for the page.
        CKRecipe *recipe = [self.pageCoverRecipes objectForKey:page];
        
        // Bypass non-owners if specified.
        if (!includeOthers && ![recipe isOwner:self.user]) {
            continue;
        }
        
        if (bookRecipe) {
            if ([self rankForRecipe:recipe] > [self rankForRecipe:bookRecipe]) {
                bookRecipe = recipe;
            }
        } else {
            bookRecipe = recipe;
        }
    }
    
    return bookRecipe;
}

- (CKRecipe *)highestRankedRecipeForPage:(NSString *)page excludeOthers:(BOOL)excludeOthers {
    NSArray *recipes = [self.pageRecipes objectForKey:page];
    
    // Further filter recipes with photos.
    NSArray *recipesWithPhotos = [self recipesWithPhotos:recipes];

    // Ranking algorithm name.
    NSString *rankingName = [self resolveRankingNameForPage:page];
    
    __block CKRecipe *highestRankedRecipe = nil;
    
    for (CKRecipe *recipe in recipesWithPhotos) {
        
        // Bypass non-owners if specified.
        if (excludeOthers && ![recipe isOwner:self.user]) {
            continue;
        }
        
        if (highestRankedRecipe) {
            if ([self rankForRecipe:recipe rankingName:rankingName] > [self rankForRecipe:highestRankedRecipe rankingName:rankingName]) {
                highestRankedRecipe = recipe;
            }
        } else {
            highestRankedRecipe = recipe;
        }
    }
    
    return highestRankedRecipe;
}

- (NSString *)resolveRankingNameForPage:(NSString *)page {
    return [[CKBookManager sharedInstance] resolveRankingNameForName:[self.pageRankings objectForKey:page]];
}

- (CGFloat)rankForRecipe:(CKRecipe *)recipe rankingName:(NSString *)rankingName {
    
    // Ranking based on the given ranking algorithm name.
    return [[CKBookManager sharedInstance] rankingScoreForRecipe:recipe rankingName:rankingName];
}

- (CGFloat)rankForRecipe:(CKRecipe *)recipe {
    
    // Default ranking based on popularity.
    return [[CKBookManager sharedInstance] rankingScoreForRecipe:recipe];
}

- (NSInteger)currentPageIndex {
    CGFloat pageSpan = self.collectionView.contentOffset.x;
    NSInteger pageIndex = ceil(pageSpan / self.collectionView.bounds.size.width);
    return pageIndex;
}

- (NSString *)resolveLikesPageName {
    NSString *resolvedLikePageName = nil;
    
    for (NSString *likePageName in [self potentialLikesPageNames]) {
        if (![self.pages containsObject:likePageName]) {
            resolvedLikePageName = likePageName;
            break;
        }
    }
    
    return resolvedLikePageName;
}

- (NSArray *)potentialLikesPageNames {
    return @[@"LIKES", @"LIKED", @"COOK LIKES", @"COOK LIKED"];
}

- (BOOL)onLikesPage {
    BOOL likesPage = NO;
    
    NSInteger currentPageIndex = [self currentPageIndex];
    NSInteger pageIndex = [self.pages count] + [self contentStartSection] - 1;
    if (self.enableLikes && [self.book isOwner] && currentPageIndex == pageIndex) {
        
        // Likes page if it's the last page of my own book.
        likesPage = YES;
    }
    
    return likesPage;
}

- (void)updateNavigationButtons {
    [self.bookNavigationView enableAddAndEdit:![self onLikesPage]];
}

- (void)addPage:(NSString *)page {
    
    if ([self.pages containsObject:self.likesPageName]) {
        
        // Excludes the likes page.
        [self.pages insertObject:page atIndex:[self.pages count] - 1];
        self.book.pages = [self.pages subarrayWithRange:(NSRange){ 0, [self.pages count] - 1 }];
        
    } else {
        
        [self.pages addObject:page];
        self.book.pages = self.pages;
    }
    
    [self.pageRecipes setObject:[NSMutableArray array] forKey:page];
    
    // Mark layout needs to be re-generated.
    [[self currentLayout] setNeedsRelayout:YES];
    [self.collectionView reloadData];
    
    // Save the book in the background.
    [self.book saveInBackground];
}

- (CGFloat)alphaForBookNavigationViewWithOffset:(CGFloat)offset {
    CGFloat alpha = 1.0;
    if (offset > 0.0) {
        alpha = 1.0 - MIN(1.0, offset / 200.0);
    }
    return alpha;
}

- (void)showNavigationView:(BOOL)show slide:(BOOL)slide {
    
    // Show/hide frames.
    CGRect showFrame = (CGRect){
        0.0, 0.0, self.bookNavigationView.frame.size.width, self.bookNavigationView.frame.size.height
    };
    CGRect hideFrame = (CGRect){
        0.0, -self.bookNavigationView.frame.size.height, self.bookNavigationView.frame.size.width, self.bookNavigationView.frame.size.height
    };
    
    if (self.bookNavigationView
        && !CGRectEqualToRect(self.bookNavigationView.frame, show ? showFrame : hideFrame)
        && !self.navBarAnimating) {
        self.navBarAnimating = YES;
        
        if (show) {
            self.bookNavigationView.hidden = NO;
            self.bookNavigationView.alpha = 0.0;
        }
        
        if (!slide) {
            self.bookNavigationView.frame = show ? showFrame : hideFrame;
        } else {
            self.bookNavigationView.alpha = 1.0;
        }
        
        // Inform status bar hide.
        [EventHelper postStatusBarHide:!show];
        
        [UIView animateWithDuration:show ? 0.3 : 0.4
                              delay:0.0
                            options:show ? UIViewAnimationCurveEaseIn : UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             if (slide) {
                                 self.bookNavigationView.frame = show ? showFrame : hideFrame;
                             } else {
                                 self.bookNavigationView.alpha = show ? 1.0 : 0.0;
                             }
                         }
                         completion:^(BOOL finished) {
                             self.navBarAnimating = NO;
                             if (!show) {
                                 self.bookNavigationView.hidden = YES;
                             }
                         }];
    }
}

- (NSInteger)contentStartSection {
    return kIndexSection + 1;
}

- (void)showOrHideNavigationViewWithOffset:(CGFloat)offset page:(NSString *)page {
    DLog(@">>>> offset[%f] <<<<", offset);
    CGRect frame = self.bookNavigationView.frame;

    CGPoint scrollOffset = [[self.contentControllerOffsets objectForKey:page] CGPointValue];
    
    CGFloat translatedOffset = scrollOffset.y - offset;
    if (scrollOffset.y > offset && frame.origin.y == 0.0) {
        translatedOffset = scrollOffset.y - offset;
    }
//    if (offset < scrollOffset.y && frame.origin.y == -frame.size.height) {
//        translatedOffset = -frame.size.height;
//    }
    DLog(@">>> scrollOffset[%f] translatedOffset[%f]", scrollOffset.y, translatedOffset);
    
    // Cap the translations.
    translatedOffset = MAX(translatedOffset, -frame.size.height);
    translatedOffset = MIN(translatedOffset, 0.0);
    
    frame.origin.y = translatedOffset;
    DLog(@">>> offset[%f] translatedOffset[%f]", offset, translatedOffset);
    
    self.bookNavigationView.frame = frame;
}

- (void)incrementCountForPage:(NSString *)page {
    NSInteger existingPageCount = [[self.pageRecipeCount objectForKey:page] integerValue];
    [self.pageRecipeCount setObject:@(existingPageCount + 1) forKey:page];
}

- (void)decrementCountForPage:(NSString *)page {
    NSInteger existingPageCount = [[self.pageRecipeCount objectForKey:page] integerValue];
    [self.pageRecipeCount setObject:@(existingPageCount - 1) forKey:page];
}

- (void)sortRecipes:(NSMutableArray *)recipes {
    [recipes sortUsingComparator:^NSComparisonResult(CKRecipe *recipe, CKRecipe *recipe2) {
        return [recipe2.recipeUpdatedDateTime compare:recipe.recipeUpdatedDateTime];
    }];
}

- (void)updateDefaultNavigationTitle {
    [self updateNavigationTitleWithPage:nil];
}

- (void)updateNavigationTitle {
    [self updateNavigationTitleWithPage:[self currentPage]];
}

- (void)updateNavigationTitleWithPage:(NSString *)pageName {
    NSMutableString *navigationTitle = [NSMutableString stringWithString:[self bookNavigationAuthorName]];
    if ([pageName length] > 0) {
        [navigationTitle appendFormat:@" - %@", pageName];
    }
    [self.bookNavigationView updateTitle:navigationTitle];
}

- (NSString *)bookNavigationAuthorName {
    return [self.book author];
}

- (void)updateNavigationTitleWithPage:(NSString *)page offset:(CGFloat)offset {
    if (offset >= 500.0) {
        [self updateNavigationTitleWithPage:page];
    } else {
        [self updateDefaultNavigationTitle];
    }
}

@end
