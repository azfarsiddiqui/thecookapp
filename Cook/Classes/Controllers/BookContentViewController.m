//
//  BookCategoryViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 13/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookContentViewController.h"
#import "CKBook.h"
#import "CKRecipe.h"
#import "BookCategoryLayout.h"
#import "MRCEnumerable.h"
#import "BookContentTitleView.h"
#import "ViewHelper.h"
#import "BookContentGridLayout.h"
#import "BookRecipeGridLargeCell.h"
#import "BookRecipeGridMediumCell.h"
#import "BookRecipeGridSmallCell.h"
#import "BookRecipeGridExtraSmallCell.h"
#import "CKPhotoManager.h"
#import "CKEditingViewHelper.h"
#import "CKEditViewController.h"
#import "CKTextFieldEditViewController.h"
#import "ProgressOverlayViewController.h"
#import "ModalOverlayHelper.h"
#import "BookNavigationHelper.h"
#import "NSString+Utilities.h"
#import "CardViewHelper.h"
#import "EventHelper.h"
#import "BookNavigationView.h"
#import "CKActivityIndicatorView.h"
#import "CKContentContainerCell.h"

@interface BookContentViewController () <UICollectionViewDataSource, UICollectionViewDelegate,
    BookContentGridLayoutDelegate, CKEditingTextBoxViewDelegate, CKEditViewControllerDelegate, UIAlertViewDelegate,
    UIGestureRecognizerDelegate> {
        
    BOOL _isFastForward;
}

@property (nonatomic, weak) id<BookContentViewControllerDelegate> delegate;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) CKBook *book;
@property (nonatomic, strong) NSString *page;
@property (nonatomic, strong) NSArray *recipes;

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) BookContentTitleView *contentTitleView;
@property (nonatomic, strong) CKActivityIndicatorView *activityView;

@property (nonatomic, strong) CKRecipe *scrollToRecipe;

// Editing.
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) CKEditingViewHelper *editingHelper;
@property (nonatomic, strong) CKTextFieldEditViewController *editViewController;
@property (nonatomic, strong) ProgressOverlayViewController *progressOverlayViewController;
@property (nonatomic, strong) NSString *updatedPage;

@property (nonatomic, assign) BOOL ownBook;
@property (nonatomic, assign) BOOL fullscreenMode;

// To keep track of scroll direction.
@property (nonatomic, assign) CGPoint startContentOffset;
@property (nonatomic, assign) BOOL disableInformScrollOffset;

@end

@implementation BookContentViewController

#define kRecipeCellId       @"RecipeCell"
#define kContentHeaderId    @"ContentHeader"
#define kLoadMoreCellId     @"LoadMoreCell"

- (void)dealloc {
    self.imageView.image = nil;
    [EventHelper unregisterSocialUpdates:self];
}

- (id)initWithBook:(CKBook *)book page:(NSString *)page delegate:(id<BookContentViewControllerDelegate>)delegate {
    
    if (self = [super init]) {
        self.delegate = delegate;
        self.book = book;
        self.ownBook = [book isOwner];
        self.page = page;
        self.editingHelper = [[CKEditingViewHelper alloc] init];
        self.fullscreenMode = NO;
        self.scrollToRecipe = nil;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];

    [self initCollectionView];
    [self initOverlay];
    [self loadData];
    [EventHelper registerSocialUpdates:self selector:@selector(socialUpdates:)];
}

- (void)viewDidDisappear:(BOOL)animated {
    self.recipes = nil;
}

- (void)loadData {
    [((BookContentGridLayout *)self.collectionView.collectionViewLayout) setNeedsRelayout:YES];
    self.recipes = [NSArray arrayWithArray:[self.delegate recipesForBookContentViewControllerForPage:self.page]];
    [self.collectionView reloadData];
    [self showIntroCard];
}

- (void)loadPageContent {
    [self showIntroCard];
    self.isFastForward = NO;
    
    if ([self.collectionView numberOfItemsInSection:0] < [self.recipes count])
    {
        [((BookContentGridLayout *)self.collectionView.collectionViewLayout) setNeedsRelayout:YES];
        [self.collectionView reloadData];
    }
}

- (CGPoint)currentScrollOffset {
    CGRect visibleFrame = [ViewHelper visibleFrameForCollectionView:self.collectionView];
    return visibleFrame.origin;
}

