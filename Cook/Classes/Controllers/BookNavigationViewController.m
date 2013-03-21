//
//  BookNavigationViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 11/02/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookNavigationViewController.h"
#import "BookNavigationLayout.h"
#import "BookRecipeCollectionViewCell.h"
#import "BookCategoryView.h"
#import "CKBook.h"
#import "CKRecipe.h"
#import "MRCEnumerable.h"
#import "ViewHelper.h"
#import "ParsePhotoStore.h"
#import "BookProfileViewController.h"
#import "BookContentsViewController.h"
#import "BookActivityViewController.h"
#import "Theme.h"
#import "BookTitleViewController.h"

@interface BookNavigationViewController () <BookNavigationDataSource, BookNavigationLayoutDelegate,
    BookContentsViewControllerDelegate, BookActivityViewControllerDelegate, BookTitleViewControllerDelegate>

@property (nonatomic, strong) UIButton *homeButton;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, assign) id<BookNavigationViewControllerDelegate> delegate;

@property (nonatomic, strong) CKBook *book;
@property (nonatomic, strong) NSMutableArray *categoryNames;
@property (nonatomic, strong) NSMutableDictionary *categoryRecipes;
@property (nonatomic, strong) ParsePhotoStore *photoStore;

@property (nonatomic, strong) BookProfileViewController *profileViewController;
@property (nonatomic, strong) BookContentsViewController *contentsViewController;
@property (nonatomic, strong) BookActivityViewController *activityViewController;
@property (nonatomic, strong) BookTitleViewController *titleViewController;

@property (nonatomic, strong) NSString *selectedCategoryName;
@property (nonatomic, strong) NSString *currentCategoryName;
@property (nonatomic, assign) BOOL justOpened;

@end

@implementation BookNavigationViewController

#define kRecipeCellId       @"RecipeCellId"
#define kCategoryHeaderId   @"CategoryHeaderId"
#define kProfileCellId      @"ProfileCellId"
#define kTitleCellId        @"TitleCellId"
#define kActivityCellId     @"ActivityCellId"
#define kNavTopLeftOffset   CGPointMake(20.0, 15.0)
#define kNavTitleOffset     CGPointMake(20.0, 28.0)

- (id)initWithBook:(CKBook *)book delegate:(id<BookNavigationViewControllerDelegate>)delegate {
    if (self = [super initWithCollectionViewLayout:[[BookNavigationLayout alloc] initWithDataSource:self
                                                                                           delegate:self]]) {
        self.delegate = delegate;
        self.book = book;
        self.photoStore = [[ParsePhotoStore alloc] init];
        self.profileViewController = [[BookProfileViewController alloc] initWithBook:book];
        self.contentsViewController = [[BookContentsViewController alloc] initWithBook:book delegate:self];
        self.activityViewController = [[BookActivityViewController alloc] initWithBook:book delegate:self];
        self.titleViewController = [[BookTitleViewController alloc] initWithBook:book delegate:self];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initNav];
    [self initCollectionView];
    [self loadData];
    
    // Mark as just opened.
    self.justOpened = YES;
}

- (void)didReceiveMemoryWarning {
    
    // TODO Clear photo cache?
    
}

#pragma mark - BookNavigationLayoutDataSource methods

- (NSUInteger)bookNavigationContentStartSection {
    return [self recipeSection];
}

- (NSUInteger)bookNavigationLayoutNumColumns {
    return 3;
}

- (NSUInteger)bookNavigationLayoutColumnWidthForItemAtIndexPath:(NSIndexPath *)indexPath {
    return 1;
}

#pragma mark - BookNavigationLayoutDelegate methods

- (void)prepareLayoutDidFinish {
    if ([self isCategoryDeepLinked]) {
        
        [self.collectionView setContentOffset:CGPointMake([self recipeSection] * self.collectionView.bounds.size.width,
                                                          0.0)
                                     animated:YES];
    } else if (self.justOpened) {
        
        // Start on page 1.
        [self.collectionView setContentOffset:CGPointMake([self titleSection] * self.collectionView.bounds.size.width,
                                                          0.0)
                                     animated:NO];
        self.justOpened = NO;
    }
}

#pragma mark - BookContentsViewControllerDelegate methods

