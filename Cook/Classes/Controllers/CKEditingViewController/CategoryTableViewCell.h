//
//  CategoryTableViewCell.h
//  Cook
//
//  Created by Jonny Sagorin on 3/7/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKCategory.h"

@interface CategoryTableViewCell : UITableViewCell

-(void)configureCellWithCategory:(CKCategory *)category;

@end
