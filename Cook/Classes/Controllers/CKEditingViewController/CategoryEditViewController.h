//
//  CategoryEditViewController.h
//  Cook
//
//  Created by Jonny Sagorin on 2/28/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKEditingViewController.h"
#import "EditingViewController.h"
#import "CKCategory.h"

@interface CategoryEditViewController : EditingViewController
@property (nonatomic,strong) CKCategory *selectedCategory;
@end
