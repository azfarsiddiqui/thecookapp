//
//  RecipeViewController.h
//  Cook
//
//  Created by Jonny Sagorin on 10/12/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookViewController.h"

@interface RecipeViewController : UIViewController
@property(nonatomic,assign) id<BookViewDelegate> bookViewDelegate;
@end
