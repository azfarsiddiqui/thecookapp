//
//  CategoryListEditViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 7/05/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CategoryItemsEditViewController.h"
#import "CategoryItemCollectionViewCell.h"
#import "CKBook.h"
#import "CKCategory.h"
#import "MRCEnumerable.h"
#import "NSString+Utilities.h"

@interface CategoryItemsEditViewController ()

@property (nonatomic, strong) CKBook *book;
@property (nonatomic, strong) CKCategory *selectedCategory;

@end

@implementation CategoryItemsEditViewController

#define kCategoryTitle  @"Categories"

- (id)initWithEditView:(UIView *)editView book:(CKBook *)book delegate:(id<CKEditViewControllerDelegate>)delegate
     editingHelper:(CKEditingViewHelper *)editingHelper white:(BOOL)white {
    
    return [self initWithEditView:editView book:book selectedCategory:nil delegate:delegate editingHelper:editingHelper
                            white:white];
}

- (id)initWithEditView:(UIView *)editView book:(CKBook *)book selectedCategory:(CKCategory *)category
          delegate:(id<CKEditViewControllerDelegate>)delegate editingHelper:(CKEditingViewHelper *)editingHelper
             white:(BOOL)white {
    
    if (self = [super initWithEditView:editView delegate:delegate items:nil selectedIndex:nil
                         editingHelper:editingHelper white:white title:kCategoryTitle]) {
        self.book = book;
        self.selectedCategory = category;
        self.addItemsFromTop = YES;
    }
    
    return self;
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

- (void)saveAndDismissItems:(BOOL)save {
    [super saveAndDismissItems:save];
}

- (Class)classForCell {
    return [CategoryItemCollectionViewCell class];
}

- (void)configureCell:(CKItemCollectionViewCell *)itemCell indexPath:(NSIndexPath *)indexPath {
    [super configureCell:itemCell indexPath:indexPath];
    
    CategoryItemCollectionViewCell *categoryCell = (CategoryItemCollectionViewCell *)itemCell;
    categoryCell.book = self.book;
}

#pragma mark - Private methods

@end
