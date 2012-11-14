//
//  ContentsCollectionViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 9/11/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "ContentsCollectionViewController.h"
#import "ContentsPhotoCell.h"
#import "CKRecipe.h"

@interface ContentsCollectionViewController ()

@property (nonatomic, strong) NSArray *recipes;

@end

@implementation ContentsCollectionViewController

#define kPhotoCellId    @"PhotoCellId"
#define kNumColumns     2

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

#pragma mark - ContentsCollectionViewController methods

- (void)loadRecipes:(NSArray *)recipes {
    self.recipes = recipes;
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDelegateFlowLayout methods

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger numItems = [self collectionView:collectionView numberOfItemsInSection:indexPath.section];
    CGSize itemSize = [ContentsPhotoCell minSize];
    if (numItems == 1) {
        itemSize = [ContentsPhotoCell maxSize];
    } else if (numItems < 5) {
        itemSize = [ContentsPhotoCell midSize];
    } else if (indexPath.row == 0) {
        itemSize = [ContentsPhotoCell midSize];
    }
    return itemSize;
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
    return [self.recipes count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CKRecipe *recipe = [self.recipes objectAtIndex:indexPath.row];
    ContentsPhotoCell *cell = (ContentsPhotoCell *)[self.collectionView dequeueReusableCellWithReuseIdentifier:kPhotoCellId
                                                                                                  forIndexPath:indexPath];
    [cell loadRecipe:recipe];
    return cell;
}


@end
