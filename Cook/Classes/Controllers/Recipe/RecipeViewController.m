//
//  RecipeViewController.m
//  Cook
//
//  Created by Jonny Sagorin on 10/12/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "RecipeViewController.h"
#import "CategoryListViewController.h"
#import "NSArray+Enumerable.h"
#import "Ingredient.h"
#import "FacebookUserView.h"
#import "ViewHelper.h"
#import "CKUser.h"
#import "RecipeNameView.h"
#import "RecipeImageView.h"
#import "IngredientsView.h"
#import "ServesView.h"
#import "CookingDirectionsView.h"
#import "CookingTimeView.h"
#import "UIEditableView.h"
#import "NSArray+Enumerable.h"
#import "Theme.h"

#define kImageViewTag   1122334455
@interface RecipeViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, CategoryListViewDelegate>
@property(nonatomic,strong) IBOutlet FacebookUserView *facebookUserView;
@property(nonatomic,strong) IBOutlet RecipeNameView *recipeNameView;
@property(nonatomic,strong) IBOutlet RecipeImageView *recipeImageView;
@property(nonatomic,strong) IBOutlet IngredientsView *ingredientsView;
@property(nonatomic,strong) IBOutlet CookingDirectionsView *cookingDirectionsView;
@property(nonatomic,strong) IBOutlet ServesView *servesView;
@property(nonatomic,strong) IBOutlet CookingTimeView *cookingTimeView;

@property(nonatomic,strong) IBOutlet UIButton *closeButton;
@property(nonatomic,strong) IBOutlet UIButton *saveButton;

@property(nonatomic,strong) IBOutletCollection(UIEditableView) NSArray *editableViews;

@property (nonatomic,strong) CategoryListViewController *categoryListViewController;

//data
@property (nonatomic,strong) Category *selectedCategory;
@property (nonatomic,strong) NSArray *categories;
@end

@implementation RecipeViewController

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    DLog();
    [self refreshData];
    [self showContentsButton:YES];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self style];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - overridden methods
-(NSArray *)pageOptionIcons
{
    return @[@"cook_book_icon_editpage.png"];
}

-(NSArray *)pageOptionLabels
{
    return @[@"EDIT"];
}

-(NSString *)pageNumberPrefixString
{
    return self.recipe.category ? self.recipe.category.name : nil;
}

-(void)didSelectCustomOptionAtIndex:(NSInteger)optionIndex
{
    //custom options
    if (optionIndex == 0) {
        DLog("EDIT");
        [self.editableViews each:^(UIEditableView *view) {
            [view makeEditable:YES];
        }];
        [self showPageButtons:NO];
        [self togglePageNumber:NO];
        self.facebookUserView.hidden = YES;
        [self toggleSaveCloseButtons:YES];
        Category *category = self.recipe.category;
        [self.categoryListViewController selectCategoryWithName:category.name];
        [self.categoryListViewController show:YES];
    }
}

#pragma mark - Action methods

-(IBAction)closeButtonTapped:(UIButton*)button
{
    [self.editableViews each:^(UIEditableView *view) {
        [view makeEditable:NO];
    }];
    [self showPageButtons:YES];
    [self togglePageNumber:YES];
    [self toggleSaveCloseButtons:NO];
    self.facebookUserView.hidden = NO;
    [self showBookmarkView];
    [self.categoryListViewController show:NO];
}

-(IBAction)saveButtonTapped:(UIButton*)button
{
    
}

#pragma mark - private methods

-(void)style
{
    
}

-(void)refreshData
{
    DLog(@"refreshing data");
    [self.recipeNameView setRecipeName:self.recipe.name];
    [self.facebookUserView setUser:[[self.dataSource currentBook] user]];

    if ([self.recipe.ingredients count] > 0) {
        self.ingredientsView.ingredients = [NSMutableArray arrayWithArray:self.recipe.ingredients];
        
    }
    if (self.recipe.description) {
        self.cookingDirectionsView.directions = self.recipe.description;
    }
    if (self.recipe.numServes > 0) {
        self.servesView.serves = self.recipe.numServes;
    }

    if (self.recipe.cookingTimeInSeconds > 0) {
        self.cookingTimeView.cookingTimeInSeconds = self.recipe.cookingTimeInSeconds;
    }

    self.recipeImageView.recipe = self.recipe;
    self.recipeImageView.parentViewController = self;
    
    //data needed by categories selection
    [Category listCategories:^(NSArray *results) {
        self.categories = results;
        [self configCategoriesList];
    } failure:^(NSError *error) {
        DLog(@"Could not retrieve categories: %@", [error description]);
    }];

}

-(void) configCategoriesList
{
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Cook" bundle:nil];
    self.categoryListViewController = [mainStoryBoard instantiateViewControllerWithIdentifier:@"CategoryListViewController"];
    self.categoryListViewController.view.frame = CGRectMake(100.0f, 6.0f, 830.f, 66.0f);
    self.categoryListViewController.delegate = self;
    self.categoryListViewController.categories = self.categories;
    [self.categoryListViewController show:NO];
    [self.view addSubview:self.categoryListViewController.view];
    
}

-(void) toggleSaveCloseButtons:(BOOL)show
{
    self.closeButton.hidden = !show;
    self.saveButton.hidden = !show;

}

#pragma mark - CategoryListViewDelegate
-(void)didSelectCategory:(Category*)category
{
    self.selectedCategory = category;

}

@end
