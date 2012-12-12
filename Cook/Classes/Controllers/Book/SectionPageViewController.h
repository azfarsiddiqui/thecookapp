//
//  SectionPageViewController.h
//  Cook
//
//  Created by Jonny Sagorin on 12/12/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "PageViewController.h"

@interface SectionPageViewController : PageViewController
-(UITableViewCell*) cellForTableView:(UITableView*)tableView indexPath:(NSIndexPath*)indexPath;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSString *sectionName;
@property (nonatomic,strong) NSArray *recipes;
-(void) refreshData;

@end