- (void)setScrollOffset:(CGPoint)scrollOffset {
    
    // This is to disable informing delegate of scrolling to the required offset as this is resetting content. Purpose
    // is so that the navigation bar doesn't react to this scroll.
    self.disableInformScrollOffset = YES;
    [self.collectionView setContentOffset:scrollOffset animated:NO];
    self.disableInformScrollOffset = NO;
}

- (void)scrollToRecipe:(CKRecipe *)recipe {
    if ([recipe.page isEqualToString:self.page]) {
        self.scrollToRecipe = recipe;
    }
}

- (void)applyOverlayAlpha:(CGFloat)alpha {
    self.overlayView.alpha = alpha;
}

- (void)loadMoreRecipes:(NSArray *)recipes {
    
    // Delete spinner cell.
    NSIndexPath *activityDeleteIndexPath = [NSIndexPath indexPathForItem:[self.recipes count] inSection:0];
    
    // Gather the index paths to insert.
    NSInteger startIndex = [self.recipes count];
    NSMutableArray *indexPathsToInsert = [NSMutableArray arrayWithArray:[recipes collectWithIndex:^(CKRecipe *recipe, NSUInteger recipeIndex) {
        return [NSIndexPath indexPathForItem:(startIndex + recipeIndex) inSection:0];
    }]];
    
    // Model updates.
    self.recipes = [NSArray arrayWithArray:[self.delegate recipesForBookContentViewControllerForPage:self.page]];
    
    // Reinsert spinner cell if there are more.
    if ([self.delegate bookContentViewControllerLoadMoreEnabledForPage:self.page]) {
        NSIndexPath *activityInsertIndexPath = [NSIndexPath indexPathForItem:[self.recipes count] inSection:0];
        [indexPathsToInsert addObject:activityInsertIndexPath];
    }
    
    // UI updates after invalidating layout.
    [((BookContentGridLayout *)self.collectionView.collectionViewLayout) setNeedsRelayout:YES];
    [self.collectionView performBatchUpdates:^{
        [self.collectionView deleteItemsAtIndexPaths:@[activityDeleteIndexPath]];
        [self.collectionView insertItemsAtIndexPaths:indexPathsToInsert];
    } completion:^(BOOL finished) {
    }];
    
}

- (void)enableEditMode:(BOOL)editMode animated:(BOOL)animated completion:(void (^)())completion {
    
    self.editMode = editMode;
    self.collectionView.scrollEnabled = !editMode;
    
    // Disable any card.
    [self showIntroCard];
    
    if (editMode) {
        
        // Prep delete button to be faded in.
        self.deleteButton.alpha = 0.0;
        if (animated) {
            self.deleteButton.transform = CGAffineTransformMakeTranslation(0.0, self.deleteButton.frame.size.height);
        }
        if (!self.deleteButton.superview) {
            [self.view addSubview:self.deleteButton];
        }
        
        // Wrap up the headerView.
        UIEdgeInsets contentInsets = [CKEditingViewHelper contentInsetsForEditMode:YES];
        [self.editingHelper wrapEditingView:self.contentTitleView
                              contentInsets:(UIEdgeInsets) {
                                  contentInsets.top + 10.0,
                                  contentInsets.left + 10.0,
                                  contentInsets.bottom + 7.0,
                                  contentInsets.right + 10.0
                              } delegate:self white:YES editMode:YES onpress:NO animated:YES];
        
    } else {
        
        [self.editingHelper unwrapEditingView:self.contentTitleView animated:YES];
    }
    
    [self.collectionView setContentOffset:CGPointZero animated:YES];
    if (animated) {
        [UIView animateWithDuration:0.25
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             
                             // Enable edit mode on content title.
                             [self.contentTitleView enableEditMode:editMode animated:NO];
                             
                             // Slide up/down the delete button.
                             self.deleteButton.alpha = editMode ? 1.0 : 0.0;
                             self.deleteButton.transform = editMode ? CGAffineTransformIdentity : CGAffineTransformMakeTranslation(0.0, self.deleteButton.frame.size.height);
                             
                         }
                         completion:^(BOOL finished)  {
                             if (completion != nil) {
                                 completion();
                             }
                         }];
    } else {
        
        // Enable edit mode on content title.
        [self.contentTitleView enableEditMode:editMode animated:NO];
        
        // Slide up/down the delete button.
        self.deleteButton.alpha = editMode ? 1.0 : 0.0;
        
        if (completion != nil) {
            completion();
        }
    }
}

