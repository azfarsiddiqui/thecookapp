//
//  IngredientsEditingViewController.h
//  Cook
//
//  Created by Jonny Sagorin on 2/4/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKEditingViewController.h"

@interface IngredientsEditingViewController : CKEditingViewController
//the font of the editable text
@property (nonatomic, strong) UIFont *editableTextFont;
//label title eg 'recipe name'
@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, assign) NSUInteger characterLimit;
@property (nonatomic, copy) NSString *text;
@end
