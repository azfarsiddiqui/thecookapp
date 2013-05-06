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

@property (nonatomic, assign) BOOL canAddItems;
@property (nonatomic, assign) BOOL addItemsFromTop;
@property (nonatomic, strong) NSString *canAddItemText;
@property (nonatomic, assign) BOOL editable;
@property (nonatomic, assign) BOOL allowSelection;
@property (nonatomic, assign) BOOL incrementalAdd;

- (id)initWithEditView:(UIView *)editView delegate:(id<CKEditViewControllerDelegate>)delegate
                 items:(NSArray *)items editingHelper:(CKEditingViewHelper *)editingHelper white:(BOOL)white
                 title:(NSString *)title;
- (id)initWithEditView:(UIView *)editView delegate:(id<CKEditViewControllerDelegate>)delegate
                 items:(NSArray *)items selectedIndex:(NSNumber *)selectedIndexNumber
         editingHelper:(CKEditingViewHelper *)editingHelper white:(BOOL)white title:(NSString *)title;

- (NSString *)addItemText;
- (void)selectedItemAtIndex:(NSInteger)index;
- (void)loadData;
- (void)showItems;
- (void)showItems:(BOOL)show;
- (void)showItems:(BOOL)show completion:(void (^)())completion;

@end
