//
//  ContentsPageViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 8/11/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "ContentsPageViewController.h"
#import "ContentsCollectionViewController.h"
#import "UIFont+Cook.h"
#import "MRCEnumerable.h"
#import "CKRecipe.h"
#import "Category.h"
#import "NewRecipeViewController.h"

@interface ContentsPageViewController () <UITableViewDataSource, UITableViewDelegate, NewRecipeViewDelegate>

@property (nonatomic, strong) ContentsCollectionViewController *contentsCollectionViewController;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UILabel *nameLabel;

@end

@implementation ContentsPageViewController

#pragma mark - PageViewController methods

#define kNameYOffset    150.0
#define kCategoryCellId @"CategoryCellId"

- (void)loadData {
    DLog();
    
    [super loadData];
    
    // Data would've been loaded by BookVC.
    if ([self.dataSource bookCategories]) {
        [self dataDidLoad];
    }
}

- (void)initPageView {
    [self initCollectionView];
    [self initTitleView];
    [self initTableView];
    
    UIButton *createButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [createButton setTitle:@"Create" forState:UIControlStateNormal];
    [createButton addTarget:self action:@selector(createTapped:) forControlEvents:UIControlEventTouchUpInside];
    [createButton sizeToFit];
    [createButton setFrame:CGRectMake(self.contentsCollectionViewController.view.frame.origin.x + self.contentsCollectionViewController.view.frame.size.width + 20.0, 18.0, createButton.frame.size.width, createButton.frame.size.height)];
    [self.view addSubview:createButton];
}

- (void)dataDidLoad {
    [super dataDidLoad];
    [self.tableView reloadData];
    [self.contentsCollectionViewController loadRecipes:[self.dataSource bookRecipes]];
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.dataSource bookCategories] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCategoryCellId forIndexPath:indexPath];
    cell.textLabel.text = [[self.dataSource bookCategories] objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark - NewRecipeViewDelegate methods

- (void)closeRequested {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)recipeCreated {
    [self.delegate bookViewReloadRequested];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private methods

- (void)initTitleView {
    
    CKBook *book = [self.dataSource currentBook];
    NSString *title = book.name;
    UIFont *font = [UIFont bookTitleFontWithSize:50.0];
    CGSize size = [title sizeWithFont:font constrainedToSize:self.view.bounds.size lineBreakMode:NSLineBreakByTruncatingTail];
    CGFloat xOffset = self.contentsCollectionViewController.view.frame.origin.x + self.contentsCollectionViewController.view.frame.size.width;
    CGFloat availableWidth = self.view.bounds.size.width - xOffset;
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset + floorf((availableWidth - size.width) / 2.0),
                                                                   kNameYOffset,
                                                                   size.width,
                                                                   size.height)];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.font = font;
    nameLabel.textColor = [UIColor blackColor];
    nameLabel.shadowColor = [UIColor whiteColor];
    nameLabel.shadowOffset = CGSizeMake(0.0, 1.0);
    nameLabel.text = title;
    [self.view addSubview:nameLabel];
    self.nameLabel = nameLabel;
}

- (void)initTableView {
    CGFloat xOffset = self.contentsCollectionViewController.view.frame.origin.x + self.contentsCollectionViewController.view.frame.size.width;
    UIEdgeInsets tableInsets = UIEdgeInsetsMake(20.0, 100.0, 50.0, 100.0);
    CGFloat availableWidth = self.view.bounds.size.width - xOffset;
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(xOffset + tableInsets.left,
                                                                           self.nameLabel.frame.origin.y + self.nameLabel.frame.size.height + tableInsets.top,
                                                                           availableWidth - tableInsets.left - tableInsets.right,
                                                                           self.view.bounds.size.height - tableInsets.top - tableInsets.bottom)
                                                           style:UITableViewStylePlain];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.autoresizingMask = UIViewAutoresizingNone;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.scrollEnabled = NO;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCategoryCellId];
}

- (void)initCollectionView {
    ContentsCollectionViewController *collectionViewController  = [[ContentsCollectionViewController alloc] init];
    collectionViewController.view.frame = CGRectMake(0.0,
                                                     0.0,
                                                     collectionViewController.view.frame.size.width,
                                                     self.view.bounds.size.height);
    [self.view addSubview:collectionViewController.view];
    self.contentsCollectionViewController = collectionViewController;
}

- (void)createTapped:(id)sender {
    DLog();
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Cook" bundle:nil];
    NewRecipeViewController *newRecipeViewVC = [mainStoryBoard instantiateViewControllerWithIdentifier:@"NewRecipeViewController"];
    newRecipeViewVC.delegate = self;
    newRecipeViewVC.book = [self.dataSource currentBook];
    [self presentViewController:newRecipeViewVC animated:YES completion:nil];
}

@end
