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
#import "CKCategory.h"
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
#import "BookCategoryViewController.h"
#import "ViewHelper.h"
#import "BookCategoryImageView.h"
#import "NSString+Utilities.h"

@interface BookNavigationStackViewController () <BookPagingStackLayoutDelegate, BookTitleViewControllerDelegate,
    BookCategoryViewControllerDelegate, BookNavigationViewDelegate, BookPageViewControllerDelegate,
    UIGestureRecognizerDelegate>

@property (nonatomic, strong) CKBook *book;
@property (nonatomic, strong) CKRecipe *featuredRecipe;
@property (nonatomic, strong) CKRecipe *saveOrUpdatedRecipe;
@property (nonatomic, assign) id<BookNavigationViewControllerDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *categories;
@property (nonatomic, strong) NSMutableArray *recipes;
@property (nonatomic, strong) NSMutableDictionary *categoryRecipes;
@property (nonatomic, strong) NSMutableDictionary *categoryControllers;
@property (nonatomic, strong) NSMutableDictionary *categoryHeaderViews;
@property (nonatomic, strong) NSMutableDictionary *categoryFeaturedRecipes;
@property (nonatomic, assign) BOOL justOpened;
@property (nonatomic, assign) BOOL updateCategories;
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
#define kCategoryCellId             @"CategoryCellId"
#define kCategoryHeaderId           @"CategoryHeaderId"
#define kProfileHeaderId            @"ProfileHeaderId"
#define kNavigationHeaderId         @"NavigationHeaderId"
#define kBookOutlineHeaderId        @"BookOutlineHeaderId"
#define kCategoryViewTag            460
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
    DLog(@"Updating layout with recipe [%@][%@]", recipe.name, recipe.category);
    
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

#pragma mark - BookNavigationViewDelegate methods

- (void)bookNavigationViewCloseTapped {
    [self closeBook];
}

- (void)bookNavigationViewHomeTapped {
    [self scrollToHome];
}

- (void)bookNavigationViewAddTapped {
    [self showAddView:YES];
}

- (UIColor *)bookNavigationColour {
    return [CKBookCover colourForCover:self.book.cover];
}

#pragma mark - BookCategoryViewControllerDelegate methods

- (NSArray *)recipesForBookCategoryViewControllerForCategory:(CKCategory *)category {
    NSString *categoryKey = [self keyForCategory:category];
    return [self.categoryRecipes objectForKey:categoryKey];
}

- (CKRecipe *)featuredRecipeForBookCategoryViewControllerForCategory:(CKCategory *)category {
    return [self featuredRecipeForCategory:category];
}

- (void)bookCategoryViewControllerScrolledOffset:(CGFloat)offset category:(CKCategory *)category {
    BookCategoryImageView *categoryHeaderView = [self.categoryHeaderViews objectForKey:[self keyForCategory:category]];
    [categoryHeaderView applyOffset:offset];
}

#pragma mark - BookTitleViewControllerDelegate methods

- (CKRecipe *)bookTitleFeaturedRecipeForCategory:(CKCategory *)category {
    return [self featuredRecipeForCategory:category];
}

- (void)bookTitleSelectedCategory:(CKCategory *)category {
    [self scrollToCategory:category animated:YES];
}

- (void)bookTitleUpdatedOrderOfCategories:(NSArray *)categories {
    BOOL orderChanged = [self orderChangedForCategories:categories];
    DLog(@"Categories order changed: %@", [NSString CK_stringForBoolean:orderChanged]);
    if (orderChanged) {
        
        // Mark to update categories on backend.
        self.updateCategories = YES;
        self.categories = [NSMutableArray arrayWithArray:categories];
        
        // Now relayout the category pages.
        [[self currentLayout] setNeedsRelayout:YES];
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndexesInRange:(NSRange){
            [self stackCategoryStartSection], [self.categories count]
        }]];
        
    }
    
}

#pragma mark - BookPagingStackLayoutDelegate methods

