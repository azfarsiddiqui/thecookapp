//
//  IngredientListEditViewController.h
//  Cook
//
//  Created by Jeff Tan-Ang on 8/05/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKItemsEditViewController.h"

@class RecipeClipboard;

@interface IngredientItemsEditViewController : CKItemsEditViewController

- (id)initWithEditView:(UIView *)editView recipeClipboard:(RecipeClipboard *)recipeClipboard
              delegate:(id<CKEditViewControllerDelegate>)delegate editingHelper:(CKEditingViewHelper *)editingHelper
                 white:(BOOL)white;

@end
