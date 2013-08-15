//
//  BookCategoryViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 13/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookContentViewController.h"
#import "CKBook.h"
#import "CKRecipe.h"
#import "BookCategoryLayout.h"
#import "ParsePhotoStore.h"
#import "MRCEnumerable.h"
#import "BookContentTitleView.h"
#import "ViewHelper.h"
#import "BookContentGridLayout.h"
#import "BookRecipeGridLargeCell.h"
#import "BookRecipeGridMediumCell.h"
#import "BookRecipeGridSmallCell.h"
#import "BookRecipeGridExtraSmallCell.h"

@interface BookContentViewController () <UICollectionViewDataSource, UICollectionViewDelegate,
    BookContentGridLayoutDelegate>

@property (nonatomic, weak) id<BookContentViewControllerDelegate> delegate;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) CKBook *book;
@property (nonatomic, strong) NSString *page;
@property (nonatomic, strong) ParsePhotoStore *photoStore;
@property (nonatomic, strong) NSMutableArray *recipes;

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) BookContentTitleView *contentTitleView;

@end

@implementation BookContentViewController

#define kRecipeCellId       @"RecipeCellId"
#define kContentHeaderId    @"ContentHeaderId"

- (id)initWithBook:(CKBook *)book page:(NSString *)page delegate:(id<BookContentViewControllerDelegate>)delegate {
    
    if (self = [super init]) {
        self.delegate = delegate;
        self.book = book;
        self.page = page;
        self.photoStore = [[ParsePhotoStore alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];

    [self initCollectionView];
    [self initOverlay];
    [self loadData];
}

- (void)loadData {
    self.recipes = [NSMutableArray arrayWithArray:[self.delegate recipesForBookContentViewControllerForPage:self.page]];
    [self.collectionView reloadData];
}

- (CGPoint)currentScrollOffset {
    CGRect visibleFrame = [ViewHelper visibleFrameForCollectionView:self.collectionView];
    return visibleFrame.origin;
}

- (void)applyOverlayAlpha:(CGFloat)alpha {
    self.overlayView.alpha = alpha;
}

#pragma mark - BookContentGridLayoutDelegate methods

- (void)bookContentGridLayoutDidFinish {
    DLog();
}

- (NSInteger)bookContentGridLayoutNumColumns {
    return 3;
}

- (BookContentGridType)bookContentGridTypeForItemAtIndex:(NSInteger)itemIndex {
    CKRecipe *recipe = [self.recipes objectAtIndex:itemIndex];
    return [self gridTypeForRecipe:recipe];
}

- (CGSize)bookContentGridLayoutHeaderSize {
    return self.contentTitleView.frame.size;
}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self applyScrollingEffectsOnCategoryView];
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
    
    CKRecipe *recipe = [self.recipes objectAtIndex:indexPath.item];
    BookContentGridType gridType = [self gridTypeForRecipe:recipe];
    NSString *cellId = [self cellIdentifierForGridType:gridType];
    
    BookRecipeGridCell *recipeCell = (BookRecipeGridCell *)[self.collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    
    [recipeCell configureRecipe:recipe book:self.book];
    
    // Configure image.
    [self configureImageForRecipeCell:recipeCell recipe:recipe indexPath:indexPath];
    
    return recipeCell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionReusableView *reusableView = [self.collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kContentHeaderId forIndexPath:indexPath];
    if (!self.contentTitleView.superview) {
        self.contentTitleView.frame = reusableView.bounds;
        [reusableView addSubview:self.contentTitleView];
    }
    
    return reusableView;
}

#pragma mark - Properties

- (BookContentTitleView *)contentTitleView {
    if (!_contentTitleView) {
        _contentTitleView = [[BookContentTitleView alloc] initWithTitle:self.page];
    }
    return _contentTitleView;
}

#pragma mark - Private 

- (void)initImageView {
    self.imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.imageView];
}

- (void)initCollectionView {
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds
                                                          collectionViewLayout:[[BookContentGridLayout alloc] initWithDelegate:self]];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    collectionView.alwaysBounceVertical = YES;
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:collectionView];
    self.collectionView = collectionView;
    
    [self.collectionView registerClass:[BookRecipeGridLargeCell class]
            forCellWithReuseIdentifier:[self cellIdentifierForGridType:BookContentGridTypeLarge]];
    [self.collectionView registerClass:[BookRecipeGridMediumCell class]
            forCellWithReuseIdentifier:[self cellIdentifierForGridType:BookContentGridTypeMedium]];
    [self.collectionView registerClass:[BookRecipeGridSmallCell class]
            forCellWithReuseIdentifier:[self cellIdentifierForGridType:BookContentGridTypeSmall]];
    [self.collectionView registerClass:[BookRecipeGridExtraSmallCell class]
            forCellWithReuseIdentifier:[self cellIdentifierForGridType:BookContentGridTypeExtraSmall]];
    
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kContentHeaderId];
}

- (void)initOverlay {
    UIView *overlayView = [[UIView alloc] initWithFrame:self.view.bounds];
    overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    overlayView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
    [self.view addSubview:overlayView];
    self.overlayView = overlayView;
}

