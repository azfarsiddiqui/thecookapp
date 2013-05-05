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

@property (nonatomic, assign) id<CKListCollectionViewCellDelegate> delegate;

- (void)configureText:(NSString *)text;
- (void)configureText:(NSString *)text editable:(BOOL)editable;
- (void)configureText:(NSString *)text font:(UIFont *)font;
- (void)configureText:(NSString *)text font:(UIFont *)font editable:(BOOL)editable;
- (void)configureText:(NSString *)text editable:(BOOL)editable selected:(BOOL)selected;
- (void)configureText:(NSString *)text placeholder:(NSString *)placeholder font:(UIFont *)font editable:(BOOL)editable;
- (void)configureText:(NSString *)text placeholder:(NSString *)placeholder font:(UIFont *)font editable:(BOOL)editable
             selected:(BOOL)selected;
- (void)configurePlaceholder:(NSString *)placeholder;
- (void)configurePlaceholder:(NSString *)placeholder font:(UIFont *)font;
- (void)configurePlaceholder:(NSString *)placeholder editable:(BOOL)editable;
- (UIEdgeInsets)listItemInsets;
- (void)focus:(BOOL)focus;
- (void)allowSelection:(BOOL)selection;
- (id)currentValue;

@end
