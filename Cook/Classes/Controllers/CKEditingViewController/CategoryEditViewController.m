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
@property (nonatomic,strong) UILabel     *titleLabel;
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
    return mainView;
}


- (void)editingViewWillAppear:(BOOL)appear {
    [super editingViewWillAppear:appear];
    if (appear) {
    } else {
        [self.titleLabel removeFromSuperview];
        [self.tableView removeFromSuperview];
        UIView *mainView = self.targetEditingView;
        mainView.backgroundColor = [UIColor blackColor];
    }
}

- (void)editingViewDidAppear:(BOOL)appear {
    [super editingViewDidAppear:appear];
    if (appear) {
        UIView *mainView = self.targetEditingView;
        
        [self addTableView:mainView];
        [self addTitleLabel:mainView];
        [self data];
        self.tableView.alpha = 0.0f;
        self.titleLabel.alpha = 0.0f;
        [UIView animateWithDuration:0.15f
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.tableView.alpha = 1.0f;
                             self.titleLabel.alpha = 0.7;
//                             mainView.backgroundColor = [UIColor colorWithHue:0.0f saturation:0.0f brightness:0.0f alpha:0.0f];

                         }
                         completion:^(BOOL finished) {
                             [UIView animateWithDuration: 0.15
                                              animations:^{
                                                  mainView.backgroundColor = [UIColor colorWithHue:0.0f saturation:0.0f brightness:0.0f alpha:0.0f];
                                              }];
                         }];
    }
}

- (void)performSave {
    [self.delegate editingView:self.sourceEditingView saveRequestedWithResult:self.selectedCategory];
    [super performSave];
}

#pragma mark - UITableViewDataSource

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *spacerView = [[UIView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, tableView.frame.size.width, kRowHeight)];
    spacerView.backgroundColor = [UIColor clearColor];
    return spacerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kRowHeight;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //padder row
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
    return kRowHeight;
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
                                      scrollPosition:UITableViewScrollPositionTop];

            }
        }];
    }
}

- (void)addTitleLabel:(UIView*)mainView {
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.backgroundColor = [UIColor blackColor];
    titleLabel.text = self.editingTitle;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = self.titleFont;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.shadowColor = [UIColor blackColor];
    titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    [titleLabel sizeToFit];
    titleLabel.frame = CGRectMake(0.0f, 0.0f, mainView.frame.size.width, 90.0f);
    self.titleLabel = titleLabel;
    [mainView addSubview:titleLabel];
}

@end
