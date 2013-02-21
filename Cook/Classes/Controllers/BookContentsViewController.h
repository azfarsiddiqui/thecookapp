//
//  BookHomeViewController.h
//  Cook
//
//  Created by Jeff Tan-Ang on 19/02/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKBook;

@interface BookContentsViewController : UICollectionViewController

- (id)initWithBook:(CKBook *)book;

@end
