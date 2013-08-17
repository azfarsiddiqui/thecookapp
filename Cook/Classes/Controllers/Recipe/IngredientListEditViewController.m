//
//  IngredientListEditViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 1/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "IngredientListEditViewController.h"
#import "IngredientListCell.h"
#import "Ingredient.h"
#import "NSString+Utilities.h"
#import "IngredientsKeyboardAccessoryViewController.h"

@interface IngredientListEditViewController () <IngredientsKeyboardAccessoryViewControllerDelegate>

@property (nonatomic, strong) IngredientsKeyboardAccessoryViewController *ingredientsAccessoryViewController;

@end

@implementation IngredientListEditViewController

#pragma mark - CKEditViewController methods

- (id)updatedValue {
    return self.items;
}

#pragma mark - CKListEditViewController methods

- (Class)classForListCell {
    return [IngredientListCell class];
}

- (void)configureCell:(IngredientListCell *)itemCell indexPath:(NSIndexPath *)indexPath {
    [super configureCell:itemCell indexPath:indexPath];
    itemCell.ingredientsAccessoryView = self.ingredientsAccessoryViewController.view;
    itemCell.allowSelection = NO;
}

- (id)createNewItem {
    return [Ingredient ingredientwithName:nil measurement:nil];
}

- (CGSize)cellSize {
    CGSize size = [super cellSize];
    return (CGSize){
        size.width,
        70.0
    };
}

- (BOOL)isEmptyForValue:(id)currentValue {
    
    Ingredient *ingredient = (Ingredient *)currentValue;
    
    // Empty if both contains no value.
    return (![ingredient.measurement CK_containsText] && ![ingredient.name CK_containsText]);
}

#pragma mark - IngredientsKeyboardAccessoryViewControllerDelegate methods

- (void)ingredientsKeyboardAccessorySelectedValue:(NSString *)value {
    IngredientListCell *ingredientCell = (IngredientListCell *)self.editingCell;
    
    // TODO
    // NIL??
    //
    
    [ingredientCell configureMeasure:value];
}

#pragma mark - Properties

- (IngredientsKeyboardAccessoryViewController *)ingredientsAccessoryViewController {
    if (!_ingredientsAccessoryViewController) {
        _ingredientsAccessoryViewController = [[IngredientsKeyboardAccessoryViewController alloc] initWithDelegate:self];
    }
    return _ingredientsAccessoryViewController;
}

@end
