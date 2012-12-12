//
//  CKTextEditingViewController.h
//  CKEditingViewControllerDemo
//
//  Created by Jeff Tan-Ang on 6/12/12.
//  Copyright (c) 2012 Cook App Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKEditingViewController.h"

@interface CKTextFieldEditingViewController : CKEditingViewController

@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, assign) NSUInteger characterLimit;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, assign) NSTextAlignment textAlignment;

@end
