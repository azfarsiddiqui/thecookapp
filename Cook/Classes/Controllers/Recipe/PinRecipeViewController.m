//
//  PinRecipeViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 17/10/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "PinRecipeViewController.h"
#import "CKBook.h"
#import "CKRecipe.h"
#import "AddRecipeLayout.h"
#import "ModalOverlayHeaderView.h"
#import "AddRecipePageCell.h"
#import "ViewHelper.h"

@interface PinRecipeViewController () <UICollectionViewDataSource, UICollectionViewDelegate, AddRecipeLayoutDelegate>

@property (nonatomic, strong) CKRecipe *recipe;
@property (nonatomic, strong) CKBook *book;
@property (nonatomic, weak) id<PinRecipeViewControllerDelegate> delegate;

@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UILabel *noPagesLabel;
@property (nonatomic, assign) BOOL loaded;
@property (nonatomic, assign) BOOL pinning;
@property (nonatomic, strong) NSNumber *selectedNumber;

@end

@implementation PinRecipeViewController

#define kHeaderCellId   @"HeaderId"
#define kCellId         @"CellId"

- (id)initWithRecipe:(CKRecipe *)recipe book:(CKBook *)book delegate:(id<PinRecipeViewControllerDelegate>)delegate {
    if (self = [super init]) {
        self.recipe = recipe;
        self.book = book;
        self.delegate = delegate;
        self.loaded = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight;
    
    self.collectionView.alpha = 0.0;
    [self.view addSubview:self.collectionView];
    self.closeButton = [ViewHelper addCloseButtonToView:self.view light:YES target:self selector:@selector(closeTapped:)];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self loadData];
}

#pragma mark - AddRecipeLayoutDelegate methods

- (void)addRecipeLayoutDidFinish {
    DLog();
}

#pragma mark - UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.pinning) {
        return;
    }
    self.pinning = YES;
    
    // Do we have a previously selected page.
    if (self.selectedNumber) {
        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:[self.selectedNumber integerValue] inSection:0]];
        cell.selected = NO;
    }
    self.selectedNumber = [NSNumber numberWithInteger:indexPath.item];
    
    NSString *page = [self.book.pages objectAtIndex:indexPath.item];
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationCurveEaseIn
                     animations:^{
                         self.collectionView.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         
                         [self showProgress:0.1 message:NSLocalizedString(@"ADDING TO PAGE", nil)];
                         
                         // Pin the recipe via network.
                         [self.recipe pinToBook:self.book
                                           page:page
                                     completion:^(CKRecipePin *recipePin) {
                                         
                                         self.pinning = NO;
                                         
                                         // Update RecipeDetailsVC.
                                         [self.delegate pinRecipeViewControllerPinnedWithRecipePin:recipePin];
                                         
                                         // Complete progress then close.
                                         [self showProgress:1.0 delay:1.0 completion:^{
                                             [self.delegate pinRecipeViewControllerCloseRequested];
                                         }];
                                         
                                     } failure:^(NSError *error) {
                                         
                                         self.pinning = NO;
                                         
                                         [self hideProgress];
                                         
                                         // Fade in the pages again.
                                         [UIView animateWithDuration:0.25
                                                               delay:0.5
                                                             options:UIViewAnimationCurveEaseIn
                                                          animations:^{
                                                              self.collectionView.alpha = 1.0;
                                                          }
                                                          completion:^(BOOL finished) {
                                                          }];
                                         
                                     }];
                     }];
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.book.pages count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    AddRecipePageCell *cell = (AddRecipePageCell *)[self.collectionView dequeueReusableCellWithReuseIdentifier:kCellId forIndexPath:indexPath];
    [cell configurePage:[self.book.pages objectAtIndex:indexPath.item]];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionReusableView *supplementaryView = nil;
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        
        ModalOverlayHeaderView *headerView = [self.collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                                     withReuseIdentifier:kHeaderCellId forIndexPath:indexPath];
        [headerView configureTitle:NSLocalizedString(@"ADD TO BOOK", nil)];
        supplementaryView = headerView;
    }
    
    return supplementaryView;
}

#pragma mark - Properties

- (UILabel *)noPagesLabel {
    if (!_noPagesLabel) {
        _noPagesLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _noPagesLabel.font = [UIFont fontWithName:@"BrandonGrotesque-Regular" size:18.0];
        _noPagesLabel.textColor = [UIColor whiteColor];
        _noPagesLabel.text = NSLocalizedString(@"NO PAGES", nil);
        [_noPagesLabel sizeToFit];
    }
    return _noPagesLabel;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds
                                             collectionViewLayout:[[AddRecipeLayout alloc] initWithDelegate:self]];
        _collectionView.bounces = YES;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.alwaysBounceVertical = YES;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight;
        [_collectionView registerClass:[AddRecipePageCell class] forCellWithReuseIdentifier:kCellId];
        [_collectionView registerClass:[ModalOverlayHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderCellId];
    }
    return _collectionView;
}

- (void)closeTapped:(id)sender {
    [self.delegate pinRecipeViewControllerCloseRequested];
}

- (void)loadData {
    // Fade the pages in.
    self.collectionView.alpha = 0.0;
    self.collectionView.transform = CGAffineTransformMakeTranslation(0.0, 30.0);
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.collectionView.alpha = 1.0;
                         self.collectionView.transform = CGAffineTransformIdentity;
                     }
                     completion:^(BOOL finished) {
                     }];
}

@end
