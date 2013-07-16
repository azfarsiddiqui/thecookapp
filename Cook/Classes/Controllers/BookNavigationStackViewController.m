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

@interface BookNavigationStackViewController () <BookPagingStackLayoutDelegate, BookIndexListViewControllerDelegate,
    BookCategoryViewControllerDelegate, BookNavigationViewDelegate, BookPageViewControllerDelegate>

@property (nonatomic, strong) CKBook *book;
@property (nonatomic, assign) id<BookNavigationViewControllerDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *categories;
@property (nonatomic, strong) NSMutableArray *recipes;
@property (nonatomic, strong) NSMutableDictionary *categoryRecipes;
@property (nonatomic, strong) NSMutableDictionary *categoryControllers;
@property (nonatomic, strong) NSMutableDictionary *categoryHeaderViews;
@property (nonatomic, assign) BOOL justOpened;
@property (nonatomic, strong) UIView *bookOutlineView;
@property (nonatomic, strong) BookNavigationView *bookNavigationView;

@property (nonatomic, strong) ParsePhotoStore *photoStore;

@property (nonatomic, strong) BookProfileViewController *profileViewController;
@property (nonatomic, strong) BookIndexListViewController *indexViewController;

@end

@implementation BookNavigationStackViewController

#define kCellId             @"CellId"
#define kProfileSection     0
#define kIndexSection       1
#define kProfileCellId      @"ProfileCellId"
#define kIndexCellId        @"IndexCellId"
#define kCategoryCellId     @"CategoryCellId"
#define kCategoryHeaderId   @"CategoryHeaderId"
#define kProfileHeaderId    @"ProfileHeaderId"
#define kNavigationHeaderId @"NavigationHeaderId"
#define kCategoryViewTag    460
#define kBookOutlineOffset  (UIOffset){-27.0, -9.0}

- (id)initWithBook:(CKBook *)book delegate:(id<BookNavigationViewControllerDelegate>)delegate {
    if (self = [super initWithCollectionViewLayout:[[BookPagingStackLayout alloc] initWithDelegate:self]]) {
        self.delegate = delegate;
        self.book = book;
        self.photoStore = [[ParsePhotoStore alloc] init];
        self.profileViewController = [[BookProfileViewController alloc] initWithBook:book];
        self.indexViewController = [[BookIndexListViewController alloc] initWithBook:book delegate:self];
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

#pragma mark - BookPageViewControllerDelegate methods

- (void)bookPageViewControllerShowNavigationBar:(BOOL)show {
    [self showNavBar:NO completion:nil];
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
            headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                            withReuseIdentifier:kProfileHeaderId
                                                                   forIndexPath:indexPath];
        } else if (indexPath.section >= [self stackCategoryStartSection]) {
            headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                            withReuseIdentifier:kCategoryHeaderId
                                                                   forIndexPath:indexPath];
            CKCategory *category = [self.categories objectAtIndex:indexPath.section - [self stackCategoryStartSection]];
            BookCategoryImageView *categoryHeaderView = (BookCategoryImageView *)headerView;
            CKRecipe *featuredRecipe = [self featuredRecipeForCategory:category];
            [self configureImageForHeaderView:categoryHeaderView recipe:featuredRecipe indexPath:indexPath];
            
            // Keep track of category views keyed on indexPath.
            [self.categoryHeaderViews setObject:categoryHeaderView forKey:indexPath];
            
        }
    } else if ([kind isEqualToString:[BookPagingStackLayout bookPagingNavigationElementKind]]) {
        
        headerView = [collectionView dequeueReusableSupplementaryViewOfKind:[BookPagingStackLayout bookPagingNavigationElementKind]
                                                        withReuseIdentifier:kNavigationHeaderId
                                                               forIndexPath:indexPath];
        BookNavigationView *navigationView = (BookNavigationView *)headerView;
        navigationView.delegate = self;
        [navigationView setTitle:self.book.user.name];
        
        // Keep a reference of the navigation view.
        self.bookNavigationView = navigationView;
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
    if ([elementKind isEqualToString:[BookPagingStackLayout bookPagingNavigationElementKind]]) {
        [self.categoryHeaderViews removeObjectForKey:indexPath];
    }
    
}

#pragma mark - Private methods

- (void)initBookOutlineView {
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
    
    // Decorations.
    UIImageView *bookOutlineOverlayView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_book_edge_overlay.png"]];
    bookOutlineOverlayView.frame = CGRectMake(-36.0, -18.0, bookOutlineOverlayView.frame.size.width, bookOutlineOverlayView.frame.size.height);
    [bookOutlineView addSubview:bookOutlineOverlayView];
    UIImageView *bookBindOverlayView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_book_edge_overlay_bind.png"]];
    bookBindOverlayView.frame = CGRectMake(-26.0, -18.0, bookBindOverlayView.frame.size.width, bookBindOverlayView.frame.size.height);
    [bookOutlineView addSubview:bookBindOverlayView];
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
    CKCategory *randomCategory = [self.categories objectAtIndex:arc4random_uniform([self.categories count])];
    CKRecipe *featuredRecipe = [self featuredRecipeForCategory:randomCategory];
    [self.indexViewController configureHeroRecipe:featuredRecipe];
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

- (void)prefetchCategoryControllers {
    
    CGRect visibleFrame = (CGRect) {
        self.collectionView.contentOffset.x,
        self.collectionView.contentOffset.y,
        self.collectionView.bounds.size.width,
        self.collectionView.bounds.size.height
    };
    
    // Figure out the pageDistance for prefetching.
    NSInteger categoryIndex = 0;
    NSInteger pageDistance = (NSInteger)visibleFrame.origin.x / self.collectionView.bounds.size.width;
    if (pageDistance >= [self stackCategoryStartSection]) {
        categoryIndex = pageDistance - [self stackCategoryStartSection];
    }
    
    NSInteger numPrefetch = 2;
    for (NSInteger currentCatIndex = categoryIndex; currentCatIndex < (categoryIndex + numPrefetch); currentCatIndex++) {
        
        // Have we exceeded the number of categories.
        if (currentCatIndex > [self.categories count] - 1) {
            break;
        }
        
        CKCategory *category = [self.categories objectAtIndex:currentCatIndex];
        NSString *categoryKey = [self keyForCategory:category];
        BookCategoryViewController *categoryController = [self.categoryControllers objectForKey:categoryKey];
        if (!categoryController) {
            DLog(@"Prefetch category VC for [%@]", category.name);
            categoryController = [[BookCategoryViewController alloc] initWithBook:self.book category:category delegate:self];
            categoryController.bookPageDelegate = self;
            [categoryController loadData];
            [self.categoryControllers setObject:categoryController forKey:categoryKey];
        }
    }
    
}

- (NSArray *)recipesWithPhotos:(NSArray *)recipes {
    return [recipes select:^BOOL(CKRecipe *recipe) {
        return [recipe hasPhotos];
    }];
}

- (CKRecipe *)featuredRecipeForCategory:(CKCategory *)category {
    NSArray *recipes = [self.categoryRecipes objectForKey:[self keyForCategory:category]];
    NSArray *recipesWithPhotos = [self recipesWithPhotos:recipes];
    if ([recipesWithPhotos count] > 0) {
        return [recipes objectAtIndex:arc4random_uniform([recipes count])];
    } else {
        return nil;
    }
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

- (void)showNavBar:(BOOL)show completion:(void (^)())completion {
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.bookNavigationView.alpha = show ? 1.0 : 0.0;
                     }
                     completion:^(BOOL finished) {
                         if (completion != nil) {
                             completion();
                         }
                     }];
}

@end
