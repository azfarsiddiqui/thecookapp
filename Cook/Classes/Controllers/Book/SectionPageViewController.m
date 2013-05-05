//
//  SectionPageViewController.m
//  Cook
//
//  Created by Jonny Sagorin on 12/12/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "SectionPageViewController.h"
#import "CKCategory.h"
#import "Theme.h"
#import "ContentsTableViewCell.h"

@interface SectionPageViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UILabel *sectionNameLabel;
@end

@implementation SectionPageViewController

#define kCategoryFont   [Theme defaultBoldFontWithSize:64.0]
#define kLabelOffset    CGPointMake(624.0, 190.0)
#define kSectionCellId   @"kSectionCellId"
#define kTableInsets    UIEdgeInsetsMake(50.0, 0.0, 0.0, 100.0)

- (void)initPageView {
    [self initSectionNameLabel];
    [self initTableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    DLog();
    [self showContentsButton:YES];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    DLog();
}

- (void)setSectionName:(NSString *)sectionName {

    _sectionName = sectionName;
    
    NSString *sectionDisplay = [self.sectionName uppercaseString];
    CGSize size = [sectionDisplay sizeWithFont:kCategoryFont
                              constrainedToSize:CGSizeMake(self.view.bounds.size.width - kLabelOffset.x,
                                                           self.view.bounds.size.height)
                                  lineBreakMode:NSLineBreakByWordWrapping];

    self.sectionNameLabel.frame = CGRectMake(self.sectionNameLabel.frame.origin.x,
                                          self.sectionNameLabel.frame.origin.y,
                                          size.width,
                                          size.height);
    self.sectionNameLabel.text = sectionDisplay;
    
    // Update tableview.
    self.tableView.frame = CGRectMake(self.tableView.frame.origin.x,
                                      self.sectionNameLabel.frame.origin.y + self.sectionNameLabel.frame.size.height,
                                      self.tableView.frame.size.width,
                                      self.view.bounds.size.height - self.sectionNameLabel.frame.origin.y - self.sectionNameLabel.frame.size.height - kTableInsets.top - kTableInsets.bottom);
}

-(void)refreshData
{
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.recipes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CKRecipe *recipe = [self.recipes objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [self cellForTableView:tableView indexPath:indexPath];
    cell.textLabel.text = [recipe.name uppercaseString];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", [self.dataSource pageNumForRecipeAtCategoryIndex:indexPath.row forCategoryName:self.sectionName]];
    return cell;
}
#pragma mark - UITableViewDelegate methods
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSUInteger requestedPageIndex = [self.dataSource pageNumForRecipeAtCategoryIndex:indexPath.row forCategoryName:self.sectionName];
    [self.delegate recipeWithIndexRequested:requestedPageIndex];
}

#pragma mark - Private methods

-(UITableViewCell*) cellForTableView:(UITableView*)tableView indexPath:(NSIndexPath*)indexPath
{
    UITableViewCell *tableViewCell = [tableView dequeueReusableCellWithIdentifier:kSectionCellId forIndexPath:indexPath];
    tableViewCell.textLabel.textColor = [Theme categoryViewTextColor];
    tableViewCell.textLabel.font = [Theme defaultBoldFontWithSize:16.0f];
    tableViewCell.detailTextLabel.textColor = [Theme defaultLabelColor];
    tableViewCell.detailTextLabel.font = [Theme defaultBoldFontWithSize:16.0f];
    
    return tableViewCell;
}

- (void)initSectionNameLabel {
    UILabel *sectionNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(kLabelOffset.x, kLabelOffset.y, 0.0, 0.0)];
    sectionNameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    sectionNameLabel.numberOfLines = 0;
    sectionNameLabel.backgroundColor = [UIColor clearColor];
    sectionNameLabel.font = kCategoryFont;
    sectionNameLabel.textColor = [Theme categoryViewTextColor];
    sectionNameLabel.shadowColor = [UIColor whiteColor];
    sectionNameLabel.shadowOffset = CGSizeMake(0.0, 1.0);
    sectionNameLabel.minimumScaleFactor = 0.5;
    [self.view addSubview:sectionNameLabel];
    self.sectionNameLabel = sectionNameLabel;
}

- (void)initTableView {
    CGFloat categoryLabelxOffset = self.sectionNameLabel.frame.origin.x;
    CGFloat categoryLabelyOffset = self.sectionNameLabel.frame.origin.y;
    CGFloat categoryLabelHeight = self.sectionNameLabel.frame.size.height;
    CGFloat availableWidth = self.view.bounds.size.width - categoryLabelxOffset;
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(categoryLabelxOffset + kTableInsets.left,
                                                                           categoryLabelyOffset + categoryLabelHeight + kTableInsets.top,
                                                                           availableWidth - kTableInsets.left - kTableInsets.right,
                                                                           self.view.bounds.size.height - categoryLabelyOffset - categoryLabelHeight - kTableInsets.top - kTableInsets.bottom)
                                                          style:UITableViewStylePlain];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.scrollEnabled = NO;
    tableView.autoresizingMask = UIViewAutoresizingNone;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.scrollEnabled = NO;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    [self.tableView registerClass:[ContentsTableViewCell class] forCellReuseIdentifier:kSectionCellId];
}

@end
