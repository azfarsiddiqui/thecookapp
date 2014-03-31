//
//  RecipeSearchViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 26/03/2014.
//  Copyright (c) 2014 Cook Apps Pty Ltd. All rights reserved.
//

#import "RecipeSearchViewController.h"
#import "AnalyticsHelper.h"
#import "ViewHelper.h"
#import "CKRecipeSearchFieldView.h"
#import "RecipeGridLayout.h"
#import "SearchRecipeGridLayout.h"
#import "BookRecipeGridExtraSmallCell.h"
#import "BookRecipeGridSmallCell.h"
#import "BookRecipeGridMediumCell.h"
#import "BookRecipeGridLargeCell.h"
#import "CKRecipe.h"
#import "CKBook.h"
#import "MRCEnumerable.h"
#import "ModalOverlayHelper.h"
#import "ImageHelper.h"
#import "AppHelper.h"
#import "RootViewController.h"
#import "CKContentContainerCell.h"

@interface RecipeSearchViewController () <UICollectionViewDataSource, UICollectionViewDelegate,
    RecipeGridLayoutDelegate, CKRecipeSearchFieldViewDelegate>

@property (nonatomic, weak) id<RecipeSearchViewControllerDelegate> delegate;
@property (nonatomic, strong) UIImageView *blurredImageView;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIView *dividerView;
@property (nonatomic, strong) UIView *topMaskView;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) CKRecipeSearchFieldView *searchFieldView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) BOOL resultsMode;
@property (nonatomic, strong) NSMutableArray *recipes;
@property (nonatomic, assign) NSUInteger count;

@end

@implementation RecipeSearchViewController

#define kContentInsets              (UIEdgeInsets){ 30.0, 15.0, 50.0, 15.0 }
#define kHeaderHeight               110.0
#define kTopMaskOffset              112.0
#define kSearchTopOffset            41.0
#define kSearchMidOffset            220.0
#define kSearchCollectionViewGap    20.0
#define kHelpFont                   [UIFont fontWithName:@"BrandonGrotesque-Regular" size:20]
#define kHeaderCellId               @"DividerHeaderId"

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (id)initWithDelegate:(id<RecipeSearchViewControllerDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.blurredImageView];
    [self.view addSubview:self.containerView];
    [self.containerView addSubview:self.collectionView];
    [self.containerView addSubview:self.closeButton];
    
    self.searchFieldView.frame = [self frameForSearchFieldViewResultsMode:NO];
    [self.containerView addSubview:self.searchFieldView];
    
    // Register for keyboard events.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [AnalyticsHelper trackEventName:kEventSearchView];
}

- (void)focusSearchField:(BOOL)focus {
    
    // Focus the search field to kick off the keyboard event that triggers everything else.
    [self.searchFieldView focus:focus];
}

#pragma mark - UICollectionViewDelegate methods

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self showRecipeAtIndexPath:indexPath];
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    NSInteger numItems = [self.recipes count];
    return numItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CKRecipe *recipe = [self.recipes objectAtIndex:indexPath.item];
    RecipeGridType gridType = [RecipeGridLayout gridTypeForRecipe:recipe];
    NSString *cellId = [RecipeGridLayout cellIdentifierForGridType:gridType];
    DLog(@"cellId: %@", cellId);
    
    BookRecipeGridCell *recipeCell = (BookRecipeGridCell *)[self.collectionView dequeueReusableCellWithReuseIdentifier:cellId
                                                                                                          forIndexPath:indexPath];
    [recipeCell configureRecipe:recipe book:recipe.book own:NO];
    return recipeCell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionReusableView *reusableView = nil;
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        
        reusableView = [self.collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                               withReuseIdentifier:kHeaderCellId forIndexPath:indexPath];
        reusableView.backgroundColor = [UIColor whiteColor];
    }
    
    return reusableView;
}


#pragma mark - RecipeGridLayoutDelegate methods

- (void)recipeGridLayoutDidFinish {
    DLog();
}

- (NSInteger)recipeGridLayoutNumItems {
    return [self.recipes count];
}

- (RecipeGridType)recipeGridTypeForItemAtIndex:(NSInteger)itemIndex {
    CKRecipe *recipe = [self.recipes objectAtIndex:itemIndex];
    return [RecipeGridLayout gridTypeForRecipe:recipe];
}

- (CGSize)recipeGridLayoutHeaderSize {
    return CGSizeZero;
}

- (CGSize)recipeGridLayoutFooterSize {
    return CGSizeZero;
}

- (CGFloat)recipeGridCellsOffset {
    return 20.0;
}

- (BOOL)recipeGridLayoutHeaderEnabled {
    return YES;
}

- (BOOL)recipeGridLayoutLoadMoreEnabled {
    return NO;
}

- (BOOL)recipeGridLayoutDisabled {
    return NO;
}

- (CGFloat)recipeGridInitialOffset {
    return 50.0;
}

- (CGFloat)recipeGridFinalOffset {
    return 270.0;
}

#pragma mark - CKRecipeSearchFieldViewDelegate methods

- (BOOL)recipeSearchFieldShouldFocus {
    if (self.resultsMode) {
        [self clearResults];
    }
    
    return YES;
}

