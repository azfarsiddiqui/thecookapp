//
//  BookIndexLayout.h
//  Cook
//
//  Created by Jeff Tan-Ang on 22/03/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BookIndexLayoutDataSource

- (NSArray *)bookIndexLayoutCategories;

@end

@interface BookIndexLayout : UICollectionViewLayout

- (id)initWithDataSource:(id<BookIndexLayoutDataSource>)dataSource;
- (NSInteger)numberOfCategoriesToDisplay;

@end
