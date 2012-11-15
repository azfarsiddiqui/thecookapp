//
//  CategoryPageViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 12/11/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "CategoryPageViewController.h"
#import "Category.h"
#import "ContentsTableViewCell.h"

@interface CategoryPageViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) UILabel *categoryLabel;
@property (nonatomic, strong) UIImageView *categoryImageView;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation CategoryPageViewController

#define kCategoryFont   [UIFont boldSystemFontOfSize:50.0]
#define kCategoryFont   [UIFont boldSystemFontOfSize:50.0]
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
    [self showContentsButton];
}

- (void)loadData {
    [super loadData];
    [self dataDidLoad];
}

- (void)loadCategory:(NSString *)category {
    
    self.category = category;
    
    // Update category image.
    self.categoryImageView.image = [Category bookImageForCategory:category];
    
    // Update category label.
    NSString *categoryDisplay = [category uppercaseString];
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
    return [[self.dataSource recipesForCategory:self.category] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CKRecipe *recipe = [[self.dataSource recipesForCategory:self.category] objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kRecipeCellId forIndexPath:indexPath];
    cell.textLabel.text = [recipe.name uppercaseString];
    return cell;
}

#pragma mark - Private methods

- (void)initCategoryImageView {
    UIImageView *categoryImageView = [[UIImageView alloc] initWithImage:nil];
    categoryImageView.frame = self.view.bounds;
    [self.view addSubview:categoryImageView];
    self.categoryImageView = categoryImageView;
}

- (void)initCategoryLabel {
    UILabel *categoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(kLabelOffset.x, kLabelOffset.y, 0.0, 0.0)];
    categoryLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    categoryLabel.backgroundColor = [UIColor clearColor];
    categoryLabel.font = kCategoryFont;
    categoryLabel.textColor = [UIColor blackColor];
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
