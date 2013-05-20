//
//  IngredientListEditViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 8/05/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "IngredientItemsEditViewController.h"
#import "IngredientItemCollectionViewCell.h"
#import "RecipeClipboard.h"
#import "Ingredient.h"

@interface IngredientItemsEditViewController ()

@property (nonatomic, strong) RecipeClipboard *recipeClipboard;

@end

@implementation IngredientItemsEditViewController

#define kIngredientsTitle  @"Ingredients"

- (id)initWithEditView:(UIView *)editView recipeClipboard:(RecipeClipboard *)recipeClipboard
              delegate:(id<CKEditViewControllerDelegate>)delegate editingHelper:(CKEditingViewHelper *)editingHelper
                 white:(BOOL)white {
    
    if (self = [super initWithEditView:editView delegate:delegate items:recipeClipboard.ingredients selectedIndex:nil
                         editingHelper:editingHelper white:white title:kIngredientsTitle]) {
        
        self.recipeClipboard = recipeClipboard;
        self.addItemsFromTop = NO;
        self.allowSelectionState = NO;
    }
    return self;
}

#pragma mark - CKEditViewController methods

- (id)updatedValue {
    return self.items;
}

#pragma mark - CKItemsEditViewController methods

- (Class)classForCell {
    return [IngredientItemCollectionViewCell class];
}

- (BOOL)validateCell:(UICollectionViewCell *)cell {
    IngredientItemCollectionViewCell *ingredientCell = (IngredientItemCollectionViewCell *)cell;
    return [self validIngredientAtCell:ingredientCell];
}

- (BOOL)readyForInsertionForPlaceholderCell:(CKItemCollectionViewCell *)placeholderCell {
    IngredientItemCollectionViewCell *ingredientCell = (IngredientItemCollectionViewCell *)placeholderCell;
    return [self validIngredientAtCell:ingredientCell];
}

- (BOOL)validIngredientAtCell:(IngredientItemCollectionViewCell *)ingredientCell {
    Ingredient *ingredient = ingredientCell.currentValue;
    return ([ingredient.name length] > 0);
}

- (void)itemsDidShow:(BOOL)show {
    [super itemsDidShow:show];
    
    if (show) {
        
        // Automatically select first placeholder item if there are no items.
        if ([self.items count] == 0) {
            [self selectCellAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
        }
    }

}



@end
