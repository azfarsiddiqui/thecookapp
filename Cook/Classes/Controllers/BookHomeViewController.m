//
//  BookHomeViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 19/02/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookHomeViewController.h"
#import "CKBook.h"
#import "CKActivity.h"
#import "CKUser.h"
#import "CKRecipe.h"
#import "BookHomeFlowLayout.h"
#import "ActivityCollectionViewCell.h"
#import "ParsePhotoStore.h"
#import "BookContentsViewController.h"

@interface BookHomeViewController ()

@property (nonatomic, strong) CKBook *book;
@property (nonatomic, strong) NSArray *activities;
@property (nonatomic, strong) ParsePhotoStore *photoStore;
@property (nonatomic, strong) BookContentsViewController *contentsViewController;

@end

@implementation BookHomeViewController

#define kActivityCellId         @"ActivityCellId"
#define kContentsHeaderCellId   @"ContentsHeaderCellId"

- (id)initWithBook:(CKBook *)book  {
    if (self = [super initWithCollectionViewLayout:[[BookHomeFlowLayout alloc] init]]) {
        self.book = book;
        self.photoStore = [[ParsePhotoStore alloc] init];
        self.contentsViewController = [[BookContentsViewController alloc] initWithBook:book];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initCollectionView];
    [self loadData];
}

- (void)configureCategories:(NSArray *)categories {
    [self.contentsViewController configureCategories:categories];
}

- (void)configureHeroRecipe:(CKRecipe *)recipe {
    [self.contentsViewController configureRecipe:recipe];
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

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionReusableView *cell = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kContentsHeaderCellId forIndexPath:indexPath];
    self.contentsViewController.view.frame = cell.bounds;
    [cell addSubview:self.contentsViewController.view];
    return cell;
}

#pragma mark - UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    DLog();
}

#pragma mark - UICollectionViewDelegateFlowLayout methods

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return [ActivityCollectionViewCell cellSize];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    
    return UIEdgeInsetsMake(80.0, 62.0, 80.0, 62.0);
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
    
    // Size of top header.
    return self.view.bounds.size;
}

#pragma mark - Private methods

- (void)initCollectionView {
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    [self.collectionView registerClass:[ActivityCollectionViewCell class] forCellWithReuseIdentifier:kActivityCellId];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kContentsHeaderCellId];
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

@end
