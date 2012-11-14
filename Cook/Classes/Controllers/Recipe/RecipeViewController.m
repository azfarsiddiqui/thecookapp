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
@property(nonatomic,strong) IBOutlet UILabel *ingredientListLabel;
@property(nonatomic,strong) IBOutlet UILabel *directionsLabel;
@property(nonatomic,strong) IBOutlet UIScrollView *recipeScrollView;
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
        self.ingredientListLabel.text = mutableIngredientString;
    }
    
    self.directionsLabel.text = self.recipe.description;
    [self.directionsLabel sizeToFit];
    
    PFImageView *imageView = (PFImageView*) [self.recipeScrollView viewWithTag:kImageViewTag];
    if (!imageView) {
        imageView = [[PFImageView alloc] init];
        imageView.tag = kImageViewTag;
        [self.recipeScrollView addSubview:imageView];
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
                    self.recipeScrollView.contentSize = CGSizeMake(imageSize.width,imageSize.height);
                    [self.recipeScrollView setContentOffset:CGPointMake(341.0f, 0.0f)];
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

@end
