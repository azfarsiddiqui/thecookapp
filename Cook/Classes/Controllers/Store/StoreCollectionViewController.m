//
//  StoreCollectionViewController.m
//  BenchtopDemo
//
//  Created by Jeff Tan-Ang on 29/11/12.
//  Copyright (c) 2012 Cook App Pty Ltd. All rights reserved.
//

#import "StoreCollectionViewController.h"
#import "StoreFlowLayout.h"
#import "StoreBookCoverViewCell.h"
#import "BenchtopBookCoverViewCell.h"
#import "CKBook.h"
#import "CKBookCoverView.h"

@interface StoreCollectionViewController ()

@end

@implementation StoreCollectionViewController

#define kCellId         @"StoreBookCellId"
#define kStoreSection   0

- (id)init {
    if (self = [super initWithCollectionViewLayout:[[StoreFlowLayout alloc] init]]) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.backgroundColor = [UIColor clearColor];
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight;
    
    self.collectionView.alwaysBounceHorizontal = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    [self.collectionView registerClass:[BenchtopBookCoverViewCell class] forCellWithReuseIdentifier:kCellId];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)enable:(BOOL)enable {
    self.enabled = enable;
}

- (void)loadData {
    // Subclasses to implement.
}

- (void)reloadBooks {
    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:kStoreSection]];
}

#pragma mark - UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    DLog(@"Item %@", indexPath);
}

#pragma mark - UICollectionViewDelegateFlowLayout methods

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [StoreBookCoverViewCell cellSize];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return -120.0;
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return [self.books count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BenchtopBookCoverViewCell *cell = (BenchtopBookCoverViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kCellId
                                                                                                             forIndexPath:indexPath];
    [cell loadBook:[self.books objectAtIndex:indexPath.item]];
    return cell;
}

#pragma mark - Private methods

@end
