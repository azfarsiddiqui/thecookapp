//
//  BookViewController.m
//  Cook
//
//  Created by Jonny Sagorin on 10/10/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookViewController.h"
#import "BookContentsViewController.h"
#import "RecipeListViewController.h"
#import "BookCategoryViewController.h"
#import "RecipeViewController.h"
#import "CookPageFlipper.h"
#import "ViewHelper.h"
#import "ContentsPageViewController.h"
#import "CKRecipe.h"
#import "MRCEnumerable.h"
#import "CategoryPageViewController.h"
#import "RecipePageViewController.h"

@interface BookViewController ()<AFKPageFlipperDataSource, BookViewDelegate, BookViewDataSource>

@property (nonatomic, strong) CookPageFlipper *pageFlipper;
@property (nonatomic, strong) CKBook *book;
@property (nonatomic, strong) CKRecipe *recipe;
@property (nonatomic, strong) NSArray *recipes;
@property (nonatomic, strong) NSMutableArray *categories;
@property (nonatomic, strong) NSMutableArray *categoryRecipes;
@property (nonatomic, strong) NSMutableArray *categoryPageIndexes;
@property (nonatomic, assign) id<BookViewControllerDelegate> delegate;
@property (nonatomic, strong) RecipeListViewController *recipeListViewController;
@property (nonatomic, strong) BookContentsViewController *bookContentsViewController;
@property (nonatomic, strong) BookCategoryViewController *bookCategoryViewController;
@property (nonatomic, strong) ContentsPageViewController *contentsViewController;
@property (nonatomic, strong) CategoryPageViewController *categoryViewController;
@property (nonatomic, strong) RecipePageViewController *recipeViewController;

@property (nonatomic, assign) NSUInteger currentCategoryIndex;

@end

@implementation BookViewController

#define kCategoryPageIndex  2

- (id)initWithBook:(CKBook*)book delegate:(id<BookViewControllerDelegate>)delegate {
    if (self = [super init]) {
        self.book = book;
        self.delegate = delegate;
        [self initScreen];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadData];
}

#pragma AFKPageFlipperDataSource methods

- (NSInteger)numberOfPagesForPageFlipper:(CookPageFlipper *) pageFlipper {
    return [self numberOfPages];
}

- (UIView *)viewForPage:(NSInteger)page inFlipper:(CookPageFlipper *)pageFlipper {
    return [self viewForPageAtIndex:page];
}

#pragma mark - BookViewDelegate

- (void)bookViewCloseRequested {
    [self.delegate bookViewControllerCloseRequested];
}

- (CGRect)bookViewBounds {
    return self.view.bounds;
}

- (UIEdgeInsets)bookViewInsets {
    return UIEdgeInsetsMake(20.0, 0.0, 10.0, 20.0);
}

- (BookViewController *)bookViewController {
    return self;
}

#pragma mark - BookViewDataSource

- (CKBook *)currentBook {
    return self.book;
}

- (CKRecipe *)currentRecipe {
    return self.recipe;
}

- (NSInteger)numberOfPages {
    NSInteger numPages = 0;
    numPages += 1;                                  // Contents page.
    if ([self.recipes count] > 0) {
        numPages += [self.categories count];        // Number of categories.
        numPages += [self.recipes count];           // Recipes page.
    }
    return numPages;
}

-(UIView *)viewForPageAtIndex:(NSInteger)pageIndex {
    UIView *view = nil;
    
    if (pageIndex == 1) {
        
        view = self.contentsViewController.view;
        
    } else {
        
        NSInteger categoryIndex = [self categoryIndexForPageIndex:pageIndex];
        if (categoryIndex != -1) {
            
            // Category page.
            NSString *category = [self.categories objectAtIndex:categoryIndex];
            [self.categoryViewController setCategory:category];
            view = self.categoryViewController.view;
            
        } else {
            
            // Recipe page.
            categoryIndex = [self currentCategoryIndexForPageIndex:pageIndex];
            NSInteger categoryPageIndex = [[self.categoryPageIndexes objectAtIndex:categoryIndex] integerValue];
            NSInteger recipeIndex = pageIndex - categoryPageIndex - 1;
            NSArray *recipes = [self.categoryRecipes objectAtIndex:categoryIndex];
            CKRecipe *recipe = [recipes objectAtIndex:recipeIndex];
            self.recipe = recipe;
            [self.recipeViewController setRecipe:recipe];
            view = self.recipeViewController.view;
        }
        
    }
    return view;
}

- (NSArray *)bookRecipes {
    return self.recipes;
}

- (NSArray *)bookCategories {
    return self.categories;
}

- (NSArray *)recipesForCategory:(NSString *)category {
    NSArray *recipes = nil;
    for (NSUInteger categoryIndex = 0; categoryIndex < [self.categories count]; categoryIndex++) {
        NSString *categoryName = [self.categories objectAtIndex:categoryIndex];
        if ([categoryName isEqualToString:category]) {
            recipes = [self.categoryRecipes objectAtIndex:categoryIndex];
            break;
        }
    }
    return recipes;
}

- (NSInteger)currentPageNumber {
    return self.pageFlipper.currentPage;
}

- (NSString *)bookViewCurrentCategory {
    return [self.categories objectAtIndex:self.currentCategoryIndex];
}

#pragma mark - Private methods

- (ContentsPageViewController *)contentsViewController {
    if (!_contentsViewController) {
        _contentsViewController = [[ContentsPageViewController alloc] initWithBookViewDelegate:self dataSource:self];
    }
    return _contentsViewController;
}