- (void)bookContentsSelectedCategory:(NSString *)category {
    
    // Selected a category, run-relayout
    self.selectedCategoryName = category;
    
    // Invalidate the current layout for deep-linking.
    [self.collectionView.collectionViewLayout invalidateLayout];
    [self.collectionView reloadData];
}

- (void)bookContentsAddRecipeRequested {
    [self.delegate bookNavigationControllerRecipeRequested:nil];
}

#pragma mark - BookActivityViewControllerDelegate methods

- (void)bookActivityViewControllerSelectedRecipe:(CKRecipe *)recipe {
    [self.delegate bookNavigationControllerRecipeRequested:recipe];
}

#pragma mark - BookTitleViewControllerDelegate methods

- (void)bookTitleViewControllerSelectedRecipe:(CKRecipe *)recipe {
    [self.delegate bookNavigationControllerRecipeRequested:recipe];
}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateNavButtons];
    [self updateNavTitle];
}

// To detect returning from category deep-linking.
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    // Reset category after returning to the contents screen after deep-linking.
    CGFloat contentsPageOffset = [self titleSection] * scrollView.bounds.size.width;
    if (scrollView.contentOffset.x == contentsPageOffset && [self isCategoryDeepLinked]) {
        self.selectedCategoryName = nil;
        
        // Invalidate the current layout for normal book mode.
        [self.collectionView.collectionViewLayout invalidateLayout];
        [self.collectionView reloadData];
    }
    
}


#pragma mark - UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger contentStartSection = [self bookNavigationContentStartSection];
    if (indexPath.section >= contentStartSection) {
        
        NSInteger categorySection = indexPath.section - contentStartSection;
        NSString *categoryName = [self.categoryNames objectAtIndex:categorySection];
        NSArray *categoryRecipes = [self.categoryRecipes objectForKey:categoryName];
        CKRecipe *recipe = [categoryRecipes objectAtIndex:indexPath.item];
        [self.delegate bookNavigationControllerRecipeRequested:recipe];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger contentStartSection = [self bookNavigationContentStartSection];
    if (indexPath.section >= contentStartSection) {
        
        // Clears the image on disappear.
        if ([cell isKindOfClass:[BookRecipeCollectionViewCell class]]) {
            BookRecipeCollectionViewCell *recipeCell = (BookRecipeCollectionViewCell *)cell;
            [recipeCell configureImage:nil];
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryView:(UICollectionReusableView *)view
      forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger contentStartSection = [self bookNavigationContentStartSection];
    if (indexPath.section >= contentStartSection) {
        
        if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
            
            // Clears the image on disappear.
            BookCategoryView *recipeCell = (BookCategoryView *)view;
            [recipeCell configureImage:nil];
        }
    }
    
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    NSInteger numSections = 0;
    
    // Info pages
    numSections += [self bookNavigationContentStartSection];
    
    // Categories
    if ([self isCategoryDeepLinked]) {
        numSections += 1;   // Only selected a category to deep link to.
    } else {
        numSections += [self.categoryNames count];  // All categories.
    }
    
    return numSections;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    NSInteger numItems = 0;
    NSInteger contentStartSection = [self bookNavigationContentStartSection];
    
    if (section >= contentStartSection) {
        
        NSInteger categorySection = section - contentStartSection;
        NSString *categoryName = [self selectedCategoryNameOrForSection:categorySection];
        NSArray *categoryRecipes = [self.categoryRecipes objectForKey:categoryName];
        numItems = [categoryRecipes count];
        
    } else {
        
        // Individual pages for non-recipes sections.
        numItems = 1;
    }
    
    return numItems;
}

- (UICollectionReusableView *)collectionView: (UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionReusableView *headerView = nil;
    NSInteger contentStartSection = [self bookNavigationContentStartSection];
    
    if (indexPath.section >= contentStartSection) {
        
        NSInteger categorySection = indexPath.section - contentStartSection;
        
        if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
            headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                            withReuseIdentifier:kCategoryHeaderId
                                                                   forIndexPath:indexPath];
            BookCategoryView *categoryHeaderView = (BookCategoryView *)headerView;
            
            // Configure the category name.
            NSString *categoryName = [self selectedCategoryNameOrForSection:categorySection];
            [categoryHeaderView configureCategoryName:categoryName];
            
            // Populate highlighted recipe
            CKRecipe *highlightRecipe = [self highlightRecipeForCategory:categoryName];
            
            // Configure image.
            [self configureImageForHeaderView:categoryHeaderView recipe:highlightRecipe indexPath:indexPath];
        }
    }
    
    return headerView;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = nil;
    
    if (indexPath.section == [self profileSection]) {
        cell = [self profileCellAtIndexPath:indexPath];
    } else if (indexPath.section == [self titleSection]) {
        cell = [self titleCellAtIndexPath:indexPath];
    } else if (indexPath.section >= [self recipeSection]) {
        cell = [self recipeCellAtIndexPath:indexPath];
    } else if (indexPath.section == [self activitySection]) {
        cell = [self activityCellAtIndexPath:indexPath];
    }
    
    return cell;
}

