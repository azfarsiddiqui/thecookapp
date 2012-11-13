//
//  RecipeListViewController.m
//  recipe
//
//  Created by Jonny Sagorin on 9/25/12.
//  Copyright (c) 2012 Cook Pty Ltd. All rights reserved.
//

#import "RecipeListViewController.h"
#import "RecipeViewController.h"
#import "NewRecipeViewController.h"
#import "RecipeListCell.h"
#import "CKRecipe.h"
#import "ViewHelper.h"

#define kCellReuseIdentifier    @"RecipeListTableViewCell"
#define kCollectionViewSideSize 500.0f
#define kCollectionViewCellSize 200.0f

@interface RecipeListViewController()<UICollectionViewDelegate,UICollectionViewDataSource, NewRecipeViewDelegate, BookViewDelegate>
@property (nonatomic, retain) UICollectionView *collectionView;
@property (nonatomic, retain) NSArray *recipes;
@property (nonatomic, assign) BOOL refreshNeeded;
@end
@implementation RecipeListViewController

-(id)init
{
    if (self = [super init]) {
        [self initScreen];
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    DLog();
}

-(void)viewWillAppear:(BOOL)animated
{
    DLog();
    [super viewWillAppear:animated];
    [self loadData:NO];
}

#pragma mark - Private Methods

-(void)initScreen
{
    self.view.frame = CGRectMake(0.0f, 0.0f, 1024.0f, 748.0f);
    self.view.backgroundColor = [UIColor whiteColor];
    self.refreshNeeded = YES;
    UILabel *testLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 30.0f)];
    testLabel.textAlignment = NSTextAlignmentCenter;
    testLabel.text = @"My Book";
    testLabel.backgroundColor = [UIColor grayColor];
    [self.view addSubview:testLabel];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(kCollectionViewCellSize, kCollectionViewCellSize)];
    
    self.collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(260.0f, 150.0f, 640.0f,500.f)
                                            collectionViewLayout:flowLayout];
    self.collectionView.backgroundColor = [UIColor darkGrayColor];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.collectionView registerClass:[RecipeListCell class] forCellWithReuseIdentifier:kCellReuseIdentifier];
    
    [self.view addSubview:self.collectionView];
    

    UIButton *closeButton = [ViewHelper buttonWithImage:[UIImage imageNamed:@"btn_close"] target:self selector:@selector(closeTapped:)];
    closeButton.frame = CGRectMake(10.0f, 25.0f, closeButton.frame.size.width, closeButton.frame.size.height);
    [self.view addSubview:closeButton];

    UIButton *addRecipeButton = [ViewHelper buttonWithImage:[UIImage imageNamed:@"btn_create_recipe"] target:self selector:@selector(createRecipeTapped:)];
    addRecipeButton.frame = CGRectMake(10.0f, 150.0f, addRecipeButton.frame.size.width, addRecipeButton.frame.size.height);
    [self.view addSubview:addRecipeButton];
}

- (void)loadData:(BOOL)forceRefresh {
    DLog();
    //for now, refresh data once unless a force refresh is requested.
    if (forceRefresh || self.refreshNeeded) {
        [self.book listRecipesSuccess:^(NSArray *recipes) {
            self.recipes = recipes;
            [self.collectionView reloadData];
            self.refreshNeeded = NO;
        } failure:^(NSError *error) {
            DLog(@"%@", [error description]);
        }];
    }
}


#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.recipes count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    RecipeListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellReuseIdentifier forIndexPath:indexPath];
    CKRecipe *recipe = [self.recipes objectAtIndex:indexPath.row];
    [cell configure:recipe];
    
    return cell;

}

#pragma mark - UICollectionViewDelegate

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    DLog();
    CKRecipe *recipe = [self.recipes objectAtIndex:indexPath.row];
    
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Cook" bundle:nil];
    RecipeViewController *recipeViewController = [mainStoryBoard instantiateViewControllerWithIdentifier:@"RecipeViewController"];
    recipeViewController.recipe = recipe;
//    recipeViewController.book = self.book;
    recipeViewController.delegate = self;
    [self presentViewController:recipeViewController animated:YES completion:nil];
}

#pragma mark - NewRecipeVieDelegate

-(void)closeRequested
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)recipeCreated
{
    [self loadData:YES];
    [self closeRequested];
}

#pragma mark - BookViewDelegate
//TEMP delegate implementation for navgiation purposes only
-(void)bookViewCloseRequested
{
    DLog();
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (CGRect)bookViewBounds {
    return self.view.bounds;
}

- (UIEdgeInsets)bookViewInsets {
    return UIEdgeInsetsMake(20.0, 0.0, 0.0, 20.0);
}

-(BookViewController *)bookViewController
{
    return nil;
}

-(void)bookViewReloadRequested
{
    
}

#pragma mark - Action buttons
-(void) createRecipeTapped:(UIButton*)button
{
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Cook" bundle:nil];
    NewRecipeViewController *newRecipeViewVC = [mainStoryBoard instantiateViewControllerWithIdentifier:@"NewRecipeViewController"];
    newRecipeViewVC.delegate = self;
    newRecipeViewVC.book = self.book;
    [self presentViewController:newRecipeViewVC animated:YES completion:nil];
    
}

-(void) closeTapped:(UIButton*)button
{
    [self.bookViewDelegate bookViewCloseRequested];
}

@end
