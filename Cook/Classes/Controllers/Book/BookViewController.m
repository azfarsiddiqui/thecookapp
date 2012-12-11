//
//  BookViewController.m
//  Cook
//
//  Created by Jonny Sagorin on 10/10/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookViewController.h"
#import "RecipeViewController.h"
#import "ViewHelper.h"
#import "ContentsPageViewController.h"
#import "CKRecipe.h"
#import "MRCEnumerable.h"
#import "RecipeLike.h"
#import "CategoryPageViewController.h"
#import "RecipeViewController.h"
#import "BookProfilePageViewController.h"
#import "MPFlipViewController.h"
#define kContentPageIndex  2
#define kBookProfilePageIndex 1

@interface BookViewController () <BookViewDelegate, BookViewDataSource, MPFlipViewControllerDataSource, MPFlipViewControllerDelegate>

//ui
@property (nonatomic, assign) id<BookViewControllerDelegate> delegate;
@property (nonatomic, assign) id<PageViewDelegate> pageViewDelegate;
@property (nonatomic, strong) ContentsPageViewController *contentsViewController;
@property (nonatomic, strong) CategoryPageViewController *categoryViewController;
@property (nonatomic, strong) BookProfilePageViewController *bookProfilePageViewController;
@property (nonatomic, strong) MPFlipViewController *flipViewController;

//data
@property (nonatomic, strong) CKBook *book;
@property (nonatomic, strong) CKRecipe *currentRecipe;
@property (nonatomic, strong) NSArray *bookRecipes;
@property (nonatomic, strong) NSArray *userLikes;
@property (nonatomic, strong) NSMutableArray *categoryNames;
@property (nonatomic, strong) NSMutableDictionary *categoryRecipes;
@property (nonatomic, strong) NSMutableArray *categoryPageIndexes;
@property (nonatomic, assign) NSInteger currentPageIndex;
@property (nonatomic, assign) NSInteger tentativeIndex;
@property (nonatomic, assign) NSUInteger currentCategoryIndex;

@end

@implementation BookViewController

- (id)initWithBook:(CKBook*)book delegate:(id<BookViewControllerDelegate>)delegate {
    if (self = [super init]) {
        self.book = book;
        self.delegate = delegate;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initScreen];
    [self loadData];
}

#pragma mark - BookViewDelegate

- (void)bookViewCloseRequested {
    [self.delegate bookViewControllerCloseRequested];
}

-(void)contentViewRequested
{
    self.currentPageIndex = kContentPageIndex + 1;
    [self.flipViewController gotoPreviousPage];
}

