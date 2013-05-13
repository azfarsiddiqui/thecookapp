//
//  IngredientListEditViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 8/05/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "IngredientListEditViewController.h"
#import "CKRecipe.h"
#import "Ingredient.h"

@interface IngredientListEditViewController ()

@property (nonatomic, strong) CKRecipe *recipe;

@end

@implementation IngredientListEditViewController

#define kIngredientsTitle  @"Ingredients"

- (id)initWithEditView:(UIView *)editView recipe:(CKRecipe *)recipe delegate:(id<CKEditViewControllerDelegate>)delegate
         editingHelper:(CKEditingViewHelper *)editingHelper white:(BOOL)white {
    
    if (self = [super initWithEditView:editView delegate:delegate items:recipe.ingredients selectedIndex:nil
                         editingHelper:editingHelper white:white title:kIngredientsTitle]) {
        self.recipe = recipe;
        self.canAddItemText = @"ADD INGREDIENT";
        self.incrementalAdd = YES;
    }
    return self;
}

#pragma mark - CKListEditViewController methods

- (id)valueAtIndex:(NSInteger)index {
    Ingredient *ingredient = [self.listItems objectAtIndex:index];
    DLog(@"Ingredient Name[%@] Measurement[%@]", ingredient.name, ingredient.measurement);
    return ingredient.name;
}

@end
