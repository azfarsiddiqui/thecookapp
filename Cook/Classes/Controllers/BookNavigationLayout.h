//
//  BookNavigationLayout.h
//  Cook
//
//  Created by Jeff Tan-Ang on 12/02/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookNavigationDataSource.h"

@class CKRecipe;

@interface BookNavigationLayout : UICollectionViewLayout

- (id)initWithDataSource:(id<BookNavigationDataSource>)dataSource;

+ (CGSize)unitSize;
+ (UIEdgeInsets)pageInsets;
+ (CGFloat)columnSeparatorWidth;;

@end
