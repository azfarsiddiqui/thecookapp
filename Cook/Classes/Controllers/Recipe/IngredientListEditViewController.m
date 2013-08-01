//
//  IngredientListEditViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 1/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "IngredientListEditViewController.h"
#import "IngredientListCell.h"

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

@end
