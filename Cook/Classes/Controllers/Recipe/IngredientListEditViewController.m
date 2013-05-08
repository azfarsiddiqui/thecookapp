//
//  IngredientListEditViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 8/05/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "IngredientListEditViewController.h"

@interface IngredientListEditViewController ()

@property (nonatomic, strong) CKRecipe *recipe;

@end

@implementation IngredientListEditViewController

#define kIngredientsTitle  @"Ingredients"

- (id)initWithEditView:(UIView *)editView recipe:(CKRecipe *)recipe delegate:(id<CKEditViewControllerDelegate>)delegate
         editingHelper:(CKEditingViewHelper *)editingHelper white:(BOOL)white {
    
    if (self = [super initWithEditView:editView delegate:delegate items:nil selectedIndex:nil
                         editingHelper:editingHelper white:white title:kIngredientsTitle]) {
        self.recipe = recipe;
        self.canAddItemText = @"ADD INGREDIENT";
        self.incrementalAdd = YES;
    }
    return self;
}

@end
