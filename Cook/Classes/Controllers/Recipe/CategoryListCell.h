//
//  CategoryListCell.h
//  Cook
//
//  Created by Jonny Sagorin on 10/8/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Category.h"

@interface CategoryListCell : UICollectionViewCell
-(void)configure:(Category*)category;
-(void)selectCell:(BOOL)selected;
@end