- (void)stackPagingLayoutDidFinish {
    
    if (self.bookUpdatedBlock != nil) {
        
        // If we have an actioned recipe, then navigate there.
        if (self.saveOrUpdatedRecipe) {
            
            // Get the index of the category within the book.
            CKCategory *category = self.saveOrUpdatedRecipe.category;
            [self scrollToCategory:category animated:NO];
            
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
    if ([self numberOfSectionsInCollectionView:self.collectionView] >= [self stackCategoryStartSection]) {
        [self applyRightBookEdgeOutline];
    }
}

- (BookPagingStackLayoutType)stackPagingLayoutType {
    return BookPagingStackLayoutTypeSlideOneWay;
}

- (NSInteger)stackCategoryStartSection {
    return kIndexSection + 1;
}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
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
    numSections += [self.categories count]; // Category pages.
    
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
        } else if (indexPath.section >= [self stackCategoryStartSection]) {
            headerView = [self categoryHeaderViewAtIndexPath:indexPath];
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
        cell = [self categoryCellAtIndexPath:indexPath];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryView:(UICollectionReusableView *)view
      forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    
    // Remove a reference to the category image view.
    if (indexPath.section >= [self stackCategoryStartSection]
        && [elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        
        NSInteger categoryIndex = indexPath.section - [self stackCategoryStartSection];
        CKCategory *category = [self.categories objectAtIndex:categoryIndex];
        [self.categoryHeaderViews removeObjectForKey:[self keyForCategory:category]];
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
    [self.collectionView registerClass:[BookCategoryImageView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kCategoryHeaderId];
    [self.collectionView registerClass:[BookNavigationView class] forSupplementaryViewOfKind:[BookPagingStackLayout bookPagingNavigationElementKind] withReuseIdentifier:kNavigationHeaderId];
    
    // Profile, Index, Category.
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kProfileCellId];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kIndexCellId];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kCategoryCellId];
}

- (void)loadData {
    DLog();
    
    // Fetch all recipes for the book, and categorise them.
    [self.book fetchRecipesSuccess:^(NSArray *recipes){
        self.recipes = [NSMutableArray arrayWithArray:recipes];
        
        // Mark layout needs to be re-generated.
        [[self currentLayout] setNeedsRelayout:YES];
        
        [self loadRecipes];
        [self loadTitlePage];
        
        // Preload categories for edit/creation if it's my own book.
        if ([self.book isUserBookAuthor:[CKUser currentUser]]) {
            [self.book prefetchCategoriesInBackground];
        }
        
    } failure:^(NSError *error) {
        DLog(@"Error %@", [error localizedDescription]);
    }];
    
}

- (void)loadRecipes {
    self.categoryRecipes = [NSMutableDictionary dictionary];
    self.categories = [NSMutableArray array];
    self.categoryHeaderViews = [NSMutableDictionary dictionary];
    self.categoryFeaturedRecipes = [NSMutableDictionary dictionary];
    
    for (CKRecipe *recipe in self.recipes) {
        
        CKCategory *category = recipe.category;
        NSString *categoryKey = [self keyForCategory:category];
        
        if (![self.categories detect:^BOOL(CKCategory *existingCategory) {
            NSString *currentCategoryKey = [self keyForCategory:existingCategory];
            return [currentCategoryKey isEqualToString:categoryKey];
            
        }]) {
            
            NSMutableArray *recipes = [NSMutableArray arrayWithObject:recipe];
            [self.categoryRecipes setObject:recipes forKey:categoryKey];
            [self.categories addObject:category];
            
        } else {
            
            NSMutableArray *recipes = [self.categoryRecipes objectForKey:categoryKey];
            [recipes addObject:recipe];
        }
        
    }
    
    // Sort the categories and extract category name list.
    NSSortDescriptor *categoryOrder = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    [self.categories sortUsingDescriptors:@[categoryOrder]];

    // Update the categories for the book if we don't have network loaded categories.
    if ([self.book.currentCategories count] == 0) {
        self.book.currentCategories = self.categories;
    }
    
    // Initialise the categoryControllers
    self.categoryControllers = [NSMutableDictionary dictionaryWithCapacity:[self.categories count]];
    
    // Now reload the categories.
    if ([self.categories count] > 0) {
        
        // Now relayout the category pages.
        [[self currentLayout] setNeedsRelayout:YES];
        [self.collectionView reloadData];
        
    }
    
}

- (void)loadTitlePage {
    if ([self.categories count] > 0) {
        
        // Load the categories.
        [self.titleViewController configureCategories:self.categories];
        
        // Load the hero recipe.
        CKCategory *randomCategory = [self.categories objectAtIndex:arc4random_uniform([self.categories count])];
        self.featuredRecipe = [self featuredRecipeForCategory:randomCategory];
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

- (UICollectionViewCell *)categoryCellAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *categoryCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:kCategoryCellId
                                                                                        forIndexPath:indexPath];
    NSInteger categoryIndex = indexPath.section - [self stackCategoryStartSection];
    CKCategory *category = [self.categories objectAtIndex:categoryIndex];
    NSString *categoryKey = [self keyForCategory:category];
    
    // Load or create categoryController.
    BookCategoryViewController *categoryController = [self.categoryControllers objectForKey:categoryKey];
    if (!categoryController) {
        DLog(@"Create category VC for [%@]", category.name);
        categoryController = [[BookCategoryViewController alloc] initWithBook:self.book category:category delegate:self];
        categoryController.bookPageDelegate = self;
        [self.categoryControllers setObject:categoryController forKey:categoryKey];
    } else {
        DLog(@"Reusing category VC for [%@]", category.name);
    }
    
    // Unload existing category view.
    UIView *categoryView = [categoryCell.contentView viewWithTag:kCategoryViewTag];
    [categoryView removeFromSuperview];
    
    // Load the current category view.
    categoryController.view.frame = categoryCell.contentView.bounds;
    categoryController.view.tag = kCategoryViewTag;
    [categoryCell.contentView addSubview:categoryController.view];
    
    return categoryCell;
}

- (NSString *)keyForCategory:(CKCategory *)category {
    return category.objectId;
}

- (NSArray *)recipesWithPhotos:(NSArray *)recipes {
    return [recipes select:^BOOL(CKRecipe *recipe) {
        return [recipe hasPhotos];
    }];
}

- (CKRecipe *)featuredRecipeForCategory:(CKCategory *)category {
    NSString *categoryKey = [self keyForCategory:category];
    CKRecipe *featuredRecipe = [self.categoryFeaturedRecipes objectForKey:categoryKey];
    if (!featuredRecipe) {
        NSArray *recipes = [self.categoryRecipes objectForKey:[self keyForCategory:category]];
        NSArray *recipesWithPhotos = [self recipesWithPhotos:recipes];
        if ([recipesWithPhotos count] > 0) {
            featuredRecipe = [recipes objectAtIndex:arc4random_uniform([recipes count])];
            [self.categoryFeaturedRecipes setObject:featuredRecipe forKey:categoryKey];
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

- (void)configureImageForHeaderView:(BookCategoryImageView *)categoryHeaderView recipe:(CKRecipe *)recipe
                          indexPath:(NSIndexPath *)indexPath {
    
    if ([recipe hasPhotos]) {
        [self.photoStore imageForParseFile:[recipe imageFile]
                                      size:categoryHeaderView.frame.size
                                 indexPath:indexPath
                                completion:^(NSIndexPath *completedIndexPath, UIImage *image) {
                                    if ([indexPath isEqual:completedIndexPath]) {
                                        [categoryHeaderView configureImage:image];
                                    }
                                }];
        
    } else {
        [categoryHeaderView configureImage:nil];
    }
}

- (void)showRecipe:(CKRecipe *)recipe {
    [self.delegate bookNavigationControllerRecipeRequested:recipe];
}

- (void)showAddView:(BOOL)show {
    [self.delegate bookNavigationControllerAddRecipeRequested];
}

- (UICollectionReusableView *)profileHeaderViewAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *headerView = [self.collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                                   withReuseIdentifier:kProfileHeaderId
                                                                                          forIndexPath:indexPath];
    BookProfileHeaderView *profileHeaderView = (BookProfileHeaderView *)headerView;
    [profileHeaderView configureWithBook:self.book];
    return headerView;
}

- (UICollectionReusableView *)categoryHeaderViewAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *headerView = [self.collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                                   withReuseIdentifier:kCategoryHeaderId
                                                                                          forIndexPath:indexPath];
    BookCategoryImageView *categoryHeaderView = (BookCategoryImageView *)headerView;
    
    NSInteger categoryIndex = indexPath.section - [self stackCategoryStartSection];
    CKCategory *category = [self.categories objectAtIndex:categoryIndex];
    
    // Get the corresponding categoryVC to retrieve current scroll offset.
    NSString *categoryKey = [self keyForCategory:category];
    BookCategoryViewController *categoryController = [self.categoryControllers objectForKey:categoryKey];
    [categoryHeaderView applyOffset:[categoryController currentScrollOffset].y];
    
    // Load featured recipe image.
    CKRecipe *featuredRecipe = [self featuredRecipeForCategory:category];
    [self configureImageForHeaderView:categoryHeaderView recipe:featuredRecipe indexPath:indexPath];
    
    // Keep track of category views keyed on indexPath.
    [self.categoryHeaderViews setObject:categoryHeaderView forKey:[self keyForCategory:category]];
    
    return headerView;
}

- (UICollectionReusableView *)navigationHeaderViewAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *headerView = [self.collectionView dequeueReusableSupplementaryViewOfKind:[BookPagingStackLayout bookPagingNavigationElementKind]
                                                                                   withReuseIdentifier:kNavigationHeaderId
                                                                                          forIndexPath:indexPath];
    BookNavigationView *navigationView = (BookNavigationView *)headerView;
    navigationView.delegate = self;
    [navigationView setTitle:self.book.user.name];
    
    // Keep a reference of the navigation view.
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
        if (visibleFrame.origin.x > ([self stackCategoryStartSection] * self.collectionView.bounds.size.width)) {
            [self scrollToHome];
        }
    } else {
        self.collectionView.panGestureRecognizer.enabled = YES;
    }
}

