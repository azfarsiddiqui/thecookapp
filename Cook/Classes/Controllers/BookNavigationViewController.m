//
//  BookNavigationViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 11/02/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookNavigationViewController.h"
#import "BookNavigationFlowLayout.h"
#import "RecipeCollectionViewCell.h"
#import "CategoryHeaderView.h"
#import "CKBook.h"
#import "CKRecipe.h"
#import "MRCEnumerable.h"

@interface BookNavigationViewController ()

@property (nonatomic, strong) CKBook *book;
@property (nonatomic, strong) NSMutableArray *categoryNames;
@property (nonatomic, strong) NSMutableDictionary *categoryRecipes;
@property (nonatomic, strong) NSMutableDictionary *categoryRecipesLoadingMonitor;
@property (nonatomic, strong) NSMutableDictionary *categoryHeaders;

@end

@implementation BookNavigationViewController

#define kRecipeCellId       @"RecipeCellId"
#define kCategoryHeaderId   @"CategoryHeaderId"

- (id)initWithBook:(CKBook *)book {
    if (self = [super initWithCollectionViewLayout:[[BookNavigationFlowLayout alloc] init]]) {
        self.book = book;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initCollectionView];
    [self loadData];
}

#pragma mark - UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    DLog();
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryView:(UICollectionReusableView *)view forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    
    // Remove the reference to the category header once it's scrolled off.
    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        NSString *categoryName = [self.categoryNames objectAtIndex:indexPath.section];
        [self.categoryHeaders removeObjectForKey:categoryName];
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout methods

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
    referenceSizeForHeaderInSection:(NSInteger)section {
    
    CGSize unitSize = [BookNavigationFlowLayout unitSize];
    return CGSizeMake(unitSize.width * 2.0, unitSize.height);
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return [BookNavigationFlowLayout unitSize];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(112.0, 50.0, 112.0, 40.0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    // Gaps between rows.
    return 0.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    
    // Gaps between columns.
    return [BookNavigationFlowLayout columnSeparatorWidth];
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
    
    // Configure the category image from a random recipe that has an image.
    CKRecipe *randomRecipe = [self highlightRecipeForCategory:categoryName];
    if (randomRecipe) {
        [categoryHeaderView configureImageForRecipe:randomRecipe];
    }
    
    // Hang on to the categoryHeaderView.
    [self.categoryHeaders setObject:categoryHeaderView forKey:categoryName];
    
    return categoryHeaderView;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RecipeCollectionViewCell *cell = (RecipeCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kRecipeCellId
                                                                                                           forIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor lightGrayColor];
    return cell;
}

#pragma mark - Private methods

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
        
        // No go ahead and reload each recipes with required relations.
        
        
        
        
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
        
        // Start hydrating recipe images as a group.
        NSArray *categoryRecipes = [self.categoryRecipes objectForKey:categoryName];
        for (CKRecipe *recipe in categoryRecipes) {
            [CKRecipe fetchImagesForRecipe:recipe
                                   success:^{
                                       DLog(@"Hydrated recipe [%@]", recipe.name);
                                       [self updateCellImageForRecipe:recipe];
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



@end
