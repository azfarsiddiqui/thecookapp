//
//  ContentsCollectionViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 9/11/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "ContentsCollectionViewController.h"
#import "ContentsPhotoCell.h"

@interface ContentsCollectionViewController ()

@end

@implementation ContentsCollectionViewController

#define kPhotoCellId    @"PhotoCellId"
#define kNumColumns     3

- (id)init {
    if (self = [super initWithCollectionViewLayout:[[UICollectionViewFlowLayout alloc] init]]) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    CGSize cellSize = [ContentsPhotoCell cellSize];
    self.view.frame = CGRectMake(0.0, 0.0, kNumColumns * cellSize.width, cellSize.height);
    self.view.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight;
    self.collectionView.alwaysBounceHorizontal = NO;
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.decelerationRate = UIScrollViewDecelerationRateNormal;
    [self.collectionView registerClass:[ContentsPhotoCell class] forCellWithReuseIdentifier:kPhotoCellId];
}

#pragma mark - UICollectionViewDelegateFlowLayout methods

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [ContentsPhotoCell cellSize];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsZero;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return 15;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ContentsPhotoCell *cell = (ContentsPhotoCell *)[self.collectionView dequeueReusableCellWithReuseIdentifier:kPhotoCellId
                                                                                                  forIndexPath:indexPath];
    cell.contentView.backgroundColor = (indexPath.item % 2 == 0) ? [UIColor lightGrayColor] : [UIColor darkGrayColor];
    cell.contentView.alpha = 0.7;
    return cell;
}


@end
