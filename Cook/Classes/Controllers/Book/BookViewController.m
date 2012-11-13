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
        
    } else if ([self isCategoryPageForPageIndex:pageIndex]) {
        
        // Category page.
        self.currentCategoryIndex = pageIndex - kCategoryPageIndex;
        [self.categoryViewController setCategory:[self bookViewCurrentCategory]];
        view = self.categoryViewController.view;
        
    } else {
        
        // Get the recipe for the current page.
        NSUInteger recipeIndex = pageIndex - self.currentCategoryIndex - kCategoryPageIndex - 1;
        NSArray *recipes = [self.categoryRecipes objectAtIndex:self.currentCategoryIndex];
        CKRecipe *recipe = [recipes objectAtIndex:recipeIndex];
        self.recipe = recipe;
        [self.recipeViewController setRecipe:recipe];
        view = self.recipeViewController.view;
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
            if ([self.categoryRecipes containsObject:recipe.category.name]) {
                NSMutableArray *recipes = [self.categoryRecipes objectAtIndex:[self.categoryRecipes indexOfObject:recipe.category.name]];
                [recipes addObject:recipe];
            } else {
                NSMutableArray *recipes = [NSMutableArray array];
                [recipes addObject:recipe];
                [self.categoryRecipes addObject:recipes];
                [self.categories addObject:recipe.category.name];
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
    BOOL categoryPage = NO;
    
    NSUInteger categoryPageIndex = pageIndex - kCategoryPageIndex;
    if (categoryPageIndex == 0) {
        categoryPage = YES;
    } else {
        for (NSUInteger categoryIndex = 0; categoryIndex < [self.categoryRecipes count]; categoryIndex++) {
            NSArray *recipes = [self.categoryRecipes objectAtIndex:categoryIndex];
            NSUInteger numRecipes = [recipes count];
            NSUInteger nextCategoryIndex = numRecipes + 1;
            if (categoryPageIndex == nextCategoryIndex) {
                categoryPage = YES;
                break;
            }
        }
    }
    return categoryPage;
}

@end
