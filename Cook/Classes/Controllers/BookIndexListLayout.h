//
//  BookIndexListLayout.h
//  Cook
//
//  Created by Jeff Tan-Ang on 3/06/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BookIndexListLayoutDataSource

- (NSArray *)bookIndexListLayoutCategories;

@end

@interface BookIndexListLayout : UICollectionViewLayout

- (id)initWithDataSource:(id<BookIndexListLayoutDataSource>)dataSource;

@end
