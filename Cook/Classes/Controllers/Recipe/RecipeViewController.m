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
@property(nonatomic,strong) IBOutlet UIProgressView *progressView;
@property(nonatomic,strong) IBOutlet UILabel *uploadProgressLabel;
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationIsLandscape(interfaceOrientation));
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
        
        [self showPageComponents:YES];
        self.selectedCategory = self.recipe.category;
        [self.categoryListViewController selectCategoryWithName:self.selectedCategory.name];
    }
}

#pragma mark - Action methods

-(IBAction)closeButtonTapped:(UIButton*)button
{
    [self.editableViews each:^(UIEditableView *view) {
        [view makeEditable:NO];
    }];
    
    [self showPageComponents:NO];
    [self showBookmarkView];
}

-(IBAction)saveButtonTapped:(UIButton*)button
{
    if ([self validate]) {
        button.enabled = NO;
        self.recipe.category = self.selectedCategory;
        self.recipe.name = self.recipeNameView.recipeName;
        self.recipe.description = self.cookingDirectionsView.directions;
        if (self.recipeImageView.imageEdited) {
            self.recipe.image = self.recipeImageView.recipeImage;
        }
        self.recipe.numServes = self.servesView.serves;
        self.recipe.cookingTimeInSeconds = self.cookingTimeView.cookingTimeInSeconds;
        self.recipe.recipeViewImageContentOffset = self.recipeImageView.scrollViewContentOffset;
        self.recipe.ingredients = [NSArray arrayWithArray:self.ingredientsView.ingredients];
        
        self.uploadProgressLabel.hidden = NO;

        [self.recipe saveWithSuccess:^{
            [self closeButtonTapped:nil];
            button.enabled = YES;
        } failure:^(NSError *error) {
            DLog(@"An error occurred: %@", [error description]);
            [self displayMessage:[error description]];
            button.enabled = YES;
        } imageUploadProgress:^(int percentDone) {
            float percentage = percentDone/100.0f;
            [self.progressView setProgress:percentage animated:YES];
            self.uploadProgressLabel.text = [NSString stringWithFormat:@"Uploading (%i%%)",percentDone];
        }];
    }
}

#pragma mark - private methods

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


-(void)showPageComponents:(BOOL)show
{
    [self showPageButtons:show];
    [self showPageNumber:show];
    
    self.closeButton.hidden = !show;
    self.saveButton.hidden = !show;
    self.progressView.hidden = !show;
    
    self.facebookUserView.hidden = !show;
    [self.categoryListViewController show:!show];
    
}

-(BOOL)validate
{
    if ([self nullOrEmpty:self.recipeNameView.recipeName]) {
        [self displayMessage:@"Recipe Name is blank"];
        return false;
    }
    
    if ([self nullOrEmpty:self.cookingDirectionsView.directions]) {
        [self displayMessage:@"Recipe Method is blank"];
        return false;
    }
    
    if (!self.selectedCategory) {
        [self displayMessage:@"Please select a food category"];
        return false;
    }
    return true;
}

-(BOOL)nullOrEmpty:(NSString*)input
{
    NSString *trimmedString = [input stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return (!input || [@"" isEqualToString:trimmedString]);
}

-(void)displayMessage:(NSString *)message
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:message
                                                       delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alertView show];
}

#pragma mark - CategoryListViewDelegate
-(void)didSelectCategory:(Category*)category
{
    self.selectedCategory = category;

}

@end
