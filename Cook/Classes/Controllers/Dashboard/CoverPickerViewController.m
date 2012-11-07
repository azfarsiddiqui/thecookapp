//
//  CoverPickerViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 7/11/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "CoverPickerViewController.h"
#import "CoverPickerCell.h"
#import "MRCEnumerable.h"
#import "BookCover.h"

@interface CoverPickerViewController ()

@property (nonatomic, copy) NSString *cover;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) NSMutableArray *availableCovers;
@property (nonatomic, assign) id<CoverPickerViewControllerDelegate> delegate;
@property (nonatomic, assign) BOOL expanded;

@end

@implementation CoverPickerViewController

#define kIllustrationCellId     @"IllustrationCell"
#define kCoverTag               260

- (void)dealloc {
    //[self.collectionView removeObserver:self forKeyPath:@"contentSize"];
}

- (id)initWithCover:(NSString *)cover delegate:(id<CoverPickerViewControllerDelegate>)delegate {
    if (self = [super initWithCollectionViewLayout:[[UICollectionViewFlowLayout alloc] init]]) {
        self.cover = cover;
        self.delegate = delegate;
        self.availableCovers = [NSMutableArray arrayWithObjects:@"Yellow", @"Pink", @"Red", @"Blue", @"Light Green", nil];
    }
    return self;
}

- (void)viewDidLoad {
    CGSize itemSize = [CoverPickerCell minCellSize];
    
    self.view.frame = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    self.view.backgroundColor = [UIColor clearColor];
    
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    flowLayout.itemSize = itemSize;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.sectionInset = UIEdgeInsetsZero;
    flowLayout.minimumLineSpacing = 0.0;
    
    self.collectionView.alwaysBounceHorizontal = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.decelerationRate = UIScrollViewDecelerationRateNormal;
    [self.collectionView registerClass:[CoverPickerCell class] forCellWithReuseIdentifier:kIllustrationCellId];
    
    // Observe changes in contentSize and contentOffset.
    //[self.collectionView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:NULL];
}

#pragma mark - UICollectionViewDelegate methods

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // Expand if not expanded.
    if (!self.expanded) {
        [self toggleExpansion];
        return;
    }
    
    // Ignore if same was selected.
    if (self.currentIndex == indexPath.row) {
        return;
    }
    
    // TODO
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return [self.availableCovers count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *currentCover = [self.availableCovers objectAtIndex:indexPath.item];
    UICollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:kIllustrationCellId
                                                                                forIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor clearColor];
    UIImageView *coverImageView = (UIImageView *)[cell viewWithTag:kCoverTag];
    if (!coverImageView) {
        coverImageView = [[UIImageView alloc] initWithImage:nil];
        coverImageView.frame = cell.contentView.bounds;
        coverImageView.tag = kCoverTag;
        coverImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth;
        [cell.contentView addSubview:coverImageView];
    }
    
    UIImage *coverImage = [[BookCover customiseImageForCover:currentCover] stretchableImageWithLeftCapWidth:1 topCapHeight:0];
    if (indexPath.row == 0 || indexPath.row == [self.availableCovers count] - 1) {
        coverImage = [coverImage stretchableImageWithLeftCapWidth:12 topCapHeight:0];
    }
    coverImageView.image = coverImage;
    return cell;
}

#pragma mark - KVO methods.

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"contentSize"]) {
        CGRect frame = self.view.frame;
        frame.size.width = self.collectionView.contentSize.width;
        self.view.frame = frame;
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - Private

- (void)toggleExpansion {
    self.expanded = !self.expanded;
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    flowLayout.itemSize = self.expanded ? [CoverPickerCell maxCellSize] : [CoverPickerCell minCellSize];
    [self.collectionView reloadData];
    [self.delegate coverPickerExpanded:self.expanded];
}

@end
