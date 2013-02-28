//
//  TestViewController.h
//  Cook
//
//  Created by Jonny Sagorin on 1/23/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookModalViewController.h"
#import "CKRecipe.h"

@interface TestViewController : UIViewController <BookModalViewController>
@property(nonatomic,strong) CKRecipe *recipe;
@property(nonatomic,strong) CKBook *selectedBook;
@end
