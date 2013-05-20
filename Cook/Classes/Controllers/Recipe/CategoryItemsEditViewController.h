//
//  CategoryListEditViewController.h
//  Cook
//
//  Created by Jeff Tan-Ang on 7/05/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKTextItemsEditViewController.h"

@class CKBook;
@class CKCategory;
@class CKEditingViewHelper;

@interface CategoryItemsEditViewController : CKTextItemsEditViewController

- (id)initWithEditView:(UIView *)editView book:(CKBook *)book delegate:(id<CKEditViewControllerDelegate>)delegate
     editingHelper:(CKEditingViewHelper *)editingHelper white:(BOOL)white;

- (id)initWithEditView:(UIView *)editView book:(CKBook *)book selectedCategory:(CKCategory *)category
          delegate:(id<CKEditViewControllerDelegate>)delegate editingHelper:(CKEditingViewHelper *)editingHelper
             white:(BOOL)white;

@end
