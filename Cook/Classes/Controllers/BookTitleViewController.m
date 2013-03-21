//
//  BookTitleViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 19/03/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookTitleViewController.h"
#import "CKBook.h"
#import "CKActivity.h"
#import "CKRecipe.h"
#import "ParsePhotoStore.h"
#import "ActivityCollectionViewCell.h"
#import "Theme.h"
#import "AppHelper.h"
#import "ImageHelper.h"
#import "BookTitleView.h"

@interface BookTitleViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) CKBook *book;
@property (nonatomic, assign) id<BookTitleViewControllerDelegate> delegate;
@property (nonatomic, strong) ParsePhotoStore *photoStore;
@property (nonatomic, strong) NSArray *activities;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIImageView *headerShadowImageView;
@property (nonatomic, strong) UIImageView *footerShadowImageView;
@property (nonatomic, strong) CKRecipe *heroRecipe;
@property (nonatomic, strong) BookTitleView *titleView;

@end

@implementation BookTitleViewController

#define kActivityCellId         @"ActivityCellId"
#define kHeaderId               @"HeaderId"
#define kCollectionViewInsets   UIEdgeInsetsMake(80.0, 0.0, 30.0, 0.0)

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
    
    self.view.frame = [[AppHelper sharedInstance] fullScreenFrame];
    
    [self initCollectionView];
    [self initShadowViews];
    [self loadData];
}

- (void)configureHeroRecipe:(CKRecipe *)recipe {
    
    // Only set the hero recipe once.
    if (self.heroRecipe) {
        return;
    }
    
    self.heroRecipe = recipe;
    [self.photoStore imageForParseFile:[recipe imageFile]   
                                  size:[BookTitleView heroImageSize]
                            completion:^(UIImage *image) {
                                [self.titleView configureImage:image];
                            }];
}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self fadeShadowView:NO];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self fadeShadowView:(!decelerate && scrollView.contentOffset.y <= 0)];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self fadeShadowView:scrollView.contentOffset.y <= 0];
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.activities count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ActivityCollectionViewCell *cell = (ActivityCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kActivityCellId
                                                                                                               forIndexPath:indexPath];
    CKActivity *activity = [self.activities objectAtIndex:indexPath.item];
    [cell configureActivity:activity];
    [self configureImageForActivityCell:cell activity:activity indexPath:indexPath];
    return cell;
}

- (UICollectionReusableView *)collectionView: (UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionReusableView *headerView = nil;
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                        withReuseIdentifier:kHeaderId
                                                               forIndexPath:indexPath];
        BookTitleView *titleView = (BookTitleView *)headerView;
        [titleView configureBook:self.book];
        self.titleView = titleView;
    }
    
    return headerView;
}

#pragma mark - UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    CKActivity *activity = [self.activities objectAtIndex:indexPath.item];
    [self.delegate bookTitleViewControllerSelectedRecipe:activity.recipe];
}

#pragma mark - UICollectionViewDelegateFlowLayout methods

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return [ActivityCollectionViewCell cellSize];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    
    return UIEdgeInsetsMake(25.0, 62.0, 80.0, 62.0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    
    // Between rows
    return 36.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    
    // Between columns
    return 36.0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
    referenceSizeForHeaderInSection:(NSInteger)section {
    return [BookTitleView headerSize];
}

#pragma mark - Private methods

- (void)initCollectionView {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(kCollectionViewInsets.left,
                                                                                          kCollectionViewInsets.top,
                                                                                          self.view.bounds.size.width - kCollectionViewInsets.left - kCollectionViewInsets.right,
                                                                                          self.view.bounds.size.height - kCollectionViewInsets.top - kCollectionViewInsets.bottom)
                                                            collectionViewLayout:flowLayout];
    collectionView.backgroundColor = [UIColor whiteColor];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:collectionView];
    self.collectionView = collectionView;
    
    [collectionView registerClass:[BookTitleView class]
       forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderId];
    [collectionView registerClass:[ActivityCollectionViewCell class] forCellWithReuseIdentifier:kActivityCellId];
}

- (void)initShadowViews {
    
    // Top shadow view.
    UIImageView *headerShadowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_book_update_header_shadow.png"]];
    headerShadowImageView.frame = CGRectMake(self.view.bounds.origin.x,
                                             self.collectionView.frame.origin.y,
                                             headerShadowImageView.frame.size.width,
                                             headerShadowImageView.frame.size.height);
    headerShadowImageView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:headerShadowImageView];
    self.headerShadowImageView = headerShadowImageView;
    
    // Bottom shadow view.
    UIImageView *footerShadowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_book_update_header_shadow_bottom.png"]];
    footerShadowImageView.frame = CGRectMake(self.view.bounds.origin.x,
                                             self.collectionView.frame.origin.y + self.collectionView.frame.size.height - footerShadowImageView.frame.size.height,
                                             footerShadowImageView.frame.size.width,
                                             footerShadowImageView.frame.size.height);
    footerShadowImageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:footerShadowImageView];
    self.footerShadowImageView = footerShadowImageView;
    
    // Initial states of shadows.
    // self.headerShadowImageView.hidden = YES;
}

- (void)loadData {
    [CKActivity activitiesForUser:self.book.user
                          success:^(NSArray *activities) {
                              DLog(@"Activities: %@", activities)
                              self.activities = activities;
                              [self.collectionView reloadData];
                          }
                          failure:^(NSError *error)  {
                              DLog(@"Unable to load activities: %@", [error localizedDescription]);
                          }];
}

- (void)configureImageForActivityCell:(ActivityCollectionViewCell *)activityCell activity:(CKActivity *)activity
                            indexPath:(NSIndexPath *)indexPath {
    CKRecipe *recipe = activity.recipe;
    
    // Configure recipe image only if this activity pertains to a recipe.
    if (recipe) {
        if ([recipe hasPhotos]) {
            
            CGSize imageSize = [ActivityCollectionViewCell imageSize];
            [self.photoStore imageForParseFile:[recipe imageFile]
                                          size:imageSize
                                     indexPath:indexPath
                                    completion:^(NSIndexPath *completedIndexPath, UIImage *image) {
                                        
                                        // Check that we have matching indexPaths as cells are re-used.
                                        if ([indexPath isEqual:completedIndexPath]) {
                                            [activityCell configureImage:image];
                                        }
                                    }];
            
        } else {
            [activityCell configureImage:nil];
        }
    }
}

- (void)fadeShadowView:(BOOL)fade {
//    if (!self.headerShadowImageView.hidden && fade) {
//        [UIView animateWithDuration:0.2
//                              delay:0.0
//                            options:UIViewAnimationCurveEaseIn
//                         animations:^{
//                             self.headerShadowImageView.alpha = 0.0;
//                         }
//                         completion:^(BOOL finished) {
//                             self.headerShadowImageView.hidden = YES;
//                         }];
//        
//    } else if (self.headerShadowImageView.hidden && !fade) {
//        self.headerShadowImageView.alpha = 0.0;
//        self.headerShadowImageView.hidden = NO;
//        [UIView animateWithDuration:0.2
//                              delay:0.0
//                            options:UIViewAnimationCurveEaseIn
//                         animations:^{
//                             self.headerShadowImageView.alpha = 1.0;
//                         }
//                         completion:^(BOOL finished) {
//                         }];
//    }
}

@end
