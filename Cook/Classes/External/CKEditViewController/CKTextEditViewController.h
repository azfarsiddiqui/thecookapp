//
//  CKTextEditViewController.h
//  CKEditViewControllerDemo
//
//  Created by Jeff Tan-Ang on 28/04/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKEditViewController.h"

@interface CKTextEditViewController : CKEditViewController

@property (nonatomic, assign) NSUInteger characterLimit;
@property (nonatomic, strong) UILabel *limitLabel;
@property (nonatomic, assign) NSTextAlignment textAlignment;
@property (nonatomic, assign) BOOL showLimit;
@property (nonatomic, assign) BOOL textLimited;
@property (nonatomic, assign) BOOL forceUppercase;
@property (nonatomic, assign) BOOL clearOnFocus;

- (id)initWithEditView:(UIView *)editView delegate:(id<CKEditViewControllerDelegate>)delegate
         editingHelper:(CKEditingViewHelper *)editingHelper white:(BOOL)white title:(NSString *)title
        characterLimit:(NSUInteger)characterLimit;

@end
