//
//  GridRecipeActionsView.m
//  Cook
//
//  Created by Jeff Tan-Ang on 18/02/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "GridRecipeStatsView.h"

@interface GridRecipeStatsView ()

@property (nonatomic, strong) UIImageView *backgroundView;

@end

@implementation GridRecipeStatsView

- (id)init {
    if (self = [super initWithFrame:CGRectZero]) {
        
        UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_recipe_iconbar.png"]];
        self.frame = backgroundView.frame;
        [self addSubview:backgroundView];
        self.backgroundView = backgroundView;
    }
    return self;
}

- (void)configureRecipe:(CKRecipe *)recipe {
    
}

@end
