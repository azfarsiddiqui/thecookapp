//
//  CKListCell.h
//  CKEditViewControllerDemo
//
//  Created by Jeff Tan-Ang on 23/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKListCell;

@protocol CKListCellDelegate <NSObject>

- (void)listItemChangedForCell:(CKListCell *)cell;
- (void)listItemProcessCancelForCell:(CKListCell *)cell;
- (BOOL)listItemValidatedForCell:(CKListCell *)cell;
- (BOOL)listItemCanCancelForCell:(CKListCell *)cell;

@end

@interface CKListCell : UICollectionViewCell

@property (nonatomic, weak) id<CKListCellDelegate> delegate;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, assign) BOOL allowSelection;
@property (nonatomic, assign) BOOL editMode;
@property (nonatomic, strong) UIFont *font;

+ (UIEdgeInsets)listItemInsets;

- (void)configureValue:(id)value;
- (void)configureValue:(id)value selected:(BOOL)selected;

- (NSString *)textValueForValue:(id)value;
- (id)currentValue;
- (void)setEditing:(BOOL)editMode;

@end
