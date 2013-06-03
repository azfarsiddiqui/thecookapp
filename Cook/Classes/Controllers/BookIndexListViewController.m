//
//  BookIndexListViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 3/06/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookIndexListViewController.h"
#import "CKBook.h"
#import "ParsePhotoStore.h"
#import "BookIndexListLayout.h"
#import "BookIndexCell.h"
#import "Theme.h"
#import "CKRecipe.h"
#import "ImageHelper.h"
#import "CKBookCover.h"

@interface BookIndexListViewController () <BookIndexListLayoutDataSource, UICollectionViewDataSource,
    UICollectionViewDelegate>

@property (nonatomic, strong) CKBook *book;
@property (nonatomic, strong) CKRecipe *heroRecipe;
@property (nonatomic, assign) id<BookIndexListViewControllerDelegate> delegate;
@property (nonatomic, strong) ParsePhotoStore *photoStore;
@property (nonatomic, strong) NSArray *categories;

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation BookIndexListViewController

#define kCellId         @"kBookIndexListCell"
#define kIndexWidth     485.0

- (id)initWithBook:(CKBook *)book delegate:(id<BookIndexListViewControllerDelegate>)delegate {
    if (self = [super init]) {
        self.book = book;
        self.delegate = delegate;
        self.photoStore = [[ParsePhotoStore alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self initBackgroundImageView];
    [self initTitleView];
    [self initCollectionView];
    [self initShadowViews];
}

- (void)configureCategories:(NSArray *)categories {
    self.categories = categories;
    
    [self.collectionView performBatchUpdates:^{
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    } completion:^(BOOL finished) {
        [self showIndex:YES animated:YES];
    }];
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

#pragma mark - BookIndexListLayoutDataSource methods

- (NSArray *)bookIndexListLayoutCategories {
    return self.categories;
}

#pragma mark - UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.delegate bookIndexSelectedCategory:[self.categories objectAtIndex:indexPath.item]];
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
    
    BookIndexCell *cell = (BookIndexCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kCellId forIndexPath:indexPath];
    NSString *category = [self.categories objectAtIndex:indexPath.item];
    [cell configureCategory:category recipes:[self.delegate bookIndexRecipesForCategory:category]];
    return cell;
}

#pragma mark - Private methods

- (void)initBackgroundImageView {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:nil];
    imageView.frame = self.view.bounds;
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    imageView.backgroundColor = [Theme categoryHeaderBackgroundColour];
    [self.view addSubview:imageView];
    self.imageView = imageView;
}

- (void)initTitleView {
    
}

- (void)initCollectionView {
    BookIndexListLayout *indexLayout = [[BookIndexListLayout alloc] initWithDataSource:self];
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - kIndexWidth,
                                                                                          self.view.bounds.origin.y,
                                                                                          kIndexWidth,
                                                                                          self.view.bounds.size.height)
                                                          collectionViewLayout:indexLayout];
    collectionView.backgroundColor = [CKBookCover colourForCover:self.book.cover];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.alwaysBounceVertical = YES;
    collectionView.alwaysBounceHorizontal = NO;
    collectionView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:collectionView];
    self.collectionView = collectionView;
    [collectionView registerClass:[BookIndexCell class] forCellWithReuseIdentifier:kCellId];
    
    // Hide it in the side.
    [self showIndex:NO animated:NO];
}

- (void)initShadowViews {
    
    // Top shadow view.
    UIImageView *headerShadowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_book_update_header_shadow.png"]];
    headerShadowImageView.frame = CGRectMake(self.view.bounds.origin.x,
                                             self.view.bounds.origin.y,
                                             headerShadowImageView.frame.size.width,
                                             headerShadowImageView.frame.size.height);
    headerShadowImageView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:headerShadowImageView];
    
    // Bottom shadow view.
    UIImageView *footerShadowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_book_update_header_shadow_bottom.png"]];
    footerShadowImageView.frame = CGRectMake(self.view.bounds.origin.x,
                                             self.view.bounds.size.height - footerShadowImageView.frame.size.height,
                                             footerShadowImageView.frame.size.width,
                                             footerShadowImageView.frame.size.height);
    footerShadowImageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:footerShadowImageView];
}

- (void)showIndex:(BOOL)show animated:(BOOL)animated {
    CGAffineTransform transform = show ? CGAffineTransformIdentity : CGAffineTransformMakeTranslation(self.collectionView.bounds.size.width, 0.0);
    
    if (show) {
        self.collectionView.hidden = NO;
        self.collectionView.alpha = 0.0;
    }
    
    if (animated) {
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationCurveEaseIn
                         animations:^{
                             self.collectionView.transform = transform;
                             self.collectionView.alpha = show ? 1.0 : 0.0;
                         } completion:^(BOOL finished) {
                             if (!show) {
                                 self.collectionView.hidden = YES;
                             }
                         }];
    } else {
        self.collectionView.transform = transform;
        if (!show) {
            self.collectionView.hidden = YES;
        }
    }
}

@end
