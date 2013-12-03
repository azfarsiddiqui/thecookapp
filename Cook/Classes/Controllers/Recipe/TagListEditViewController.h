//
//  TagListEditViewController.h
//  Cook
//
//  Created by Gerald Kim on 14/10/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKRecipeTag.h"
#import "CKEditViewController.h"

typedef enum {
    kMealTagType = 0,
    kAllergyTagType = 2,
    kFoodTagType = 1
} TagType;

@interface TagListEditViewController : CKEditViewController

- (id)initWithEditView:(UIView *)editView delegate:(id<CKEditViewControllerDelegate>)delegate
         selectedItems:(NSArray *)selectedItems
         editingHelper:(CKEditingViewHelper *)editingHelper;

//- (void)updateCellsWithTagArray:(NSArray *)allItems;

@end