#pragma mark - BookPageViewController methods

- (void)showIntroCard:(BOOL)show {
    
    if (![self.book isOwner]) {
        return;
    }
    
    NSString *cardTag = @"AddRecipeCard";
    
    if (show) {
        CGSize cardSize = [CardViewHelper cardViewSize];
        [[CardViewHelper sharedInstance] showCardViewWithTag:cardTag
                                                        icon:[UIImage imageNamed:@"cook_intro_icon_category.png"]
                                                       title:@"ADD A RECIPE"
                                                    subtitle:@"OR PHOTOS, TIPS, NOTES, ANYTHING FOOD RELATED!"
                                                        view:self.view
                                                      anchor:CardViewAnchorTopRight
                                                      center:(CGPoint){
                                                          self.view.bounds.size.width - floorf(cardSize.width / 2.0) - 1.0,
                                                          floorf(cardSize.height / 2.0) + 70.0
                                                      }];
    } else {
        [[CardViewHelper sharedInstance] hideCardViewWithTag:cardTag];
    }
    
}

#pragma mark - BookContentGridLayoutDelegate methods

- (void)bookContentGridLayoutDidFinish {
    DLog();
    if (self.scrollToRecipe) {
        self.disableInformScrollOffset = YES;
        NSInteger scrollIndex = [self.recipes indexOfObject:self.scrollToRecipe];
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:scrollIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
        self.disableInformScrollOffset = NO;
        self.scrollToRecipe = nil;
    }
}

- (NSInteger)bookContentGridLayoutNumItems {
    return self.isFastForward ? 0 : [self.recipes count];
}

- (NSInteger)bookContentGridLayoutNumColumns {
    return 3;
}

- (BookContentGridType)bookContentGridTypeForItemAtIndex:(NSInteger)itemIndex {
    CKRecipe *recipe = [self.recipes objectAtIndex:itemIndex];
    return [self gridTypeForRecipe:recipe];
}

- (CGSize)bookContentGridLayoutHeaderSize {
    return (CGSize){
        self.collectionView.bounds.size.width,
        self.contentTitleView.frame.size.height
    };
}

- (CGSize)bookContentGridLayoutFooterSize {
    return self.activityView.frame.size;
}

- (BOOL)bookContentGridLayoutLoadMoreEnabled {
    return [self.delegate bookContentViewControllerLoadMoreEnabledForPage:self.page];
}

- (BOOL)bookContentGridLayoutFastForwardEnabled {
    return self.isFastForward;
}

#pragma mark - CKSaveableContent methods

- (BOOL)contentSaveRequired {
    return [self.updatedPage CK_containsText] && ![self.updatedPage CK_equalsIgnoreCase:self.page];
}

- (void)contentPerformSave:(BOOL)save {
    if (save) {
        if ([self contentSaveRequired]) {
            [self renamePage];
        } else {
            [self restorePage];
        }
    } else {
        [self restorePage];
    }
}

#pragma mark - CKEditingTextBoxViewDelegate methods

- (void)editingTextBoxViewTappedForEditingView:(UIView *)editingView {
    [self performPageNameEdit];
}

- (void)editingTextBoxViewSaveTappedForEditingView:(UIView *)editingView {
}

#pragma mark - CKEditViewControllerDelegate methods

- (void)editViewControllerWillAppear:(BOOL)appear {
    [self.bookPageDelegate bookPageViewController:self editing:appear];
}

- (void)editViewControllerDidAppear:(BOOL)appear {
}

- (void)editViewControllerDismissRequested {
    [self.editViewController performEditing:NO];
}

- (void)editViewControllerUpdateEditView:(UIView *)editingView value:(id)value {
    if ([value length] > 0) {
        [self updateContentTitleViewWithTitle:value];
        self.updatedPage = value;
        [self.editingHelper updateEditingView:self.contentTitleView];
    }
}

- (id)editViewControllerInitialValueForEditView:(UIView *)editingView {
    if (self.updatedPage) {
        return [self.updatedPage uppercaseString];
    } else {
        return [self.page uppercaseString];
    }
}

