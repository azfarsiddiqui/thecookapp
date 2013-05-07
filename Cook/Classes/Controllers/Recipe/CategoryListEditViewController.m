//
//  CategoryListEditViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 7/05/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CategoryListEditViewController.h"
#import "CKBook.h"
#import "CKCategory.h"
#import "MRCEnumerable.h"
#import "NSString+Utilities.h"

@interface CategoryListEditViewController ()

@end

@implementation CategoryListEditViewController

#define kCategoryTitle  @"Categories"

- (id)initWithEditView:(UIView *)editView book:(CKBook *)book delegate:(id<CKEditViewControllerDelegate>)delegate
     editingHelper:(CKEditingViewHelper *)editingHelper white:(BOOL)white {
    
    return [self initWithEditView:editView book:book selectedCategory:nil delegate:delegate editingHelper:editingHelper
                            white:white];
}

- (id)initWithEditView:(UIView *)editView book:(CKBook *)book selectedCategory:(CKCategory *)category
          delegate:(id<CKEditViewControllerDelegate>)delegate editingHelper:(CKEditingViewHelper *)editingHelper
             white:(BOOL)white {
    
    NSNumber *selectedCategoryIndexNUmber = [CategoryListEditViewController selectedCategoryIndexForCategory:category book:book];
    NSArray *categoryNames = [book.currentCategories collect:^id(CKCategory *category) {
        return category.name;
    }];
    
    if (self = [super initWithEditView:editView delegate:delegate items:categoryNames
                         selectedIndex:selectedCategoryIndexNUmber editingHelper:editingHelper white:white
                                 title:kCategoryTitle]) {
        self.allowSelection = YES;
        self.addItemsFromTop = YES;
        self.canAddItemText = @"ADD CATEGORY";
    }
    
    return self;
}

#pragma mark - CKListEditViewController methods

//- (void)loadData {
//    
//}

#pragma mark - Private methods

+ (NSNumber *)selectedCategoryIndexForCategory:(CKCategory *)category book:(CKBook *)book {
    if (category == nil) {
        return nil;
    }
    
    NSInteger categoryIndex = [book.currentCategories findIndexWithBlock:^BOOL(CKCategory *existingCategory) {
        return [category.name CK_equalsIgnoreCase:existingCategory.name];
    }];
    return (categoryIndex >= 0) ? [NSNumber numberWithInteger:categoryIndex] : nil;
}

@end
