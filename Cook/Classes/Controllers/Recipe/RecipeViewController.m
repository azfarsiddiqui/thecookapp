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
@interface RecipeViewController ()
@property(nonatomic,strong) IBOutlet FacebookUserView *facebookUserView;
@property(nonatomic,strong) IBOutlet RecipeNameView *recipeNameView;
@property(nonatomic,strong) IBOutlet RecipeImageView *recipeImageView;
@property(nonatomic,strong) IBOutlet IngredientsView *ingredientsView;
@property(nonatomic,strong) IBOutlet CookingDirectionsView *cookingDirectionsView;
@property(nonatomic,strong) IBOutlet ServesView *servesView;
@property(nonatomic,strong) IBOutlet CookingTimeView *cookingTimeView;

@property(nonatomic,strong) IBOutletCollection(UIEditableView) NSArray *editableViews;

@end

@implementation RecipeViewController

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    DLog();
    [self refreshData];
    [self showContentsButton];

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
    }
}

#pragma mark - private methods

-(void)style
{
}

-(void)refreshData
{
    [self.recipeNameView setRecipeName:self.recipe.name];
    [self.facebookUserView setUser:[[self.dataSource currentBook] user]];
    NSMutableString *mutableIngredientString = [[NSMutableString alloc]init];
    [self.recipe.ingredients each:^(Ingredient *ingredient) {
        [mutableIngredientString appendFormat:@"%@\n",ingredient.name];
    }];

    if ([mutableIngredientString length] > 0) {
        self.ingredientsView.ingredients = [NSString stringWithString:mutableIngredientString];
    }
//
//    if (self.recipe.description) {
//        CGSize maxSize = CGSizeMake(330.0f, CGFLOAT_MAX);
//        self.cookingDirectionsLabel.text = self.recipe.description;
//        CGSize requiredSize = [self.recipe.description sizeWithFont:self.cookingDirectionsLabel.font constrainedToSize:maxSize lineBreakMode:NSLineBreakByWordWrapping];
//        self.cookingDirectionsLabel.frame = CGRectMake(0, 0, requiredSize.width, requiredSize.height);
//        [self adjustScrollView:self.cookingDirectionsScrollView forHeight:requiredSize.height];
//
//    }
//    
//    PFImageView *imageView = (PFImageView*) [self.recipeImageScrollView viewWithTag:kImageViewTag];
//    if (!imageView) {
//        imageView = [[PFImageView alloc] init];
//        imageView.tag = kImageViewTag;
//        [self.recipeImageScrollView addSubview:imageView];
//    }
//    
//    if (self.recipe.numServes > 0) {
//        self.numServesLabel.text = [NSString stringWithFormat:@"%i",self.recipe.numServes];
//    }
//
//    if (self.recipe.cookingTimeInSeconds > 0) {
//        self.cookingTimeLabel.text = [ViewHelper formatAsHoursSeconds:self.recipe.cookingTimeInSeconds];
//    }
//
//    [CKRecipe imagesForRecipe:self.recipe success:^{
//        if ([self.recipe imageFile]) {
//            imageView.file = [self.recipe imageFile];
//            [imageView loadInBackground:^(UIImage *image, NSError *error) {
//                if (!error) {
//                    CGSize imageSize = CGSizeMake(image.size.width, image.size.height);
//                    DLog(@"recipe image size: %@",NSStringFromCGSize(imageSize));
//                    imageView.frame = CGRectMake(0.0f, 0.0f, imageSize.width, imageSize.height);
//                    imageView.image = image;
//                    self.recipeImageScrollView.contentSize = CGSizeMake(imageSize.width,imageSize.height);
//                    if (self.recipe.recipeViewImageContentOffset.x!=0) {
//                        self.recipeImageScrollView.contentOffset = self.recipe.recipeViewImageContentOffset;
//                    } else {
//                        self.recipeImageScrollView.contentOffset = CGPointMake(340.0f, 0.0f);
//                    }
//                    
//                } else {
//                    DLog(@"Error loading image in background: %@", [error description]);
//                }
//            }];
//        }
//    } failure:^(NSError *error) {
//        DLog(@"Error loading image: %@", [error description]);
//    }];
//
}


@end
