//
//  CategoryListViewController.h
//  Cook
//
//  Created by Jonny Sagorin on 10/8/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Category.h"

@protocol CategoryListViewDelegate
-(void)didSelectCategory:(Category*)category;
@end
@interface CategoryListViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource>
@property(nonatomic,strong) NSArray *categories;
@property(nonatomic,assign) id<CategoryListViewDelegate> delegate;
-(void)show:(BOOL)show;
-(void)selectCategoryWithName:(NSString*)categoryName;
@end
