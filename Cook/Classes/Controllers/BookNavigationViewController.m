//
//  BookNavigationViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 11/02/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookNavigationViewController.h"
#import "BookNavigationFlowLayout.h"
#import "BookNavigationLayout.h"
#import "RecipeCollectionViewCell.h"
#import "CategoryHeaderView.h"
#import "CKBook.h"
#import "CKRecipe.h"
#import "MRCEnumerable.h"
#import "ViewHelper.h"

@interface BookNavigationViewController () <BookNavigationLayoutDataSource>

@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, assign) id<BookNavigationViewControllerDelegate> delegate;

@property (nonatomic, strong) CKBook *book;
@property (nonatomic, strong) NSMutableArray *categoryNames;
@property (nonatomic, strong) NSMutableDictionary *categoryRecipes;
@property (nonatomic, strong) NSMutableDictionary *categoryRecipesLoadingMonitor;
@property (nonatomic, strong) NSMutableDictionary *categoryHeaders;

@end

@implementation BookNavigationViewController

#define kRecipeCellId       @"RecipeCellId"
#define kCategoryHeaderId   @"CategoryHeaderId"

- (id)initWithBook:(CKBook *)book delegate:(id<BookNavigationViewControllerDelegate>)delegate {
    if (self = [super initWithCollectionViewLayout:[[BookNavigationLayout alloc] initWithDataSource:self]]) {
        self.delegate = delegate;
        self.book = book;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initNavButtons];
    [self initCollectionView];
    [self loadData];
}

#pragma mark - BookNavigationLayoutDataSource methods

- (NSUInteger)bookNavigationLayoutNumColumns {
    return 3;
}

- (NSUInteger)bookNavigationLayoutColumnWidthForItemAtIndexPath:(NSIndexPath *)indexPath {
    return 1;
}

#pragma mark - UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    DLog();
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryView:(UICollectionReusableView *)view
      forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    
    // Remove the reference to the category header once it's scrolled off.
    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        NSString *categoryName = [self.categoryNames objectAtIndex:indexPath.section];
        [self.categoryHeaders removeObjectForKey:categoryName];
    }
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.categoryNames count];
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    NSString *categoryName = [self.categoryNames objectAtIndex:section];
    NSArray *categoryRecipes = [self.categoryRecipes objectForKey:categoryName];
    return [categoryRecipes count];
}

- (UICollectionReusableView *)collectionView: (UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    CategoryHeaderView *categoryHeaderView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kCategoryHeaderId forIndexPath:indexPath];
    
    // Configure the category name.
    NSString *categoryName = [self.categoryNames objectAtIndex:indexPath.section];
    [categoryHeaderView configureCategoryName:categoryName];
    
    // Ensure images for recipes in the category is loaded.
    [self preloadImagesForCategory:categoryName];
    
    // Hang on to the categoryHeaderView.
    [self.categoryHeaders setObject:categoryHeaderView forKey:categoryName];
    
    return categoryHeaderView;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RecipeCollectionViewCell *cell = (RecipeCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kRecipeCellId
                                                                                                           forIndexPath:indexPath];
    NSString *categoryName = [self.categoryNames objectAtIndex:indexPath.section];
    NSArray *categoryRecipes = [self.categoryRecipes objectForKey:categoryName];
    CKRecipe *recipe = [categoryRecipes objectAtIndex:indexPath.item];
    
    cell.backgroundColor = [UIColor lightGrayColor];
    
    [cell configureRecipe:recipe];
    return cell;
}

#pragma mark - Private methods

- (void)initNavButtons {
    UIButton *closeButton = [ViewHelper buttonWithImage:[UIImage imageNamed:@"cook_book_icon_close_gray.png"]
                                                 target:self
                                               selector:@selector(closeTapped:)];
    closeButton.frame = CGRectMake(20.0,
                                   15.0,
                                   closeButton.frame.size.width,
                                   closeButton.frame.size.height);
    [self.view addSubview:closeButton];
    self.closeButton = closeButton;
}

- (void)initCollectionView {
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.pagingEnabled = YES;
    
    [self.collectionView registerClass:[RecipeCollectionViewCell class] forCellWithReuseIdentifier:kRecipeCellId];
    [self.collectionView registerClass:[CategoryHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:kCategoryHeaderId];
}

- (void)loadData {
    
    // Fetch all recipes for the book and partition them into their categories.
    [self.book fetchRecipesSuccess:^(NSArray *recipes) {
        
        self.categoryRecipes = [NSMutableDictionary dictionary];
        self.categoryNames = [NSMutableArray array];
        self.categoryRecipesLoadingMonitor = [NSMutableDictionary dictionary];
        self.categoryHeaders = [NSMutableDictionary dictionary];
        
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
        
        // Now reload the collection.
        [self.collectionView reloadData];
        
        
    } failure:^(NSError *error) {
        DLog(@"Error %@", [error localizedDescription]);
    }];
}

- (CKRecipe *)highlightRecipeForCategory:(NSString *)categoryName {
    NSArray *categoryRecipes = [self.categoryRecipes objectForKey:categoryName];
    
        // Pick a random recipe with image otherwise return nil.
    if ([categoryRecipes count] > 0) {
        
        // Get first object.
        return [categoryRecipes objectAtIndex:0];
//        return [categoryRecipes objectAtIndex:arc4random() % ([categoryRecipes count])];
        
    } else {
        return nil;
    }
    
}

- (void)preloadImagesForCategory:(NSString *)categoryName {
    NSNumber *categoryRecipesLoaded = [self.categoryRecipesLoadingMonitor objectForKey:categoryName];
    if (!categoryRecipesLoaded) {
        
        DLog(@"Preloading images for category: %@", categoryName);
        
        CKRecipe *highlightRecipe = [self highlightRecipeForCategory:categoryName];
        
        // Start hydrating recipe images as a group.
        NSArray *categoryRecipes = [self.categoryRecipes objectForKey:categoryName];
        for (CKRecipe *recipe in categoryRecipes) {
            [CKRecipe fetchImagesForRecipe:recipe
                                   success:^{
                                       DLog(@"Hydrated image for recipe [%@]", recipe.name);
                                       [self updateCellImageForRecipe:recipe];
                                       
                                       // Update category headerView if we've loaded the highlight recipe.
                                       if (highlightRecipe == recipe) {
                                           CategoryHeaderView *categoryHeaderView = [self.categoryHeaders objectForKey:categoryName];
                                           [self configureImageForHeaderView:categoryHeaderView recipe:recipe];
                                       }
                                       
                                   }
                                   failure:^(NSError *error) {
                                       DLog(@"Unable to hydrate recipe [%@]", recipe.name);
                                   }];
        }
        
        // Mark as loaded.
        [self.categoryRecipesLoadingMonitor setObject:[NSNumber numberWithBool:YES] forKey:categoryName];
    }
}

- (void)updateCellImageForRecipe:(CKRecipe *)recipe {
    
    // Reload cell images.
    NSArray *visibleCells = [self.collectionView visibleCells];
    for (RecipeCollectionViewCell *cell in visibleCells) {
        if (cell.recipe == recipe) {
            [cell updateImage];
            break;
        }
    }
}

- (void)closeTapped:(id)sender {
    [self.delegate bookNavigationControllerCloseRequested];
}

- (void)configureImageForHeaderView:(CategoryHeaderView *)categoryHeaderView recipe:(CKRecipe *)recipe {
    if (categoryHeaderView) {
        [categoryHeaderView configureImageForRecipe:recipe];
    }
}

@end
