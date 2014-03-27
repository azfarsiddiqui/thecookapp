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
#import "CKSearchFieldView.h"
#import "RecipeGridLayout.h"
#import "BookRecipeGridExtraSmallCell.h"
#import "BookRecipeGridSmallCell.h"
#import "BookRecipeGridMediumCell.h"
#import "BookRecipeGridLargeCell.h"
#import "CKRecipe.h"
#import "CKBook.h"
#import "MRCEnumerable.h"

@interface RecipeSearchViewController () <UICollectionViewDataSource, UICollectionViewDelegate,
    RecipeGridLayoutDelegate, CKSearchFieldViewDelegate>

@property (nonatomic, weak) id<RecipeSearchViewControllerDelegate> delegate;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) CKSearchFieldView *searchFieldView;
@property (nonatomic, strong) UILabel *helpLabel;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) BOOL resultsMode;
@property (nonatomic, strong) NSMutableArray *recipes;
@property (nonatomic, assign) NSUInteger count;

@end

@implementation RecipeSearchViewController

#define kContentInsets          (UIEdgeInsets){ 30.0, 15.0, 50.0, 15.0 }
#define kSearchTopOffset        41.0
#define kSearchMidOffset        220.0
#define kHelpTopOffset          100.0
#define kHelpMidOffset          300.0
#define kSearchHelpGap          40.0
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
    
    self.helpLabel.frame = [self frameForHelpLabelResultsMode:NO];
    [self.view addSubview:self.helpLabel];
    
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

#pragma mark - CKSearchFieldViewDelegate methods

- (UIFont *)searchFieldTextFont {
    return [UIFont fontWithName:@"BrandonGrotesque-Regular" size:26];
}

- (BOOL)searchFieldShouldFocus {
    if (self.resultsMode) {
        [self clearResults];
    }
    return YES;
}

- (BOOL)searchFieldViewSearchIconTappable {
    return NO;
}

- (void)searchFieldViewSearchIconTapped {
    DLog();
}

- (void)searchFieldViewSearchByText:(NSString *)text {
    
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

- (void)searchFieldViewClearRequested {
    [self clearResults];
}

- (NSString *)searchFieldViewPlaceholderText {
    return @"SEARCH";
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

- (CKSearchFieldView *)searchFieldView {
    if (!_searchFieldView) {
        _searchFieldView = [[CKSearchFieldView alloc] initWithWidth:410.0 delegate:self];
        _searchFieldView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
    }
    return _searchFieldView;
}

- (UILabel *)helpLabel {
    if (!_helpLabel) {
        _helpLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _helpLabel.backgroundColor = [UIColor clearColor];
        _helpLabel.font = kHelpFont;
        _helpLabel.textColor = [UIColor whiteColor];
        _helpLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
        _helpLabel.text = @"TYPE UP A RECIPE NAME, TAG AND INGREDIENT";
        [_helpLabel sizeToFit];
    }
    return _helpLabel;
}

#pragma mark - Private methods

- (void)closeTapped:(id)sender {
    [self.delegate recipeSearchViewControllerDismissRequested];
}

- (void)showRecipeAtIndexPath:(NSIndexPath *)indexPath {
    DLog();
}

- (CGRect)frameForSearchFieldViewResultsMode:(BOOL)resultsMode {
    return (CGRect) {
        floorf((self.view.bounds.size.width - self.searchFieldView.frame.size.width) / 2.0),
        resultsMode ? kSearchTopOffset : kSearchMidOffset,
        self.searchFieldView.frame.size.width,
        self.searchFieldView.frame.size.height
    };
}

- (CGRect)frameForHelpLabelResultsMode:(BOOL)resultsMode {
    CGRect helpFrame = (CGRect) {
        floorf((self.view.bounds.size.width - self.helpLabel.frame.size.width) / 2.0),
        resultsMode ? kHelpTopOffset : kHelpMidOffset,
        self.helpLabel.frame.size.width,
        self.helpLabel.frame.size.height
    };
    DLog(@"HELP FRAME %@", NSStringFromCGRect(helpFrame));
    return helpFrame;
}

- (void)enableResultsMode:(BOOL)resultsMode {
    [self enableResultsMode:resultsMode completion:nil];
}

- (void)enableResultsMode:(BOOL)resultsMode completion:(void (^)())completion {
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationCurveEaseInOut
                     animations:^{
                         self.searchFieldView.frame = [self frameForSearchFieldViewResultsMode:resultsMode];
                         self.helpLabel.frame = [self frameForHelpLabelResultsMode:resultsMode];
                         self.helpLabel.alpha = resultsMode ? 0.0 : 1.0;
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
    self.helpLabel.frame = [self frameForHelpLabelResultsMode:show];
    
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
