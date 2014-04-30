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
#import "CKActivityIndicatorView.h"
#import "CKRecipeSearch.h"
#import "NSString+Utilities.h"

@interface RecipeSearchViewController () <UICollectionViewDataSource, UICollectionViewDelegate,
    RecipeGridLayoutDelegate, CKRecipeSearchFieldViewDelegate>

@property (nonatomic, weak) id<RecipeSearchViewControllerDelegate> delegate;
@property (nonatomic, assign) NSUInteger batchIndex;
@property (nonatomic, assign) NSUInteger numBatches;
@property (nonatomic, strong) UIImageView *blurredImageView;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIView *blurredContainerView;
@property (nonatomic, strong) UIImageView *blurredContainerImageView;
@property (nonatomic, strong) UIView *dividerView;
@property (nonatomic, strong) UIView *topMaskView;
@property (nonatomic, strong) UIView *modalOverlayView;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *filterButton;
@property (nonatomic, strong) UIButton *errorMessageButton;
@property (nonatomic, strong) CKActivityIndicatorView *activityView;
@property (nonatomic, strong) CKRecipeSearchFieldView *searchFieldView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) BOOL resultsMode;
@property (nonatomic, assign) NSUInteger numRetries;
@property (nonatomic, strong) NSMutableArray *recipes;
@property (nonatomic, assign) NSUInteger count;
@property (nonatomic, strong) NSString *keyword;
@property (nonatomic, assign) CKRecipeSearchFilter searchFilter;
@property (nonatomic, strong) NSMutableDictionary *filterResults;
@property (nonatomic, strong) UIImage *arrowImage;
@property (nonatomic, strong) UIImage *blurredContainerImage;
@property (nonatomic, assign) BOOL modalBlurEnabled;

@end

@implementation RecipeSearchViewController

#define kContentInsets              (UIEdgeInsets){ 30.0, 15.0, 50.0, 15.0 }
#define BUTTON_INSETS               (UIEdgeInsets){ 30.0, 15.0, 50.0, 0.0 }
#define BUTTON_CONTENT_INSETS       (UIEdgeInsets){ 10.0, 15.0, 10.0, 5.0 }
#define BUTTON_ARROW_GAP            -2.0
#define BUTTON_TITLE_OFFSET         -15.0
#define kHeaderHeight               110.0
#define kTopMaskOffset              112.0
#define kSearchTopOffset            41.0
#define kSearchMidOffset            220.0
#define kSearchCollectionViewGap    20.0
#define MAX_NUM_RETRIES             1
#define kHelpFont                   [UIFont fontWithName:@"BrandonGrotesque-Regular" size:20]
#define FILTER_FONT                 [UIFont fontWithName:@"BrandonGrotesque-Regular" size:20]
#define kHeaderCellId               @"DividerHeaderId"
#define LOAD_MORE_CELL_ID           @"LoadMoreCellId"
#define MODAL_SCALE_TRANSFORM       0.9
#define MODAL_OVERLAY_ALPHA         0.5

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (id)initWithDelegate:(id<RecipeSearchViewControllerDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
        
        // Default search filter.
        self.searchFilter = CKRecipeSearchFilterPopularity;
        self.filterResults = [NSMutableDictionary dictionary];
        
        // Modal blur?
        self.modalBlurEnabled = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.blurredImageView];
    [self.view addSubview:self.containerView];
    
    self.searchFieldView.frame = [self frameForSearchFieldViewResultsMode:NO];
    [self.containerView addSubview:self.collectionView];
    [self.containerView addSubview:self.searchFieldView];
    [self.containerView addSubview:self.closeButton];
    [self.containerView addSubview:self.filterButton];
    
    UIScreenEdgePanGestureRecognizer *screenEdgeRecogniser = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self
                                                                                                               action:@selector(screenEdgeSwiped:)];
    screenEdgeRecogniser.edges = UIRectEdgeLeft;
    [self.view addGestureRecognizer:screenEdgeRecogniser];
    
    // Register for keyboard events.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [AnalyticsHelper trackEventName:kEventSearchView];
}

