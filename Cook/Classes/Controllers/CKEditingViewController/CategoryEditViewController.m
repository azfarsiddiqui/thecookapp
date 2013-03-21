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
#define kHeaderHeight       20.0f
#define kOverlayRect        CGRectMake(100.0f,0.0f,824.0f, 20.0f)

@interface CategoryEditViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong) NSArray *categories;
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) UIView *padderView;
@end

@implementation CategoryEditViewController

-(id)initWithDelegate:(id<CKEditingViewControllerDelegate>)delegate sourceEditingView:(CKEditableView *)sourceEditingView
{
    if (self = [super initWithDelegate:delegate sourceEditingView:sourceEditingView]) {
        self.mainViewInsets = UIEdgeInsetsMake(0.0f,100.0f,0.0f,100.0f);
        self.transparentOverlayRect = kOverlayRect;
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
        UIView *mainView = self.targetEditingView;
        [self addPadderView:mainView];
    } else {
        [self.tableView removeFromSuperview];
        [self.padderView removeFromSuperview];
        [self updateViewAlphas:1.0f];
    }
}

- (void)editingViewDidAppear:(BOOL)appear {
    [super editingViewDidAppear:appear];
    if (appear) {
        UIView *mainView = self.targetEditingView;
        [self addTableView:mainView];
        [self data];
        self.tableView.alpha = 0.0f;
        [UIView animateWithDuration:0.15f
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.tableView.alpha = 1.0f;
                         }
                         completion:^(BOOL finished) {
                             [UIView animateWithDuration: 0.15
                                              animations:^{
                                                  [self updateViewAlphas:0.0f];
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
    UIView *headerView = [self newPadderView];
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kHeaderHeight;
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
        [self doneTapped];
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

- (void)addPadderView:(UIView*)mainView {
    self.padderView = [self newPadderView];
//    self.padderView.backgroundColor = [UIColor greenColor];
    self.padderView.frame = CGRectMake(0.0f, 0.0f, 0.0f, kOverlayRect.size.height);
    [mainView addSubview:self.padderView];
}

- (UIView*)newPadderView
{
    UIView *padderView = [[UIView alloc] initWithFrame:CGRectZero];
    padderView.alpha = 0.7f;
    padderView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin;
    padderView.backgroundColor = [UIColor blackColor];
    return padderView;
}

@end
