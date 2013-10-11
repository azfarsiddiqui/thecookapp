//
//  BookCoverPhotoViewController.h
//  Cook
//
//  Created by Jeff Tan-Ang on 11/10/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKNavigationController.h"
#import "BookModalViewController.h"

@class CKBook;

@interface BookCoverPhotoViewController : UIViewController <BookModalViewController>

- (id)initWithBook:(CKBook *)book;

@end