- (void)focusSearchField:(BOOL)focus {
    
    // Focus the search field to kick off the keyboard event that triggers everything else.
    [self.searchFieldView focus:focus];
}

#pragma mark - AppModalViewController methods

- (void)setModalViewControllerDelegate:(id<AppModalViewControllerDelegate>)modalViewControllerDelegate {
    DLog();
}

- (void)appModalViewControllerWillAppear:(NSNumber *)appearNumber {
    DLog();
    
    BOOL appear = [appearNumber boolValue];
    if (appear) {
        
        if (self.modalBlurEnabled) {
            
            self.blurredContainerImageView = [[UIImageView alloc] initWithFrame:self.blurredContainerView.frame];
            self.blurredContainerImageView.image = self.blurredContainerImage;
            self.blurredContainerImageView.frame = (CGRect) {
                floorf((self.view.bounds.size.width - self.blurredContainerImageView.frame.size.width) / 2.0),
                floorf((self.view.bounds.size.height - self.blurredContainerImageView.frame.size.height) / 2.0),
                self.blurredContainerImageView.frame.size.width,
                self.blurredContainerImageView.frame.size.height
            };
            self.blurredContainerImageView.alpha = 0.0;
            [self.view addSubview:self.blurredContainerImageView];
            
        } else {
            
            // Create overlay.
            self.modalOverlayView = [[UIView alloc] initWithFrame:self.view.bounds];
            self.modalOverlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
            self.modalOverlayView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:MODAL_OVERLAY_ALPHA];
            self.modalOverlayView.alpha = 0.0;
            [self.view addSubview:self.modalOverlayView];

        }
    }
}

- (void)appModalViewControllerAppearing:(NSNumber *)appearingNumber {
    DLog();
    
    BOOL appearing = [appearingNumber boolValue];
    
    // Scale appropriate views.
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(MODAL_SCALE_TRANSFORM, MODAL_SCALE_TRANSFORM);
    self.containerView.transform = appearing ? scaleTransform : CGAffineTransformIdentity;
    
    // Fade container in/out.
    self.containerView.alpha = appearing ? 0.5 : 1.0;
    
    if (self.modalBlurEnabled) {
        
        // Fade blurred container view in/out.
        self.blurredContainerImageView.alpha = appearing ? 1.0 : 0.0;
        self.blurredContainerImageView.transform = appearing ? scaleTransform : CGAffineTransformIdentity;
        
    } else {
        
        // Fade overlay in/out.
        self.modalOverlayView.alpha = appearing ? 1.0 : 0.0;
        
    }
    
}

