//
//  CKGrowingTextViewEditViewController.h
//  Cook
//
//  Created by Gerald on 13/01/2014.
//  Copyright (c) 2014 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKTextEditViewController.h"

@interface CKGrowingTextViewEditViewController : CKTextEditViewController

@property (nonatomic, assign) NSInteger numLines;
@property (nonatomic, strong) UIFont *textViewFont;
@property (nonatomic, assign) CGFloat maxHeight;
@property (nonatomic, assign) BOOL forceUppercase;

- (BOOL)contentScrollable;

@end
