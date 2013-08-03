//
//  RecipeViewController.h
//  RecipeViewPrototype
//
//  Created by Jeff Tan-Ang on 9/04/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookModalViewController.h"

@class CKRecipe;
@class CKBook;

@interface RecipeViewController : UIViewController <BookModalViewController>

// Create new recipe in the given book and page.
- (id)initWithBook:(CKBook *)book page:(NSString *)page;

// Create with the given recipe and book.
- (id)initWithRecipe:(CKRecipe *)recipe;
- (id)initWithRecipe:(CKRecipe *)recipe book:(CKBook *)book;

@end