- (void)appModalViewControllerDidAppear:(NSNumber *)appearNumber {
    DLog();
    
    BOOL appeared = [appearNumber boolValue];
    if (!appeared) {
        
        if (self.modalBlurEnabled) {
            
            // Remove blurred container view.
            self.blurredContainerImage = nil;
            self.blurredContainerImageView.image = nil;
            [self.blurredContainerImageView removeFromSuperview];
            self.blurredContainerImageView = nil;
            
        } else {
            
            [self.modalOverlayView removeFromSuperview];
            self.modalOverlayView = nil;
        }
        
    }
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
    
    // Load more if there are more batches to load.
    if (numItems > 0 && [self recipeGridLayoutLoadMoreEnabled]) {
        numItems += 1;      // Spinner if there are more
    }
    
    return numItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = nil;
    
    if (indexPath.item < [self.recipes count]) {
        
        // Recipe cell.
        CKRecipe *recipe = [self.recipes objectAtIndex:indexPath.item];
        RecipeGridType gridType = [RecipeGridLayout gridTypeForRecipe:recipe];
        NSString *cellId = [RecipeGridLayout cellIdentifierForGridType:gridType];
        
        BookRecipeGridCell *recipeCell = (BookRecipeGridCell *)[self.collectionView dequeueReusableCellWithReuseIdentifier:cellId
                                                                                                              forIndexPath:indexPath];
        [recipeCell configureRecipe:recipe book:recipe.book own:NO];
        cell = recipeCell;
        
    } else {
        
        // Spinner.
        CKContentContainerCell *activityCell = (CKContentContainerCell *)[self.collectionView dequeueReusableCellWithReuseIdentifier:LOAD_MORE_CELL_ID
                                                                                                                        forIndexPath:indexPath];
        [self.activityView removeFromSuperview];
        [activityCell configureContentView:self.activityView];
        if (![self.activityView isAnimating]) {
            [self.activityView startAnimating];
        }
        
        cell = activityCell;
        
        // Load more?
        if ([self recipeGridLayoutLoadMoreEnabled]) {
            self.filterButton.enabled = NO;
            self.filterButton.alpha = 0.5;
            [self searchWithBatchIndex:self.batchIndex + 1];
        }
    }
    
    return cell;
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
    return self.activityView.frame.size;
}

- (CGFloat)recipeGridCellsOffset {
    return 20.0;
}

- (BOOL)recipeGridLayoutHeaderEnabled {
    return YES;
}

- (BOOL)recipeGridLayoutLoadMoreEnabled {
    return (self.batchIndex < self.numBatches - 1);
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
    
    // If we're in results mode, then clear it and go to normal state.
    if (self.resultsMode) {
        [self enableResultsMode:NO];
        [self clearResults];
    }
    
    return YES;
}

- (BOOL)recipeSearchFieldShouldResign {
    
    // If we're not in results mode, and have cached results, then show it again.
    if (!self.resultsMode) {
        
        // Check if there are cached results to show.
        CKRecipeSearch *searchResults = [self currentFilterResults];
        if (searchResults && [searchResults.results count] > 0) {
            
            __weak typeof(self) weakSelf = self;
            
            [self enableResultsMode:YES completion:^{
                weakSelf.recipes = [NSMutableArray arrayWithArray:searchResults.results];
                weakSelf.count = searchResults.count;
                weakSelf.batchIndex = searchResults.batchIndex;
                weakSelf.numBatches = searchResults.numBatches;
                [weakSelf displayResults];
                
            }];
        }
    }
    
    return YES;
}

- (NSString *)recipeSearchFieldViewPlaceholderText {
    return @"RECIPE, INGREDIENT OR TAG";
}

- (void)recipeSearchFieldViewSearchByText:(NSString *)text {
    
    // Remember keyword.
    self.keyword = text;
    
    // Clear all cached results.
    [self.filterResults removeAllObjects];
    
    [self enableResultsMode:YES completion:^{
        [self performSearch];
    }];
}

