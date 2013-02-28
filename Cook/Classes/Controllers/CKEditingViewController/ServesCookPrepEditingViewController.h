//
//  ServesEditingViewController.h
//  Cook
//
//  Created by Jonny Sagorin on 2/20/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKEditingViewController.h"
#import "BlankEditViewController.h"

@interface ServesCookPrepEditingViewController : BlankEditViewController
@property (nonatomic, assign) NSInteger numServes;
@property (nonatomic, assign) NSInteger cookingTimeInMinutes;
@property (nonatomic, assign) NSInteger prepTimeInMinutes;

@end