- (BOOL)editViewControllerCanSaveFor:(CKEditViewController *)editViewController {
    BOOL canSave = YES;
    
    NSString *text = [editViewController updatedValue];
    NSArray *pages = [self.bookPageDelegate bookPageViewControllerAllPages];

    if ([pages detect:^BOOL(NSString *page) {
        return ([page CK_equalsIgnoreCase:text]);
    }] && ![text CK_equalsIgnoreCase:self.page]) {
        canSave = NO;
        [editViewController updateTitle:@"PAGE ALREADY EXISTS" toast:YES];
    }
        
    return canSave;
}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    // Track the current begin scroll position.
    self.startContentOffset = scrollView.contentOffset;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self applyScrollingEffectsOnCategoryView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
}

#pragma mark - UICollectionViewDelegate methods

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return !self.editMode;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.editMode) {
        [self showRecipeAtIndexPath:indexPath];
    }
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    NSInteger numItems = 0;
    
    if (!self.isFastForward) {//Don't load recipes if fast forward
        
        numItems = [self.recipes count];
        
        // Spinner only if there are more than one recipes.
        if ([self.delegate bookContentViewControllerLoadMoreEnabledForPage:self.page] && numItems > 0) {
            numItems += 1;
        }
    }
    
    return numItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = nil;
    if (indexPath.item < [self.recipes count]) {
        
        CKRecipe *recipe = [self.recipes objectAtIndex:indexPath.item];
        BookContentGridType gridType = [self gridTypeForRecipe:recipe];
        NSString *cellId = [self cellIdentifierForGridType:gridType];
        
        BookRecipeGridCell *recipeCell = (BookRecipeGridCell *)[self.collectionView dequeueReusableCellWithReuseIdentifier:cellId
                                                                                                              forIndexPath:indexPath];
        [recipeCell configureRecipe:recipe book:self.book own:self.ownBook];
        
        // Load more?
        if (indexPath.item == ([self.recipes count] - 1)) {
            [self.delegate bookContentViewControllerLoadMoreForPage:self.page];
        }
        
        cell = recipeCell;
        
    } else if ([self.delegate bookContentViewControllerLoadMoreEnabledForPage:self.page] && indexPath.item == [self.recipes count]) {
        
        // Spinner.
        CKContentContainerCell *activityCell = (CKContentContainerCell *)[self.collectionView dequeueReusableCellWithReuseIdentifier:kLoadMoreCellId
                                                                                                                        forIndexPath:indexPath];
        [self.activityView removeFromSuperview];
        [activityCell configureContentView:self.activityView];
        if (![self.activityView isAnimating]) {
            [self.activityView startAnimating];
        }
        
        cell = activityCell;
    }
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionReusableView *reusableView = nil;
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        
        reusableView = [self.collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                               withReuseIdentifier:kContentHeaderId forIndexPath:indexPath];
        if (!self.contentTitleView.superview) {
            self.contentTitleView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
            self.contentTitleView.frame = (CGRect){
                floorf((reusableView.bounds.size.width - self.contentTitleView.frame.size.width) / 2.0),
                floorf((reusableView.bounds.size.height - self.contentTitleView.frame.size.height) / 2.0),
                self.contentTitleView.frame.size.width,
                self.contentTitleView.frame.size.height
            };
            [reusableView addSubview:self.contentTitleView];
        }
    }
    
    return reusableView;
}

#pragma mark - UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    // OK Button tapped.
    if (buttonIndex == 1) {
        [self deletePage];
    }
    
}

#pragma mark - Properties

- (BookContentTitleView *)contentTitleView {
    if (!_contentTitleView) {
        _contentTitleView = [[BookContentTitleView alloc] initWithTitle:self.page];
        _contentTitleView.userInteractionEnabled = NO;
    }
    return _contentTitleView;
}

- (UIButton *)deleteButton {
    if (!_deleteButton) {
        UIEdgeInsets contentInsets = [self pageContentInsets];
        _deleteButton = [ViewHelper deleteButtonWithTarget:self selector:@selector(deleteTapped:)];
        _deleteButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin;
        [_deleteButton setFrame:CGRectMake(self.view.bounds.size.width - _deleteButton.frame.size.width - contentInsets.right,
                                           self.view.bounds.size.height - _deleteButton.frame.size.height - contentInsets.bottom,
                                           _deleteButton.frame.size.width,
                                           _deleteButton.frame.size.height)];
    }
    return _deleteButton;
}

