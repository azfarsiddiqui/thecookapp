//
//  RecipeListCell.m
//  recipe
//
//  Created by Jonny Sagorin on 9/27/12.
//  Copyright (c) 2012 Cook Pty Ltd. All rights reserved.
//

#import "RecipeListCell.h"

@interface RecipeListCell ()
@property (strong, nonatomic) UILabel *recipeNameLabel;
@property (strong, nonatomic) UIView *overlayView;
@property (strong, nonatomic) PFImageView *imageView;
@end
@implementation RecipeListCell

-(void)configure:(CKRecipe*)recipe;
{
    self.contentView.backgroundColor = [UIColor clearColor];

    if (!self.imageView) {
        self.imageView = [[PFImageView alloc] init];
        self.imageView.backgroundColor = [UIColor clearColor];
        self.imageView.image = [UIImage imageNamed:@"image_placeholder"]; // placeholder image
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        CGRect frame = CGRectMake(0.0f, 25.0f, self.frame.size.width, self.frame.size.height);
        self.imageView.frame = frame;
        [self.contentView addSubview:self.imageView];
    }

    if (!self.overlayView) {
        self.overlayView = [[UIView alloc]initWithFrame:CGRectMake(0.0f, self.frame.size.height - 30.0f, self.frame.size.width, 30.0f)];
        self.overlayView.backgroundColor = [UIColor blackColor];
        self.overlayView.alpha = 0.2f;
        
        self.recipeNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0.0f, self.frame.size.height - 25.0f, self.frame.size.width, 20.0f)];
        self.recipeNameLabel.textColor = [UIColor whiteColor];
        self.recipeNameLabel.font = [UIFont systemFontOfSize:14.0f];
        self.recipeNameLabel.textAlignment = NSTextAlignmentCenter;
        self.recipeNameLabel.backgroundColor = [UIColor clearColor];
        
        [self.contentView addSubview:self.recipeNameLabel];
        [self.contentView addSubview:self.overlayView];
    }
    self.recipeNameLabel.text = recipe.name;


    [CKRecipe imagesForRecipe:recipe success:^{
        if ([recipe imageFile]) {
            self.imageView.file = [recipe imageFile];
            [self.imageView loadInBackground];
        }
    } failure:^(NSError *error) {
        DLog(@"Error loading image: %@", [error description]);
    }];
}
@end
