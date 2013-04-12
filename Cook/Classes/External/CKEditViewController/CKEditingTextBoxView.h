//
//  CKEditingTextBoxView.h
//  CKEditViewControllerDemo
//
//  Created by Jeff Tan-Ang on 12/04/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CKEditingTextBoxView : UIView

- (id)initWithEditingFrame:(CGRect)editingFrame contentInsets:(UIEdgeInsets)contentInsets;
- (id)initWithEditingFrame:(CGRect)editingFrame contentInsets:(UIEdgeInsets)contentInsets white:(BOOL)white;
- (void)showEditingIcon:(BOOL)show animated:(BOOL)animated;

@end