- (void)recipeSearchFieldViewClearRequested {
    [self enableResultsMode:NO];
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

- (UIButton *)filterButton {
    if (!_filterButton) {
        
        UIImage *arrowSelectedImage = [[UIImage imageNamed:@"cook_dash_search_downarrow_onpress.png"] resizableImageWithCapInsets:(UIEdgeInsets){ 0.0, 1.0, 0.0, 17.0 }];
        
        _filterButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_filterButton setTitle:[self displayForSearchFilter:self.searchFilter] forState:UIControlStateNormal];
        [_filterButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_filterButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:[self alphaForFilterButtonEnabled:NO]] forState:UIControlStateHighlighted];
        [_filterButton addTarget:self action:@selector(filterTapped:) forControlEvents:UIControlEventTouchUpInside];
        [_filterButton setImage:self.arrowImage forState:UIControlStateNormal];
        [_filterButton setImage:arrowSelectedImage forState:UIControlStateHighlighted];
        _filterButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        _filterButton.titleLabel.lineBreakMode = NSLineBreakByClipping;
        _filterButton.titleLabel.font = FILTER_FONT;
        _filterButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin;
        [_filterButton sizeToFit];
        _filterButton.frame = (CGRect){
            self.view.bounds.size.width - kContentInsets.right - _filterButton.frame.size.width - BUTTON_INSETS.right - BUTTON_CONTENT_INSETS.left - BUTTON_CONTENT_INSETS.right - BUTTON_ARROW_GAP,
            self.searchFieldView.frame.origin.y + floorf((self.searchFieldView.frame.size.height - _filterButton.frame.size.height - BUTTON_CONTENT_INSETS.top - BUTTON_CONTENT_INSETS.bottom) / 2.0),
            _filterButton.frame.size.width + BUTTON_CONTENT_INSETS.left + BUTTON_CONTENT_INSETS.right + BUTTON_ARROW_GAP,
            _filterButton.frame.size.height + BUTTON_CONTENT_INSETS.top + BUTTON_CONTENT_INSETS.bottom,
        };
        
        _filterButton.imageEdgeInsets = (UIEdgeInsets){ 0.0, _filterButton.frame.size.width - self.arrowImage.size.width - BUTTON_CONTENT_INSETS.right, 0.0, 0.0 };
        _filterButton.titleEdgeInsets = (UIEdgeInsets){ 0.0, BUTTON_TITLE_OFFSET, 0.0, self.arrowImage.size.width + BUTTON_CONTENT_INSETS.right + BUTTON_ARROW_GAP };
        _filterButton.hidden = YES;
    }
    return _filterButton;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [ViewHelper closeButtonLight:YES target:self selector:@selector(closeTapped:)];
        _closeButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
        _closeButton.frame = (CGRect){
            kContentInsets.left,
            floorf((kHeaderHeight - _closeButton.frame.size.height) / 2.0) + 7.0,
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
        [self.collectionView registerClass:[CKContentContainerCell class] forCellWithReuseIdentifier:LOAD_MORE_CELL_ID];
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

- (UIView *)blurredContainerView {
    if (!_blurredContainerView) {
        
        CGSize intendedSize = (CGSize){
            self.view.bounds.size.width / MODAL_SCALE_TRANSFORM,
            self.view.bounds.size.height / MODAL_SCALE_TRANSFORM
        };
        _blurredContainerView = [[UIImageView alloc] initWithFrame:(CGRect){
            floorf((self.view.bounds.size.width - intendedSize.width) / 2.0),
            floorf((self.view.bounds.size.height - intendedSize.height) / 2.0),
            intendedSize.width,
            intendedSize.height
        }];
        _blurredContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    }
    return _blurredContainerView;
}

- (CKActivityIndicatorView *)activityView {
    if (!_activityView) {
        _activityView = [[CKActivityIndicatorView alloc] initWithStyle:CKActivityIndicatorViewStyleSmall];
        _activityView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    }
    return _activityView;
}

- (UIImage *)arrowImage {
    if (!_arrowImage) {
        _arrowImage = [[UIImage imageNamed:@"cook_dash_search_downarrow.png"] resizableImageWithCapInsets:(UIEdgeInsets){ 0.0, 1.0, 0.0, 17.0 }];
    }
    return _arrowImage;
}

- (UIButton *)errorMessageButton {
    if (!_errorMessageButton) {
        _errorMessageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _errorMessageButton.titleLabel.font = [UIFont fontWithName:@"BrandonGrotesque-Regular" size:18.0];
        _errorMessageButton.titleLabel.numberOfLines = 0;
        _errorMessageButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _errorMessageButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_errorMessageButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_errorMessageButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
        [_errorMessageButton setTitle:[NSString stringWithFormat:@"COULDN'T CONNECT%@PLEASE TRY AGAIN", [NSString CK_lineBreakString]] forState:UIControlStateNormal];
        _errorMessageButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        [_errorMessageButton sizeToFit];
        _errorMessageButton.frame = (CGRect){
            floorf((self.view.bounds.size.width - _errorMessageButton.frame.size.width) / 2.0),
            floorf((self.view.bounds.size.height - _errorMessageButton.frame.size.height) / 2.0),
            _errorMessageButton.frame.size.width,
            _errorMessageButton.frame.size.height
        };
        [_errorMessageButton addTarget:self action:@selector(retryTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _errorMessageButton;
}

#pragma mark - Private methods

- (void)closeTapped:(id)sender {
    [self.delegate recipeSearchViewControllerDismissRequested];
}

- (void)retryTapped:(id)sender {
    [self focusSearchField:YES];
}

- (CGFloat)alphaForFilterButtonEnabled:(BOOL)enabled {
    return enabled ? 1.0 : 0.5;
}

- (void)filterTapped:(id)sender {
    self.searchFilter = [self nextSearchFilter];

    // Update filter button.
    self.filterButton.enabled = NO;
//    self.filterButton.alpha = [self alphaForFilterButtonEnabled:NO];
    [self updateFilterButton];
    
    // Check results
    CKRecipeSearch *searchResults = [self currentFilterResults];
    if (searchResults) {
        
        // Mark as searching.
        [self.searchFieldView setSearching:YES];
        
        __weak typeof(self) weakSelf = self;
        [self clearResultsCompletion:^{
            
            weakSelf.recipes = [NSMutableArray arrayWithArray:searchResults.results];
            weakSelf.count = searchResults.count;
            weakSelf.batchIndex = searchResults.batchIndex;
            weakSelf.numBatches = searchResults.numBatches;
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.4 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [weakSelf displayResults];
            });

        }];
        
    } else {
        
        // Mark as searching.
        [self.searchFieldView setSearching:YES];
        
        [self clearResultsCompletion:^{
            [self searchWithBatchIndex:0];
        }];
    }
    
}

- (CKRecipeSearchFilter)nextSearchFilter {
    switch (self.searchFilter) {
        case CKRecipeSearchFilterPopularity:
            return CKRecipeSearchFilterCreationDate;
            break;
        case CKRecipeSearchFilterCreationDate:
            return CKRecipeSearchFilterPopularity;
            break;
        default:
            return CKRecipeSearchFilterPopularity;
            break;
    }
}

- (void)showRecipeAtIndexPath:(NSIndexPath *)indexPath {
    
    // Pre-render the blurred snapshot.
    if (self.modalBlurEnabled) {
        
        // Add the blurred container view to host containerView so we can capture bigger screenshot.
        self.blurredContainerView.frame = (CGRect){
            floorf((self.view.bounds.size.width - self.blurredContainerView.frame.size.width) / 2.0),
            floorf((self.view.bounds.size.height - self.blurredContainerView.frame.size.height) / 2.0),
            self.blurredContainerView.frame.size.width,
            self.blurredContainerView.frame.size.height
        };
        [self.view addSubview:self.blurredContainerView];
        
        // Move container view to blurredContainer view to capture
        [self.containerView removeFromSuperview];
        self.containerView.frame = (CGRect){
            floorf((self.blurredContainerView.bounds.size.width - self.containerView.frame.size.width) / 2.0),
            floorf((self.blurredContainerView.bounds.size.height - self.containerView.frame.size.height) / 2.0),
            self.containerView.frame.size.width,
            self.containerView.frame.size.height
        };
        [self.blurredContainerView addSubview:self.containerView];
        
        // Capture this blurredContainerView as a bigger screenshot.
        self.blurredContainerImage = [ImageHelper blurredImageFromView:self.blurredContainerView];
        
        // Move the containerView back.
        [self.containerView removeFromSuperview];
        self.containerView.frame = self.view.bounds;
        [self.view insertSubview:self.containerView aboveSubview:self.blurredImageView];
        [self.blurredContainerView removeFromSuperview];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        CKRecipe *recipe = [self.recipes objectAtIndex:indexPath.item];
        [[[AppHelper sharedInstance] rootViewController] showModalWithRecipe:recipe callerViewController:self];
    });
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
    
    // Stop searching if resultsMode is off. Could be cancelled while still performing the previous search.
    if (!resultsMode) {
        [self.searchFieldView setSearching:NO];
    }
    
    // Mark results mode appropriately.
    self.resultsMode = resultsMode;
    
    if (!resultsMode) {
        self.filterButton.hidden = YES;
    }
    
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationCurveEaseInOut
                     animations:^{
                         [self.searchFieldView expand:!resultsMode animated:NO];
                         self.searchFieldView.frame = frame;
                         self.errorMessageButton.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         
                         [self.errorMessageButton removeFromSuperview];
                         
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
    
    // Clear results display.
    [self.searchFieldView showMessage:nil];
    
    // Clear data.
    self.batchIndex = 0;
    self.numBatches = 0;
    [self.recipes removeAllObjects];
    
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationCurveEaseIn
                     animations:^{
                         
                         // Fade out the collection view.
                         self.collectionView.alpha = 0.0;
                         
                     }
                     completion:^(BOOL finished) {
                         
                         [((RecipeGridLayout *)self.collectionView.collectionViewLayout) setNeedsRelayout:YES];
                         [self.collectionView reloadData];
                         [self.collectionView setContentOffset:CGPointZero animated:NO];

                         [UIView animateWithDuration:0.25
                                               delay:0.0
                                             options:UIViewAnimationCurveEaseIn
                                          animations:^{
                                              self.collectionView.alpha = 1.0;
                                          }
                                          completion:^(BOOL finished) {
                                              
                                              if (completion != nil) {
                                                  completion();
                                              }
                                              
                                          }];
                     }];
    
}

- (void)performSearch {
    [self searchWithBatchIndex:0];
}

- (void)searchWithBatchIndex:(NSUInteger)batchIndex {
    
    if (batchIndex == 0) {
        [self.searchFieldView setSearching:YES];
    }
    
    [CKRecipe searchWithTerm:self.keyword
                      filter:self.searchFilter
                  batchIndex:batchIndex
                     success:^(NSString *keyword, NSArray *recipes, NSUInteger count, NSUInteger searchBatchIndex,
                               NSUInteger numBatches) {
                         
                         // Ignore if keyword doesn't match this request.
                         // Ignore if not in results mode.
                         if (![self.keyword isEqualToString:keyword] || !self.resultsMode) {
                             return;
                         }
                         
                         // Slice index to insert recipes.
                         NSUInteger nextSliceIndex = 0;
                         
                         if (batchIndex == 0) {
                             [AnalyticsHelper trackEventName:kEventSearchSubmit params:@{ kEventParamsSearchFilter : [self currentDisplayForSearchFilter] }];
                             [self.searchFieldView setSearching:NO];
                             [self.searchFieldView showNumResults:count];
                             self.recipes = [NSMutableArray arrayWithArray:recipes];
                             
                         } else {
                             nextSliceIndex = [self.recipes count];
                             [self.recipes addObjectsFromArray:recipes];
                         }
                         
                         // If there are more than 1 result then display filter.
                         self.filterButton.hidden = (count < 2);
                         self.filterButton.enabled = YES;
                         self.filterButton.alpha = [self alphaForFilterButtonEnabled:YES];
                         [self updateFilterButton];
                         
                         // Save results in cache.
                         CKRecipeSearch *searchResults = [self currentFilterResults];
                         if (!searchResults) {
                             searchResults = [[CKRecipeSearch alloc] init];
                             [self.filterResults setObject:searchResults forKey:@(self.searchFilter)];
                         }
                         searchResults.batchIndex = searchBatchIndex;
                         searchResults.numBatches = numBatches;
                         searchResults.results = [NSArray arrayWithArray:self.recipes];
                         searchResults.count = count;
                         
                         // Update pagination stuff.
                         self.count = count;
                         self.batchIndex = searchBatchIndex;
                         self.numBatches = numBatches;
                         
                         // Delete spinner cell.
                         NSArray *indexPathsToDelete = nil;
                         if (nextSliceIndex > 0) {
                             NSIndexPath *spinnerIndexPath = [NSIndexPath indexPathForItem:nextSliceIndex inSection:0];
                             indexPathsToDelete = @[spinnerIndexPath];
                         }
                         
                         // Gather indexPaths to insert if any.
                         NSMutableArray *indexPathsToInsert = nil;
                         if ([recipes count] > 0) {

                             indexPathsToInsert = [NSMutableArray arrayWithArray:[recipes collectWithIndex:^(CKRecipe *recipe, NSUInteger recipeIndex) {
                                 return [NSIndexPath indexPathForItem:nextSliceIndex + recipeIndex inSection:0];
                             }]];
                             
                             // Reinsert spinner cell if there are more.
                             if ([self recipeGridLayoutLoadMoreEnabled]) {
                                 NSIndexPath *activityInsertIndexPath = [NSIndexPath indexPathForItem:[self.recipes count] inSection:0];
                                 [indexPathsToInsert addObject:activityInsertIndexPath];
                             }
                             
                         }
                         
                         // UI updates after invalidating layout.
                         [((RecipeGridLayout *)self.collectionView.collectionViewLayout) setNeedsRelayout:YES];
                         
                         // Need to update collection view with inserts or deletes.
                         if ([indexPathsToDelete count] > 0 || [indexPathsToInsert count] > 0) {
                             
                             [self.collectionView performBatchUpdates:^{
                                 if ([indexPathsToDelete count] > 0) {
                                     [self.collectionView deleteItemsAtIndexPaths:indexPathsToDelete];
                                 }
                                 if ([indexPathsToInsert count] > 0) {
                                     [self.collectionView insertItemsAtIndexPaths:indexPathsToInsert];
                                 }
                             } completion:^(BOOL finished) {
                                 
                             }];
                             
                         }
                         
                     }
                     failure:^(NSError *error) {
                         
                         // Attempt to reload data.
                         if (batchIndex == 0 && self.numRetries < MAX_NUM_RETRIES) {
                             self.numRetries += 1;
                             
                             __weak typeof(self) weakSelf = self;
                             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                                 [weakSelf performSearch];
                             });
                             
                         } else {
                             
                             // Add error message if not there.
                             if (batchIndex == 0 && !self.errorMessageButton.superview) {
                                 self.errorMessageButton.alpha = 1.0;
                                 [self.view addSubview:self.errorMessageButton];
                             }
                             
                             [self.searchFieldView setSearching:NO];
                         }
                         
                     }];
}

