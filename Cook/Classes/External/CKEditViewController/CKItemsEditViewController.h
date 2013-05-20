//
//  CKItemsEditViewController.h
//  CKEditViewControllerDemo
//
//  Created by Jeff Tan-Ang on 13/05/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKEditViewController.h"

@class CKItemCollectionViewCell;

@protocol CKItemCellDelegate <NSObject>

- (BOOL)processedValueForCell:(CKItemCollectionViewCell *)cell;
- (void)returnRequestedForCell:(CKItemCollectionViewCell *)cell;

@end

@interface CKItemsEditViewController : CKEditViewController

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, assign) BOOL allowSelectionState;
@property (nonatomic, assign) BOOL addItemsFromTop;
@property (nonatomic, strong) NSNumber *selectedIndexNumber;

- (id)initWithEditView:(UIView *)editView delegate:(id<CKEditViewControllerDelegate>)delegate
                 items:(NSArray *)items editingHelper:(CKEditingViewHelper *)editingHelper white:(BOOL)white
                 title:(NSString *)title;

- (id)initWithEditView:(UIView *)editView delegate:(id<CKEditViewControllerDelegate>)delegate
                 items:(NSArray *)items selectedIndex:(NSNumber *)selectedIndexNumber
         editingHelper:(CKEditingViewHelper *)editingHelper white:(BOOL)white title:(NSString *)title;

// Data loading.
- (void)loadData;
- (void)showItems;
- (void)showItems:(BOOL)show;

// Customisation options.
- (Class)classForCell;
- (void)configureCell:(CKItemCollectionViewCell *)itemCell indexPath:(NSIndexPath *)indexPath;
- (void)selectCellAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)validateCell:(CKItemCollectionViewCell *)itemCell;
- (BOOL)readyForInsertionForPlaceholderCell:(CKItemCollectionViewCell *)placeholderCell;
- (void)resetPlaceholderCell:(CKItemCollectionViewCell *)placeholderCell;
- (id)itemValueAtIndex:(NSInteger)index;
- (NSInteger)itemIndexForCell:(CKItemCollectionViewCell *)itemCell;

// Extended lifecycle events.
- (void)itemsDidShow:(BOOL)show;

@end
