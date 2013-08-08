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
#import "BookPagingStackLayout.h"
#import "ParsePhotoStore.h"
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

@interface BookNavigationStackViewController () <BookPagingStackLayoutDelegate, BookTitleViewControllerDelegate,
    BookContentViewControllerDelegate, BookNavigationViewDelegate, BookPageViewControllerDelegate,
    UIGestureRecognizerDelegate>

@property (nonatomic, strong) CKBook *book;
@property (nonatomic, strong) CKRecipe *featuredRecipe;
@property (nonatomic, strong) CKRecipe *saveOrUpdatedRecipe;
@property (nonatomic, assign) id<BookNavigationViewControllerDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *pages;
@property (nonatomic, strong) NSMutableArray *recipes;
@property (nonatomic, strong) NSMutableDictionary *pageRecipes;
@property (nonatomic, strong) NSMutableDictionary *categoryControllers;
@property (nonatomic, strong) NSMutableDictionary *pageHeaderViews;
@property (nonatomic, strong) NSMutableDictionary *pageFeaturedRecipes;
@property (nonatomic, assign) BOOL justOpened;
@property (nonatomic, assign) BOOL updatePages;
@property (nonatomic, assign) BOOL lightStatusBar;
@property (nonatomic, strong) UIView *bookOutlineView;

@property (nonatomic, strong) BookNavigationView *bookNavigationView;

@property (nonatomic, strong) UIView *benchtopSnapshotView;
@property (nonatomic, strong) UIView *leftOutlineView;
@property (nonatomic, strong) UIView *rightOutlineView;

@property (nonatomic, strong) ParsePhotoStore *photoStore;

@property (nonatomic, strong) BookProfileViewController *profileViewController;
@property (nonatomic, strong) BookTitleViewController *titleViewController;

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

