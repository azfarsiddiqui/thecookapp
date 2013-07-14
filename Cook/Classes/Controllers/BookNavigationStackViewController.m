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
#import "BookPagingStackLayout.h"
#import "ParsePhotoStore.h"
#import "BookProfileViewController.h"
#import "BookIndexListViewController.h"
#import "BookHeaderView.h"
#import "MRCEnumerable.h"
#import "CKBookCover.h"
#import "BookCategoryViewController.h"

@interface BookNavigationStackViewController () <BookPagingStackLayoutDelegate, BookIndexListViewControllerDelegate, BookCategoryViewControllerDelegate>

@property (nonatomic, strong) CKBook *book;
@property (nonatomic, assign) id<BookNavigationViewControllerDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *categories;
@property (nonatomic, strong) NSMutableArray *recipes;
@property (nonatomic, strong) NSMutableDictionary *categoryRecipes;
@property (nonatomic, strong) NSMutableDictionary *categoryControllers;
@property (nonatomic, assign) BOOL justOpened;

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
#define kHeaderId           @"HeaderId"
#define kCategoryViewTag    460

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
    if (active) {
        
        // Unselect cells.
        NSArray *selectedIndexPaths = [self.collectionView indexPathsForSelectedItems];
        if ([selectedIndexPaths count] > 0) {
            NSIndexPath *selectedIndexPath = [selectedIndexPaths objectAtIndex:0];
            UICollectionViewCell *selectedCell = [self.collectionView cellForItemAtIndexPath:selectedIndexPath];
            [selectedCell setSelected:NO];
        }
        
    } else {
        
    }
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
        [self prefetchCategoryControllers];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self prefetchCategoryControllers];
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
        headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                        withReuseIdentifier:kHeaderId
                                                               forIndexPath:indexPath];
        BookHeaderView *categoryHeaderView = (BookHeaderView *)headerView;
        categoryHeaderView.userInteractionEnabled = NO;
        
        // Configure the category name.
        CKCategory *category = [self.categories objectAtIndex:indexPath.section - [self stackCategoryStartSection]];
        [categoryHeaderView  configureTitle:category.name];
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

#pragma mark - Private methods

- (void)initBookOutlineView {
    UIImage *outlineImage = [CKBookCover outlineImageForCover:self.book.cover];
    UIImageView *bookOutlineView = [[UIImageView alloc] initWithImage:outlineImage];
    bookOutlineView.frame = CGRectMake(-26.0, -8.0, bookOutlineView.frame.size.width, bookOutlineView.frame.size.height);
    [self.view insertSubview:bookOutlineView belowSubview:self.collectionView];
    
    // Decorations.
    UIImageView *bookOutlineOverlayView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_book_edge_overlay"]];
    bookOutlineOverlayView.frame = CGRectMake(-36.0, -18.0, bookOutlineOverlayView.frame.size.width, bookOutlineOverlayView.frame.size.height);
    [bookOutlineView addSubview:bookOutlineOverlayView];
    UIImageView *bookBindOverlayView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_book_edge_overlay_bind.png"]];
    bookBindOverlayView.frame = CGRectMake(-26.0, -18.0, bookBindOverlayView.frame.size.width, bookBindOverlayView.frame.size.height);
    [bookOutlineView addSubview:bookBindOverlayView];
}

- (void)initCollectionView {
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.pagingEnabled = YES;
    self.collectionView.alwaysBounceVertical = NO;
    self.collectionView.alwaysBounceHorizontal = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    
    // Headers
    [self.collectionView registerClass:[BookHeaderView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:kHeaderId];
    
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

@end
