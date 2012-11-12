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

@interface BookViewController ()<AFKPageFlipperDataSource, BookViewDelegate, BookViewDataSource>

@property (nonatomic, strong) CookPageFlipper *pageFlipper;
@property (nonatomic, strong) CKBook *book;
@property (nonatomic, strong) NSArray *recipes;
@property (nonatomic, assign) id<BookViewControllerDelegate> delegate;
@property (nonatomic, strong) RecipeListViewController *recipeListViewController;
@property (nonatomic, strong) RecipeViewController *recipeViewController;
@property (nonatomic, strong) BookContentsViewController *bookContentsViewController;
@property (nonatomic, strong) BookCategoryViewController *bookCategoryViewController;
@property (nonatomic, strong) ContentsPageViewController *contentsViewController;

@end

@implementation BookViewController

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

- (NSInteger)numberOfPages {
    NSInteger numPages = 0;
    numPages += 1;                          // Contents page.
    if ([self.recipes count] > 0) {
        numPages += [self.book numCategories];  // Categories page.
        numPages += [self.recipes count];       // Recipes page.
    }
    return numPages;
}

-(UIView *)viewForPageAtIndex:(NSInteger)pageIndex {
    UIView *view = nil;
    switch (pageIndex) {
        case 1:
//            view = self.contentsViewController.view;
              view = self.recipeListViewController.view;
            break;
        case 2:
            view = self.recipeListViewController.view;
            break;
        default:
            break;
    }
    return view;
}

- (NSArray *)bookRecipes {
    return self.recipes;
}

- (NSInteger)currentPageNumber {
    return self.pageFlipper.currentPage;
}

#pragma mark - Private methods

- (ContentsPageViewController *)contentsViewController {
    if (!_contentsViewController) {
        _contentsViewController = [[ContentsPageViewController alloc] initWithBookViewDelegate:self dataSource:self];
    }
    return _contentsViewController;
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

- (RecipeViewController *)recipeViewController
{
    if (!_recipeViewController) {
        UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Cook" bundle:nil];
        _recipeViewController = [mainStoryBoard instantiateViewControllerWithIdentifier:@"RecipeViewController"];
        _recipeViewController.delegate = self;
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
    //    CGRect pageFrame = CGRectMake(kPageEdgeInsets.left,
    //                                  kPageEdgeInsets.top,
    //                                  self.backgroundView.frame.size.width - kPageEdgeInsets.left - kPageEdgeInsets.right,
    //                                  self.backgroundView.frame.size.height - kPageEdgeInsets.top - kPageEdgeInsets.bottom);
    //    DLog(@"FLIPPER FRAME: %@", NSStringFromCGRect(pageFrame));
    self.pageFlipper = [[CookPageFlipper alloc] initWithFrame:self.view.frame];
    //    pageFlipper.autoresizingMask = UIViewAutoresizingNone;
    self.pageFlipper.dataSource = self;
    [self.view addSubview:self.pageFlipper];
}

- (void)loadData {
    [self.book listRecipesSuccess:^(NSArray *recipes) {
        
        self.recipes = recipes;
        
        // Reload page flipper.
        [self.pageFlipper reloadData];
        
    } failure:^(NSError *error) {
        DLog(@"Error %@", [error localizedDescription]);
    }];
}

- (void)resetPageView:(UIView *)pageView {
    
    // Override AFKPageFlipper behaviour.
    pageView.hidden = NO;
    pageView.frame = self.pageFlipper.bounds;
}

@end
