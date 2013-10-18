//
//  RecipeDetailsViewController.h
//  SnappingScrollViewDemo
//
//  Created by Jeff Tan-Ang on 8/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookModalViewController.h"

@class CKRecipe;
@class CKBook;

@interface RecipeDetailsViewController : UIViewController <BookModalViewController, UIAlertViewDelegate>

@property (nonatomic, assign) BOOL hideNavigation;

- (id)initWithRecipe:(CKRecipe *)recipe;
- (id)initWithRecipe:(CKRecipe *)recipe book:(CKBook *)book;
- (id)initWithBook:(CKBook *)book page:(NSString *)page;

@end
