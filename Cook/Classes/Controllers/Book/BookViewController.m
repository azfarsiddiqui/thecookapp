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
#import "CKUIHelper.h"

@interface BookViewController ()<AFKPageFlipperDataSource, BookViewDelegate, BookViewDataSource>

@property (nonatomic, strong) AFKPageFlipper *pageFlipper;
@property (nonatomic, strong) CKBook *book;
@property (nonatomic, assign) id<BookViewControllerDelegate> delegate;
@property (nonatomic, strong) RecipeListViewController *recipeListViewController;
@property (nonatomic, strong) RecipeViewController *recipeViewController;
@property (nonatomic, strong) BookContentsViewController *bookContentsViewController;
@property (nonatomic, strong) BookCategoryViewController *bookCategoryViewController;

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

#pragma AFKPageFlipperDataSource methods

- (NSInteger)numberOfPagesForPageFlipper:(CookPageFlipper *) pageFlipper {
    return [self numberOfPagesInBook];
}

- (UIView *)viewForPage:(NSInteger)page inFlipper:(CookPageFlipper *)pageFlipper {
    DLog(@"view for page %i", page);
    return [self viewForPageAtIndex:page];
}

#pragma mark - BookViewDelegate

- (void)bookViewCloseRequested {
    [self.delegate bookViewControllerCloseRequested];
}

#pragma mark - BookViewDatasource
-(NSInteger)numberOfPagesInBook
{
    //    NSInteger numPages = 0;
    //    numPages += 1;                          // Profile page
    //    numPages += [self numCategories];
    //    numPages += [self numRecipes];
    return 4;
}

-(UIView *)viewForPageAtIndex:(NSInteger)pageIndex
{
    UIView *view = nil;
    switch (pageIndex) {
        case 1:
            //recipe list
            view = self.recipeListViewController.view;
            break;
        case 2:
            //book contents
            view = self.bookContentsViewController.view;
            break;
        case 3:
            view = self.bookCategoryViewController.view;
            break;
        case 4: 
            view = self.recipeViewController.view;
            break;
        default:
            break;
    }
    return view;
}
#pragma mark - Private methods

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
        _recipeViewController.bookViewDelegate = self;
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
    self.pageFlipper = [[AFKPageFlipper alloc] initWithFrame:self.view.frame];
    //    pageFlipper.autoresizingMask = UIViewAutoresizingNone;
    self.pageFlipper.dataSource = self;
    [self.view addSubview:self.pageFlipper];
    //    [self.backgroundView addSubview:pageFlipper];
    //    [pageFlipper release];
    //}
}

@end
