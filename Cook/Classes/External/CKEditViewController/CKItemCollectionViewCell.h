//
//  CKItemCollectionViewCell.h
//  CKEditViewControllerDemo
//
//  Created by Jeff Tan-Ang on 14/05/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKItemsEditViewController.h"

@interface CKItemCollectionViewCell : UICollectionViewCell

@property (nonatomic, assign) id<CKItemCellDelegate> delegate;
@property (nonatomic, assign) BOOL placeholder;
@property (nonatomic, assign) BOOL allowSelectionState;
@property (nonatomic, strong) UIImageView *boxImageView;

- (void)focusForEditing:(BOOL)focus;
- (BOOL)shouldBeSelectedForState:(BOOL)selected;
- (void)configureValue:(id)value;
- (id)currentValue;

@end
