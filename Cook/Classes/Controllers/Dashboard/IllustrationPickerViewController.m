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
#import "ImageHelper.h"

@interface IllustrationPickerViewController () <IllustrationBookCellDelegate>

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
    UIEdgeInsets insets = UIEdgeInsetsMake(20.0, 40.0, 0.0, 20.0);
    CGSize itemSize = [IllustrationBookCell cellSize];
    
    UIImageView *dockView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_customise_book_dock.png"]];
    dockView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view insertSubview:dockView belowSubview:self.collectionView];
    
    self.view.frame = CGRectMake(0.0, 0.0, 0.0, dockView.frame.size.height);
    self.view.backgroundColor = [UIColor clearColor];
    
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    flowLayout.itemSize = itemSize;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.sectionInset = insets;
    flowLayout.minimumLineSpacing = 28.0;
    
    self.collectionView.frame = self.view.bounds;
    self.collectionView.alwaysBounceHorizontal = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.pagingEnabled = NO;
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
    cell.delegate = self;
    [cell setCover:self.cover];
    [cell setIllustration:currentIllustration];
    return cell;
}

#pragma mark - IllustrationBookCellDelegate methods

- (UIImage *)imageForIllustration:(NSString *)illustration size:(CGSize)size {
    return [ImageHelper scaledImage:[CKBookCover imageForIllustration:illustration] size:size];
}

- (UIImage *)imageForCover:(NSString *)cover size:(CGSize)size {
    return [ImageHelper scaledImage:[CKBookCover imageForCover:cover] size:size];
}

#pragma mark - Private

@end
