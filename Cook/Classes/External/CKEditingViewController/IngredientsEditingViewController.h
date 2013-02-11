//
//  IngredientsEditingViewController.h
//  Cook
//
//  Created by Jonny Sagorin on 2/4/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//  View for listing ingredients for editing. Editing not done in this view.
//  Editing view is IngredientEditorViewController
//

#import "CKEditingViewController.h"

@interface IngredientsEditingViewController : CKEditingViewController
//the font of the editable text
@property (nonatomic, strong) UIFont *editableTextFont;
//label title eg 'recipe name'
@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, assign) NSUInteger characterLimit;

//new-line delimited list of ingredients
@property (nonatomic, strong) NSMutableArray *ingredientList;
@end