- (void)displayResults {
    
    // Gather indexPaths to insert.
    NSMutableArray *indexPathsToInsert = [NSMutableArray arrayWithArray:[self.recipes collectWithIndex:^(CKRecipe *recipe, NSUInteger recipeIndex) {
        return [NSIndexPath indexPathForItem:recipeIndex inSection:0];
    }]];
    
    // Reinsert spinner cell if there are more.
    if ([self recipeGridLayoutLoadMoreEnabled]) {
        NSIndexPath *activityInsertIndexPath = [NSIndexPath indexPathForItem:[self.recipes count] inSection:0];
        [indexPathsToInsert addObject:activityInsertIndexPath];
    }
    
    [self.searchFieldView setSearching:NO];
    [self.searchFieldView showNumResults:self.count];
    
    // If there are more than 1 result then display filter.
    self.filterButton.hidden = (self.count < 2);
    self.filterButton.enabled = YES;
    self.filterButton.alpha = [self alphaForFilterButtonEnabled:YES];
    
    // UI updates after invalidating layout.
    if ([indexPathsToInsert count] > 0) {

        [((RecipeGridLayout *)self.collectionView.collectionViewLayout) setNeedsRelayout:YES];
        [self.collectionView performBatchUpdates:^{
            [self.collectionView insertItemsAtIndexPaths:indexPathsToInsert];
        } completion:^(BOOL finished) {
        }];
    }
    
}

