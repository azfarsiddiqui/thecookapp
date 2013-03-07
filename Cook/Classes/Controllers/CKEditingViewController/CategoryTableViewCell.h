//
//  CategoryTableViewCell.h
//  Cook
//
//  Created by Jonny Sagorin on 3/7/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Category.h"

@interface CategoryTableViewCell : UITableViewCell

-(void)configureCellWithCategory:(Category *)category forRowAtIndexPath:(NSIndexPath *)indexPath;

@end
