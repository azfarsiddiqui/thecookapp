//
//  BookProfileViewController.h
//  Cook
//
//  Created by Jeff Tan-Ang on 26/02/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookPageViewController.h"

@class CKBook;

@interface BookProfileViewController : BookPageViewController

- (id)initWithBook:(CKBook *)book;

@end
