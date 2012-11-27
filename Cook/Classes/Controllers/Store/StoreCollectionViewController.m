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
#import "CKBookCover.h"
#import "CKBookCoverView.h"

@interface StoreCollectionViewController ()

@property (nonatomic, strong) NSMutableArray *bookIllustrations;
@property (nonatomic, strong) NSMutableArray *bookCovers;

@end

@implementation StoreCollectionViewController

#define kStoreBookCellId            @"StoreBookCell"
#define kBookCoverViewTag           240

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

- (void)showBooks {
    [self showBooks:YES];
}

- (void)showBooks:(BOOL)show {
    if (show) {
        NSUInteger bookCount = 10;
        self.bookIllustrations = [NSMutableArray arrayWithCapacity:bookCount];
        self.bookCovers = [NSMutableArray arrayWithCapacity:bookCount];
        for (NSUInteger bookIndex = 0; bookIndex < bookCount; bookIndex++) {
            [self.bookIllustrations addObject:[CKBookCover randomIllustration]];
            [self.bookCovers addObject:[CKBookCover randomCover]];
        }
    } else {
        [self.bookCovers removeAllObjects];
        [self.bookIllustrations removeAllObjects];
    }
    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
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
    return [self.bookIllustrations count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    StoreBookCell *cell = (StoreBookCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kStoreBookCellId forIndexPath:indexPath];
    CKBookCoverView *bookCoverView = (CKBookCoverView *)[cell viewWithTag:kBookCoverViewTag];
    if (!bookCoverView) {
        CGFloat scaleFactor = 1 / [StoreBookCell scaleFactor];
        bookCoverView = [[CKBookCoverView alloc] initWithFrame:cell.contentView.bounds];
        bookCoverView.tag = kBookCoverViewTag;
        [cell.contentView addSubview:bookCoverView];
        bookCoverView.transform = CGAffineTransformMakeScale(scaleFactor, scaleFactor);
    }
    [bookCoverView setCover:[self.bookCovers objectAtIndex:indexPath.item] illustration:[self.bookIllustrations objectAtIndex:indexPath.item]];
    //[bookCoverView setTitle:@"Cook" author:@"Guest" caption:@"Recipes I love"];
    return cell;
}

@end