- (id)initWithBook:(CKBook *)book delegate:(id<BookNavigationViewControllerDelegate>)delegate {
    if (self = [super initWithCollectionViewLayout:[[BookPagingStackLayout alloc] initWithDelegate:self]]) {
        self.delegate = delegate;
        self.book = book;
        self.photoStore = [[ParsePhotoStore alloc] init];
        self.profileViewController = [[BookProfileViewController alloc] initWithBook:book];
        self.profileViewController.bookPageDelegate = self;
        self.titleViewController = [[BookTitleViewController alloc] initWithBook:book delegate:self];
        self.titleViewController.bookPageDelegate = self;
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

- (void)updateWithRecipe:(CKRecipe *)recipe completion:(BookNavigationUpdatedBlock)completion {
    DLog(@"Updating layout with recipe [%@][%@]", recipe.name, recipe.page);
    
    // Check if this was a new recipe, in which case add it to the recipes list
    if (![self.recipes detect:^BOOL(CKRecipe *existingRecipe) {
        return [existingRecipe.objectId isEqualToString:recipe.objectId];
    }]) {
        
        // Add to the list of recipes.
        [self.recipes addObject:recipe];
    }
    
    // Remember the recipe that was actioned.
    self.saveOrUpdatedRecipe = recipe;
    
    // Remember the block, which will be invoked in the prepareLayoutDidFinish method after layout completes.
    self.bookUpdatedBlock = completion;
    
    // Load recipes to rebuild the layout.
    [self loadRecipes];
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

- (UIColor *)bookNavigationColour {
    return [CKBookCover textColourForCover:self.book.cover];
}

#pragma mark - BookContentViewControllerDelegate methods

- (NSArray *)recipesForBookContentViewControllerForPage:(NSString *)page {
    return [self.pageRecipes objectForKey:page];
}

- (CKRecipe *)featuredRecipeForBookContentViewControllerForPage:(NSString *)page {
    return [self featuredRecipeForPage:page];
}

- (void)bookContentViewControllerScrolledOffset:(CGFloat)offset page:(NSString *)page {
    BookContentImageView *contentHeaderView = [self.pageHeaderViews objectForKey:page];
    [contentHeaderView applyOffset:offset];
}

#pragma mark - BookTitleViewControllerDelegate methods

- (CKRecipe *)bookTitleFeaturedRecipeForPage:(NSString *)page {
    return [self featuredRecipeForPage:page];
}

- (NSInteger)bookTitleNumRecipesForPage:(NSString *)page {
    NSArray *pageRecipes = [self.pageRecipes objectForKey:page];
    return [pageRecipes count];
}

- (void)bookTitleSelectedPage:(NSString *)page {
    [self scrollToPage:page animated:YES];
}

- (void)bookTitleUpdatedOrderOfPages:(NSArray *)pages {
    BOOL orderChanged = [self orderChangedForPages:pages];
    DLog(@"Pages order changed: %@", [NSString CK_stringForBoolean:orderChanged]);
    if (orderChanged) {
        
        // Mark to update categories on backend.
        self.updatePages = YES;
        self.pages = [NSMutableArray arrayWithArray:pages];
        
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
    
    // Mark layout needs to be re-generated.
    [[self currentLayout] setNeedsRelayout:YES];
    [self.collectionView reloadData];
    
    // Mark as pages updated.
    self.updatePages = YES;
}

#pragma mark - BookPagingStackLayoutDelegate methods

- (void)stackPagingLayoutDidFinish {
    
    if (self.bookUpdatedBlock != nil) {
        
        // If we have an actioned recipe, then navigate there.
        if (self.saveOrUpdatedRecipe) {
            
            // Get the index of the page within the book.
            NSString *page = self.saveOrUpdatedRecipe.page;
            [self scrollToPage:page animated:NO];
            
        }
        
        // Invoked from recipe edit/added block.
        self.bookUpdatedBlock();
        self.bookUpdatedBlock = nil;
        
    } else if (self.justOpened) {
        
        // Start on page 1.
        [self.collectionView setContentOffset:(CGPoint){ kIndexSection * self.collectionView.bounds.size.width, 0.0 }
                                     animated:NO];
        self.justOpened = NO;
        
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
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
//        [self updateStatusBar];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//    [self updateStatusBar];
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
    
    // Remove a reference to the content image view.
    if (indexPath.section >= [self stackContentStartSection]
        && [elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        
        NSInteger pageIndex = indexPath.section - [self stackContentStartSection];
        NSString *page = [self.pages objectAtIndex:pageIndex];
        [self.pageHeaderViews removeObjectForKey:page];
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

#pragma mark - Private methods

- (void)initBookOutlineView {
    
    // Coloured cover outline.
    UIImage *outlineImage = [CKBookCover outlineImageForCover:self.book.cover];
    UIImageView *bookOutlineView = [[UIImageView alloc] initWithImage:outlineImage];
    bookOutlineView.frame = (CGRect){
        kBookOutlineOffset.horizontal,
        kBookOutlineOffset.vertical,
        bookOutlineView.frame.size.width,
        bookOutlineView.frame.size.height
    };
    [self.view insertSubview:bookOutlineView belowSubview:self.collectionView];
    self.bookOutlineView = bookOutlineView;
    
    // Book overlay.
    UIImageView *bookOutlineOverlayView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_book_edge_overlay.png"]];
    bookOutlineOverlayView.frame = bookOutlineView.bounds;
    [bookOutlineView addSubview:bookOutlineOverlayView];
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
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kContentCellId];
}

- (void)loadData {
    DLog();
    
    CKUser *currentUser = [CKUser currentUser];
    if ([self.book isOwner]) {
        
        // Fetch all recipes for the book, and categorise them.
        [self.book fetchRecipesSuccess:^(NSArray *recipes){
            
            self.recipes = [NSMutableArray arrayWithArray:recipes];
            
            // Mark layout needs to be re-generated.
            [[self currentLayout] setNeedsRelayout:YES];
            
            [self loadRecipes];
            [self loadTitlePage];
            
        } failure:^(NSError *error) {
            DLog(@"Error %@", [error localizedDescription]);
        }];
        
    } else {
        
        // Are we friends with the book's owner?
        [currentUser checkIsFriendsWithUser:self.book.user
                                 completion:^(BOOL alreadySent, BOOL alreadyConnected, BOOL pendingAcceptance) {
                                     
                                     // Fetch all recipes for the book, and categorise them.
                                     [self.book fetchRecipesOwner:NO friends:alreadyConnected success:^(NSArray *recipes) {
                                         
                                         self.recipes = [NSMutableArray arrayWithArray:recipes];
                                         
                                         // Mark layout needs to be re-generated.
                                         [[self currentLayout] setNeedsRelayout:YES];
                                         
                                         [self loadRecipes];
                                         [self loadTitlePage];
                                         
                                     } failure:^(NSError *error) {
                                         DLog(@"Error %@", [error localizedDescription]);
                                     }];
                                     
                                 } failure:^(NSError *error) {
                                 }];
    }
    
}

- (void)loadRecipes {
    self.pageRecipes = [NSMutableDictionary dictionary];
    self.pageHeaderViews = [NSMutableDictionary dictionary];
    self.pageFeaturedRecipes = [NSMutableDictionary dictionary];
    
    // Keep a reference of pages.
    self.pages = [NSMutableArray arrayWithArray:self.book.pages];
    
    // Loop through and gather recipes for each page.
    for (CKRecipe *recipe in self.recipes) {
        
        NSString *page = recipe.page;
        NSMutableArray *pageRecipes = [self.pageRecipes objectForKey:page];
        if (!pageRecipes) {
            pageRecipes = [NSMutableArray array];
            [self.pageRecipes setObject:pageRecipes forKey:page];
        }
        [pageRecipes addObject:recipe];
    }
    
    // Initialise the categoryControllers
    self.categoryControllers = [NSMutableDictionary dictionaryWithCapacity:[self.pages count]];
    
    // Now reload the categories.
    if ([self.pages count] > 0) {
        
        // Now relayout the category pages.
        [[self currentLayout] setNeedsRelayout:YES];
        [self.collectionView reloadData];
        
    }
}

- (void)loadTitlePage {
    
    // Load the pages.
    [self.titleViewController configurePages:self.pages];
    
    // Load the hero recipe.
    if ([self.pages count] > 0) {
        NSString *page = [self.pages objectAtIndex:arc4random_uniform([self.pages count])];
        self.featuredRecipe = [self featuredRecipeForPage:page];
        [self.titleViewController configureHeroRecipe:self.featuredRecipe];
    }
}

- (UICollectionViewCell *)profileCellAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *profileCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:kProfileCellId forIndexPath:indexPath];;
    if (!self.profileViewController.view.superview) {
        self.profileViewController.view.frame = profileCell.contentView.bounds;
        [profileCell.contentView addSubview:self.profileViewController.view];
    }
    return profileCell;
}

- (UICollectionViewCell *)indexCellAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *indexCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:kIndexCellId forIndexPath:indexPath];
    if (!self.titleViewController.view.superview) {
        self.titleViewController.view.frame = indexCell.contentView.bounds;
        [indexCell.contentView addSubview:self.titleViewController.view];
    }
    return indexCell;
}

- (UICollectionViewCell *)contentCellAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *categoryCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:kContentCellId
                                                                                        forIndexPath:indexPath];
    NSInteger pageIndex = indexPath.section - [self stackContentStartSection];
    NSString *page = [self.pages objectAtIndex:pageIndex];
    
    // Load or create categoryController.
    BookContentViewController *categoryController = [self.categoryControllers objectForKey:page];
    if (!categoryController) {
        DLog(@"Create page VC for [%@]", page);
        categoryController = [[BookContentViewController alloc] initWithBook:self.book page:page delegate:self];
        categoryController.bookPageDelegate = self;
        [self.categoryControllers setObject:categoryController forKey:page];
    } else {
        DLog(@"Reusing page VC for [%@]", page);
    }
    
    // Unload existing page view.
    UIView *contentView = [categoryCell.contentView viewWithTag:kContentViewTag];
    [contentView removeFromSuperview];
    
    // Load the current category view.
    categoryController.view.frame = categoryCell.contentView.bounds;
    categoryController.view.tag = kContentViewTag;
    [categoryCell.contentView addSubview:categoryController.view];
    
    return categoryCell;
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

- (CKRecipe *)featuredRecipeForPage:(NSString *)page {
    CKRecipe *featuredRecipe = [self.pageFeaturedRecipes objectForKey:page];
    if (!featuredRecipe) {
        NSArray *recipes = [self.pageRecipes objectForKey:page];
        NSArray *recipesWithPhotos = [self recipesWithPhotos:recipes];
        if ([recipesWithPhotos count] > 0) {
            featuredRecipe = [recipes objectAtIndex:arc4random_uniform([recipes count])];
            [self.pageFeaturedRecipes setObject:featuredRecipe forKey:page];
        }
    }
    return featuredRecipe;
}

- (void)closeTapped:(id)sender {
    [self closeBook];
}

- (void)scrollToHome {
    [self.collectionView setContentOffset:(CGPoint){
        kIndexSection * self.collectionView.bounds.size.width,
        self.collectionView.contentOffset.y
    } animated:YES];
}

- (void)configureImageForHeaderView:(BookContentImageView *)contentHeaderView recipe:(CKRecipe *)recipe
                          indexPath:(NSIndexPath *)indexPath {
    
    if ([recipe hasPhotos]) {
        [self.photoStore imageForParseFile:[recipe imageFile]
                                      size:contentHeaderView.frame.size
                                 indexPath:indexPath
                                completion:^(NSIndexPath *completedIndexPath, UIImage *image) {
                                    if ([indexPath isEqual:completedIndexPath]) {
                                        [contentHeaderView configureImage:image];
                                    }
                                }];
        
    } else {
        
        // Load default book cover image.
        [contentHeaderView configureImage:[CKBookCover recipeEditBackgroundImageForCover:self.book.cover]
                              placeholder:YES];
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
    [profileHeaderView configureWithBook:self.book];
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
    BookContentViewController *categoryController = [self.categoryControllers objectForKey:page];
    [categoryHeaderView applyOffset:[categoryController currentScrollOffset].y];
    
    // Load featured recipe image.
    CKRecipe *featuredRecipe = [self featuredRecipeForPage:page];
    [self configureImageForHeaderView:categoryHeaderView recipe:featuredRecipe indexPath:indexPath];
    
    // Keep track of category views keyed on indexPath.
    [self.pageHeaderViews setObject:categoryHeaderView forKey:page];
    
    return headerView;
}

- (UICollectionReusableView *)navigationHeaderViewAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *headerView = [self.collectionView dequeueReusableSupplementaryViewOfKind:[BookPagingStackLayout bookPagingNavigationElementKind]
                                                                                   withReuseIdentifier:kNavigationHeaderId
                                                                                          forIndexPath:indexPath];
    BookNavigationView *navigationView = (BookNavigationView *)headerView;
    navigationView.delegate = self;
    [navigationView setTitle:self.book.user.name editable:[self.book isOwner]];
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
    
    CGFloat minTrueScale = 0.5;
    CGFloat maxMinScale = 0.9;
    CGFloat maxTrueScale = 1.5;
    CGFloat maxMaxScale = 1.1;
    
    if (pinchGesture.state == UIGestureRecognizerStateBegan
        || pinchGesture.state == UIGestureRecognizerStateChanged) {
    
        CGFloat scale = pinchGesture.scale;
        
        if (scale >= maxTrueScale) {
            scale = maxMaxScale;
        } else if (scale >= 1.0) {
            scale = 1.0 + ((maxMaxScale - 1.0) * ((scale - 1.0) / 0.5));
        } else if (scale < minTrueScale) {
            scale = maxMinScale;
        } else  {
            scale = maxMinScale + ((1.0 - maxMinScale) * ((scale - minTrueScale) / minTrueScale));
        }
        
        self.view.transform = CGAffineTransformMakeScale(scale, scale);
        
	} else if (pinchGesture.state == UIGestureRecognizerStateEnded) {
        
        // Pinch close when smaller than 0.5.
        [self pinchClose:(pinchGesture.scale <= minTrueScale)];
        
    }
    
}

- (void)pinchClose:(BOOL)close {
    if (close) {
        [self closeBook];
    } else {
        [UIView animateWithDuration:0.15
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.view.transform = CGAffineTransformIdentity;
                         }
                         completion:^(BOOL finished) {
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
    
    // Update categories if required. This also updates the ordering of the category.
    if (self.updatePages) {
        self.book.pages = self.pages;
        [self.book saveInBackground];
    }
    
    [self.delegate bookNavigationControllerCloseRequested];
}

- (void)scrollToPage:(NSString *)page animated:(BOOL)animated {
    NSInteger pageIndex = [self.pages indexOfObject:page];
    pageIndex += [self stackContentStartSection];
    
    [self.collectionView setContentOffset:(CGPoint){
        pageIndex * self.collectionView.bounds.size.width,
        self.collectionView.contentOffset.y
    } animated:animated];
}

@end
