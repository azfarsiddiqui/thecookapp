//
//  CKListCollectionViewCell.h
//  CKEditViewControllerDemo
//
//  Created by Jeff Tan-Ang on 1/05/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKEditingTextBoxView.h"

@class CKListCollectionViewCell;

@protocol CKListCollectionViewCellDelegate <NSObject>

- (void)listItemAddedForCell:(CKListCollectionViewCell *)cell;
- (void)listItemChangedForCell:(CKListCollectionViewCell *)cell;
- (void)listItemCancelledForCell:(CKListCollectionViewCell *)cell;
- (BOOL)listItemValidatedForCell:(CKListCollectionViewCell *)cell;

@end

@interface CKListCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) id<CKListCollectionViewCellDelegate> delegate;
@property (nonatomic, strong) NSString *placeholder;

- (void)configureValue:(id)value;
- (void)configureValue:(id)value editable:(BOOL)editable;
- (void)configureValue:(id)value font:(UIFont *)font;
- (void)configureValue:(id)value font:(UIFont *)font editable:(BOOL)editable;
- (void)configureValue:(id)value editable:(BOOL)editable selected:(BOOL)selected;
- (void)configureValue:(id)value placeholder:(NSString *)placeholder font:(UIFont *)font editable:(BOOL)editable;
- (void)configureValue:(id)valuet placeholder:(NSString *)placeholder font:(UIFont *)font editable:(BOOL)editable
             selected:(BOOL)selected;
- (void)configurePlaceholder:(NSString *)placeholder;
- (void)configurePlaceholder:(NSString *)placeholder font:(UIFont *)font;
- (void)configurePlaceholder:(NSString *)placeholder editable:(BOOL)editable;
- (UIEdgeInsets)listItemInsets;
- (void)focus:(BOOL)focus;
- (void)allowSelection:(BOOL)selection;
- (id)currentValue;
- (NSString *)textValueForValue:(id)value;

@end
