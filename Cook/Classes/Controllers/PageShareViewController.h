//
//  PageShareViewController.h
//  Cook
//
//  Created by Gerald on 4/12/2014.
//  Copyright (c) 2014 Cook Apps Pty Ltd. All rights reserved.
//

#import "ShareViewController.h"

@class CKBook;

@interface PageShareViewController : ShareViewController

- (id)initWithBook:(CKBook *)book pageName:(NSString *)page featuredImageURL:(NSURL *)pageImageURL delegate:(id<ShareViewControllerDelegate>)delegate;

@end
