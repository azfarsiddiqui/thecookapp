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
#import "RecipeLike.h"
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
@property(nonatomic,strong) IBOutlet UIButton *likeButton;
@property(nonatomic,strong) IBOutlet UIProgressView *progressView;
@property(nonatomic,strong) IBOutlet UILabel *uploadProgressLabel;
@property(nonatomic,strong) IBOutlet UILabel *likesLabel;
@property(nonatomic,strong) IBOutletCollection(UIEditableView) NSArray *editableViews;

@property (nonatomic,strong) CategoryListViewController *categoryListViewController;

//data
@property (nonatomic,strong) Category *selectedCategory;
@property (nonatomic,strong) NSArray *categories;
@property (nonatomic,assign) BOOL recipeLiked;
@end

@implementation RecipeViewController

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    DLog();
    [self refreshData];
    [self showContentsButton:YES];
    [self configLikesLabel];
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
        [self configPageComponentsForEditing:YES];
        self.selectedCategory = self.recipe.category;
        self.categoryListViewController.selectedCategoryName = self.selectedCategory.name;
    }
}

#pragma mark - Action methods

-(IBAction)closeButtonTapped:(UIButton*)button
{
    [self.editableViews each:^(UIEditableView *view) {
        [view makeEditable:NO];
    }];
    
    [self configPageComponentsForEditing:NO];
    [self showBookmarkView];
}

-(IBAction)saveButtonTapped:(UIButton*)button
{
    if ([self validate]) {
        button.enabled = NO;
        self.recipe.category = self.selectedCategory;
        self.recipe.name = self.recipeNameView.recipeName;
        self.recipe.description = self.cookingDirectionsView.directions;
        BOOL imageChanged = self.recipeImageView.imageEdited;
        if (imageChanged) {
            DLog(@"image changed");
            self.recipe.image = self.recipeImageView.recipeImage;
            self.uploadProgressLabel.hidden = NO;
        } else {
            DLog(@"image didn't change");
        }
        
        self.recipe.numServes = self.servesView.serves;
        self.recipe.cookingTimeInSeconds = self.cookingTimeView.cookingTimeInSeconds;
        self.recipe.recipeViewImageContentOffset = self.recipeImageView.scrollViewContentOffset;
        self.recipe.ingredients = [NSArray arrayWithArray:self.ingredientsView.ingredients];
        

        if (imageChanged) {
            self.progressView.hidden = NO;
            self.uploadProgressLabel.hidden = NO;
            [self.recipe saveAndUploadImageWithSuccess:^{
                [self closeButtonTapped:nil];
                button.enabled = YES;
                self.progressView.hidden = YES;
                self.uploadProgressLabel.hidden = YES;
            } failure:^(NSError *error) {
                DLog(@"An error occurred: %@", [error description]);
                [self displayMessage:[error description]];
                button.enabled = YES;
            } imageUploadProgress:^(int percentDone) {
                float percentage = percentDone/100.0f;
                [self.progressView setProgress:percentage animated:YES];
                self.uploadProgressLabel.text = [NSString stringWithFormat:@"Uploading (%i%%)",percentDone];
            }];
        } else {
            [self.recipe saveWithSuccess:^{
                [self closeButtonTapped:nil];
                button.enabled = YES;
            } failure:^(NSError *error) {
                DLog(@"An error occurred: %@", [error description]);
                [self displayMessage:[error description]];
                button.enabled = YES;

            }];
        }
    }
}

-(IBAction)likeButtonTapped:(UIButton*)button
{
    button.enabled = NO;
    //do the opposite of the current value
    [RecipeLike updateRecipeLikeForUser:[CKUser currentUser] recipe:self.recipe liked:!self.recipeLiked withSuccess:^(id object) {
        button.enabled = YES;
        button.selected = !button.selected;
    } failure:^(NSError *error) {
        button.enabled = YES;
        DLog(@"could not like/unlike recipe: %@", [error description]);
    }];
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
    
//    self.recipeLiked = [RecipeLike recipeLI:[CKUser currentUser] forRecipe:self.recipe];
//    
//    [RecipeLike fetchRecipeLikeForUser:[CKUser currentUser]
//                                recipe:self.recipe withSuccess:^(RecipeLike *recipeLike) {
//                                    self.recipeLike = recipeLike;
//                                    if (self.recipeLike) {
//                                        self.likeButton.selected = YES;
//                                    }
//                                } failure:^(NSError *error) {
//                                    DLog(@"Could not fetch recipe likes: %@", [error description]);
//    }];
//    
    self.likesLabel.text = [NSString stringWithFormat:@"%i",0];

}

-(void)updateLikes:(BOOL)liked
{
    
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


-(void)configPageComponentsForEditing:(BOOL)editing
{
    [self showPageButtons:!editing];
    [self showPageNumber:!editing];
    self.closeButton.hidden = !editing;
    self.saveButton.hidden = !editing;

    [self.categoryListViewController show:editing];
    self.facebookUserView.hidden = editing;
    
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

-(void)configLikesLabel
{
    self.likesLabel.font = [Theme defaultFontWithSize:14.0f];
    self.likesLabel.text = @"0";
}

#pragma mark - CategoryListViewDelegate
-(void)didSelectCategoryWithName:(NSString *)categoryName
{
    [self.categories each:^(Category *category) {
        if ([category.name isEqualToString:categoryName]) {
            self.selectedCategory = category;
        }
    }];
}

@end
