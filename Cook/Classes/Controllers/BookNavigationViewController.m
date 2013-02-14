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
#import "NewRecipeViewController.h"

@interface BookNavigationViewController () <BookNavigationLayoutDataSource, NewRecipeViewDelegate>

@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *createButton;
@property (nonatomic, assign) id<BookNavigationViewControllerDelegate> delegate;

@property (nonatomic, strong) CKBook *book;
@property (nonatomic, strong) NSMutableArray *categoryNames;
@property (nonatomic, strong) NSMutableDictionary *categoryRecipes;

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
    
    // Populate highlighted recipe
    CKRecipe *highlightRecipe = [self highlightRecipeForCategory:categoryName];
    [self configureImageForHeaderView:categoryHeaderView recipe:highlightRecipe];
    
    return categoryHeaderView;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RecipeCollectionViewCell *cell = (RecipeCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kRecipeCellId
                                                                                                           forIndexPath:indexPath];
    NSString *categoryName = [self.categoryNames objectAtIndex:indexPath.section];
    NSArray *categoryRecipes = [self.categoryRecipes objectForKey:categoryName];
    
    // Populate recipe.
    CKRecipe *recipe = [categoryRecipes objectAtIndex:indexPath.item];
    [cell configureRecipe:recipe];
    
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

- (void)createTapped:(id)sender {
    DLog();
    
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Cook" bundle:nil];
    NewRecipeViewController *newRecipeViewVC = [mainStoryBoard instantiateViewControllerWithIdentifier:@"NewRecipeViewController"];
    newRecipeViewVC.recipeViewDelegate = self;
    newRecipeViewVC.book = self.book;
    [self presentViewController:newRecipeViewVC animated:YES completion:nil];
}

- (void)configureImageForHeaderView:(CategoryHeaderView *)categoryHeaderView recipe:(CKRecipe *)recipe {
    if (categoryHeaderView) {
        [categoryHeaderView configureImageForRecipe:recipe];
    }
}

@end