- (CategoryPageViewController *)categoryViewController {
    if (!_categoryViewController) {
        _categoryViewController = [[CategoryPageViewController alloc] initWithBookViewDelegate:self dataSource:self];
    }
    return _categoryViewController;
}

- (RecipeListViewController *)recipeListViewController
{
    if (!_recipeListViewController) {
        _recipeListViewController = [[RecipeListViewController alloc]init];
        _recipeListViewController.book = self.book;
        _recipeListViewController.bookViewDelegate = self;
    }
    return _recipeListViewController;
}

- (BookContentsViewController *)bookContentsViewController
{
    if (!_bookContentsViewController) {
        UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Cook" bundle:nil];
        _bookContentsViewController = [mainStoryBoard instantiateViewControllerWithIdentifier:@"BookContentsViewController"];
        _bookContentsViewController.bookViewDelegate = self;
    }
    return _bookContentsViewController;
}

- (BookCategoryViewController *)bookCategoryViewController
{
    if (!_bookCategoryViewController) {
        UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Cook" bundle:nil];
        _bookCategoryViewController = [mainStoryBoard instantiateViewControllerWithIdentifier:@"BookCategoryViewController"];
        _bookCategoryViewController.bookViewDelegate = self;
    }
    return _bookCategoryViewController;
}

- (RecipePageViewController *)recipeViewController
{
    if (!_recipeViewController) {
        _recipeViewController = [[RecipePageViewController alloc] initWithBookViewDelegate:self dataSource:self];
    }
    return _recipeViewController;
}

-(void) initScreen
{
   self.view.frame = CGRectMake(0.0f, 0.0f, 1024.0f, 748.0f);
   self.view.backgroundColor = [UIColor whiteColor];
   [self initFlipper];
}

- (void)initFlipper {
    self.pageFlipper = [[CookPageFlipper alloc] initWithFrame:self.view.frame];
    self.pageFlipper.dataSource = self;
    [self.view addSubview:self.pageFlipper];
}

- (void)loadData {
    [self.book listRecipesSuccess:^(NSArray *recipes) {
        
        self.currentCategoryIndex = 0;
        self.categoryRecipes = [NSMutableArray array];
        self.categories = [NSMutableArray array];
        
        for (CKRecipe *recipe in recipes) {
            
            if (![self.categoryRecipes containsObject:recipe.category.name]) {
                
                NSMutableArray *recipes = [NSMutableArray array];
                [recipes addObject:recipe];
                [self.categoryRecipes addObject:recipes];
                [self.categories addObject:recipe.category.name];
            } else {
                
                NSUInteger categoryIndex = [self.categoryRecipes indexOfObject:recipe.category.name];
                
                // Add recipe to existing category.
                NSMutableArray *recipes = [self.categoryRecipes objectAtIndex:categoryIndex];
                [recipes addObject:recipe];
                
            }
        }
        
        // Assign category page indexes.
        self.categoryPageIndexes = [NSMutableArray arrayWithCapacity:[self.categoryRecipes count]];
        for (NSUInteger categoryIndex = 0; categoryIndex < [self.categoryRecipes count]; categoryIndex++) {
            if (categoryIndex > 0) {
                NSInteger previousCategoryIndex = [[self.categoryPageIndexes lastObject] integerValue];
                NSArray *categoryRecipes = [self.categoryRecipes objectAtIndex:categoryIndex - 1];
                [self.categoryPageIndexes addObject:[NSNumber numberWithInteger:previousCategoryIndex + [categoryRecipes count] + 1]];
            } else {
                [self.categoryPageIndexes addObject:[NSNumber numberWithInteger:kCategoryPageIndex]];
            }
        }
        
        // Set recipes - important for observe (TODO remove this).
        self.recipes = recipes;
        
        // Reload page flipper.
        [self.pageFlipper reloadData];
        
    } failure:^(NSError *error) {
        DLog(@"Error %@", [error localizedDescription]);
    }];
}

- (BOOL)isCategoryPageForPageIndex:(NSUInteger)pageIndex {
    return ([self categoryIndexForPageIndex:pageIndex] != -1);
}

- (NSInteger)categoryIndexForPageIndex:(NSUInteger)pageIndex {
    return [self.categoryPageIndexes findIndexWithBlock:^BOOL(NSNumber *pageIndexNumber) {
        return ([pageIndexNumber integerValue] == pageIndex);
    }];
}

- (NSInteger)currentCategoryIndexForPageIndex:(NSInteger)pageIndex {
    NSInteger categoryIndex = -1;
    if (pageIndex > kCategoryPageIndex) {
        
        for (NSInteger index = 0; index < [self.categoryPageIndexes count]; index++) {
            NSNumber *categoryPageIndex = [self.categoryPageIndexes objectAtIndex:index];
            if (pageIndex > [categoryPageIndex integerValue]) {
                
                // Candidate category index
                categoryIndex = index;
                
            } else {
                
                // We've found it before, break now.
                break;
            }
        }
    }
    
    return categoryIndex;
}

- (NSInteger)categoryPageIndexForPageIndex:(NSUInteger)pageIndex {
    NSInteger categoryIndex = [self categoryIndexForPageIndex:pageIndex];
    if (categoryIndex != -1) {
        return [[self.categoryPageIndexes objectAtIndex:categoryIndex] integerValue];
    } else {
        return categoryIndex;
    }
}

- (NSInteger)recipeIndexForPageIndex:(NSInteger)pageIndex categoryIndex:(NSInteger)categoryIndex {
    return 0;
}

@end