#pragma mark - NewRecipeViewDelegate methods

- (void)closeRequested {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)recipeCreated {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private methods

- (void)initNav {
    
    // Close button - hidden to start off with.
    UIButton *closeButton = [ViewHelper buttonWithImage:[UIImage imageNamed:@"cook_book_icon_close_white.png"]
                                                 target:self
                                               selector:@selector(closeTapped:)];
    closeButton.frame = CGRectMake(kNavTopLeftOffset.x,
                                   kNavTopLeftOffset.y,
                                   closeButton.frame.size.width,
                                   closeButton.frame.size.height);
    closeButton.hidden = YES;
    [self.view addSubview:closeButton];
    self.closeButton = closeButton;
    
    // Home button
    UIButton *homeButton = [ViewHelper buttonWithImage:[UIImage imageNamed:@"cook_book_icon_home_gray.png"]
                                                 target:self
                                               selector:@selector(homeTapped:)];
    homeButton.frame = CGRectMake(kNavTopLeftOffset.x,
                                  kNavTopLeftOffset.y,
                                  homeButton.frame.size.width,
                                  homeButton.frame.size.height);
    [self.view addSubview:homeButton];
    self.homeButton = homeButton;
    
    // Title
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, kNavTitleOffset.y, 0.0, 0.0)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [Theme bookNavigationTitleFont];
    titleLabel.textColor = [Theme bookNavigationTitleColour];
    titleLabel.hidden = YES;
    [self.view addSubview:titleLabel];
    self.titleLabel = titleLabel;
}

- (void)initCollectionView {
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.pagingEnabled = YES;
    
    // Profile, Contents, Activity
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kProfileCellId];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kTitleCellId];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kActivityCellId];
    
    // Categories
    [self.collectionView registerClass:[BookCategoryView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:kCategoryHeaderId];
    [self.collectionView registerClass:[BookRecipeCollectionViewCell class] forCellWithReuseIdentifier:kRecipeCellId];
}

- (void)loadData {
    
    // Fetch all recipes for the book and partition them into their categories.
    [self.book fetchRecipesSuccess:^(NSArray *recipes) {
        
        self.categoryRecipes = [NSMutableDictionary dictionary];
        self.categoryNames = [NSMutableArray array];
        
        for (CKRecipe *recipe in recipes) {
            
            NSString *categoryName = recipe.category.name;
            
            if (![self.categoryNames containsObject:categoryName]) {
                NSMutableArray *recipes = [NSMutableArray arrayWithObject:recipe];
                [self.categoryRecipes setObject:recipes forKey:categoryName];
                [self.categoryNames addObject:categoryName];
            } else {
                NSMutableArray *recipes = [self.categoryRecipes objectForKey:categoryName];
                [recipes addObject:recipe];
            }
        }
        
        // Update the VC's.
        [self.contentsViewController configureCategories:self.categoryNames];
        [self.contentsViewController configureHeroRecipe:[self highlightRecipeForBook]];
        [self.titleViewController configureHeroRecipe:[self highlightRecipeForBook]];
        
        // Now reload the collection.
        [self.collectionView reloadData];
        
        
    } failure:^(NSError *error) {
        DLog(@"Error %@", [error localizedDescription]);
    }];
}

- (void)closeTapped:(id)sender {
    [self.delegate bookNavigationControllerCloseRequested];
}

- (void)homeTapped:(id)sender {
    CGFloat contentsPageOffset = [self titleSection] * self.collectionView.bounds.size.width;
    [self.collectionView setContentOffset:CGPointMake(contentsPageOffset, 0.0) animated:YES];
}

