//
//  AddRecipeViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 17/10/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "AddRecipeViewController.h"
#import "CKBook.h"
#import "AddRecipeLayout.h"
#import "ModalOverlayHeaderView.h"
#import "AddRecipePageCell.h"
#import "ViewHelper.h"

@interface AddRecipeViewController () <UICollectionViewDataSource, UICollectionViewDelegate, AddRecipeLayoutDelegate>

@property (nonatomic, strong) CKBook *book;
@property (nonatomic, weak) id<AddRecipeViewControllerDelegate> delegate;

@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UILabel *noPagesLabel;

@end

@implementation AddRecipeViewController

#define kHeaderCellId   @"HeaderId"
#define kCellId         @"CellId"

- (id)initWithBook:(CKBook *)book delegate:(id<AddRecipeViewControllerDelegate>)delegate {
    if (self = [super init]) {
        self.book = book;
        self.delegate = delegate;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight;
    
    [self.view addSubview:self.collectionView];
    self.closeButton = [ViewHelper addCloseButtonToView:self.view light:NO target:self selector:@selector(closeTapped:)];
}

#pragma mark - AddRecipeLayoutDelegate methods

- (void)addRecipeLayoutDidFinish {
    DLog();
}

#pragma mark - UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.book.pages count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    AddRecipePageCell *cell = (AddRecipePageCell *)[self.collectionView dequeueReusableCellWithReuseIdentifier:kCellId forIndexPath:indexPath];
    [cell configurePage:[self.book.pages objectAtIndex:indexPath.item]];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionReusableView *supplementaryView = nil;
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        
        ModalOverlayHeaderView *headerView = [self.collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                                     withReuseIdentifier:kHeaderCellId forIndexPath:indexPath];
        [headerView configureTitle:@"ADD TO PAGE"];
        supplementaryView = headerView;
    }
    
    return supplementaryView;
}

#pragma mark - Properties

- (UILabel *)noPagesLabel {
    if (!_noPagesLabel) {
        _noPagesLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _noPagesLabel.font = [UIFont fontWithName:@"BrandonGrotesque-Regular" size:18.0];
        _noPagesLabel.textColor = [UIColor whiteColor];
        _noPagesLabel.text = @"NO PAGES";
        [_noPagesLabel sizeToFit];
    }
    return _noPagesLabel;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds
                                             collectionViewLayout:[[AddRecipeLayout alloc] initWithDelegate:self]];
        _collectionView.bounces = YES;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.alwaysBounceVertical = YES;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight;
        [_collectionView registerClass:[AddRecipePageCell class] forCellWithReuseIdentifier:kCellId];
        [_collectionView registerClass:[ModalOverlayHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderCellId];
    }
    return _collectionView;
}

- (void)closeTapped:(id)sender {
    [self.delegate addRecipeViewControllerCloseRequested];
}

@end
