//
//  CKListEditViewController.h
//  CKEditViewControllerDemo
//
//  Created by Jeff Tan-Ang on 30/04/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKEditViewController.h"
#import "CKEditingViewHelper.h"

@class CKListCell;

@interface CKListEditViewController : CKEditViewController

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) NSNumber *selectedIndexNumber;
@property (nonatomic, assign) BOOL allowSelection;
@property (nonatomic, strong) CKListCell *editingCell;

@property (nonatomic, assign) BOOL itemsLoaded;
@property (nonatomic, assign) BOOL canReorderItems;
@property (nonatomic, assign) BOOL canAddItems;
@property (nonatomic, assign) BOOL canDeleteItems;
@property (nonatomic, assign) BOOL addItemAfterEach;
@property (nonatomic, assign) BOOL allowMultipleSelection;

- (id)initWithEditView:(UIView *)editView delegate:(id<CKEditViewControllerDelegate>)delegate
                 items:(NSArray *)items editingHelper:(CKEditingViewHelper *)editingHelper white:(BOOL)white
                 title:(NSString *)title;
- (id)initWithEditView:(UIView *)editView delegate:(id<CKEditViewControllerDelegate>)delegate
                 items:(NSArray *)items selectedIndex:(NSNumber *)selectedIndexNumber
         editingHelper:(CKEditingViewHelper *)editingHelper white:(BOOL)white title:(NSString *)title;

- (void)loadData;

// Cell configuration.
- (Class)classForListCell;
- (void)configureCell:(CKListCell *)cell indexPath:(NSIndexPath *)indexPath;
- (void)addCellFromTop;
- (void)addCellToBottom;

// Create new item.
- (id)createNewItem;
- (BOOL)allowedToAdd;

// Extended lifecycle events.
- (void)itemsDidShow:(BOOL)show;

// Show hide items.
- (void)showItems;
- (void)hideItems;

// Cell size
- (CGSize)cellSize;

// Gesture titles.
- (NSString *)pullToReleaseTextForActivated:(BOOL)activated;
- (NSString *)swipeToDeleteTextActivated:(BOOL)activated;

@end
