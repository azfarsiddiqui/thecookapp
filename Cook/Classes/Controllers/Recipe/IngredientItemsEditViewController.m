//
//  IngredientListEditViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 8/05/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "IngredientItemsEditViewController.h"
#import "IngredientItemCollectionViewCell.h"
#import "CKRecipe.h"
#import "Ingredient.h"

@interface IngredientItemsEditViewController ()

@property (nonatomic, strong) CKRecipe *recipe;

@end

@implementation IngredientItemsEditViewController

#define kIngredientsTitle  @"Ingredients"

- (id)initWithEditView:(UIView *)editView recipe:(CKRecipe *)recipe delegate:(id<CKEditViewControllerDelegate>)delegate
         editingHelper:(CKEditingViewHelper *)editingHelper white:(BOOL)white {
    
    if (self = [super initWithEditView:editView delegate:delegate items:recipe.ingredients selectedIndex:nil
                         editingHelper:editingHelper white:white title:kIngredientsTitle]) {
        self.recipe = recipe;
        self.addItemsFromTop = NO;
        self.allowSelectionState = NO;
    }
    return self;
}

#pragma mark - CKItemsEditViewController methods

- (Class)classForCell {
    return [IngredientItemCollectionViewCell class];
}

- (BOOL)validateCell:(UICollectionViewCell *)cell {
    return YES;
}

- (BOOL)readyForInsertionForPlaceholderCell:(CKItemCollectionViewCell *)placeholderCell {
    return YES;
}



@end
