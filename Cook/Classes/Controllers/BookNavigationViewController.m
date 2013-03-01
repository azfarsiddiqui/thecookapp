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
#import "NewRecipeViewController.h"
#import "ParsePhotoStore.h"
#import "TestViewController.h"
#import "BookProfileViewController.h"
#import "BookContentsViewController.h"
#import "BookActivityViewController.h"

@interface BookNavigationViewController () <BookNavigationDataSource, BookNavigationLayoutDelegate,
    NewRecipeViewDelegate, BookContentsViewControllerDelegate>

@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *createButton;
@property (nonatomic, assign) id<BookNavigationViewControllerDelegate> delegate;

@property (nonatomic, strong) CKBook *book;
@property (nonatomic, strong) NSMutableArray *categoryNames;
@property (nonatomic, strong) NSMutableDictionary *categoryRecipes;
@property (nonatomic, strong) ParsePhotoStore *photoStore;

@property (nonatomic, strong) BookProfileViewController *profileViewController;
@property (nonatomic, strong) BookContentsViewController *contentsViewController;
@property (nonatomic, strong) BookActivityViewController *activityViewController;

@property (nonatomic, strong) NSString *selectedCategoryName;

@end

@implementation BookNavigationViewController

#define kRecipeCellId       @"RecipeCellId"
#define kCategoryHeaderId   @"CategoryHeaderId"
#define kProfileCellId      @"ProfileCellId"
#define kContentsCellId     @"ContentsCellId"
#define kActivityCellId     @"ActivityCellId"

- (id)initWithBook:(CKBook *)book delegate:(id<BookNavigationViewControllerDelegate>)delegate {
    if (self = [super initWithCollectionViewLayout:[[BookNavigationLayout alloc] initWithDataSource:self
                                                                                           delegate:self]]) {
        self.delegate = delegate;
        self.book = book;
        self.photoStore = [[ParsePhotoStore alloc] init];
        self.profileViewController = [[BookProfileViewController alloc] initWithBook:book];
        self.contentsViewController = [[BookContentsViewController alloc] initWithBook:book delegate:self];
        self.activityViewController = [[BookActivityViewController alloc] initWithBook:book];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initNavButtons];
    [self initCollectionView];
    [self loadData];
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

#pragma mark - UIScrollViewDelegate methods

// To detect returning from category deep-linking.
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    // Reset category after returning to the contents screen after deep-linking.
    CGFloat contentsPageOffset = [self contentsSection] * scrollView.bounds.size.width;
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
    
    DLog(@"Number of sections [%d]", numSections);
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
    
    DLog(@"Num Items for Section [%d]: %d", section, numItems);
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
    } else if (indexPath.section == [self contentsSection]) {
        cell = [self contentsCellAtIndexPath:indexPath];
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

- (void)initNavButtons {
    
    // Close button
    UIButton *closeButton = [ViewHelper buttonWithImage:[UIImage imageNamed:@"cook_book_icon_close_gray.png"]
                                                 target:self
                                               selector:@selector(closeTapped:)];
    closeButton.frame = CGRectMake(20.0,
                                   15.0,
                                   closeButton.frame.size.width,
                                   closeButton.frame.size.height);
    [self.view addSubview:closeButton];
    self.closeButton = closeButton;
    
    // Add button.
    if ([self.book isUserBookAuthor:[CKUser currentUser]]) {
        UIButton *createButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [createButton setTitle:@"Add" forState:UIControlStateNormal];
        [createButton addTarget:self action:@selector(createTapped:) forControlEvents:UIControlEventTouchUpInside];
        [createButton sizeToFit];
        createButton.frame = CGRectMake(closeButton.frame.origin.x + closeButton.frame.size.width + 10.0,
                                        closeButton.frame.origin.y,
                                        createButton.frame.size.width,
                                        createButton.frame.size.height);
        [self.view addSubview:createButton];
        self.createButton = createButton;
    }
}

- (void)initCollectionView {
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.pagingEnabled = YES;
    
    // Profile, Contents, Activity
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kProfileCellId];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kContentsCellId];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kActivityCellId];
    
    // Categories
    [self.collectionView registerClass:[BookCategoryView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:kCategoryHeaderId];
    [self.collectionView registerClass:[BookRecipeCollectionViewCell class] forCellWithReuseIdentifier:kRecipeCellId];
    
    // How to start a page in?
//    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:1] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
//    [self.collectionView setContentOffset:CGPointMake(self.collectionView.bounds.size.width,
//                                                      self.collectionView.bounds.origin.x)
//                                 animated:YES];
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
        [self.contentsViewController configureRecipe:[self highlightRecipeForBook]];
        
        // Now reload the collection.
        [self.collectionView reloadData];
        
        
    } failure:^(NSError *error) {
        DLog(@"Error %@", [error localizedDescription]);
    }];
}

- (void)closeTapped:(id)sender {
    [self.delegate bookNavigationControllerCloseRequested];
}

- (void)createTapped:(id)sender {
    [self.delegate bookNavigationControllerRecipeRequested:nil];
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

    } else {
        [recipeCell configureImage:nil];
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

- (UICollectionViewCell *)contentsCellAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *contentsCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:kContentsCellId forIndexPath:indexPath];
    if (!self.contentsViewController.view.superview) {
        self.contentsViewController.view.frame = contentsCell.contentView.bounds;
        [contentsCell.contentView addSubview:self.contentsViewController.view];
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

- (NSInteger)contentsSection {
    return 1;
}

- (NSInteger)activitySection {
    return 2;   // Not available in deep-linked mode.
}

- (NSInteger)recipeSection {
    return [self isCategoryDeepLinked] ? 2 : 3; // Minus the activity page if deeplinked.

}

@end
