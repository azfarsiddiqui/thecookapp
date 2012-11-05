//
//  EditIllustrationViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 5/11/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "IllustrationViewController.h"
#import "BookCover.h"
#import "EditBookCell.h"

@interface IllustrationViewController ()

@property (nonatomic, strong) NSArray *illustrations;

@end

@implementation IllustrationViewController

#define kCoverCellId        @"CoverCell"

- (id)init {
    if (self = [super initWithCollectionViewLayout:[[UICollectionViewFlowLayout alloc] init]]) {
        self.illustrations = [[BookCover illustrations] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    }
    return self;
}

- (void)viewDidLoad {
    CGSize itemSize = [EditBookCell cellSize];
    
    self.view.frame = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    self.view.backgroundColor = [UIColor clearColor];
    
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    flowLayout.itemSize = itemSize;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.collectionView.frame = self.view.bounds;
    self.collectionView.alwaysBounceHorizontal = YES;
    self.collectionView.showsHorizontalScrollIndicator = YES;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    [self.collectionView registerClass:[EditBookCell class] forCellWithReuseIdentifier:kCoverCellId];
}

#pragma mark - UICollectionViewDelegate methods

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    DLog();
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return [self.illustrations count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    EditBookCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:kCoverCellId
                                                                                forIndexPath:indexPath];
    [cell setCover:@"Red"];
    [cell setIllustration:[self.illustrations objectAtIndex:indexPath.item]];
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout methods


@end
