//
//  IngredientsEditingViewController.m
//  Cook
//
//  Created by Jonny Sagorin on 2/4/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "IngredientsEditingViewController.h"
#import "IngredientEditorViewController.h"
#import "CKEditingTextField.h"
#import "CKTextFieldEditingViewController.h"
#import "IngredientTableViewCell.h"
#import <QuartzCore/QuartzCore.h>

#define kIngredientsTableViewCell   @"IngredientsTableViewCell"
#define kTableViewInsets            UIEdgeInsetsMake(50.0, 50.0, 50.0, 50.0)

@interface IngredientsEditingViewController () <UITableViewDataSource,UITableViewDelegate, IngredientEditorDelegate>
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) IngredientEditorViewController *ingredientEditingViewController;
@end

@implementation IngredientsEditingViewController

#pragma mark - CKEditingViewController methods

- (UIView *)createTargetEditingView {
    return self.tableView;
}

- (void)editingViewWillAppear:(BOOL)appear {
    if (!appear) {
        [self.titleLabel removeFromSuperview];
    }
    [super editingViewWillAppear:appear];
}

- (void)editingViewDidAppear:(BOOL)appear {
    [super editingViewDidAppear:appear];
    
    if (appear) {
        [self addSubviews];
    }
}

- (void)performSave {
    
    UITableView *tableView = (UITableView *)self.targetEditingView;
    //result of a save - from incumbent view
    NSString * delimitedString = [[self.ingredientList valueForKey:@"description"] componentsJoinedByString:@"\n"];
    [self.delegate editingView:self.sourceEditingView saveRequestedWithResult:delimitedString];
    
    [super performSave];
}

#pragma mark - UITableViewDataSource

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90.0f;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.ingredientList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *data = [self.ingredientList objectAtIndex:indexPath.row];
    IngredientTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kIngredientsTableViewCell];
    [cell configureCellWithText:data forRowAtIndexPath:indexPath];
    return cell;
}

#pragma mark - UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect startingFrame = CGRectMake(self.tableView.frame.origin.x,
                                      self.tableView.frame.origin.y + self.tableView.frame.size.height,
                                      self.tableView.frame.size.width,
                                      0.0f);
    self.ingredientEditingViewController = [[IngredientEditorViewController alloc]initWithFrame:startingFrame
                                                                                               withViewInsets:kTableViewInsets];
    self.ingredientEditingViewController.ingredientList = self.ingredientList;
    self.ingredientEditingViewController.selectedIndex = indexPath.row;
    self.ingredientEditingViewController.ingredientEditorDelegate = self;
    [self.view addSubview:self.ingredientEditingViewController.view];
    self.ingredientEditingViewController.view.alpha = 0.0f;
    [UIView animateWithDuration:0.3f
                          delay:0.0f options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.ingredientEditingViewController.view.alpha = 1.0f;
                         [self.ingredientEditingViewController updateFrameSize:self.view.bounds forExpansion:YES];
    }
                     completion:nil
    ];
}

#pragma mark - IngredientEditorDelegate

-(void)didUpdateIngredient:(NSString *)ingredientDescription atRowIndex:(NSInteger)rowIndex
{
    [self.ingredientList replaceObjectAtIndex:rowIndex withObject:ingredientDescription];
    UITableView *tableView = (UITableView *)self.targetEditingView;
    [tableView reloadData];
    [self performSave];
    [self didDismissIngredientEditor];
}

-(void)didDismissIngredientEditor
{
    if (self.ingredientEditingViewController) {
        CGRect endingFrame = CGRectMake(self.tableView.frame.origin.x,
                                          self.tableView.frame.origin.y + self.tableView.frame.size.height,
                                          self.tableView.frame.size.width,
                                          0.0f);
        [UIView animateWithDuration:0.3f
                         animations:^{
                             self.ingredientEditingViewController.view.alpha = 0.0f;
                             [self.ingredientEditingViewController updateFrameSize:endingFrame forExpansion:NO];
                         } completion:^(BOOL finished) {
                             [self.ingredientEditingViewController.view removeFromSuperview];
                             self.ingredientEditingViewController = nil;
                         }];
    }
}

#pragma mark - Private methods

- (void)addSubviews {
    [self addTitleLabel];
}

- (UITableView*)tableView
{
    CGRect frame = CGRectMake(kTableViewInsets.left,
                              kTableViewInsets.top,
                              self.view.bounds.size.width - kTableViewInsets.left - kTableViewInsets.right,
                              self.view.bounds.size.height - kTableViewInsets.top - kTableViewInsets.bottom);
    UITableView *tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.delegate = self;
    [tableView registerClass:[IngredientTableViewCell class] forCellReuseIdentifier:kIngredientsTableViewCell];
    return tableView;
}

- (void)addTitleLabel {
    UIView *tableView = (UIView *)self.targetEditingView;
    
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
