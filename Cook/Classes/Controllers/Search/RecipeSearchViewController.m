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
#import "BookRecipeGridExtraSmallCell.h"
#import "BookRecipeGridSmallCell.h"
#import "BookRecipeGridMediumCell.h"
#import "BookRecipeGridLargeCell.h"
#import "CKRecipe.h"
#import "CKBook.h"
#import "MRCEnumerable.h"

@interface RecipeSearchViewController () <UICollectionViewDataSource, UICollectionViewDelegate,
    RecipeGridLayoutDelegate, CKRecipeSearchFieldViewDelegate>

@property (nonatomic, weak) id<RecipeSearchViewControllerDelegate> delegate;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) CKRecipeSearchFieldView *searchFieldView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) BOOL resultsMode;
@property (nonatomic, strong) NSMutableArray *recipes;
@property (nonatomic, assign) NSUInteger count;

@end

@implementation RecipeSearchViewController

#define kContentInsets          (UIEdgeInsets){ 30.0, 15.0, 50.0, 15.0 }
#define kSearchTopOffset        41.0
#define kSearchMidOffset        220.0
#define kHelpFont               [UIFont fontWithName:@"BrandonGrotesque-Regular" size:20]

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
    
    self.view.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.closeButton];
    
    self.searchFieldView.frame = [self frameForSearchFieldViewResultsMode:NO];
    [self.view addSubview:self.searchFieldView];
    
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
    return kSearchTopOffset + self.searchFieldView.frame.size.height + 20.0;
}

- (BOOL)recipeGridLayoutHeaderEnabled {
    return NO;
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
        
        [CKRecipe searchWithTerm:text
                         success:^(NSArray *recipes, NSUInteger count) {
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

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [ViewHelper closeButtonLight:YES target:self selector:@selector(closeTapped:)];
        _closeButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
        _closeButton.frame = (CGRect){
            kContentInsets.left,
            kContentInsets.top,
            _closeButton.frame.size.width,
            _closeButton.frame.size.height
        };
    }
    return _closeButton;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds
                                             collectionViewLayout:[[RecipeGridLayout alloc] initWithDelegate:self]];
        _collectionView.bounces = YES;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsVerticalScrollIndicator = YES;
        _collectionView.alwaysBounceVertical = YES;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self.collectionView registerClass:[BookRecipeGridLargeCell class]
                forCellWithReuseIdentifier:[RecipeGridLayout cellIdentifierForGridType:RecipeGridTypeLarge]];
        [self.collectionView registerClass:[BookRecipeGridMediumCell class]
                forCellWithReuseIdentifier:[RecipeGridLayout cellIdentifierForGridType:RecipeGridTypeMedium]];
        [self.collectionView registerClass:[BookRecipeGridSmallCell class]
                forCellWithReuseIdentifier:[RecipeGridLayout cellIdentifierForGridType:RecipeGridTypeSmall]];
        [self.collectionView registerClass:[BookRecipeGridExtraSmallCell class]
                forCellWithReuseIdentifier:[RecipeGridLayout cellIdentifierForGridType:RecipeGridTypeExtraSmall]];
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

#pragma mark - Private methods

- (void)closeTapped:(id)sender {
    [self.delegate recipeSearchViewControllerDismissRequested];
}

- (void)showRecipeAtIndexPath:(NSIndexPath *)indexPath {
    DLog();
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
        resultsMode ? kSearchTopOffset : kSearchMidOffset
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
        }];
        
    }
    
}

@end