- (NSString *)recipeSearchFieldViewPlaceholderText {
    return @"NAME, INGREDIENT OR TAG";
}

- (void)recipeSearchFieldViewSearchByText:(NSString *)text {
    
    [self enableResultsMode:YES completion:^{
        
        [self.searchFieldView setSearching:YES];
        
        [CKRecipe searchWithTerm:text
                         success:^(NSArray *recipes, NSUInteger count) {
                             
                             [self.searchFieldView setSearching:NO];
                             [self.searchFieldView showNumResults:count];
                             
                             self.recipes = [NSMutableArray arrayWithArray:recipes];
                             self.count = count;
                             
                             // Gather indexPaths to insert.
                             NSMutableArray *indexPathsToInsert = [NSMutableArray arrayWithArray:[recipes collectWithIndex:^(CKRecipe *recipe, NSUInteger recipeIndex) {
                                 return [NSIndexPath indexPathForItem:recipeIndex inSection:0];
                             }]];
                             
                             // UI updates after invalidating layout.
                             [((RecipeGridLayout *)self.collectionView.collectionViewLayout) setNeedsRelayout:YES];
                             [self.collectionView performBatchUpdates:^{
                                 [self.collectionView insertItemsAtIndexPaths:indexPathsToInsert];
                             } completion:^(BOOL finished) {
                             }];
                             
                         }
                         failure:^(NSError *error) {
                             
                             [self.searchFieldView setSearching:NO];
                             
                             DLog(@"Error");
                         }];
    }];
}

- (void)recipeSearchFieldViewClearRequested {
    [self clearResults];
}

#pragma mark - Keyboard events

- (void)keyboardDidShow:(NSNotification *)notification {
//    [self handleKeyboardShow:YES notification:notification];
}

- (void)keyboardDidHide:(NSNotification *)notification {
//    [self handleKeyboardShow:NO notification:notification];
}

#pragma mark - Properties

- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [[UIView alloc] initWithFrame:self.view.bounds];
        _containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    }
    return _containerView;
}

- (UIView *)dividerView {
    if (!_dividerView) {
        _dividerView.backgroundColor = [UIColor whiteColor];
        _dividerView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    }
    return _dividerView;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [ViewHelper closeButtonLight:YES target:self selector:@selector(closeTapped:)];
        _closeButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
        _closeButton.frame = (CGRect){
            kContentInsets.left,
            floorf((kHeaderHeight - _closeButton.frame.size.height) / 2.0) + 5.0,
            _closeButton.frame.size.width,
            _closeButton.frame.size.height
        };
    }
    return _closeButton;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:(CGRect){
            self.view.bounds.origin.x,
            kHeaderHeight,
            self.view.bounds.size.width,
            self.view.bounds.size.height - kHeaderHeight
        } collectionViewLayout:[[SearchRecipeGridLayout alloc] initWithDelegate:self]];
        _collectionView.bounces = YES;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.alwaysBounceVertical = YES;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleBottomMargin;
        [self.collectionView registerClass:[BookRecipeGridLargeCell class]
                forCellWithReuseIdentifier:[RecipeGridLayout cellIdentifierForGridType:RecipeGridTypeLarge]];
        [self.collectionView registerClass:[BookRecipeGridMediumCell class]
                forCellWithReuseIdentifier:[RecipeGridLayout cellIdentifierForGridType:RecipeGridTypeMedium]];
        [self.collectionView registerClass:[BookRecipeGridSmallCell class]
                forCellWithReuseIdentifier:[RecipeGridLayout cellIdentifierForGridType:RecipeGridTypeSmall]];
        [self.collectionView registerClass:[BookRecipeGridExtraSmallCell class]
                forCellWithReuseIdentifier:[RecipeGridLayout cellIdentifierForGridType:RecipeGridTypeExtraSmall]];
        [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderCellId];
    }
    return _collectionView;
}

- (CKRecipeSearchFieldView *)searchFieldView {
    if (!_searchFieldView) {
        _searchFieldView = [[CKRecipeSearchFieldView alloc] initWithDelegate:self];
        _searchFieldView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
    }
    return _searchFieldView;
}

- (UIImageView *)blurredImageView {
    if (!_blurredImageView) {
        _blurredImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        _blurredImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _blurredImageView.image = [self.delegate recipeSearchBlurredImageForDash];
    }
    return _blurredImageView;
}

#pragma mark - Private methods

- (void)closeTapped:(id)sender {
    [self clearResultsCompletion:^{
        [self.delegate recipeSearchViewControllerDismissRequested];
    }];
}

- (void)showRecipeAtIndexPath:(NSIndexPath *)indexPath {
    CKRecipe *recipe = [self.recipes objectAtIndex:indexPath.item];
    [[[AppHelper sharedInstance] rootViewController] showModalWithRecipe:recipe callerView:self.containerView];
}

- (CGRect)frameForSearchFieldViewResultsMode:(BOOL)resultsMode {
    UIOffset offset = [self offsetForSearchFieldViewResultsMode:resultsMode];
    return (CGRect) {
        offset.horizontal,
        offset.vertical,
        self.searchFieldView.frame.size.width,
        self.searchFieldView.frame.size.height
    };
}

