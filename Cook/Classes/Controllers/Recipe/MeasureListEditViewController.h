//
//  MeasureListEditViewController.h
//  Cook
//
//  Created by Gerald on 22/01/2014.
//  Copyright (c) 2014 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKListEditViewController.h"

@interface MeasureListEditViewController : CKListEditViewController

- (id)initWithEditView:(UIView *)editView
              delegate:(id<CKEditViewControllerDelegate>)delegate
         editingHelper:(CKEditingViewHelper *)editingHelper
                 white:(BOOL)white;

@end