- (void)configureImageForHeaderView:(BookCategoryView *)categoryHeaderView recipe:(CKRecipe *)recipe
                          indexPath:(NSIndexPath *)indexPath {
    
    if ([recipe hasPhotos]) {
        
        CGSize imageSize = [categoryHeaderView imageSize];
        [self.photoStore imageForParseFile:[recipe imageFile]
                                      size:imageSize
                                 indexPath:indexPath
                                completion:^(NSIndexPath *completedIndexPath, UIImage *image) {
            
                                    // Check that we have matching indexPaths as cells are re-used.
                                    if ([indexPath isEqual:completedIndexPath]) {
                                        [categoryHeaderView configureImage:image];
                                    }
        }];
        
    } else {
        [categoryHeaderView configureImage:nil];
    }
}

- (void)configureImageForRecipeCell:(BookRecipeCollectionViewCell *)recipeCell recipe:(CKRecipe *)recipe
                          indexPath:(NSIndexPath *)indexPath {
    
    if ([recipe hasPhotos]) {
        
        CGSize imageSize = [recipeCell imageSize];
        [self.photoStore imageForParseFile:[recipe imageFile]
                                      size:imageSize
                                 indexPath:indexPath
                                completion:^(NSIndexPath *completedIndexPath, UIImage *image) {
                                    
                                    // Check that we have matching indexPaths as cells are re-used.
                                    if ([indexPath isEqual:completedIndexPath]) {
                                        [recipeCell configureImage:image];
                                    }
                                }];
    }
}

- (UICollectionViewCell *)recipeCellAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger contentStartSection = [self bookNavigationContentStartSection];
    NSInteger categorySection = indexPath.section - contentStartSection;
    
    BookRecipeCollectionViewCell *recipeCell = (BookRecipeCollectionViewCell *)[self.collectionView dequeueReusableCellWithReuseIdentifier:kRecipeCellId
                                                                                                                              forIndexPath:indexPath];;
    NSString *categoryName = [self selectedCategoryNameOrForSection:categorySection];
    NSArray *categoryRecipes = [self.categoryRecipes objectForKey:categoryName];
    
    // Populate recipe.
    CKRecipe *recipe = [categoryRecipes objectAtIndex:indexPath.item];
    [recipeCell configureRecipe:recipe];
    
    // Configure image.
    [self configureImageForRecipeCell:recipeCell recipe:recipe indexPath:indexPath];
    
    return recipeCell;
}

- (UICollectionViewCell *)profileCellAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *profileCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:kProfileCellId forIndexPath:indexPath];;
    if (!self.profileViewController.view.superview) {
        self.profileViewController.view.frame = profileCell.contentView.bounds;
        [profileCell.contentView addSubview:self.profileViewController.view];
    }
    return profileCell;
}

- (UICollectionViewCell *)titleCellAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *contentsCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:kTitleCellId forIndexPath:indexPath];
    if (!self.titleViewController.view.superview) {
        self.titleViewController.view.frame = contentsCell.contentView.bounds;
        [contentsCell.contentView addSubview:self.titleViewController.view];
    }
    return contentsCell;
}

- (UICollectionViewCell *)activityCellAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *contentsCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:kActivityCellId forIndexPath:indexPath];
    if (!self.activityViewController.view.superview) {
        self.activityViewController.view.frame = contentsCell.contentView.bounds;
        [contentsCell.contentView addSubview:self.activityViewController.view];
    }
    return contentsCell;
}

- (NSArray *)recipesWithPhotosInCategory:(NSString *)categoryName {
    NSArray *categoryRecipes = [self.categoryRecipes objectForKey:categoryName];
    return [categoryRecipes select:^BOOL(CKRecipe *recipe) {
        return [recipe hasPhotos];
    }];
}

- (NSArray *)recipesWithPhotos {
    NSMutableArray *allRecipes = [NSMutableArray array];
    for (NSArray *categoryRecipes in [self.categoryRecipes allValues]) {
        [allRecipes addObjectsFromArray:categoryRecipes];
    }
    return [allRecipes select:^BOOL(CKRecipe *recipe) {
        return [recipe hasPhotos];
    }];
}

