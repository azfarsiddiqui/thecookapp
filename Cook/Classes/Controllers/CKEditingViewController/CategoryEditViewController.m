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
@property (nonatomic, strong) UILabel *titleLabel;

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


- (void)editingViewWillAppear:(BOOL)appear {
    [super editingViewWillAppear:appear];
    if (!appear) {
        [self.titleLabel removeFromSuperview];
    } else {
        [self data];
    }
    
}

- (void)editingViewDidAppear:(BOOL)appear {
    [super editingViewDidAppear:appear];
    if (appear) {
        [self addTitleLabel];
    }
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

- (void)addTitleLabel {
    UITableView *tableView = (UITableView *)self.targetEditingView;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = self.editingTitle;
    titleLabel.font = self.titleFont;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.shadowColor = [UIColor blackColor];
    titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    [titleLabel sizeToFit];
    titleLabel.frame = CGRectMake(tableView.frame.origin.x + floorf((tableView.frame.size.width - titleLabel.frame.size.width) / 2.0),
                                  tableView.frame.origin.y - titleLabel.frame.size.height + 5.0,
                                  titleLabel.frame.size.width,
                                  titleLabel.frame.size.height);
    [self.view addSubview:titleLabel];
    self.titleLabel = titleLabel;
}

@end
