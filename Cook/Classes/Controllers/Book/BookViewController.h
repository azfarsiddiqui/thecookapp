//
//  BookViewController.h
//  Cook
//
//  Created by Jonny Sagorin on 10/10/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKBook.h"
@protocol BookViewDelegate
-(void)closeRequested;
@end

@interface BookViewController : UIViewController
-(id)initWithBook:(CKBook*)book;
@end
