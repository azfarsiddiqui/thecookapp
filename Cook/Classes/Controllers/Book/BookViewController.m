//
//  BookViewController.m
//  Cook
//
//  Created by Jonny Sagorin on 10/10/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookViewController.h"
#import "RecipeListViewController.h"
#import "CookPageFlipper.h"
#import "CKUIHelper.h"

@interface BookViewController ()<AFKPageFlipperDataSource, BookViewDelegate>
@property (nonatomic, strong) AFKPageFlipper *pageFlipper;
@property (nonatomic,strong) CKBook *book;
@property (nonatomic,strong) RecipeListViewController *recipeListViewController;
@end

@implementation BookViewController
@synthesize recipeListViewController=_recipeListViewController;
-(id)initWithBook:(CKBook *)book
{
    if (self = [super init]) {
        self.book = book;
        [self initScreen];
    }
    return self;
}

#pragma AFKPageFlipperDataSource methods

- (NSInteger)numberOfPagesForPageFlipper:(CookPageFlipper *) pageFlipper {
    //    NSInteger numPages = 0;
    //    numPages += 1;                          // Profile page
    //    numPages += [self numCategories];
    //    numPages += [self numRecipes];
    return 1;
}

- (UIView *)viewForPage:(NSInteger)page inFlipper:(CookPageFlipper *)pageFlipper {
    DLog(@"view for page %i", page);
    UIView *view = nil;
    switch (page) {
        case 1:
            //recipe list
            view = self.recipeListViewController.view;
            break;
        default:
            break;
    }
    return view;
    //
    //    PageViewController *pageViewController = [self pageViewControllerForPage:page];
    //    self.currentPageViewController = pageViewController;
    //    [pageViewController pageDidShow:YES];
    //
    //    UIView *pageView = pageViewController.view;
    //    [self resetPageView:pageView];
    //    
    //    return pageView;
    return nil;
}

#pragma mark - Action delegates
-(void) closeRequested
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
