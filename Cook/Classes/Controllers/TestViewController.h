//
//  TestViewController.h
//  Cook
//
//  Created by Jonny Sagorin on 1/23/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKRecipe.h"
#import "BookModalViewController.h"

@interface TestViewController : UIViewController <BookModalViewController>
-(id) initWithRecipe:(CKRecipe*)recipe selectedBook:(CKBook*)book;
@end