- (void)loadFeaturedRecipe {
    CKRecipe *featuredRecipe = [self.delegate featuredRecipeForBookContentViewControllerForPage:self.page];
    [self.photoStore imageForParseFile:[featuredRecipe imageFile]
                                  size:self.imageView.bounds.size
                            completion:^(UIImage *image) {
                                self.imageView.image = image;
                            }];
}

- (void)configureImageForRecipeCell:(BookRecipeGridCell *)recipeCell recipe:(CKRecipe *)recipe
                          indexPath:(NSIndexPath *)indexPath {
    
    if ([recipe hasPhotos]) {
        CGSize imageSize = [BookRecipeGridCell imageSize];
        [self.photoStore imageForParseFile:[recipe imageFile]
                                      size:imageSize
                                 indexPath:indexPath
                                completion:^(NSIndexPath *completedIndexPath, UIImage *image) {
                                    
                                    // Check that we have matching indexPaths as cells are re-used.
                                    if ([indexPath isEqual:completedIndexPath]) {
                                        [recipeCell configureImage:image];
                                    }
                                }];
    } else {
        [recipeCell configureImage:nil];
    }
}

- (void)showRecipeAtIndexPath:(NSIndexPath *)indexPath {
    CKRecipe *recipe = [self.recipes objectAtIndex:indexPath.item];
    [self.bookPageDelegate bookPageViewControllerShowRecipe:recipe];
}

- (void)applyScrollingEffectsOnCategoryView {
    CGRect visibleFrame = [ViewHelper visibleFrameForCollectionView:self.collectionView];
    [self.delegate bookContentViewControllerScrolledOffset:visibleFrame.origin.y page:self.page];
}

- (BookContentGridType)gridTypeForRecipe:(CKRecipe *)recipe {
    
    // Defaults to large, which makes computing combinations easier.
    BookContentGridType gridType = BookContentGridTypeLarge;
    
    if ([recipe hasPhotos]) {
        
        if (![recipe hasTitle] && ![recipe hasStory] && ![recipe hasMethod] && ![recipe hasIngredients]) {
            
            // +Photo -Title -Story -Method -Ingredients
            gridType = BookContentGridTypeExtraSmall;
            
        } else if ([recipe hasTitle] && ![recipe hasStory] && ![recipe hasMethod] && ![recipe hasIngredients]) {
            
            // +Photo +Title -Story -Method -Ingredients
            gridType = BookContentGridTypeSmall;
            
        } else if (![recipe hasTitle] && [recipe hasStory] && ![recipe hasMethod] && ![recipe hasIngredients]) {
            
            // +Photo -Title +Story -Method -Ingredients
            gridType = BookContentGridTypeMedium;
            
        } else if (![recipe hasTitle] && ![recipe hasStory] && [recipe hasMethod] && ![recipe hasIngredients]) {
            
            // +Photo -Title -Story +Method -Ingredients
            gridType = BookContentGridTypeMedium;
            
        } else if (![recipe hasTitle] && ![recipe hasStory] && ![recipe hasMethod] && [recipe hasIngredients]) {
            
            // +Photo -Title -Story -Method +Ingredients
            gridType = BookContentGridTypeMedium;
            
        }
        
    } else {
        
        if ([recipe hasTitle] && ![recipe hasStory] && ![recipe hasMethod] && ![recipe hasIngredients]) {
            
            // -Photo +Title -Story -Method -Ingredients
            gridType = BookContentGridTypeExtraSmall;
            
        } else if (![recipe hasTitle] && [recipe hasStory] && ![recipe hasMethod] && ![recipe hasIngredients]) {
            
            // -Photo -Title +Story -Method -Ingredients
            gridType = BookContentGridTypeExtraSmall;
            
        } else if (![recipe hasTitle] && ![recipe hasStory] && [recipe hasMethod] && ![recipe hasIngredients]) {
            
            // -Photo -Title -Story +Method -Ingredients
            gridType = BookContentGridTypeExtraSmall;
            
        } else if (![recipe hasTitle] && ![recipe hasStory] && ![recipe hasMethod] && [recipe hasIngredients]) {
            
            // -Photo -Title -Story -Method +Ingredients
            gridType = BookContentGridTypeExtraSmall;
            
        } else if ([recipe hasTitle] && [recipe hasStory] && ![recipe hasIngredients]) {
            
            // -Photo +Title +Story (+/-)Method -Ingredients
            gridType = BookContentGridTypeSmall;
            
        } else if ([recipe hasTitle] && ![recipe hasStory] && [recipe hasMethod] && ![recipe hasIngredients]) {
            
            // -Photo +Title -Story +Method -Ingredients
            gridType = BookContentGridTypeSmall;
            
        } else if ([recipe hasTitle] && ![recipe hasStory] && ![recipe hasMethod] && ![recipe hasIngredients]) {
            
            // -Photo +Title -Story -Method +Ingredients
            gridType = BookContentGridTypeSmall;
            
        }
    }
    
    DLog(@"recipe[%@] gridType[%d]", recipe.name, gridType);

    return gridType;
}

- (NSString *)cellIdentifierForGridType:(BookContentGridType)gridType {
    return [NSString stringWithFormat:@"GridType%d", gridType];
}

@end
