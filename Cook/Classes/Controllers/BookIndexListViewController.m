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
#import "BookIndexSubtitledCell.h"
#import "Theme.h"
#import "CKRecipe.h"
#import "ImageHelper.h"
#import "CKBookCover.h"
#import "CKBookTitleIndexView.h"

@interface BookIndexListViewController () <BookIndexListLayoutDataSource, UICollectionViewDataSource,
    UICollectionViewDelegate>

@property (nonatomic, strong) CKBook *book;
@property (nonatomic, strong) CKRecipe *heroRecipe;
@property (nonatomic, assign) id<BookIndexListViewControllerDelegate> delegate;
@property (nonatomic, strong) ParsePhotoStore *photoStore;
@property (nonatomic, strong) NSArray *categories;

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *profileImageView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) CKBookTitleIndexView *titleIndexView;

@end

@implementation BookIndexListViewController

#define kCellId                 @"kBookIndexListCell"
#define kIndexWidth             240.0
#define kImageIndexGap          10.0
#define kTitleIndexTopOffset    40.0

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
    
    [self initBackgroundView];
    [self initTitleView];
    [self initCollectionView];
    [self initProfileView];
    [self initShadowViews];
}

- (void)configureCategories:(NSArray *)categories {
    self.categories = categories;
    
    [self.collectionView performBatchUpdates:^{
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    } completion:^(BOOL finished) {
        [self showIndexAnimated:YES];
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

- (void)initBackgroundView {
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    backgroundView.backgroundColor = [UIColor clearColor];
    backgroundView.clipsToBounds = YES;
    [self.view addSubview:backgroundView];
    self.backgroundView = backgroundView;
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:nil];
    imageView.frame = self.view.bounds;
    imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    imageView.backgroundColor = [Theme categoryHeaderBackgroundColour];
    [backgroundView addSubview:imageView];
    self.imageView = imageView;
}

- (void)initTitleView {
    CKBookTitleIndexView *titleIndexView = [[CKBookTitleIndexView alloc] initWithName:self.book.user.name title:self.book.name];
    titleIndexView.frame = (CGRect){
        floorf((self.view.bounds.size.width - titleIndexView.frame.size.width) / 2.0),
        floorf((self.view.bounds.size.height - titleIndexView.frame.size.height) / 2.0),
        titleIndexView.frame.size.width,
        titleIndexView.frame.size.height
    };
    [self.view addSubview:titleIndexView];
    self.titleIndexView = titleIndexView;
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
    
    // Prep collection view to be transitioned in later.
    self.collectionView.alpha = 0.0;
    self.collectionView.transform = CGAffineTransformMakeTranslation(collectionView.frame.size.width, 0.0);
}

- (void)initProfileView {
    UIImageView *profileImageView = [[UIImageView alloc] initWithImage:nil];
    profileImageView.frame = (CGRect){
        self.view.bounds.origin.x,
        self.view.bounds.origin.y,
        kIndexWidth,
        self.view.bounds.size.height
    };
    profileImageView.backgroundColor = [CKBookCover colourForCover:self.book.cover];
    [self.view addSubview:profileImageView];
    self.profileImageView = profileImageView;
    
    // Prep image view to be transitioned in later.
    self.profileImageView.alpha = 0.0;
    self.profileImageView.transform = CGAffineTransformMakeTranslation(-self.profileImageView.frame.size.width, 0.0);
    
    // Load the photo.
    if ([self.book.user hasCoverPhoto]) {
        [self.photoStore imageForParseFile:[self.book.user parseCoverPhotoFile]
                                      size:self.profileImageView.bounds.size
                                completion:^(UIImage *image) {
                                    self.profileImageView.image = image;
                                }];
    }

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

- (void)showIndexAnimated:(BOOL)animated {
    
    CGRect backgroundFrame = (CGRect){
        self.view.bounds.origin.x + kIndexWidth + kImageIndexGap,
        self.view.bounds.origin.y,
        self.view.bounds.size.width - self.profileImageView.frame.size.width - self.collectionView.frame.size.width - (kImageIndexGap * 2.0),
        self.view.bounds.size.height
    };
    
    CGRect titleViewFrame = (CGRect) {
        floorf((self.view.bounds.size.width - self.titleIndexView.frame.size.width) / 2.0),
        kTitleIndexTopOffset,
        self.titleIndexView.frame.size.width,
        self.titleIndexView.frame.size.height
    };
    
    if (animated) {
        [UIView animateWithDuration:0.4
                              delay:0.0
                            options:UIViewAnimationCurveEaseIn
                         animations:^{
                             self.titleIndexView.frame = titleViewFrame;
                             self.titleIndexView.transform = CGAffineTransformMakeScale(0.7, 0.7);
                             self.backgroundView.frame = backgroundFrame;
                             self.collectionView.transform = CGAffineTransformIdentity;
                             self.collectionView.alpha = 1.0;
                             self.profileImageView.transform = CGAffineTransformIdentity;
                             self.profileImageView.alpha = 1.0;
                         } completion:^(BOOL finished) {
                         }];
    } else {
        self.titleIndexView.frame = titleViewFrame;
        self.titleIndexView.transform = CGAffineTransformMakeScale(0.7, 0.7);
        self.backgroundView.frame = backgroundFrame;
        self.collectionView.transform = CGAffineTransformIdentity;
        self.collectionView.alpha = 1.0;
        self.profileImageView.transform = CGAffineTransformIdentity;
        self.profileImageView.alpha = 1.0;
    }
}

- (CGRect)backgroundFrameForShow:(BOOL)show {
    if (show) {
        return self.view.bounds;
    } else {
        return (CGRect){
            self.view.bounds.origin.x,
            self.view.bounds.origin.y,
            self.view.bounds.size.width - self.collectionView.frame.origin.x - kImageIndexGap,
            self.view.bounds.size.height
        };
    }
}

@end
