//
//  CategoryListEditViewController.h
//  Cook
//
//  Created by Jeff Tan-Ang on 31/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKListEditViewController.h"

@class CKBook;
@class CKCategory;

@interface CategoryListEditViewController : CKListEditViewController

- (id)initWithEditView:(UIView *)editView book:(CKBook *)book selectedCategory:(CKCategory *)category
              delegate:(id<CKEditViewControllerDelegate>)delegate editingHelper:(CKEditingViewHelper *)editingHelper
                 white:(BOOL)white;

@end
