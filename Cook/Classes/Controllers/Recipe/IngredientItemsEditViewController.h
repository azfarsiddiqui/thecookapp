//
//  IngredientListEditViewController.h
//  Cook
//
//  Created by Jeff Tan-Ang on 8/05/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKItemsEditViewController.h"

@class CKRecipe;

@interface IngredientItemsEditViewController : CKItemsEditViewController

- (id)initWithEditView:(UIView *)editView recipe:(CKRecipe *)recipe delegate:(id<CKEditViewControllerDelegate>)delegate
         editingHelper:(CKEditingViewHelper *)editingHelper white:(BOOL)white;

@end
