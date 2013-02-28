//
//  TextViewEditingViewController.h
//  Cook
//
//  Created by Jonny Sagorin on 1/25/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKEditingViewController.h"

@interface TextViewEditingViewController : CKEditingViewController
//the font of the editable text
@property (nonatomic, strong) UIFont *editableTextFont;
//label title eg 'recipe name'
@property (nonatomic, strong) UIFont *titleFont;

@property (nonatomic, copy) NSString *text;
@property (nonatomic, assign) NSUInteger characterLimit;


@end
