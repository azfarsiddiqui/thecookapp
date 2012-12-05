//
//  RecipeViewController.m
//  Cook
//
//  Created by Jonny Sagorin on 10/12/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "RecipeViewController.h"
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
@interface RecipeViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
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
        [self toggleSaveCloseButtons:YES];
    }
}

#pragma mark - Action methods

-(IBAction)closeButtonTapped:(UIButton*)button
{
    [self.editableViews each:^(UIEditableView *view) {
        [view makeEditable:NO];
    }];
    [self showPageButtons:YES];
    [self toggleSaveCloseButtons:NO];
    [self showBookmarkView];
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
}


-(void) toggleSaveCloseButtons:(BOOL)show
{
    self.closeButton.hidden = !show;
    self.saveButton.hidden = !show;

}
@end