- (void)updateFilterButton {
    NSString *filterDisplay = [self displayForSearchFilter:self.searchFilter];
    [self.filterButton setTitle:filterDisplay forState:UIControlStateNormal];
    [self.filterButton sizeToFit];
    self.filterButton.frame = (CGRect){
        self.view.bounds.size.width - kContentInsets.right - self.filterButton.frame.size.width - BUTTON_INSETS.right - BUTTON_CONTENT_INSETS.left - BUTTON_CONTENT_INSETS.right - BUTTON_ARROW_GAP,
        self.searchFieldView.frame.origin.y + floorf((self.searchFieldView.frame.size.height - self.filterButton.frame.size.height - BUTTON_CONTENT_INSETS.top - BUTTON_CONTENT_INSETS.bottom) / 2.0),
        self.filterButton.frame.size.width + BUTTON_CONTENT_INSETS.left + BUTTON_CONTENT_INSETS.right + BUTTON_ARROW_GAP,
        self.filterButton.frame.size.height + BUTTON_CONTENT_INSETS.top + BUTTON_CONTENT_INSETS.bottom,
    };
    self.filterButton.imageEdgeInsets = (UIEdgeInsets){ 0.0, self.filterButton.frame.size.width - self.arrowImage.size.width - BUTTON_CONTENT_INSETS.right, 0.0, 0.0 };
    self.filterButton.titleEdgeInsets = (UIEdgeInsets){ 0.0, BUTTON_TITLE_OFFSET, 0.0, self.arrowImage.size.width + BUTTON_CONTENT_INSETS.right + BUTTON_ARROW_GAP };
}

