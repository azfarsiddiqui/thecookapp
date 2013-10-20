//
//  TagListEditViewController.h
//  Cook
//
//  Created by Gerald Kim on 14/10/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKListEditViewController.h"
#import "CKRecipeTag.h"

@interface TagListEditViewController : CKListEditViewController

- (id)initWithEditView:(UIView *)editView
              delegate:(id<CKEditViewControllerDelegate>)delegate
              allItems:(NSArray *)allItems
                 selectedItems:(NSArray *)selectedItems
         editingHelper:(CKEditingViewHelper *)editingHelper;
- (void)updateCellsWithTagArray:(NSArray *)allItems;

@end
