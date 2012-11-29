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
#import "CKTextField.h"
#import "Theme.h"

#define kImageViewTag   1122334455
@interface RecipeViewController ()
@property(nonatomic,strong) IBOutlet UIScrollView *ingredientsScrollView;
@property(nonatomic,strong) IBOutlet UIScrollView *cookingDirectionsScrollView;
@property(nonatomic,strong) IBOutlet UIScrollView *recipeImageScrollView;
@property (nonatomic,strong) IBOutlet UILabel *numServesLabel;
@property (nonatomic,strong) IBOutlet UILabel *cookingTimeLabel;

@property(nonatomic,strong) IBOutlet CKTextField *recipeNameTextField;

@property(nonatomic,strong) UILabel *ingredientsLabel;
@property(nonatomic,strong) UILabel *cookingDirectionsLabel;

@property(nonatomic,strong) IBOutlet FacebookUserView *facebookUserView;
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
        [self.recipeNameTextField enableEditMode:YES];
    }
    
    DLog();
}

#pragma mark - private methods

-(void)style
{
    self.ingredientsLabel.font = [Theme defaultLabelFont];
    self.ingredientsLabel.textColor = [Theme ingredientsLabelColor];
    self.cookingDirectionsLabel.font = [Theme defaultLabelFont];
    self.cookingDirectionsLabel.textColor = [Theme directionsLabelColor];
    self.numServesLabel.font = [Theme defaultLabelFont];
    self.numServesLabel.textColor = [Theme defaultLabelColor];
    self.cookingTimeLabel.font = [Theme defaultLabelFont];
    self.cookingTimeLabel.textColor = [Theme defaultLabelColor];
    self.recipeNameTextField.font = [Theme defaultFontWithSize:42.0f];
    [self.recipeNameTextField enableEditMode:NO];
}

-(void)refreshData
{
    self.recipeNameTextField.text = [self.recipe.name uppercaseString];
    [self.facebookUserView setUser:[[self.dataSource currentBook] user]];
    NSMutableString *mutableIngredientString = [[NSMutableString alloc]init];
    [self.recipe.ingredients each:^(Ingredient *ingredient) {
        [mutableIngredientString appendFormat:@"%@\n",ingredient.name];
    }];
    
    if ([mutableIngredientString length] > 0) {
        CGSize maxSize = CGSizeMake(190.0f, CGFLOAT_MAX);
        self.ingredientsLabel.text = mutableIngredientString;
        CGSize requiredSize = [mutableIngredientString sizeWithFont:self.ingredientsLabel.font constrainedToSize:maxSize lineBreakMode:NSLineBreakByWordWrapping];
        self.ingredientsLabel.frame = CGRectMake(0, 0, requiredSize.width, requiredSize.height);
        [self adjustScrollView:self.ingredientsScrollView forHeight:requiredSize.height];

    }
    
    if (self.recipe.description) {
        CGSize maxSize = CGSizeMake(330.0f, CGFLOAT_MAX);
        self.cookingDirectionsLabel.text = self.recipe.description;
        CGSize requiredSize = [self.recipe.description sizeWithFont:self.cookingDirectionsLabel.font constrainedToSize:maxSize lineBreakMode:NSLineBreakByWordWrapping];
        self.cookingDirectionsLabel.frame = CGRectMake(0, 0, requiredSize.width, requiredSize.height);
        [self adjustScrollView:self.cookingDirectionsScrollView forHeight:requiredSize.height];

    }
    
    PFImageView *imageView = (PFImageView*) [self.recipeImageScrollView viewWithTag:kImageViewTag];
    if (!imageView) {
        imageView = [[PFImageView alloc] init];
        imageView.tag = kImageViewTag;
        [self.recipeImageScrollView addSubview:imageView];
    }
    
    if (self.recipe.numServes > 0) {
        self.numServesLabel.text = [NSString stringWithFormat:@"%i",self.recipe.numServes];
    }

    if (self.recipe.cookingTimeInSeconds > 0) {
        self.cookingTimeLabel.text = [ViewHelper formatAsHoursSeconds:self.recipe.cookingTimeInSeconds];
    }

    [CKRecipe imagesForRecipe:self.recipe success:^{
        if ([self.recipe imageFile]) {
            imageView.file = [self.recipe imageFile];
            [imageView loadInBackground:^(UIImage *image, NSError *error) {
                if (!error) {
                    CGSize imageSize = CGSizeMake(image.size.width, image.size.height);
                    DLog(@"recipe image size: %@",NSStringFromCGSize(imageSize));
                    imageView.frame = CGRectMake(0.0f, 0.0f, imageSize.width, imageSize.height);
                    imageView.image = image;
                    self.recipeImageScrollView.contentSize = CGSizeMake(imageSize.width,imageSize.height);
                    if (self.recipe.recipeViewImageContentOffset.x!=0) {
                        self.recipeImageScrollView.contentOffset = self.recipe.recipeViewImageContentOffset;
                    } else {
                        self.recipeImageScrollView.contentOffset = CGPointMake(340.0f, 0.0f);
                    }
                    
                } else {
                    DLog(@"Error loading image in background: %@", [error description]);
                }
            }];
        }
    } failure:^(NSError *error) {
        DLog(@"Error loading image: %@", [error description]);
    }];

}

-(UILabel *)ingredientsLabel
{
    if (!_ingredientsLabel) {
        _ingredientsLabel = [[UILabel alloc]initWithFrame:CGRectMake(0.0f, 0.0f, self.ingredientsScrollView.frame.size.width, 20.0f)];
        _ingredientsLabel.numberOfLines = 0;
        [self.ingredientsScrollView addSubview:_ingredientsLabel];
    }
    
    return _ingredientsLabel;
}

-(UILabel *)cookingDirectionsLabel
{
    if (!_cookingDirectionsLabel) {
        _cookingDirectionsLabel = [[UILabel alloc]initWithFrame:CGRectMake(0.0f, 0.0f,  330.0f, 20.0f)];
        _cookingDirectionsLabel.numberOfLines = 0;
        _cookingDirectionsLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self.cookingDirectionsScrollView addSubview:_cookingDirectionsLabel];
    }
    
    return _cookingDirectionsLabel;
}

-(void) adjustScrollView:(UIScrollView*)scrollView forHeight:(float)height
{
    scrollView.contentSize = height > scrollView.frame.size.height ?
        CGSizeMake(scrollView.frame.size.width, height) :
    CGSizeMake(scrollView.frame.size.width, scrollView.frame.size.height);
}

@end
