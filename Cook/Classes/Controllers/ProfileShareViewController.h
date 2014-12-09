//
//  ProfileShareViewController.h
//  Cook
//
//  Created by Gerald on 2/12/2014.
//  Copyright (c) 2014 Cook Apps Pty Ltd. All rights reserved.
//

#import "ShareViewController.h"

@class CKBook;

@interface ProfileShareViewController : ShareViewController

- (id)initWithBook:(CKBook *)book delegate:(id<ShareViewControllerDelegate>)delegate;

@end