-(void)requestedPageIndex:(NSUInteger)pageIndex
{
    self.currentPageIndex = pageIndex-1;
    [self.flipViewController gotoNextPage];
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

- (void)bookViewReloadRequested {
    DLog();
    self.bookRecipes = nil;
    [self loadData];
}

- (UIViewController *)viewControllerForPageIndex:(NSInteger)pageIndex {
    UIViewController *viewController = nil;
    UIView *view = nil;
    
    switch (pageIndex) {
        case kBookProfilePageIndex: {
            // Contents page.
            view = self.bookProfilePageViewController.view;
            viewController = self.bookProfilePageViewController;
            self.pageViewDelegate = self.bookProfilePageViewController;
            break;
        }
        case kContentPageIndex: {
            // Contents page.
            view = self.contentsViewController.view;
            viewController = self.contentsViewController;
            self.pageViewDelegate = self.contentsViewController;
            break;
        }
        default: {
            NSInteger categoryIndex = [self categoryIndexForPageIndex:pageIndex];
            if (categoryIndex != -1) {
                // Category page.
                NSString *categoryName = [self.categoryNames objectAtIndex:categoryIndex];
                view = self.categoryViewController.view;    // TODO Fix this to make sure viewDidLoad called.
                viewController = self.categoryViewController;
                [self.categoryViewController loadCategory:categoryName];
                view = self.categoryViewController.view;
                self.pageViewDelegate = self.categoryViewController;
            } else {
                
                // Recipe page.
                categoryIndex = [self currentCategoryIndexForPageIndex:pageIndex];
                NSInteger categoryPageIndex = [[self.categoryPageIndexes objectAtIndex:categoryIndex] integerValue];
                NSInteger recipeIndex = pageIndex - categoryPageIndex - 1;
                NSString *categoryName = [self.categoryNames objectAtIndex:categoryIndex];
                NSArray *recipes = [self.categoryRecipes objectForKey:categoryName];
                CKRecipe *recipe = [recipes objectAtIndex:recipeIndex];
                self.currentRecipe = recipe;
                RecipeViewController *recipeViewController = [self newRecipeViewController];
                recipeViewController.recipe = recipe;
                viewController = recipeViewController;
                view = recipeViewController.view;
                self.pageViewDelegate = recipeViewController;
                break;
            }
        }
    }
    if (self.pageViewDelegate) {
        [self.pageViewDelegate hidePageNumberAndDisplayLoading];
    }
    return viewController;
}

#pragma mark - BookViewDataSource (context-related)

- (CKRecipe *)currentRecipe {
    return self.currentRecipe;
}

- (CKBook *)currentBook {
    return self.book;
}

- (NSInteger)currentPageNumber {
    return self.currentPageIndex;
}

#pragma mark - BookViewDataSource (book-related)

- (NSUInteger)numberOfPages {
    NSInteger numPages = 0;
    numPages += 2;                                  // Contents page and Profile page
    if ([self.bookRecipes count] > 0) {
        numPages += [self.categoryNames count];        // Number of categories.
        numPages += [self.bookRecipes count];           // Recipes page.
    }
    return numPages;
}

- (UIView *)viewForPageAtIndex:(NSUInteger)pageIndex {
    UIViewController *viewController = [self viewControllerForPageIndex:pageIndex];
    return viewController.view;
}

- (NSArray *)recipesInBook {
    return self.bookRecipes;
}


#pragma mark - BookviewDataSource (page-contents/section)
-(NSUInteger)sectionsInPageContent {
    return [self.categoryNames count] + ([self.userLikes count] > 0 ? 1: 0);
}

-(NSString *)sectionNameForPageContentAtIndex:(NSUInteger)sectionIndex
{
    if (([self.userLikes count] > 0) && (sectionIndex == [self.categoryNames count])) {
        return  @"LIKES";
    } else {
        return [self.categoryNames objectAtIndex:sectionIndex];
    }
}

-(NSUInteger)pageNumForSectionName:(NSString *)sectionName;
{
    if ([sectionName isEqualToString:@"LIKES"]) {
        return [self pageNumForLikesSection];
    }  else {
        return [self pageNumForCategoryName:sectionName];
    }
}

-(NSUInteger)pageNumForRecipe:(CKRecipe*)recipe
{
    NSString *categoryName = recipe.category.name;
    NSArray *recipesForCategory = [self recipesForCategory:categoryName];
    NSUInteger i = 0;
    for (CKRecipe *categoryRecipe in recipesForCategory) {
        if ([categoryRecipe isEqual:recipe]) {
            DLog(@"found recipe! i is %i", i);
            break;
        }
        i++;
    }
    
    return [self pageNumForRecipeAtCategoryIndex:i forCategoryName:categoryName];
}

#pragma mark - BookviewDataSource (category-related)
- (NSArray *)recipesForCategory:(NSString *)categoryName {
    NSArray *recipes = nil;
    NSUInteger categoryIndex = [self.categoryNames indexOfObject:categoryName];
    if (categoryIndex != NSNotFound) {
        recipes = [self.categoryRecipes objectForKey:categoryName];
    }
    return recipes;
}

- (NSUInteger)numRecipesInCategory:(NSString *)categoryName {
    NSInteger recipeCount = 0;
    NSInteger categoryIndex = [self.categoryNames indexOfObject:categoryName];
    if (categoryIndex != NSNotFound) {
        recipeCount = [[self.categoryRecipes objectForKey:categoryName] count];
    }
    return recipeCount;
}

-(NSUInteger)pageNumForRecipeAtCategoryIndex:(NSInteger)recipeIndex forCategoryName:(NSString *)categoryName
{
    return [self pageNumForCategoryName:categoryName] + recipeIndex + 1;
}

-(NSUInteger)pageNumForCategoryName:(NSString *)categoryName
{
    NSInteger categoryIndex = [self.categoryNames indexOfObject:categoryName];
    NSNumber *pageCategoryIndex = [self.categoryPageIndexes objectAtIndex:categoryIndex];
    return [pageCategoryIndex intValue];
}

-(NSUInteger)pageNumForLikesSection
{
    //page number for last category +  number of pages in category
    NSString *lastCategoryName = [self.categoryNames objectAtIndex:[self.categoryNames count]-1];
    NSUInteger lastCategoryPageNum = [self pageNumForCategoryName:lastCategoryName];
    NSUInteger numRecipesInLastCategory = [self numRecipesInCategory:lastCategoryName];
    
    return lastCategoryPageNum + numRecipesInLastCategory + 1;
}

#pragma mark - MPFlipViewControllerDataSource methods

- (UIViewController *)flipViewController:(MPFlipViewController *)flipViewController viewControllerBeforeViewController:(UIViewController *)viewController {
	NSInteger index = self.currentPageIndex;
	index--;
	if (index < kBookProfilePageIndex) {
		return nil; // reached beginning, don't wrap
    }
    
	self.tentativeIndex = index;
    
	return [self viewControllerForPageIndex:index];
}

- (UIViewController *)flipViewController:(MPFlipViewController *)flipViewController
       viewControllerAfterViewController:(UIViewController *)viewController {
	NSInteger index = self.currentPageIndex;
	index++;
	if (index > [self numberOfPages]) {
		return nil; // reached end, don't wrap
    }
	self.tentativeIndex = index;
	return [self viewControllerForPageIndex:index];
}

#pragma mark - MPFlipViewControllerDelegate protocol

- (void)flipViewController:(MPFlipViewController *)flipViewController didFinishAnimating:(BOOL)finished
    previousViewController:(UIViewController *)previousViewController transitionCompleted:(BOOL)completed {
	if (completed) {
		self.currentPageIndex = self.tentativeIndex;
        if (self.pageViewDelegate) {
            [self.pageViewDelegate showPageNumberAndHideLoading];
        }
        DLog(@"updated page index to %i", self.currentPageIndex);
	}
}

- (MPFlipViewControllerOrientation)flipViewController:(MPFlipViewController *)flipViewController
                   orientationForInterfaceOrientation:(UIInterfaceOrientation)orientation {
    return MPFlipViewControllerOrientationHorizontal;
}

#pragma mark - Private methods

- (ContentsPageViewController *)contentsViewController {
    if (!_contentsViewController) {
        _contentsViewController = [[ContentsPageViewController alloc] initWithBookViewDelegate:self dataSource:self withButtonStyle:NavigationButtonStyleWhite];
    }
    return _contentsViewController;
}

- (CategoryPageViewController *)categoryViewController {
    if (!_categoryViewController) {
        _categoryViewController = [[CategoryPageViewController alloc] initWithBookViewDelegate:self dataSource:self withButtonStyle:NavigationButtonStyleGray];
    }
    return _categoryViewController;
}

-(BookProfilePageViewController *)bookProfilePageViewController
{
    if (!_bookProfilePageViewController) {
        UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Cook" bundle:nil];
        _bookProfilePageViewController = [mainStoryBoard instantiateViewControllerWithIdentifier:@"BookProfilePageViewController"];
        _bookProfilePageViewController.delegate = self;
        _bookProfilePageViewController.dataSource = self;
    }
    return _bookProfilePageViewController;
}

- (RecipeViewController *)newRecipeViewController
{
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Cook" bundle:nil];
    RecipeViewController * recipeViewController = [mainStoryBoard instantiateViewControllerWithIdentifier:@"RecipeViewController"];
    recipeViewController.delegate = self;
    recipeViewController.dataSource = self;
    return recipeViewController;
}

-(void) initScreen
{
   self.view.frame = CGRectMake(0.0f, 0.0f, 1024.0f, 748.0f);
   self.view.backgroundColor = [UIColor whiteColor];
   [self initFlipper];
}

- (void)initFlipper {
    self.currentPageIndex = kContentPageIndex;
    self.flipViewController = [[MPFlipViewController alloc] initWithOrientation:MPFlipViewControllerOrientationHorizontal];
    self.flipViewController.delegate = self;
    self.flipViewController.dataSource = self;
    self.flipViewController.view.frame = self.view.bounds;
	[self addChildViewController:self.flipViewController];
	[self.view addSubview:self.flipViewController.view];
	[self.flipViewController didMoveToParentViewController:self];
    [self.flipViewController setViewController:self.contentsViewController direction:MPFlipViewControllerDirectionForward animated:NO completion:nil];
	
	// Add the page view controller's gesture recognizers to the book view controller's view so that the gestures are started more easily.
	self.view.gestureRecognizers = self.flipViewController.gestureRecognizers;
}

- (void)loadData {
    [self.book fetchRecipesSuccess:^(NSArray *recipes) {
        
        self.currentCategoryIndex = 0;
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
        
        // Assign category page indexes.
        NSUInteger categoryNameCount = [self.categoryNames count];
        self.categoryPageIndexes = [NSMutableArray arrayWithCapacity:categoryNameCount];
        for (NSUInteger categoryIndex = 0; categoryIndex < categoryNameCount; categoryIndex++) {
            if (categoryIndex > 0) {
                NSInteger previousCategoryIndex = [[self.categoryPageIndexes lastObject] integerValue];
                NSString *categoryName = [self.categoryNames objectAtIndex:categoryIndex - 1];
                NSArray *categoryRecipes = [self.categoryRecipes objectForKey:categoryName];
                [self.categoryPageIndexes addObject:[NSNumber numberWithInteger:previousCategoryIndex + [categoryRecipes count] + 1]];
            } else {
                [self.categoryPageIndexes addObject:[NSNumber numberWithInteger:kContentPageIndex+1]];
            }
        }
        
        // Set recipes - important for observe (TODO remove this).
        self.bookRecipes = recipes;

        //fetch likes for user
        [RecipeLike fetchRecipeLikesForUser:[CKUser currentUser] withSuccess:^(NSArray *results) {
             self.userLikes = results;
            [self.contentsViewController refreshData];
        } failure:^(NSError *error) {
            DLog(@"fetch recipe likes for user returned an error: %@", [error description]);
            [self.contentsViewController refreshData];
        }];

        
    } failure:^(NSError *error) {
        DLog(@"Error %@", [error localizedDescription]);
    }];
}

- (NSInteger)categoryIndexForPageIndex:(NSUInteger)pageIndex {
    return [self.categoryPageIndexes findIndexWithBlock:^BOOL(NSNumber *pageIndexNumber) {
        return ([pageIndexNumber integerValue] == pageIndex);
    }];
}

- (NSInteger)currentCategoryIndexForPageIndex:(NSInteger)pageIndex {
    NSInteger categoryIndex = -1;
    if (pageIndex > kContentPageIndex) {
        
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

@end
