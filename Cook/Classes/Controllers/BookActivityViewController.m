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
#import "Theme.h"
#import "AppHelper.h"

@interface BookActivityViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, assign) CKBook *book;
@property (nonatomic, assign) id<BookActivityViewControllerDelegate> delegate;
@property (nonatomic, strong) ParsePhotoStore *photoStore;
@property (nonatomic, strong) NSArray *activities;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIImageView *headerShadowImageView;

@end

@implementation BookActivityViewController

#define kActivityCellId         @"ActivityCellId"
#define kHeaderHeight           140.0
#define kHeaderInsets           UIEdgeInsetsMake(50.0, 55.0, 0.0, 0.0)

- (id)initWithBook:(CKBook *)book delegate:(id<BookActivityViewControllerDelegate>)delegate {
    if (self = [super init]) {
        self.book = book;
        self.delegate = delegate;
        self.photoStore = [[ParsePhotoStore alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initHeaderView];
    [self initCollectionView];
    [self loadData];
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

#pragma mark - UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    CKActivity *activity = [self.activities objectAtIndex:indexPath.item];
    [self.delegate bookActivityViewControllerSelectedRecipe:activity.recipe];
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

#pragma mark - Private methods

- (void)initHeaderView {
    UIImageView *headerShadowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_book_update_header_shadow.png"]];
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x,
                                                                  self.view.bounds.origin.y,
                                                                  self.view.bounds.size.width,
                                                                  kHeaderHeight - headerShadowImageView.frame.size.height)];
    headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
    headerView.backgroundColor = [UIColor whiteColor];
    headerView.clipsToBounds = YES;
    [self.view addSubview:headerView];
    self.headerView = headerView;
    
    headerShadowImageView.frame = CGRectMake(self.view.bounds.origin.x,
                                             headerView.frame.origin.y + headerView.frame.size.height,
                                             headerShadowImageView.frame.size.width,
                                             headerShadowImageView.frame.size.height);
    headerShadowImageView.autoresizingMask = UIViewAutoresizingNone;
    headerShadowImageView.hidden = YES;
    [self.view addSubview:headerShadowImageView];
    self.headerShadowImageView = headerShadowImageView;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor whiteColor];
    label.textColor = [Theme bookActivityHeaderColour];
    label.font = [Theme bookActivityHeaderFont];
    label.text = @"UPDATES";
    [label sizeToFit];
    label.frame = CGRectMake(headerView.bounds.origin.x + kHeaderInsets.left,
                             headerView.bounds.origin.y + kHeaderInsets.top,
                             label.frame.size.width,
                             label.frame.size.height);
    [headerView addSubview:label];
}

- (void)initCollectionView {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x,
                                                                                          self.headerView.frame.origin.y + self.headerView.frame.size.height,
                                                                                          self.view.bounds.size.width,
                                                                                          self.view.bounds.size.height - self.headerView.frame.origin.y - self.headerView.frame.size.height)
                                                          collectionViewLayout:flowLayout];
    collectionView.backgroundColor = [UIColor whiteColor];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight;
    [self.view insertSubview:collectionView belowSubview:self.headerShadowImageView];
    self.collectionView = collectionView;
    
    [collectionView registerClass:[ActivityCollectionViewCell class] forCellWithReuseIdentifier:kActivityCellId];
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
    if (!self.headerShadowImageView.hidden && fade) {
        [UIView animateWithDuration:0.2
                              delay:0.0
                            options:UIViewAnimationCurveEaseIn
                         animations:^{
                             self.headerShadowImageView.alpha = 0.0;
                         }
                         completion:^(BOOL finished) {
                             self.headerShadowImageView.hidden = YES;
                         }];
        
    } else if (self.headerShadowImageView.hidden && !fade) {
        self.headerShadowImageView.alpha = 0.0;
        self.headerShadowImageView.hidden = NO;
        [UIView animateWithDuration:0.2
                              delay:0.0
                            options:UIViewAnimationCurveEaseIn
                         animations:^{
                             self.headerShadowImageView.alpha = 1.0;
                         }
                         completion:^(BOOL finished) {
                         }];
    }
}

@end