- (CKActivityIndicatorView *)activityView {
    if (!_activityView) {
        _activityView = [[CKActivityIndicatorView alloc] initWithStyle:CKActivityIndicatorViewStyleSmall];
        _activityView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    }
    return _activityView;
}

#pragma mark - Private 

- (void)initImageView {
    self.imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.imageView];
}

- (void)initCollectionView {
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds
                                                          collectionViewLayout:[[BookContentGridLayout alloc] initWithDelegate:self]];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    collectionView.alwaysBounceVertical = YES;
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:collectionView];
    self.collectionView = collectionView;
    
    [self.collectionView registerClass:[BookRecipeGridLargeCell class]
            forCellWithReuseIdentifier:[self cellIdentifierForGridType:BookContentGridTypeLarge]];
    [self.collectionView registerClass:[BookRecipeGridMediumCell class]
            forCellWithReuseIdentifier:[self cellIdentifierForGridType:BookContentGridTypeMedium]];
    [self.collectionView registerClass:[BookRecipeGridSmallCell class]
            forCellWithReuseIdentifier:[self cellIdentifierForGridType:BookContentGridTypeSmall]];
    [self.collectionView registerClass:[BookRecipeGridExtraSmallCell class]
            forCellWithReuseIdentifier:[self cellIdentifierForGridType:BookContentGridTypeExtraSmall]];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kContentHeaderId];
    [self.collectionView registerClass:[CKContentContainerCell class] forCellWithReuseIdentifier:kLoadMoreCellId];
}

- (void)initOverlay {
    UIView *overlayView = [[UIView alloc] initWithFrame:self.view.bounds];
    overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    overlayView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
    overlayView.alpha = 0.0;    // Start off clear.
    [self.view addSubview:overlayView];
    self.overlayView = overlayView;
}

- (void)showRecipeAtIndexPath:(NSIndexPath *)indexPath {
    CKRecipe *recipe = [self.recipes objectAtIndex:indexPath.item];
    [self.bookPageDelegate bookPageViewControllerShowRecipe:recipe];
}

- (void)applyScrollingEffectsOnCategoryView {
    if (!self.disableInformScrollOffset) {
        CGRect visibleFrame = [ViewHelper visibleFrameForCollectionView:self.collectionView];
        [self.delegate bookContentViewControllerScrolledOffset:visibleFrame.origin.y page:self.page
                                             distanceTravelled:(self.collectionView.contentOffset.y - self.startContentOffset.y)];
    }
}

