//
//  CKEditableView.h
//  CKBookCoverViewDemo
//
//  Created by Jeff Tan-Ang on 12/12/12.
//  Copyright (c) 2012 Cook App Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CKEditableViewDelegate
- (void)editableViewEditRequestedForView:(UIView *)view;
@end

@interface CKEditableView : UIView

@property (nonatomic, strong) UIButton *editButton;
@property (nonatomic, assign) UIEdgeInsets contentInsets;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, assign) id<CKEditableViewDelegate> delegate;

- (id) initWithDelegate:(id<CKEditableViewDelegate>)delegate;
- (void) enableEditMode:(BOOL)enable;

@end
