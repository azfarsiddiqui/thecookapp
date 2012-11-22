//
//  EditIllustrationViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 5/11/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "IllustrationPickerViewController.h"
#import "CKBookCover.h"
#import "IllustrationBookCell.h"
#import "IllustrationFlowLayout.h"
#import "NSString+Utilities.h"
#import "MRCEnumerable.h"

@interface IllustrationPickerViewController ()

@property (nonatomic, strong) NSString *cover;
@property (nonatomic, strong) NSMutableArray *availableIllustrations;
@property (nonatomic, assign) id<IllustrationPickerViewControllerDelegate> delegate;
@property (nonatomic, assign) NSInteger currentIndex;

@end

@implementation IllustrationPickerViewController

#define kIllustrationCellId        @"IllustrationCell"

- (id)initWithIllustration:(NSString *)illustration cover:(NSString *)cover
                  delegate:(id<IllustrationPickerViewControllerDelegate>)delegate {
    if (self = [super initWithCollectionViewLayout:[[IllustrationFlowLayout alloc] init]]) {
        self.availableIllustrations = [NSMutableArray arrayWithArray:[[CKBookCover illustrations]
                                                                      sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
        self.illustration = illustration;
        self.cover = cover;
        self.delegate = delegate;
        self.currentIndex = [self.availableIllustrations findIndexWithBlock:^(NSString *illustration) {
            return [self.illustration isEqualToString:illustration];
        }];
    }
    return self;
}

- (void)viewDidLoad {
    CGSize itemSize = [IllustrationBookCell cellSize];
    
    self.view.frame = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    self.view.backgroundColor = [UIColor clearColor];
    
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    flowLayout.itemSize = itemSize;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.sectionInset = UIEdgeInsetsMake(0.0, 20.0, 20.0, 20.0);
    flowLayout.minimumLineSpacing = 15.0;
    
    self.collectionView.frame = self.view.bounds;
    self.collectionView.alwaysBounceHorizontal = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.decelerationRate = UIScrollViewDecelerationRateNormal;
    [self.collectionView registerClass:[IllustrationBookCell class] forCellWithReuseIdentifier:kIllustrationCellId];
}

- (void)changeCover:(NSString *)cover {
    self.cover = cover;
    [self.collectionView reloadData];
}

- (void)scrollToIllustration {
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentIndex inSection:0]
                                atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                        animated:NO];
}

#pragma mark - UICollectionViewDelegate methods

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // Ignore if same was selected.
    if (self.currentIndex == indexPath.row) {
        return;
    }
    
    NSString *selectedIllustration = [self.availableIllustrations objectAtIndex:indexPath.row];
    NSInteger indexToClear = self.currentIndex;
    self.currentIndex = indexPath.row;
    
    // Reload the selected, and the previous cell.
    [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObjects:
                                                  indexPath,
                                                  [NSIndexPath indexPathForItem:indexToClear inSection:0], nil]];
    
    // Inform delegate of update.
    [self.delegate illustrationSelected:selectedIllustration];
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return [self.availableIllustrations count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *currentIllustration = [self.availableIllustrations objectAtIndex:indexPath.item];
    IllustrationBookCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:kIllustrationCellId
                                                                                forIndexPath:indexPath];
    [cell setCover:self.cover];
    [cell setIllustration:currentIllustration];
    return cell;
}

#pragma mark - Private

@end
