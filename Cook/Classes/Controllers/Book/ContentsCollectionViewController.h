//
//  ContentsCollectionViewController.h
//  Cook
//
//  Created by Jeff Tan-Ang on 9/11/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookViewController.h"
@interface ContentsCollectionViewController : UICollectionViewController

- (void)loadRecipes:(NSArray *)recipes;
@property(nonatomic,assign) id<BookViewDataSource> bookViewDataSource;
@property(nonatomic,assign) id<BookViewDelegate> bookViewDelegate;
@end
