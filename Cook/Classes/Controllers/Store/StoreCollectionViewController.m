//
//  StoreCollectionViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 23/11/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "StoreCollectionViewController.h"
#import "StoreFlowLayout.h"
#import "StoreBookCell.h"

@interface StoreCollectionViewController ()

@end

@implementation StoreCollectionViewController

#define kStoreBookCellId            @"StoreBookCell"

- (id)init {
    if (self = [super initWithCollectionViewLayout:[[StoreFlowLayout alloc] init]]) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGSize cellSize = [StoreBookCell cellSize];
    self.view.frame = CGRectMake(0.0, 0.0, cellSize.width, cellSize.height);
    
    self.collectionView.alwaysBounceHorizontal = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    [self.collectionView registerClass:[StoreBookCell class] forCellWithReuseIdentifier:kStoreBookCellId];
}

#pragma mark - UICollectionViewDelegate methods

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    DLog();
}

#pragma mark - UICollectionViewDelegateFlowLayout methods

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [StoreBookCell cellSize];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0.0, 200.0, 0.0, 200.0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 20.0;
}


#pragma mark - UICollectionViewDataSource methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return 10;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    StoreBookCell *cell = (StoreBookCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kStoreBookCellId forIndexPath:indexPath];
    return cell;
}

@end
