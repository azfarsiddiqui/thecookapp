//
//  CKListTableViewCell.h
//  CKEditViewControllerDemo
//
//  Created by Jeff Tan-Ang on 29/04/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKTableViewCell;

@protocol CKListTableViewCellDelegate <NSObject>

- (void)listTableViewFocusRequestedForCell:(CKTableViewCell *)cell;

@end

@interface CKTableViewCell : UITableViewCell

@property (nonatomic, assign) id<CKListTableViewCellDelegate> delegate;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier borderHeight:(CGFloat)borderHeight font:(UIFont *)font
                contentInsets:(UIEdgeInsets)contentInsets;
- (void)setItemText:(NSString *)itemText;
- (void)setItemText:(NSString *)itemText editable:(BOOL)editable;

@end
