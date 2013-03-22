//
//  BookContentsViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 27/02/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookIndexViewController.h"
#import <Parse/Parse.h>
#import "CKBook.h"
#import "Theme.h"
#import "ImageHelper.h"
#import "CKRecipe.h"
#import "ParsePhotoStore.h"
#import "AppHelper.h"
#import "BookIndexLayout.h"
#import "BookIndexCell.h"

@interface BookIndexViewController () <UITableViewDataSource, UITableViewDelegate, BookIndexLayoutDataSource>

@property (nonatomic, strong) CKBook *book;
@property (nonatomic, strong) CKRecipe *heroRecipe;
@property (nonatomic, assign) id<BookIndexViewControllerDelegate> delegate;
@property (nonatomic, strong) ParsePhotoStore *photoStore;
@property (nonatomic, strong) UIView *contentsView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *categories;

@end

@implementation BookIndexViewController

#define kContentsWidth      180.0
#define kTitleSize          CGSizeMake(600.0, 300.0)
#define kProfileWidth       200.0
#define kBookTitleInsets    UIEdgeInsetsMake(30.0, 20.0, 20.0, 20.0)
#define kTitleNameGap       0.0
#define kContentsItemHeight 50.0
#define kCellId             @"kIndexCcellId"

- (id)initWithBook:(CKBook *)book delegate:(id<BookIndexViewControllerDelegate>)delegate {
    if (self = [super initWithCollectionViewLayout:[[BookIndexLayout alloc] initWithDataSource:self]]) {
        self.book = book;
        self.delegate = delegate;
        self.photoStore = [[ParsePhotoStore alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.backgroundColor = [Theme activityInfoViewColour];
    [self.collectionView registerClass:[BookIndexCell class] forCellWithReuseIdentifier:kCellId];
}

- (void)viewDidAppear:(BOOL)animated {
    //[self initContentsView];
}

- (void)configureCategories:(NSArray *)categories {
    self.categories = categories;
    
    [self.collectionView reloadData];
    
    // Update the frame of the tableView so that we can position it center.
    [self updateTableFrame];
    [self.tableView reloadData];
}

#pragma mark - BookIndexLayoutDataSource methods

- (NSArray *)bookIndexLayoutCategories {
    return self.categories;
}

#pragma mark - UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger numCategoriesToDisplay = [collectionView numberOfItemsInSection:0];
    if ([self canAddRecipe] && indexPath.item == (numCategoriesToDisplay - 1)) {
        [self.delegate bookIndexAddRecipeRequested];
    } else {
        [self.delegate bookIndexSelectedCategory:[self.categories objectAtIndex:indexPath.item]];
    }
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    BookIndexLayout *indexLayout = (BookIndexLayout *)self.collectionView.collectionViewLayout;
    return [indexLayout numberOfCategoriesToDisplay];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    BookIndexCell *cell = (BookIndexCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kCellId forIndexPath:indexPath];
    NSString *category = [self.categories objectAtIndex:indexPath.item];
    [cell configureCategory:category recipes:[self.delegate bookIndexRecipesForCategory:category]];
    return cell;
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numRows = [self.categories count];
    if ([self canAddRecipe]) {
        numRows += 1;   // Add Recipe
    }
    return numRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"ContentsCellId";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.textColor = [Theme bookContentsItemColour];
        cell.textLabel.font = [Theme bookContentsItemFont];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSInteger numRows = [self tableView:tableView numberOfRowsInSection:0];
    if ([self canAddRecipe] && indexPath.item == (numRows - 1)) {
        cell.textLabel.text = @"ADD RECIPE";
    } else {
        NSString *categoryName = [[self.categories objectAtIndex:indexPath.item] uppercaseString];
        cell.textLabel.text = categoryName;
    }
    return cell;
}

#pragma mark - UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kContentsItemHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger numRows = [self tableView:tableView numberOfRowsInSection:0];
    if ([self canAddRecipe] && indexPath.item == (numRows - 1)) {
        [self.delegate bookIndexAddRecipeRequested];
    } else {
        [self.delegate bookIndexSelectedCategory:[self.categories objectAtIndex:indexPath.item]];
    }
}

#pragma mark - Private methods

- (void)initContentsView {
    UIView *contentsView = [[UIView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x,
                                                                    self.view.bounds.origin.y,
                                                                    self.view.bounds.size.width,
                                                                    self.view.bounds.size.height)];
    contentsView.backgroundColor = [Theme bookContentsViewColour];
    [self.view addSubview:contentsView];
    self.contentsView = contentsView;
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.scrollEnabled = NO;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [contentsView addSubview:tableView];
    self.tableView = tableView;
    [self updateTableFrame];
}

- (void)updateTableFrame {
    CGFloat tableHeight = [self tableView:self.tableView numberOfRowsInSection:0] * kContentsItemHeight;
    self.tableView.frame = CGRectMake(self.contentsView.bounds.origin.x,
                                      floorf((self.contentsView.bounds.size.height - tableHeight) / 2.0),
                                      self.contentsView.bounds.size.width,
                                      tableHeight);

}

- (BOOL)canAddRecipe {
    return ([self.book.user isEqual:[CKUser currentUser]]);
}

@end
