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

@interface IngredientListEditViewController ()

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

#pragma mark - CKListCellDelegate methods

- (BOOL)listItemValidatedForCell:(CKListCell *)cell {
    Ingredient *ingredient = (Ingredient *)[cell currentValue];
    NSString *text = ingredient.name;
    return ([text length] > 0);
}



@end
