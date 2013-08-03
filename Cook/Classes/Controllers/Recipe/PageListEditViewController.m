//
//  BookPageListEditViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 3/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "PageListEditViewController.h"
#import "CKRecipe.h"
#import "CKBook.h"
#import "MRCEnumerable.h"
#import "PageListCell.h"

@interface PageListEditViewController ()

@end

@implementation PageListEditViewController

- (id)initWithEditView:(UIView *)editView recipe:(CKRecipe *)recipe delegate:(id<CKEditViewControllerDelegate>)delegate
         editingHelper:(CKEditingViewHelper *)editingHelper white:(BOOL)white {
    if (self = [super initWithEditView:editView delegate:delegate items:recipe.book.pages editingHelper:editingHelper
                                 white:white title:nil]) {
        
        self.selectedIndexNumber = @([recipe.book.pages findIndexWithBlock:^BOOL(NSString *page) {
            return [[page uppercaseString] isEqualToString:[recipe.page uppercaseString]];
        }]);
        
    }
    return self;
}

- (Class)classForListCell {
    return [PageListCell class];
}

@end
