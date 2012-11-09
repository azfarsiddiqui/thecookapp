//
//  PageViewController.h
//  Cook
//
//  Created by Jeff Tan-Ang on 8/11/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookViewController.h"

@interface PageViewController : UIViewController

@property (nonatomic, assign) id<BookViewDelegate> delegate;

- (id)initWithBookViewDelegate:(id<BookViewDelegate>)delegate;
- (void)initPageView;
- (void)loadData;

@end
