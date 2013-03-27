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

- (void)configureCategories:(NSArray *)categories {
    self.categories = categories;
    [self.collectionView reloadData];
}

#pragma mark - BookIndexLayoutDataSource methods

- (NSArray *)bookIndexLayoutCategories {
    return self.categories;
}

#pragma mark - UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.delegate bookIndexSelectedCategory:[self.categories objectAtIndex:indexPath.item]];
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

#pragma mark - Private methods


@end