- (BOOL)orderChangedForCategories:(NSArray *)categories {
    __block BOOL orderChanged = NO;
    
    [self.book.currentCategories enumerateObjectsUsingBlock:^(CKCategory *category, NSUInteger categoryIndex, BOOL *stop) {
        
        // Abort if no matching index found in received categories.
        if (categoryIndex < [categories count] - 1) {
            stop = YES;
        }
        
        // Check objectIds to determine if order is maintained.
        CKCategory *updatedCategory = [categories objectAtIndex:categoryIndex];
        DLog(@"Comparing category[%@] with updated [%@]", category.objectId, updatedCategory.objectId);
        if (![category.objectId isEqualToString:updatedCategory.objectId]) {
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
    if (self.updateCategories) {
        [self.book saveCategories:self.categories
                          success:^{
                              DLog(@"Saved categories.");
                          }
                          failure:^(NSError *error) {
                              DLog(@"Unable to save categories: %@", [error localizedDescription]);
                          }];
    }
    
    [self.delegate bookNavigationControllerCloseRequested];
}

- (void)scrollToCategory:(CKCategory *)category animated:(BOOL)animated {
    NSInteger categoryIndex = [self.categories indexOfObject:category];
    categoryIndex += [self stackCategoryStartSection];
    
    [self.collectionView setContentOffset:(CGPoint){
        categoryIndex * self.collectionView.bounds.size.width,
        self.collectionView.contentOffset.y
    } animated:animated];
}

@end
