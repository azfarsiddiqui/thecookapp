//
//  CKImageEditViewController.h
//  CKEditViewControllerDemo
//
//  Created by Jeff Tan-Ang on 15/04/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKEditViewController.h"

@interface CKImageEditViewController : CKEditViewController

- (id)initWithEditView:(UIView *)editView delegate:(id<CKEditViewControllerDelegate>)delegate
         editingHelper:(CKEditingViewHelper *)editingHelper white:(BOOL)white image:(UIImage *)image;

@end
