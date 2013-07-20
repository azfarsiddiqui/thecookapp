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
#import "BookIndexListViewController.h"
#import "BookHeaderView.h"
#import "BookProfileHeaderView.h"
#import "BookNavigationView.h"
#import "MRCEnumerable.h"
#import "CKBookCover.h"
#import "BookCategoryViewController.h"
#import "ViewHelper.h"
#import "BookCategoryImageView.h"
#import "BookAddViewController.h"

@interface BookNavigationStackViewController () <BookPagingStackLayoutDelegate, BookIndexListViewControllerDelegate,
    BookCategoryViewControllerDelegate, BookNavigationViewDelegate, BookPageViewControllerDelegate,
    BookAddViewControllerDelegate>

@property (nonatomic, strong) CKBook *book;
@property (nonatomic, strong) CKRecipe *featuredRecipe;
@property (nonatomic, assign) id<BookNavigationViewControllerDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *categories;
@property (nonatomic, strong) NSMutableArray *recipes;
@property (nonatomic, strong) NSMutableDictionary *categoryRecipes;
@property (nonatomic, strong) NSMutableDictionary *categoryControllers;
@property (nonatomic, strong) NSMutableDictionary *categoryHeaderViews;
@property (nonatomic, strong) NSMutableDictionary *categoryFeaturedRecipes;
@property (nonatomic, assign) BOOL justOpened;
@property (nonatomic, strong) UIView *bookOutlineView;
@property (nonatomic, strong) BookNavigationView *bookNavigationView;

@property (nonatomic, strong) UIView *leftOutlineView;
@property (nonatomic, strong) UIView *rightOutlineView;

@property (nonatomic, strong) ParsePhotoStore *photoStore;

@property (nonatomic, strong) BookProfileViewController *profileViewController;
@property (nonatomic, strong) BookIndexListViewController *indexViewController;
@property (nonatomic, strong) BookAddViewController *bookAddViewController;

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
        self.indexViewController = [[BookIndexListViewController alloc] initWithBook:book delegate:self];
        self.indexViewController.bookPageDelegate = self;
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
}

- (void)updateWithRecipe:(CKRecipe *)recipe completion:(BookNavigationUpdatedBlock)completion {
    DLog(@"Updating layout with recipe [%@][%@]", recipe.name, recipe.category);
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

#pragma mark - BookAddViewControllerDelegate methods

- (void)bookAddViewControllerCloseRequested {
    [self showAddView:NO];
}

#pragma mark - BookPageViewControllerDelegate methods

- (void)bookPageViewControllerCloseRequested {
    [self.delegate bookNavigationControllerCloseRequested];
}

- (void)bookPageViewControllerShowRecipe:(CKRecipe *)recipe {
    [self showRecipe:recipe];
}

#pragma mark - BookNavigationViewDelegate methods

- (void)bookNavigationViewCloseTapped {
    [self.delegate bookNavigationControllerCloseRequested];
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

#pragma mark - BookIndexListViewControllerDelegate methods

- (void)bookIndexSelectedCategory:(NSString *)category {
}

- (void)bookIndexAddRecipeRequested {
}

- (NSArray *)bookIndexRecipesForCategory:(NSString *)category {
    return nil;
}

#pragma mark - BookPagingStackLayoutDelegate methods

- (void)stackPagingLayoutDidFinish {
    
    if (self.justOpened) {
        
        // Start on page 1.
        [self.collectionView setContentOffset:(CGPoint){ kIndexSection * self.collectionView.bounds.size.width, 0.0 }
                                     animated:NO];
        self.justOpened = NO;
        
    } else {
        
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
//    return BookPagingStackLayoutTypeSlideOneWayScale;
//    return BookPagingStackLayoutTypeSlideBothWays;
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
    NSInteger numItems = 0;
    
    if (section == kProfileSection) {
        numItems = 1;
    } else if (section == kIndexSection) {
        numItems = 1;
    } else {
        numItems = [self.categories count];
    }
    
    return numItems;
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

- (UIView *)leftOutlineView {
    if (!_leftOutlineView) {
        
        // Dashboard.
        _leftOutlineView = [self.delegate bookNavigationSnapshotAtRect:(CGRect){
           0.0, 0.0, kBookOutlineSnapshotWidth, self.collectionView.bounds.size.height
        }];
        
        // Book edge.
        UIView *leftBookEdgeView = [self.view resizableSnapshotViewFromRect:(CGRect){
            kBookOutlineOffset.horizontal,
            self.view.bounds.origin.y,
            -kBookOutlineOffset.horizontal,
            self.view.bounds.size.height
        } withCapInsets:UIEdgeInsetsZero];
        
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
        _rightOutlineView = [self.delegate bookNavigationSnapshotAtRect:(CGRect){
            self.collectionView.bounds.size.width, 0.0, kBookOutlineSnapshotWidth, self.collectionView.bounds.size.height
        }];
        
        // Book edge.
        UIView *rightBookEdgeView = [self.view resizableSnapshotViewFromRect:(CGRect){
            self.view.bounds.size.width,
            self.view.bounds.origin.y,
            -kBookOutlineOffset.horizontal,
            self.view.bounds.size.height
        } withCapInsets:UIEdgeInsetsZero];
        
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
//    self.collectionView.hidden = YES;
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
        [self loadRecipes];
        [self loadFeaturedRecipe];
        
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
    
    // Now reload the collection.
    [self.collectionView reloadData];
}

- (void)loadFeaturedRecipe {
    if ([self.categories count] > 0) {
        CKCategory *randomCategory = [self.categories objectAtIndex:arc4random_uniform([self.categories count])];
        self.featuredRecipe = [self featuredRecipeForCategory:randomCategory];
        [self.indexViewController configureHeroRecipe:self.featuredRecipe];
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
    if (!self.indexViewController.view.superview) {
        self.indexViewController.view.frame = indexCell.contentView.bounds;
        [indexCell.contentView addSubview:self.indexViewController.view];
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
    [self.delegate bookNavigationControllerCloseRequested];
}

- (void)scrollToHome {
    [self.collectionView setContentOffset:(CGPoint){
        kIndexSection * self.collectionView.bounds.size.width, self.collectionView.contentOffset.y
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
    if (show) {
        self.bookAddViewController = [[BookAddViewController alloc] initWithDelegate:self];
        self.bookAddViewController.view.frame = self.view.bounds;
        self.bookAddViewController.view.alpha = 0.0;
        [self.view addSubview:self.bookAddViewController.view];
    }
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.bookAddViewController.view.alpha = show ? 1.0 : 0.0;
                     }
                     completion:^(BOOL finished) {
                         if (show) {
                             [self.bookAddViewController enable:YES];
                         } else {
                             [self.bookAddViewController.view removeFromSuperview];
                             self.bookAddViewController = nil;
                         }
                     }];
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
    NSInteger categoryIndex = indexPath.section - [self stackCategoryStartSection];
    CKCategory *category = [self.categories objectAtIndex:categoryIndex];
    BookCategoryImageView *categoryHeaderView = (BookCategoryImageView *)headerView;
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
    self.rightOutlineView.frame = (CGRect){
        self.collectionView.contentSize.width,
        self.collectionView.bounds.origin.y,
        self.rightOutlineView.frame.size.width,
        self.collectionView.bounds.size.height
    };
    if (!self.rightOutlineView.superview) {
        [self.collectionView addSubview:self.rightOutlineView];
    }
}

@end
