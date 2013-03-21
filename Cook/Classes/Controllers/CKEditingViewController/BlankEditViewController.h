//
//  BlankEditViewController.h
//  Cook
//
//  Created by Jonny Sagorin on 2/28/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKEditingViewController.h"

@interface BlankEditViewController : CKEditingViewController
@property(nonatomic,assign) float backgroundAlpha;
@property (nonatomic,assign) UIEdgeInsets mainViewInsets;

-(void)updateViewAlphas:(float)alphas;
@end
