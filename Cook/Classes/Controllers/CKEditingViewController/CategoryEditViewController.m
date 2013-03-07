//
//  CategoryEditViewController.m
//  Cook
//
//  Created by Jonny Sagorin on 2/28/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CategoryEditViewController.h"
#import "NSArray+Enumerable.h"
#import "CategoryTableViewCell.h"
#import "Theme.h"

#define kCategoryTableViewCellIdentifier @"CategoryTableViewCellIdentifier"

@interface CategoryEditViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong) NSArray *categories;
@property (nonatomic,strong) UITableView *tableView;
@end

@implementation CategoryEditViewController

-(id)initWithDelegate:(id<CKEditingViewControllerDelegate>)delegate sourceEditingView:(CKEditableView *)sourceEditingView
{
    if (self = [super initWithDelegate:delegate sourceEditingView:sourceEditingView]) {
    }
    return self;
}

-(UIView *)createTargetEditingView
{
    UIView *mainView = [super createTargetEditingView];
    [self addTableView:mainView];
    return mainView;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self data];
    
}

- (void)performSave {
    [self.delegate editingView:self.sourceEditingView saveRequestedWithResult:self.selectedCategory];
    [super performSave];
}

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.categories count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CategoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCategoryTableViewCellIdentifier];
    Category *category = [self.categories objectAtIndex:indexPath.row];
    [cell configureCellWithCategory:category];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90.0f;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedCategory = [self.categories objectAtIndex:indexPath.row];
}

#pragma mark - Private Methods
-(void) data
{
    //data needed by categories selection
    [Category listCategories:^(NSArray *results) {
        self.categories = results;
        [self.tableView reloadData];
        [self setCategoryInList];
    } failure:^(NSError *error) {
        DLog(@"Could not retrieve categories: %@", [error description]);
    }];
}

-(void) addTableView:(UIView*)mainView
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, mainView.frame.size.width, mainView.frame.size.height)
                                                  style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.autoresizingMask = UIViewAutoresizingNone;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.scrollEnabled = YES;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[CategoryTableViewCell class] forCellReuseIdentifier:kCategoryTableViewCellIdentifier];
    [mainView addSubview:self.tableView];
}

-(void) setCategoryInList
{
    if (self.selectedCategory) {
        [self.categories enumerateObjectsUsingBlock:^(Category *category, NSUInteger idx, BOOL *stop) {
            if ([self.selectedCategory.name isEqualToString:category.name]) {
                stop = YES;
                [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0] animated:NO
                                      scrollPosition:UITableViewScrollPositionMiddle];
            }
        }];
    }
}

@end
