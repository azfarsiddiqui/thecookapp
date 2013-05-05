//
//  CKListEditViewController.h
//  CKEditViewControllerDemo
//
//  Created by Jeff Tan-Ang on 29/04/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKEditViewController.h"

@protocol CKTableEditViewControllerDataSource <NSObject>

- (NSInteger)tableEditViewControllerNumberOfItems;
- (NSString *)tableEditViewControllerTextItemAtIndex:(NSInteger)itemIndex;

@end

@interface CKTableEditViewController : CKEditViewController

- (id)initWithEditView:(UIView *)editView delegate:(id<CKEditViewControllerDelegate>)delegate
            dataSource:(id<CKTableEditViewControllerDataSource>)dataSource
         editingHelper:(CKEditingViewHelper *)editingHelper white:(BOOL)white title:(NSString *)title;

- (UIEdgeInsets)listItemContentInsets;
- (NSString *)addItemText;
- (void)selectedItemAtIndex:(NSInteger)index;

@end
