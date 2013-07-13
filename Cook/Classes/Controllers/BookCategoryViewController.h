//
//  BookCategoryViewController.h
//  Cook
//
//  Created by Jeff Tan-Ang on 13/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKBook;
@class CKCategory;

@interface BookCategoryViewController : UICollectionViewController

- (id)initWithBook:(CKBook *)book category:(CKCategory *)category;

@end