- (void)updateCloseButton {
    self.filterButton.frame = (CGRect){
        self.view.bounds.size.width - kContentInsets.right - self.filterButton.frame.size.width - BUTTON_INSETS.right - BUTTON_CONTENT_INSETS.left - BUTTON_CONTENT_INSETS.right - BUTTON_ARROW_GAP,
        self.searchFieldView.frame.origin.y + floorf((self.searchFieldView.frame.size.height - self.filterButton.frame.size.height - BUTTON_CONTENT_INSETS.top - BUTTON_CONTENT_INSETS.bottom) / 2.0),
        self.filterButton.frame.size.width + BUTTON_CONTENT_INSETS.left + BUTTON_CONTENT_INSETS.right + BUTTON_ARROW_GAP,
        self.filterButton.frame.size.height + BUTTON_CONTENT_INSETS.top + BUTTON_CONTENT_INSETS.bottom,
    };
}

- (NSString *)currentDisplayForSearchFilter {
    return [self displayForSearchFilter:self.searchFilter];
}

- (NSString *)displayForSearchFilter:(CKRecipeSearchFilter)filter {
    switch (filter) {
        case CKRecipeSearchFilterPopularity:
            return @"POPULAR";
            break;
        case CKRecipeSearchFilterCreationDate:
            return @"LATEST";
            break;
        default:
            return @"POPULAR";
            break;
    }
}

- (CKRecipeSearch *)currentFilterResults {
    return [self.filterResults objectForKey:@(self.searchFilter)];
}

- (void)screenEdgeSwiped:(UIScreenEdgePanGestureRecognizer *)screenEdgeRecogniser {
    if (screenEdgeRecogniser.state == UIGestureRecognizerStateBegan) {
        [self.delegate recipeSearchViewControllerDismissRequested];
    }
}

@end
