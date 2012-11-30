//
//  CKViewController.m
//  CKBookCoverViewDemo
//
//  Created by Jeff Tan-Ang on 21/11/12.
//  Copyright (c) 2012 Cook App Pty Ltd. All rights reserved.
//

#import "BenchtopCollectionViewController.h"
#import "BenchtopCollectionFlowLayout.h"
#import "BenchtopBookCoverViewCell.h"
#import "CKUser.h"
#import "CKBook.h"
#import "CKLoginView.h"
#import "EventHelper.h"

@interface BenchtopCollectionViewController () <CKLoginViewDelegate>

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) CKBook *myBook;
@property (nonatomic, strong) CKLoginView *loginView;

@end

@implementation BenchtopCollectionViewController

#define kCellId         @"BenchtopCellId"
#define kMySection      0

- (id)init {
    if (self = [super initWithCollectionViewLayout:[[BenchtopCollectionFlowLayout alloc] init]]) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initBackground];
    [self initLoginView];
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.alwaysBounceHorizontal = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    [self.collectionView registerClass:[BenchtopBookCoverViewCell class] forCellWithReuseIdentifier:kCellId];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)enable:(BOOL)enable {
    if (enable) {
        
        // Start loading my book if not there already.
        NSInteger numMyBooks = [self.collectionView numberOfItemsInSection:kMySection];
        if (numMyBooks == 0) {
            [self loadMyBook];
        }
        
    }
}

#pragma mark - UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    DLog();
}

#pragma mark - UICollectionViewDelegateFlowLayout methods

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [BenchtopBookCoverViewCell cellSize];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (section == kMySection) {
        return UIEdgeInsetsMake(155.0, 362.0, 155.0, 0.0);
    } else {
        return UIEdgeInsetsMake(155.0, 300.0, 155.0, 362.0);
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    NSInteger numSections = 1;
    return numSections;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    if (section == kMySection) {
        return self.myBook ? 1 : 0;
    } else {
        return 0;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BenchtopBookCoverViewCell *cell = (BenchtopBookCoverViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kCellId
                                                                                                               forIndexPath:indexPath];
    if (indexPath.section == kMySection) {
        [cell loadBook:self.myBook];
    }
    
    return cell;
}

#pragma mark - CKLoginViewDelegate

- (void)loginViewTapped {
    
    // Spin the facebook button.
    [self.loginView loginStarted];
    
    // Dispatch login after one second.
    [self performSelector:@selector(performLogin) withObject:nil afterDelay:1.0];
}

#pragma mark - Private methods

- (void)initBackground {
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_dash_bg_whole.png"]];
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, backgroundView.frame.size.width, backgroundView.frame.size.height);
    self.view.clipsToBounds = NO;
    [self.view insertSubview:backgroundView belowSubview:self.collectionView];
    self.backgroundView = backgroundView;
}

- (void)initLoginView {
    CKUser *currentUser = [CKUser currentUser];
    
    CKLoginView *loginView = [[CKLoginView alloc] initWithDelegate:self];
    loginView.frame = CGRectMake(floorf((self.view.bounds.size.width - loginView.frame.size.width) / 2.0),
                                 self.view.bounds.size.height - loginView.frame.size.height - 60.0,
                                 loginView.frame.size.width,
                                 loginView.frame.size.height);
    loginView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin;
    loginView.hidden = [currentUser isSignedIn];
    [self.view addSubview:loginView];
    self.loginView = loginView;
}

- (void)loadMyBook {
    
    // This will be called twice - once from cache if exists, then from network.
    [CKBook bookForUser:[CKUser currentUser]
                success:^(CKBook *book) {
                    self.myBook = book;
                    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:kMySection]];
                }
                failure:^(NSError *error) {
                    DLog(@"Error: %@", [error localizedDescription]);
                }];
}

- (void)performLogin {
    
    // Now tries and log the user in.
    [CKUser loginWithFacebookCompletion:^{
        
        CKUser *user = [CKUser currentUser];
        if (user.admin) {
            [self.loginView loginAdminDone];
        } else {
            [self.loginView loginLoadingFriends:[user numFollows]];
        }
        
        [self informLoginSuccessful:YES];
        
    } failure:^(NSError *error) {
        DLog(@"Error logging in: %@", [error localizedDescription]);
        
        // Reset the facebook button.
        [self.loginView loginFailed];
        
        [self informLoginSuccessful:NO];
    }];
}

- (void)informLoginSuccessful:(BOOL)success {
    
    // Remove the login view.
    self.loginView.hidden = success;
    
    [self loadMyBook];
    
    // Inform login successful.
    [EventHelper postLoginSuccessful:success];
    
}
@end
