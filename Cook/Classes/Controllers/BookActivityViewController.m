//
//  BookActivityViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 28/02/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookActivityViewController.h"
#import "CKBook.h"
#import "CKActivity.h"
#import "CKRecipe.h"
#import "ParsePhotoStore.h"
#import "ActivityCollectionViewCell.h"

@interface BookActivityViewController ()

@property (nonatomic, assign) CKBook *book;
@property (nonatomic, strong) ParsePhotoStore *photoStore;
@property (nonatomic, strong) NSArray *activities;

@end

@implementation BookActivityViewController

#define kActivityCellId         @"ActivityCellId"

- (id)initWithBook:(CKBook *)book {
    if (self = [super initWithCollectionViewLayout:[[UICollectionViewFlowLayout alloc] init]]) {
        self.book = book;
        self.photoStore = [[ParsePhotoStore alloc] init];
        [self loadData];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initCollectionView];
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

#pragma mark - Private methods

- (void)initCollectionView {
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    [self.collectionView registerClass:[ActivityCollectionViewCell class] forCellWithReuseIdentifier:kActivityCellId];
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