- (UIOffset)offsetForSearchFieldViewResultsMode:(BOOL)resultsMode {
    CGSize searchFieldSize = [self.searchFieldView sizeForExpanded:!resultsMode];
    return (UIOffset) {
        floorf((self.view.bounds.size.width - searchFieldSize.width) / 2.0),
        resultsMode ? floorf((kHeaderHeight - searchFieldSize.height) / 2.0) + 10.0 : kSearchMidOffset
    };
}

- (void)enableResultsMode:(BOOL)resultsMode {
    [self enableResultsMode:resultsMode completion:nil];
}

- (void)enableResultsMode:(BOOL)resultsMode completion:(void (^)())completion {
    CGSize searchFieldSize = [self.searchFieldView sizeForExpanded:!resultsMode];
    UIOffset offset = [self offsetForSearchFieldViewResultsMode:resultsMode];
    CGRect frame = (CGRect){ offset.horizontal, offset.vertical, searchFieldSize.width, searchFieldSize.height };
    
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationCurveEaseInOut
                     animations:^{
                         [self.searchFieldView expand:!resultsMode animated:NO];
                         self.searchFieldView.frame = frame;
                     }
                     completion:^(BOOL finished) {
                         self.resultsMode = YES;
                         if (completion != nil) {
                             completion();
                         }
                     }];
}
- (void)handleKeyboardShow:(BOOL)show notification:(NSNotification *)notification {
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    self.searchFieldView.frame = [self frameForSearchFieldViewResultsMode:show];
    
    [UIView commitAnimations];
}

- (void)clearResults {
    [self clearResultsCompletion:nil];
}

- (void)clearResultsCompletion:(void (^)())completion  {
    
    [self enableResultsMode:NO];
    
    // Gather indexPaths to insert.
    NSMutableArray *indexPathsToDelete = [NSMutableArray arrayWithArray:[self.recipes collectWithIndex:^(CKRecipe *recipe, NSUInteger recipeIndex) {
        return [NSIndexPath indexPathForItem:recipeIndex inSection:0];
    }]];
    [self.recipes removeAllObjects];
    
    if ([indexPathsToDelete count] > 0) {
        
        // UI updates after invalidating layout.
        [((RecipeGridLayout *)self.collectionView.collectionViewLayout) setNeedsRelayout:YES];
        [self.collectionView performBatchUpdates:^{
            [self.collectionView deleteItemsAtIndexPaths:indexPathsToDelete];
        } completion:^(BOOL finished) {
            if (completion != nil) {
                completion();
            }
        }];
        
    } else {
        
        if (completion != nil) {
            completion();
        }
    }
    
}

- (void)loadSnapshotImage:(UIImage *)snapshotImage {
    
    // Blurred imageView to be hidden to start off with.
    self.blurredImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    self.blurredImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.blurredImageView];
    self.blurredImageView.alpha = 0.0;  // To be faded in after blurred image has finished loaded.
    self.blurredImageView.image = snapshotImage;
    
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationCurveEaseIn
                     animations:^{
                         self.blurredImageView.alpha = 1.0;
                     } completion:^(BOOL finished) {
                     }];
    
}

- (void)applyTopMaskViewIfRequired {
    if (self.topMaskView) {
        return;
    }
    
    CGRect maskFrame = [self maskFrame];
    self.topMaskView = [self.blurredImageView resizableSnapshotViewFromRect:maskFrame afterScreenUpdates:YES withCapInsets:UIEdgeInsetsZero];
    self.topMaskView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
    self.topMaskView.frame = maskFrame;
    
    // Alpha gradient.
    CAGradientLayer *alphaGradientLayer = [CAGradientLayer layer];
    NSArray *colours = [NSArray arrayWithObjects:
                       (id)[[UIColor colorWithWhite:0 alpha:0] CGColor],
                       (id)[[UIColor colorWithWhite:0 alpha:1] CGColor],
                       nil];
    alphaGradientLayer.colors = colours;
    alphaGradientLayer.frame = self.topMaskView.bounds;
    
    // Start the gradient at the bottom and go almost half way up.
    [alphaGradientLayer setStartPoint:CGPointMake(0.0, 1.0)];
    [alphaGradientLayer setEndPoint:CGPointMake(0.0, 0.25)];
    
    // Apply the mask to the topMaskView.
    self.topMaskView.layer.mask = alphaGradientLayer;
    [self.view insertSubview:self.topMaskView aboveSubview:self.collectionView];
}

- (UIImage *)topBackgroundImage {
    UIGraphicsBeginImageContextWithOptions(self.blurredImageView.bounds.size, YES, 0.0);
    [self.blurredImageView resizableSnapshotViewFromRect:[self maskFrame] afterScreenUpdates:YES withCapInsets:UIEdgeInsetsZero];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (CGRect)maskFrame {
    return (CGRect){
        self.view.bounds.origin.x,
        self.view.bounds.origin.y,
        self.view.bounds.size.width,
        kSearchTopOffset + self.searchFieldView.frame.size.height
    };
}

@end
