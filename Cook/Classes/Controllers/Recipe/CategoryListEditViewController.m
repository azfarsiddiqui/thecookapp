//
//  CategoryListEditViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 31/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CategoryListEditViewController.h"
#import "CKBook.h"
#import "CKCategory.h"
#import "CategoryListCell.h"
#import "MRCEnumerable.h"

@interface CategoryListEditViewController ()

@property (nonatomic, strong) CKBook *book;
@property (nonatomic, strong) CKCategory *selectedCategory;

@end

@implementation CategoryListEditViewController

#define kCategoryTitle  @"Categories"

- (id)initWithEditView:(UIView *)editView book:(CKBook *)book selectedCategory:(CKCategory *)category
              delegate:(id<CKEditViewControllerDelegate>)delegate editingHelper:(CKEditingViewHelper *)editingHelper
                 white:(BOOL)white {
    
    if (self = [super initWithEditView:editView delegate:delegate items:nil selectedIndex:nil
                         editingHelper:editingHelper white:white title:kCategoryTitle]) {
        self.book = book;
        self.selectedCategory = category;
    }
    
    return self;
}

#pragma mark - CKEditViewController methods

// Returns all categories.
- (id)updatedValue {
    return self.items;
}

#pragma mark - CKItemsEditViewController methods

- (void)loadData {
    
    [self.book fetchCategoriesSuccess:^(NSArray *categories) {
        
        self.items = [NSMutableArray arrayWithArray:categories];
        
        // Determine selected index if selectedCategory was given.
        NSInteger selectedCategoryIndex = [categories findIndexWithBlock:^BOOL(CKCategory *category) {
            return [category.objectId isEqualToString:self.selectedCategory.objectId];
        }];
        if (selectedCategoryIndex >= 0) {
            self.selectedIndexNumber = [NSNumber numberWithInteger:selectedCategoryIndex];
        }
        
        [self showItems];
        
    } failure:^(NSError *error) {
        DLog(@"Error loading categories.");
    }];
    
}

- (Class)classForListCell {
    return [CategoryListCell class];
}

- (void)configureCell:(CategoryListCell *)itemCell indexPath:(NSIndexPath *)indexPath {
    [super configureCell:itemCell indexPath:indexPath];
    
    CategoryListCell *categoryCell = (CategoryListCell *)itemCell;
    categoryCell.book = self.book;
}

- (id)createNewItem {
    return [CKCategory categoryForName:nil book:self.book];
}

@end
