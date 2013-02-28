//
//  BookHomeViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 19/02/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookHomeViewController.h"
#import "CKBook.h"
#import "CKUser.h"
#import "CKRecipe.h"
#import "BookContentsViewController.h"
#import "BookActivityViewController.h"

@interface BookHomeViewController () <BookContentsViewControllerDelegate>

@property (nonatomic, strong) CKBook *book;
@property (nonatomic, assign) id<BookHomeViewControllerDelegate> delegate;
@property (nonatomic, strong) BookContentsViewController *contentsViewController;
@property (nonatomic, strong) BookActivityViewController *activityViewCOntroller;

@end

@implementation BookHomeViewController

#define kActivityCellId         @"ActivityCellId"
#define kContentsCellId         @"kContentsCellId"

- (id)initWithBook:(CKBook *)book delegate:(id<BookHomeViewControllerDelegate>)delegate  {
    if (self = [super initWithCollectionViewLayout:[[UICollectionViewFlowLayout alloc] init]]) {
        self.book = book;
        self.delegate = delegate;
        self.contentsViewController = [[BookContentsViewController alloc] initWithBook:book delegate:self];
        self.activityViewCOntroller = [[BookActivityViewController alloc] initWithBook:book];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initCollectionView];
}

- (void)configureCategories:(NSArray *)categories {
    [self.contentsViewController configureCategories:categories];
}

- (void)configureHeroRecipe:(CKRecipe *)recipe {
    [self.contentsViewController configureRecipe:recipe];
}

#pragma mark - BookContentsViewControllerDelegate methods

- (void)bookContentsSelectedCategory:(NSString *)category {
    [self.delegate bookHomeSelectedCategory:category];
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = nil;
    if (indexPath.section == 0) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:kContentsCellId forIndexPath:indexPath];
        if (!self.contentsViewController.view.superview) {
            self.contentsViewController.view.frame = cell.contentView.bounds;
            [cell.contentView addSubview:self.contentsViewController.view];
        }
    } else {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:kActivityCellId forIndexPath:indexPath];
        if (!self.activityViewCOntroller.view.superview) {
            self.activityViewCOntroller.view.frame = cell.contentView.bounds;
            [cell.contentView addSubview:self.activityViewCOntroller.view];
        }
    }
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout methods

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return self.collectionView.bounds.size;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    
    return UIEdgeInsetsZero;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    
    // Between rows
    return 0.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    
    // Between columns
    return 0.0;
}

#pragma mark - Private methods

- (void)initCollectionView {
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.collectionView.pagingEnabled = YES;
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kActivityCellId];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kContentsCellId];
}

@end
