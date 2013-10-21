//
//  CKTextViewEditViewController.h
//  CKEditViewControllerDemo
//
//  Created by Jeff Tan-Ang on 16/04/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKTextEditViewController.h"

@interface CKTextViewEditViewController : CKTextEditViewController

@property (nonatomic, assign) NSInteger numLines;
@property (nonatomic, strong) UIFont *textViewFont;
@property (nonatomic, assign) CGFloat maxHeight;
@property (nonatomic, assign) BOOL forceUppercase;

- (BOOL)contentScrollable;

@end
