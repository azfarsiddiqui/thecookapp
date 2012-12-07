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
-(void)didSelectCategoryWithName:(NSString*)categoryName;
@end
@interface CategoryListViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource>
@property(nonatomic,strong) NSArray *categories;
@property(nonatomic,assign) id<CategoryListViewDelegate> delegate;
@property(nonatomic,strong) NSString *selectedCategoryName;
-(void)show:(BOOL)show;
@end
