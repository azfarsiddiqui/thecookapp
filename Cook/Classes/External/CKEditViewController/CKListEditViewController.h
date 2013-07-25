//
//  CKListEditViewController.h
//  CKEditViewControllerDemo
//
//  Created by Jeff Tan-Ang on 30/04/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKEditViewController.h"
#import "CKEditingViewHelper.h"

@interface CKListEditViewController : CKEditViewController

@property (nonatomic, strong) NSMutableArray *listItems;
@property (nonatomic, strong) NSNumber *selectedIndexNumber;
@property (nonatomic, assign) BOOL allowSelection;

@property (nonatomic, assign) BOOL canReorder;
@property (nonatomic, assign) BOOL canAddItems;
@property (nonatomic, assign) BOOL canDeleteItems;

- (id)initWithEditView:(UIView *)editView delegate:(id<CKEditViewControllerDelegate>)delegate
                 items:(NSArray *)items editingHelper:(CKEditingViewHelper *)editingHelper white:(BOOL)white
                 title:(NSString *)title;
- (id)initWithEditView:(UIView *)editView delegate:(id<CKEditViewControllerDelegate>)delegate
                 items:(NSArray *)items selectedIndex:(NSNumber *)selectedIndexNumber
         editingHelper:(CKEditingViewHelper *)editingHelper white:(BOOL)white title:(NSString *)title;

- (void)loadData;

// The class type for cell.
- (Class)classForListCell;

// Extended lifecycle events.
- (void)itemsDidShow:(BOOL)show;

@end
