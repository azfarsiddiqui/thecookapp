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

#define kImageViewTag   1122334455
@interface RecipeViewController ()
@property(nonatomic,strong) IBOutlet UILabel *recipeNameLabel;
@property(nonatomic,strong) IBOutlet UILabel *userNameLabel;
@property(nonatomic,strong) IBOutlet UIScrollView *ingredientsScrollView;
@property(nonatomic,strong) IBOutlet UIScrollView *cookingDirectionsScrollView;
@property(nonatomic,strong) IBOutlet UIScrollView *recipeImageScrollView;

@property(nonatomic,strong) UILabel *ingredientsLabel;
@property(nonatomic,strong) UILabel *cookingDirectionsLabel;
@end

@implementation RecipeViewController

-(void)awakeFromNib
{
    [super awakeFromNib];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    DLog();
    [self refreshData];

}
- (void)viewDidLoad
{
    [super viewDidLoad];
    DLog();
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Overridden methods
-(void)refreshData
{
    [super loadData];
    self.recipeNameLabel.text = self.recipe.name;
    self.userNameLabel.text = [[[self.dataSource currentBook] userName] uppercaseString];

    NSMutableString *mutableIngredientString = [[NSMutableString alloc]init];
    [self.recipe.ingredients each:^(Ingredient *ingredient) {
        [mutableIngredientString appendFormat:@"%@\n",ingredient.name];
    }];
    
    if ([mutableIngredientString length] > 0) {
        CGSize maxSize = CGSizeMake(self.ingredientsScrollView.frame.size.width, CGFLOAT_MAX);
        self.ingredientsLabel.text = mutableIngredientString;
        CGSize requiredSize = [self.ingredientsLabel sizeThatFits:maxSize];
        self.ingredientsLabel.frame = CGRectMake(0, 0, requiredSize.width, requiredSize.height);
        [self adjustScrollView:self.ingredientsScrollView forHeight:requiredSize.height];

    }
    
    if (self.recipe.description) {
        CGSize maxSize = CGSizeMake(self.cookingDirectionsScrollView.frame.size.width, CGFLOAT_MAX);
        self.cookingDirectionsLabel.text = self.recipe.description;
        CGSize requiredSize = [self.cookingDirectionsLabel sizeThatFits:maxSize];
        self.cookingDirectionsLabel.frame = CGRectMake(0, 0, requiredSize.width, requiredSize.height);
        [self adjustScrollView:self.cookingDirectionsScrollView forHeight:requiredSize.height];

    }
    
    PFImageView *imageView = (PFImageView*) [self.recipeImageScrollView viewWithTag:kImageViewTag];
    if (!imageView) {
        imageView = [[PFImageView alloc] init];
        imageView.tag = kImageViewTag;
        [self.recipeImageScrollView addSubview:imageView];
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
                    [self.recipeImageScrollView setContentOffset:CGPointMake(341.0f, 0.0f)];
                } else {
                    DLog(@"Error loading image in background: %@", [error description]);
                }
                [super dataDidLoad];
            }];
        }
    } failure:^(NSError *error) {
        DLog(@"Error loading image: %@", [error description]);
    }];

}

#pragma mark - private methods

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
        _cookingDirectionsLabel = [[UILabel alloc]initWithFrame:CGRectMake(0.0f, 0.0f, self.cookingDirectionsScrollView.frame.size.width, 20.0f)];
        _cookingDirectionsLabel.numberOfLines = 0;
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
