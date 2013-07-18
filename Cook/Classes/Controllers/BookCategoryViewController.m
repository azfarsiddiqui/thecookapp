//
//  BookCategoryViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 13/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookCategoryViewController.h"
#import "CKBook.h"
#import "CKCategory.h"
#import "CKRecipe.h"
#import "BookCategoryLayout.h"
#import "ParsePhotoStore.h"
#import "BookRecipeCollectionViewCell.h"
#import "MRCEnumerable.h"
#import "BookHeaderView.h"
#import "ViewHelper.h"

@interface BookCategoryViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, weak) id<BookCategoryViewControllerDelegate> delegate;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) CKBook *book;
@property (nonatomic, strong) CKCategory *category;
@property (nonatomic, strong) ParsePhotoStore *photoStore;
@property (nonatomic, strong) NSMutableArray *recipes;

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) BookHeaderView *bookHeaderView;

@end

@implementation BookCategoryViewController

#define kRecipeCellId       @"RecipeCellId"
#define kCategoryHeaderId   @"CategoryHeaderId"

- (id)initWithBook:(CKBook *)book category:(CKCategory *)category delegate:(id<BookCategoryViewControllerDelegate>)delegate {
    
    if (self = [super init]) {
        self.delegate = delegate;
        self.book = book;
        self.category = category;
        self.photoStore = [[ParsePhotoStore alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    
//    [self initImageView];
    [self initCollectionView];
    [self loadData];
}

- (void)loadData {
    self.recipes = [NSMutableArray arrayWithArray:[self.delegate
                                                   recipesForBookCategoryViewControllerForCategory:self.category]];
    [self.collectionView reloadData];
//    [self loadFeaturedRecipe];
}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self applyScrollingEffectsOnCategoryView];
}

#pragma mark - UICollectionViewDelegateFlowLayout methods

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    
    return (UIEdgeInsets) { 210.0, 20.0, 20.0, 20.0 };
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
  
    return [BookCategoryLayout unitSize];
}

#pragma mark - UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self showRecipeAtIndexPath:indexPath];
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    NSInteger numItems = 0;
    numItems = [self.recipes count];
    return numItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    BookRecipeCollectionViewCell *recipeCell = (BookRecipeCollectionViewCell *)[self.collectionView dequeueReusableCellWithReuseIdentifier:kRecipeCellId forIndexPath:indexPath];
    CKRecipe *recipe = [self.recipes objectAtIndex:indexPath.item];
    [recipeCell configureRecipe:recipe book:self.book];
    
    // Configure image.
    [self configureImageForRecipeCell:recipeCell recipe:recipe indexPath:indexPath];
    
    return recipeCell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    BookHeaderView *bookHeaderView = (BookHeaderView *)[self.collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kCategoryHeaderId forIndexPath:indexPath];
    [bookHeaderView configureTitle:self.category.name];
    
    // Keep a reference of it around so we can fade it out later.
    self.bookHeaderView = bookHeaderView;
    
    return bookHeaderView;
}

#pragma mark - Private 

- (void)initImageView {
    self.imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.imageView];
}

- (void)initCollectionView {
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds
                                                          collectionViewLayout:[[BookCategoryLayout alloc] init]];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    collectionView.alwaysBounceVertical = YES;
    collectionView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:collectionView];
    self.collectionView = collectionView;
    
    [self.collectionView registerClass:[BookRecipeCollectionViewCell class] forCellWithReuseIdentifier:kRecipeCellId];
    [self.collectionView registerClass:[BookHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kCategoryHeaderId];
}

- (void)loadFeaturedRecipe {
    CKRecipe *featuredRecipe = [self.delegate featuredRecipeForBookCategoryViewControllerForCategory:self.category];
    [self.photoStore imageForParseFile:[featuredRecipe imageFile]
                                  size:self.imageView.bounds.size
                            completion:^(UIImage *image) {
                                self.imageView.image = image;
                            }];
}

- (void)configureImageForRecipeCell:(BookRecipeCollectionViewCell *)recipeCell recipe:(CKRecipe *)recipe
                          indexPath:(NSIndexPath *)indexPath {
    
    if ([recipe hasPhotos]) {
        
        CGSize imageSize = [recipeCell imageSize];
        [self.photoStore imageForParseFile:[recipe imageFile]
                                      size:imageSize
                                 indexPath:indexPath
                                completion:^(NSIndexPath *completedIndexPath, UIImage *image) {
                                    
                                    // Check that we have matching indexPaths as cells are re-used.
                                    if ([indexPath isEqual:completedIndexPath]) {
                                        [recipeCell configureImage:image];
                                    }
                                }];
    }
}

- (void)showRecipeAtIndexPath:(NSIndexPath *)indexPath {
    CKRecipe *recipe = [self.recipes objectAtIndex:indexPath.item];
    [self.bookPageDelegate bookPageViewControllerShowRecipe:recipe];
    
//    [UIView animateWithDuration:0.2
//                          delay:0.0
//                        options:UIViewAnimationOptionCurveEaseIn
//                     animations:^{
//                         self.bookHeaderView.alpha = 0.0;
//                         
//                         for (UICollectionViewCell *cell in [self.collectionView visibleCells]) {
//                             cell.alpha = 0.0;
//                         }
//                         
//                     }
//                     completion:^(BOOL finished) {
//                         [self.bookPageDelegate bookPageViewControllerShowRecipe:recipe];
//                     }];
}

- (void)applyScrollingEffectsOnCategoryView {
    CGRect visibleFrame = [ViewHelper visibleFrameForCollectionView:self.collectionView];
    [self.delegate bookCategoryViewControllerScrolledOffset:visibleFrame.origin.y category:self.category];
}

@end
