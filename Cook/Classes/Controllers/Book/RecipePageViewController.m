//
//  RecipePageViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 13/11/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "RecipePageViewController.h"

@interface RecipePageViewController ()

@property (nonatomic, strong) UILabel *recipeLabel;

@end

@implementation RecipePageViewController

#define kCategoryFont   [UIFont boldSystemFontOfSize:30.0]

- (void)loadData {
    [super loadData];
    [self dataDidLoad];
}

- (void)setRecipe:(CKRecipe *)recipe {
    
    NSString *recipeName = [NSString stringWithFormat:@"Recipe: %@", recipe.name];
    
    if (!self.recipeLabel) {
        UILabel *recipeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        recipeLabel.backgroundColor = [UIColor clearColor];
        recipeLabel.font = kCategoryFont;
        recipeLabel.textColor = [UIColor blackColor];
        recipeLabel.shadowColor = [UIColor whiteColor];
        recipeLabel.shadowOffset = CGSizeMake(0.0, 1.0);
        [self.view addSubview:recipeLabel];
        self.recipeLabel = recipeLabel;
    }
    
    CGSize size = [recipeName sizeWithFont:kCategoryFont constrainedToSize:self.view.bounds.size lineBreakMode:NSLineBreakByTruncatingTail];
    self.recipeLabel.frame = CGRectMake(floorf((self.view.bounds.size.width - size.width) / 2.0),
                                        floorf((self.view.bounds.size.height - size.height) / 2.0),
                                        size.width,
                                        size.height);
    self.recipeLabel.text = recipeName;
}

@end
