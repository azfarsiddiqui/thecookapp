//
//  BookPageListEditViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 3/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "PageListEditViewController.h"
#import "RecipeDetails.h"
#import "MRCEnumerable.h"
#import "PageListCell.h"

@interface PageListEditViewController ()

@end

@implementation PageListEditViewController

- (id)initWithEditView:(UIView *)editView recipeDetails:(RecipeDetails *)recipeDetails
              delegate:(id<CKEditViewControllerDelegate>)delegate editingHelper:(CKEditingViewHelper *)editingHelper
                 white:(BOOL)white {
    
    if (self = [super initWithEditView:editView delegate:delegate items:recipeDetails.availablePages editingHelper:editingHelper
                                 white:white title:nil]) {
        
        self.selectedIndexNumber = @([recipeDetails.availablePages findIndexWithBlock:^BOOL(NSString *page) {
            return [[page uppercaseString] isEqualToString:[recipeDetails.page uppercaseString]];
        }]);
        
    }
    return self;
}

- (Class)classForListCell {
    return [PageListCell class];
}

@end
