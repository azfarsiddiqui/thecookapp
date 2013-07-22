//
//  BookTitleViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 12/04/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookTitleViewController.h"
#import "CKBook.h"
#import "Theme.h"
#import "CKBookTitleIndexView.h"
#import "ParsePhotoStore.h"
#import "CKRecipe.h"
#import "CKUser.h"
#import "ImageHelper.h"
#import "BookTitleCell.h"
#import "UIColor+Expanded.h"

@interface BookTitleViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) CKBook *book;
@property (nonatomic, strong) NSMutableArray *categories;
@property (nonatomic, strong) CKRecipe *heroRecipe;
@property (nonatomic, assign) id<BookTitleViewControllerDelegate> delegate;

@property (nonatomic, strong) ParsePhotoStore *photoStore;

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) CKBookTitleIndexView *bookTitleView;

@end

@implementation BookTitleViewController

#define kCellId                 @"BookTitleCellId"
#define kHeaderId               @"BookTitleHeaderId"
#define kIndexWidth             240.0
#define kImageIndexGap          10.0
#define kTitleIndexTopOffset    40.0
#define kBorderInsets           (UIEdgeInsets){ 20.0, 0.0, 5.0, 0.0 }

- (id)initWithBook:(CKBook *)book delegate:(id<BookTitleViewControllerDelegate>)delegate {
    if (self = [super init]) {
        self.book = book;
        self.delegate = delegate;
        self.photoStore = [[ParsePhotoStore alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithHexString:@"f2f2f2"];
    
    [self initBackgroundView];
    [self initCollectionView];
    [self addCloseButtonWhite:YES];
}

- (void)configureCategories:(NSArray *)categories {
    self.categories = [NSMutableArray arrayWithArray:categories];
    [self.collectionView reloadData];
}

- (void)configureHeroRecipe:(CKRecipe *)recipe {
    
    // Only set the hero recipe once.
    if (self.heroRecipe) {
        return;
    }
    
    self.heroRecipe = recipe;
    [self.photoStore imageForParseFile:[recipe imageFile]
                                  size:self.imageView.bounds.size
                            completion:^(UIImage *image) {
                                [ImageHelper configureImageView:self.imageView image:image];
                            }];
}

#pragma mark - UICollectionViewDelegateFlowLayout methods

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    
    return (UIEdgeInsets) { 100.0, 90.0, 90.0, 90.0 };
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
    minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    
    return 20.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    
    return 30.0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
referenceSizeForHeaderInSection:(NSInteger)section {
    
    CGSize headerSize = (CGSize) {
        self.collectionView.bounds.size.width,
        420.0
    };
    return headerSize;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return [BookTitleCell cellSize];
}

#pragma mark - UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.delegate bookTitleSelectedCategory:[self.categories objectAtIndex:indexPath.item]];
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return [self.categories count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    BookTitleCell *cell = (BookTitleCell *)[self.collectionView dequeueReusableCellWithReuseIdentifier:kCellId forIndexPath:indexPath];
    CKCategory *category = [self.categories objectAtIndex:indexPath.item];
    [cell configureCategory:category];
    
    // Load featured recipe for the category.
    CKRecipe *featuredRecipe = [self.delegate bookTitleFeaturedRecipeForCategory:category];
    [self configureImageForTitleCell:cell recipe:featuredRecipe indexPath:indexPath];
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *supplementaryView = nil;
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        supplementaryView = [self.collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                    withReuseIdentifier:kHeaderId forIndexPath:indexPath];
        if (!self.bookTitleView.superview) {
            self.bookTitleView.frame = (CGRect){
                floorf((supplementaryView.bounds.size.width - self.bookTitleView.frame.size.width) / 2.0),
                supplementaryView.bounds.size.height - self.bookTitleView.frame.size.height,
                self.bookTitleView.frame.size.width,
                self.bookTitleView.frame.size.height
            };
            [supplementaryView addSubview:self.bookTitleView];
        }
    }
    
    return supplementaryView;
}

#pragma mark - Properties

- (CKBookTitleIndexView *)bookTitleView {
    if (!_bookTitleView) {
        _bookTitleView = [[CKBookTitleIndexView alloc] initWithName:self.book.user.name title:self.book.name];
    }
    return _bookTitleView;
}

#pragma mark - Private methods

- (void)initBackgroundView {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:nil];
    imageView.frame = self.view.bounds;
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    imageView.backgroundColor = [Theme categoryHeaderBackgroundColour];
    [self.view addSubview:imageView];
    self.imageView = imageView;
    
    UIImage *borderImage = [[UIImage imageNamed:@"cook_book_inner_title_border.png"] resizableImageWithCapInsets:(UIEdgeInsets){14.0, 18.0, 14.0, 18.0 }];
    UIImageView *borderImageView = [[UIImageView alloc] initWithImage:borderImage];
    borderImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleHeight;
    borderImageView.frame = (CGRect){
        kBorderInsets.left,
        kBorderInsets.top,
        self.view.bounds.size.width - kBorderInsets.left - kBorderInsets.right,
        self.view.bounds.size.height - kBorderInsets.top - kBorderInsets.bottom
    };
    [self.view addSubview:borderImageView];
}

- (void)initCollectionView {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds
                                                          collectionViewLayout:flowLayout];
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.alwaysBounceVertical = YES;
    collectionView.alwaysBounceHorizontal = NO;
    collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:collectionView];
    self.collectionView = collectionView;
    
    [collectionView registerClass:[BookTitleCell class] forCellWithReuseIdentifier:kCellId];
    [collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
              withReuseIdentifier:kHeaderId];
}

- (void)configureImageForTitleCell:(BookTitleCell *)titleCell recipe:(CKRecipe *)recipe
                         indexPath:(NSIndexPath *)indexPath {
    
    if ([recipe hasPhotos]) {
        CGSize imageSize = [BookTitleCell cellSize];
        [self.photoStore imageForParseFile:[recipe imageFile]
                                      size:imageSize
                                 indexPath:indexPath
                                completion:^(NSIndexPath *completedIndexPath, UIImage *image) {
                                    
                                    // Check that we have matching indexPaths as cells are re-used.
                                    if ([indexPath isEqual:completedIndexPath]) {
                                        [titleCell configureImage:image];
                                    }
                                }];
    }
}

@end
