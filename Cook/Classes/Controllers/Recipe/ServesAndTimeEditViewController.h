//
//  ServesAndTimeEditViewController.h
//  Cook
//
//  Created by Jeff Tan-Ang on 9/05/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKEditViewController.h"

@class RecipeClipboard;

@interface ServesAndTimeEditViewController : CKEditViewController

- (id)initWithEditView:(UIView *)editView recipeClipboard:(RecipeClipboard *)recipeClipboard
              delegate:(id<CKEditViewControllerDelegate>)delegate editingHelper:(CKEditingViewHelper *)editingHelper
                 white:(BOOL)white;

@end
