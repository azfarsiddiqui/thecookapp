//
//  CategoryEditViewController.h
//  Cook
//
//  Created by Jonny Sagorin on 2/28/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKEditingViewController.h"
#import "BlankEditViewController.h"
#import "Category.h"

@interface CategoryEditViewController : BlankEditViewController
@property (nonatomic,strong) Category *selectedCategory;
@property (nonatomic, strong) UIFont *titleFont;

@end
