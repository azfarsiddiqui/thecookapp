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

- (BOOL)listItemEmptyForCell:(CKListCell *)cell;
- (void)listItemFocused:(BOOL)focused cell:(CKListCell *)cell;
- (void)listItemReturnedForCell:(CKListCell *)cell;

@end

@interface CKListCell : UICollectionViewCell <UITextFieldDelegate>

@property (nonatomic, weak) id<CKListCellDelegate> delegate;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIImageView *boxImageView;
@property (nonatomic, assign) BOOL allowSelection;
@property (nonatomic, assign) BOOL allowReorder;
@property (nonatomic, assign) BOOL editMode;
@property (nonatomic, strong) UIFont *font;

+ (UIEdgeInsets)listItemInsets;

- (void)configureValue:(id)value;
- (void)configureValue:(id)value selected:(BOOL)selected;

- (NSString *)textValueForValue:(id)value;
- (id)currentValue;

// Enable editing on cell, empty refers to it being a newly created cell.
- (void)setEditing:(BOOL)editing;
- (void)setEditing:(BOOL)editing empty:(BOOL)empty;

- (BOOL)isEmpty;

@end
