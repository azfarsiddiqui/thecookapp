//
//  ContentsCollectionViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 9/11/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "ContentsCollectionViewController.h"

@interface ContentsCollectionViewController ()

@end

@implementation ContentsCollectionViewController

- (id)init {
    if (self = [super initWithCollectionViewLayout:[[UICollectionViewFlowLayout alloc] init]]) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
//    flowLayout.itemSize = itemSize;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.sectionInset = UIEdgeInsetsMake(0.0, 20.0, 20.0, 20.0);
    flowLayout.minimumLineSpacing = 15.0;
    
    self.collectionView.frame = self.view.bounds;
    self.collectionView.alwaysBounceHorizontal = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.decelerationRate = UIScrollViewDecelerationRateNormal;
//    [self.collectionView registerClass:[IllustrationBookCell class] forCellWithReuseIdentifier:kIllustrationCellId];
}

@end
