//
//  BookPageListEditViewController.h
//  Cook
//
//  Created by Jeff Tan-Ang on 3/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKListEditViewController.h"

@class RecipeDetails;

@interface PageListEditViewController : CKListEditViewController

- (id)initWithEditView:(UIView *)editView recipeDetails:(RecipeDetails *)recipeDetails
              delegate:(id<CKEditViewControllerDelegate>)delegate editingHelper:(CKEditingViewHelper *)editingHelper
                 white:(BOOL)white;

@end