- (CKRecipe *)highlightRecipeForCategory:(NSString *)categoryName {
    NSArray *recipes = [self recipesWithPhotosInCategory:categoryName];
    if ([recipes count] > 0) {
        return [recipes objectAtIndex:arc4random_uniform([recipes count])];
    } else {
        return nil;
    }
}

- (CKRecipe *)highlightRecipeForBook {
    NSArray *recipes = [self recipesWithPhotos];
    if ([recipes count] > 0) {
        return [recipes objectAtIndex:arc4random_uniform([recipes count])];
    } else {
        return nil;
    }
}

- (BOOL)isCategoryDeepLinked {
    return (self.selectedCategoryName != nil);
}

- (NSString *)selectedCategoryNameOrForSection:(NSInteger)section {
    if ([self isCategoryDeepLinked]) {
        return self.selectedCategoryName;
    } else {
        return [self.categoryNames objectAtIndex:section];
    }
}

- (NSInteger)profileSection {
    return 0;
}

- (NSInteger)titleSection {
    return 1;
}

- (NSInteger)activitySection {
    return 2;   // Not available in deep-linked mode.
}

- (NSInteger)recipeSection {
    return [self isCategoryDeepLinked] ? 2 : 3; // Minus the activity page if deeplinked.

}

- (void)updateNavButtons {
    
    CGFloat contentsPageOffset = [self titleSection] * self.collectionView.bounds.size.width;
    
    // Close button visible only on the contents page.
    if (self.collectionView.contentOffset.x >= contentsPageOffset
        && self.collectionView.contentOffset.x < (contentsPageOffset + (self.collectionView.bounds.size.width) / 2.0)) {
        self.closeButton.hidden = NO;
        self.homeButton.hidden = YES;
    } else {
        self.closeButton.hidden = YES;
        self.homeButton.hidden = NO;
    }
    
}

- (void)updateNavTitle {
    CGFloat contentsPageOffset = [self recipeSection] * self.collectionView.bounds.size.width;
    if (self.collectionView.contentOffset.x >= contentsPageOffset) {
        self.titleLabel.hidden = NO;
        
        NSString *categoryName = [self currentCategoryNameFromOffset];
        if (![self.currentCategoryName isEqualToString:categoryName]) {
            NSString *navTitle = [self navigationTitle];
            self.titleLabel.text = navTitle;
            [self.titleLabel sizeToFit];
            self.titleLabel.frame = CGRectMake(floorf((self.view.bounds.size.width - self.titleLabel.frame.size.width) / 2.0),
                                               self.titleLabel.frame.origin.y,
                                               self.titleLabel.frame.size.width,
                                               self.titleLabel.frame.size.height);
            self.currentCategoryName = navTitle;
        }
        
    } else {
        self.currentCategoryName = nil;
        self.titleLabel.hidden = YES;
    }
}

- (NSString *)navigationTitle {
    NSMutableString *title = [NSMutableString stringWithString:self.book.name];
    NSString *currentCategoryName = [self currentCategoryNameFromOffset];
    if ([currentCategoryName length] > 0) {
        [title appendFormat:@" - %@", [currentCategoryName uppercaseString]];
    }
    return title;
}

- (NSString *)currentCategoryNameFromOffset {
    // Start off with the first category name.
    NSString *categoryName = categoryName = [self.categoryNames objectAtIndex:0];
    CGFloat recipePageOffset = [self recipeSection] * self.collectionView.bounds.size.width;
    
    if (self.collectionView.contentOffset.x >= recipePageOffset) {
        BookNavigationLayout *layout = (BookNavigationLayout *)self.collectionView.collectionViewLayout;
        
        NSArray *pageOffsets = [layout pageOffsetsForContentsSections];
        CGFloat currentOffset = self.collectionView.contentOffset.x;
        
        for (NSInteger pageOffsetIndex = 0; pageOffsetIndex < [pageOffsets count]; pageOffsetIndex++) {
            
            NSNumber *pageOffsetNumber = [pageOffsets objectAtIndex:pageOffsetIndex];
            if (currentOffset < [pageOffsetNumber floatValue]) {
                break;
            }
            
            // Update category name.
            categoryName = [self.categoryNames objectAtIndex:pageOffsetIndex];
        }
        
    }
    return categoryName;
}

@end
