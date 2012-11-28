//
//  CategoryPageViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 12/11/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "CategoryPageViewController.h"
#import "Category.h"
#import "Theme.h"
#import "ContentsTableViewCell.h"

@interface CategoryPageViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSString *categoryName;
@property (nonatomic, strong) UILabel *categoryLabel;
@property (nonatomic, strong) UIImageView *categoryImageView;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation CategoryPageViewController

#define kCategoryFont   [Theme defaultFontBoldWithSize:64.0]
#define kLabelOffset    CGPointMake(600.0, 190)
#define kRecipeCellId   @"kRecipeCellId"
#define kTableInsets    UIEdgeInsetsMake(0.0, 0.0, 50.0, 50.0)

- (void)initPageView {
    [self initCategoryImageView];
    [self initCategoryLabel];
    [self initTableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    DLog();
    [self showContentsButton];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    DLog();
}
- (void)loadCategory:(NSString *)categoryName {
    
    self.categoryName = categoryName;
    
    // Update category image.
    UIImage *categoryImage = [Category bookImageForCategory:categoryName];
    self.categoryImageView.frame = CGRectMake(self.view.bounds.origin.x,
                                              self.view.bounds.origin.y,
                                              categoryImage.size.width,
                                              categoryImage.size.height);
    self.categoryImageView.image = categoryImage;
    
    // Update category label.
    NSString *categoryDisplay = [categoryName uppercaseString];
    CGSize size = [categoryDisplay sizeWithFont:kCategoryFont
                              constrainedToSize:CGSizeMake(self.view.bounds.size.width - kLabelOffset.x,
                                                           self.view.bounds.size.height)
                                  lineBreakMode:NSLineBreakByTruncatingTail];
    self.categoryLabel.frame = CGRectMake(self.categoryLabel.frame.origin.x,
                                          self.categoryLabel.frame.origin.y,
                                          size.width,
                                          size.height);
    self.categoryLabel.text = categoryDisplay;
    
    // Update tableview.
    self.tableView.frame = CGRectMake(self.tableView.frame.origin.x,
                                      self.categoryLabel.frame.origin.y + self.categoryLabel.frame.size.height,
                                      self.tableView.frame.size.width,
                                      self.view.bounds.size.height - self.categoryLabel.frame.origin.y - self.categoryLabel.frame.size.height - kTableInsets.top - kTableInsets.bottom);
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSource numRecipesInCategory:self.categoryName];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CKRecipe *recipe = [[self.dataSource recipesForCategory:self.categoryName] objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [self cellForTableView:tableView indexPath:indexPath];
    cell.textLabel.text = [recipe.name uppercaseString];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", [self.dataSource pageNumForRecipeAtCategoryIndex:indexPath.row forCategoryName:self.categoryName]];
    return cell;
}

#pragma mark - UITableViewDelegate methods
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSUInteger requestedPageIndex = [self.dataSource pageNumForRecipeAtCategoryIndex:indexPath.row forCategoryName:self.categoryName];
    [self.delegate requestedPageIndex:requestedPageIndex];
}

#pragma mark - Private methods

-(UITableViewCell*) cellForTableView:(UITableView*)tableView indexPath:(NSIndexPath*)indexPath
{
    UITableViewCell *tableViewCell = [tableView dequeueReusableCellWithIdentifier:kRecipeCellId forIndexPath:indexPath];
    tableViewCell.textLabel.textColor = [Theme categoryViewTextColor];
    tableViewCell.textLabel.font = [Theme defaultFontBoldWithSize:16.0f];
    tableViewCell.detailTextLabel.textColor = [Theme defaultLabelColor];
    tableViewCell.detailTextLabel.font = [Theme defaultFontBoldWithSize:16.0f];
    
    return tableViewCell;
}
- (void)initCategoryImageView {
    UIImageView *categoryImageView = [[UIImageView alloc] initWithImage:nil];
    [self.view addSubview:categoryImageView];
    self.categoryImageView = categoryImageView;
}

- (void)initCategoryLabel {
    UILabel *categoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(kLabelOffset.x, kLabelOffset.y, 0.0, 0.0)];
    categoryLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    categoryLabel.backgroundColor = [UIColor clearColor];
    categoryLabel.font = kCategoryFont;
    categoryLabel.textColor = [Theme categoryViewTextColor];
    categoryLabel.shadowColor = [UIColor whiteColor];
    categoryLabel.shadowOffset = CGSizeMake(0.0, 1.0);
    categoryLabel.minimumScaleFactor = 0.5;
    [self.view addSubview:categoryLabel];
    self.categoryLabel = categoryLabel;
}

- (void)initTableView {
    CGFloat xOffset = self.categoryLabel.frame.origin.x;
    CGFloat availableWidth = self.view.bounds.size.width - xOffset;
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(xOffset + kTableInsets.left,
                                                                           self.categoryLabel.frame.origin.y + self.categoryLabel.frame.size.height + kTableInsets.top,
                                                                           availableWidth - kTableInsets.left - kTableInsets.right,
                                                                           self.view.bounds.size.height - self.categoryLabel.frame.origin.y - self.categoryLabel.frame.size.height - kTableInsets.top - kTableInsets.bottom)
                                                          style:UITableViewStylePlain];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.autoresizingMask = UIViewAutoresizingNone;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.scrollEnabled = YES;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    [self.tableView registerClass:[ContentsTableViewCell class] forCellReuseIdentifier:kRecipeCellId];
}


@end