- (BookContentGridType)gridTypeForRecipe:(CKRecipe *)recipe {
    
    // Defaults to large, which makes computing combinations easier.
    BookContentGridType gridType = BookContentGridTypeLarge;
    
    if ([recipe hasPhotos]) {
        
        if (![recipe hasTitle] && ![recipe hasStory] && ![recipe hasMethod] && ![recipe hasIngredients]) {
            
            // +Photo -Title -Story -Method -Ingredients
            gridType = BookContentGridTypeExtraSmall;
            
        } else if ([recipe hasTitle] && ![recipe hasStory] && ![recipe hasMethod] && ![recipe hasIngredients]) {
            
            // +Photo +Title -Story -Method -Ingredients
            gridType = BookContentGridTypeSmall;
            
        } else if (![recipe hasTitle] && [recipe hasStory] && ![recipe hasMethod] && ![recipe hasIngredients]) {
            
            // +Photo -Title +Story -Method -Ingredients
            gridType = BookContentGridTypeMedium;
            
        } else if (![recipe hasTitle] && ![recipe hasStory] && [recipe hasMethod] && ![recipe hasIngredients]) {
            
            // +Photo -Title -Story +Method -Ingredients
            gridType = BookContentGridTypeMedium;
            
        } else if (![recipe hasTitle] && ![recipe hasStory] && ![recipe hasMethod] && [recipe hasIngredients]) {
            
            // +Photo -Title -Story -Method +Ingredients
            gridType = BookContentGridTypeMedium;
            
        }
        
    } else {
        
        if ([recipe hasTitle] && ![recipe hasStory] && ![recipe hasMethod] && ![recipe hasIngredients]) {
            
            // -Photo +Title -Story -Method -Ingredients
            gridType = BookContentGridTypeExtraSmall;
            
        } else if (![recipe hasTitle] && [recipe hasStory] && ![recipe hasMethod] && ![recipe hasIngredients]) {
            
            // -Photo -Title +Story -Method -Ingredients
            gridType = BookContentGridTypeExtraSmall;
            
        } else if (![recipe hasTitle] && ![recipe hasStory] && [recipe hasMethod] && ![recipe hasIngredients]) {
            
            // -Photo -Title -Story +Method -Ingredients
            gridType = BookContentGridTypeExtraSmall;
            
        } else if (![recipe hasTitle] && ![recipe hasStory] && ![recipe hasMethod] && [recipe hasIngredients]) {
            
            // -Photo -Title -Story -Method +Ingredients
            gridType = BookContentGridTypeExtraSmall;
            
        } else if ([recipe hasTitle] && [recipe hasStory] && ![recipe hasIngredients]) {
            
            // -Photo +Title +Story (+/-)Method -Ingredients
            gridType = BookContentGridTypeSmall;
            
        } else if ([recipe hasTitle] && ![recipe hasStory] && [recipe hasMethod] && ![recipe hasIngredients]) {
            
            // -Photo +Title -Story +Method -Ingredients
            gridType = BookContentGridTypeSmall;
            
        } else if ([recipe hasTitle] && ![recipe hasStory] && ![recipe hasMethod] && [recipe hasIngredients]) {
            
            // -Photo +Title -Story -Method +Ingredients
            gridType = BookContentGridTypeSmall;
            
        }
    }
    
//    DLog(@"recipe[%@] gridType[%d]", recipe.name, gridType);

    return gridType;
}

- (NSString *)cellIdentifierForGridType:(BookContentGridType)gridType {
    return [NSString stringWithFormat:@"GridType%d", gridType];
}

- (void)deleteTapped:(id)sender {
    NSString *message = nil;
    if ([self.recipes count] > 0) {
        message = @"This will also delete the recipes on this page.";
    }
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Delete Page?"
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [alertView show];
}

- (void)deletePage {
    
    // Inform delegate to exit. edit mode.
    [self.bookPageDelegate bookPageViewController:self editModeRequested:NO];
    
    self.progressOverlayViewController = [[ProgressOverlayViewController alloc] initWithTitle:@"DELETING"];
    [ModalOverlayHelper showModalOverlayForViewController:self.progressOverlayViewController
                                                     show:YES
                                               completion:^{
                                                   
                                                   __weak BookContentViewController *weakSelf = self;
                                                   [weakSelf.progressOverlayViewController updateProgress:0.1];
                                                   
                                                   [weakSelf.book deletePage:weakSelf.page
                                                                     success:^{
                                                                     
                                                                         [weakSelf.progressOverlayViewController updateProgress:0.9];
                                                                     
                                                                         // Ask the opened book to relayout.
                                                                         [[BookNavigationHelper sharedInstance] updateBookNavigationWithDeletedPage:weakSelf.page
                                                                                                                                         completion:^{
                                                                                                                                             
                                                                                                                                             [weakSelf.progressOverlayViewController updateProgress:1.0 delay:0.5 completion:^{
                                                                                                                                                 [weakSelf enableEditMode:NO animated:NO completion:^{
                                                                                                                                                     [ModalOverlayHelper hideModalOverlayForViewController:weakSelf.progressOverlayViewController completion:nil];
                                                                                                                                                 }];
                                                                                                                                             }];
                                                                         }];
                                                                 }
                                                                 failure:^(NSError *error) {
                                                                     
                                                                     // Unable to delete.
                                                                     [weakSelf enableEditMode:NO animated:NO completion:^{
                                                                         [ModalOverlayHelper hideModalOverlayForViewController:weakSelf.progressOverlayViewController completion:nil];
                                                                     }];
                                                                 }];
                                               }];
}

