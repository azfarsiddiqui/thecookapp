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
#define kRowHeight          90.0f

@interface CategoryEditViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong) NSArray *categories;
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation CategoryEditViewController

-(id)initWithDelegate:(id<CKEditingViewControllerDelegate>)delegate sourceEditingView:(CKEditableView *)sourceEditingView
{
    if (self = [super initWithDelegate:delegate sourceEditingView:sourceEditingView]) {
        self.mainViewInsets = UIEdgeInsetsMake(0.0f,100.0f,0.0f,100.0f);
        self.transparentOverlayRect = CGRectMake(100.0f,0.0f,824.0f, 90.0f);
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
    //padder row
    return [self.categories count] + 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CategoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCategoryTableViewCellIdentifier];
    if (indexPath.row > 0) {
        Category *category = [self.categories objectAtIndex:indexPath.row-1];
        [cell configureCellWithCategory:category];
    } else {
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kRowHeight;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row > 0) {
        self.selectedCategory = [self.categories objectAtIndex:indexPath.row-1];
    }
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
    self.tableView.showsVerticalScrollIndicator = NO;
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
    titleLabel.alpha = 0.7f;
    titleLabel.backgroundColor = [UIColor blackColor];
    titleLabel.text = self.editingTitle;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = self.titleFont;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.shadowColor = [UIColor blackColor];
    titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    [titleLabel sizeToFit];
    titleLabel.frame = CGRectMake(tableView.frame.origin.x,
                                  tableView.frame.origin.y,
                                  tableView.frame.size.width,
                                  90.0f);
    [self.view addSubview:titleLabel];
    self.titleLabel = titleLabel;
}

@end