- (void)renamePage {
    self.progressOverlayViewController = [[ProgressOverlayViewController alloc] initWithTitle:@"RENAMING PAGE"];
    [ModalOverlayHelper showModalOverlayForViewController:self.progressOverlayViewController
                                                     show:YES
                                               completion:^{
                                                   
                                                   __weak BookContentViewController *weakSelf = self;
                                                   [weakSelf.progressOverlayViewController updateProgress:0.1];
                                                   [self.book renamePage:self.page
                                                                  toPage:self.updatedPage
                                                                 success:^{
                                                                     
                                                                     // Finished, now ask opened book to relayout.
                                                                     [weakSelf.progressOverlayViewController updateProgress:0.9];
                                                                     [[BookNavigationHelper sharedInstance] updateBookNavigationWithRenamedPage:weakSelf.updatedPage fromPage:weakSelf.page completion:^{
                                                                         
                                                                         // Update current page name.
                                                                         weakSelf.page = weakSelf.updatedPage;
                                                                         [weakSelf.progressOverlayViewController updateProgress:1.0 delay:0.5 completion:^{
                                                                             
                                                                             // Disable edit mode.
                                                                             [weakSelf enableEditMode:NO animated:NO completion:^{
                                                                                 [ModalOverlayHelper hideModalOverlayForViewController:weakSelf.progressOverlayViewController completion:nil];
                                                                             }];
                                                                             
                                                                             // Clear updatedPage state.
                                                                             self.updatedPage = nil;
                                                                             
                                                                         }];
                                                                         
                                                                     }];
                                                                     
                                                                 }
                                                                 failure:^(NSError *error) {
                                                                     [weakSelf.progressOverlayViewController updateWithTitle:@"Unable to Rename" delay:1.5 completion:^{
                                                                         
                                                                         [ModalOverlayHelper hideModalOverlayForViewController:weakSelf.progressOverlayViewController completion:nil];
                                                                         
                                                                         [self restorePage];
                                                                     }];
                                                                 }];
                                               }];
}

- (void)performPageNameEdit {
    CKTextFieldEditViewController *editViewController = [[CKTextFieldEditViewController alloc] initWithEditView:self.contentTitleView
                                                                                                       delegate:self
                                                                                                  editingHelper:self.editingHelper
                                                                                                          white:YES
                                                                                                          title:@"Page Name"
                                                                                                 characterLimit:16];
    editViewController.showTitle = YES;
    editViewController.forceUppercase = YES;
    editViewController.font = [UIFont fontWithName:@"BrandonGrotesque-Regular" size:48.0];
    [editViewController performEditing:YES];
    self.editViewController = editViewController;

}

- (void)updateContentTitleViewWithTitle:(NSString *)title {
    [self.contentTitleView updateWithTitle:title];
    CGRect contentTitleFrame = self.contentTitleView.frame;
    contentTitleFrame.origin.x = floorf((self.contentTitleView.superview.bounds.size.width - contentTitleFrame.size.width) / 2.0);
    contentTitleFrame.origin.y = floorf((self.contentTitleView.superview.bounds.size.height - contentTitleFrame.size.height) / 2.0);
    self.contentTitleView.frame = contentTitleFrame;
}

- (void)restorePage {
    [self updateContentTitleViewWithTitle:self.page];
    [self.editingHelper updateEditingView:self.contentTitleView animated:NO];
    [self.editingHelper unwrapEditingView:self.contentTitleView animated:YES];
    
    // Clear updatedPage state.
    self.updatedPage = nil;
}

- (void)showIntroCard {
    [self showIntroCard:([self.delegate bookContentViewControllerAddSupportedForPage:self.page]
                         && [self.recipes count] == 0 && !self.editMode)];
}

- (void)socialUpdates:(NSNotification *)notification {
    CKRecipe *recipe = [EventHelper socialUpdatesRecipeForNotification:notification];
    
    // Ignore non-related page recipe updates.
    if (![recipe.page isEqualToString:self.page]) {
        return;
    }
    
    // Look for the recipe index.
    NSInteger recipeIndex = [self.recipes findIndexWithBlock:^BOOL(CKRecipe *existingRecipe) {
        return [existingRecipe.objectId isEqualToString:recipe.objectId];
    }];
    if (recipeIndex != -1) {
        [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:recipeIndex inSection:0]]];
    }
    
}

- (NSArray *)allIndexPaths {
    return [self.recipes collectWithIndex:^id(CKRecipe *recipe, NSUInteger recipeIndex) {
        return [NSIndexPath indexPathForItem:recipeIndex inSection:0];
    }];
}


@end
