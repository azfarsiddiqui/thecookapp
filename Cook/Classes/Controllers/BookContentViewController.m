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

@interface BookContentViewController () <UICollectionViewDataSource, UICollectionViewDelegate,
    BookContentGridLayoutDelegate, CKEditingTextBoxViewDelegate, CKEditViewControllerDelegate, UIAlertViewDelegate>

@property (nonatomic, weak) id<BookContentViewControllerDelegate> delegate;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) CKBook *book;
@property (nonatomic, strong) NSString *page;
@property (nonatomic, strong) NSMutableArray *recipes;

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) BookContentTitleView *contentTitleView;

// Editing.
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) CKEditingViewHelper *editingHelper;
@property (nonatomic, strong) CKTextFieldEditViewController *editViewController;
@property (nonatomic, strong) ProgressOverlayViewController *progressOverlayViewController;
@property (nonatomic, strong) NSString *updatedPage;

@end

@implementation BookContentViewController

#define kRecipeCellId       @"RecipeCellId"
#define kContentHeaderId    @"ContentHeaderId"

- (id)initWithBook:(CKBook *)book page:(NSString *)page delegate:(id<BookContentViewControllerDelegate>)delegate {
    
    if (self = [super init]) {
        self.delegate = delegate;
        self.book = book;
        self.page = page;
        self.editingHelper = [[CKEditingViewHelper alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];

    [self initCollectionView];
    [self initOverlay];
    [self loadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self showIntroCard:([self.recipes count] == 0)];
}

- (void)loadData {
    self.recipes = [NSMutableArray arrayWithArray:[self.delegate recipesForBookContentViewControllerForPage:self.page]];
    [self.collectionView reloadData];
}

- (CGPoint)currentScrollOffset {
    CGRect visibleFrame = [ViewHelper visibleFrameForCollectionView:self.collectionView];
    return visibleFrame.origin;
}

- (void)setScrollOffset:(CGPoint)scrollOffset {
    [self.collectionView setContentOffset:scrollOffset animated:NO];
}

- (void)applyOverlayAlpha:(CGFloat)alpha {
    self.overlayView.alpha = alpha;
}

- (void)enableEditMode:(BOOL)editMode animated:(BOOL)animated completion:(void (^)())completion {
    
    // Disable any card.
    [self showIntroCard:!editMode];
    
    self.editMode = editMode;
    self.collectionView.scrollEnabled = !editMode;
    
    if (editMode) {
        
        // Scroll to top.
        [self.collectionView setContentOffset:CGPointZero animated:YES];
        
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
                              } delegate:self white:YES editMode:YES animated:YES];
        
    } else {
        
        [self.editingHelper unwrapEditingView:self.contentTitleView animated:YES];
    }
    
    if (animated) {
        
        [UIView animateWithDuration:0.25
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             
                             // Hide all visible cells.
                             for (UICollectionViewCell *cell in [self.collectionView visibleCells]) {
                                 cell.alpha = editMode ? 0.0 : 1.0;
                             }
                             
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
        [self.contentTitleView enableEditMode:editMode animated:NO];
        self.deleteButton.alpha = editMode ? 1.0 : 0.0;
        
        if (!self.editMode) {
            [self.bookPageDelegate bookPageViewController:self editModeRequested:NO];
        }
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
                                                          self.view.bounds.size.width - floorf(cardSize.width / 2.0),
                                                          floorf(cardSize.height / 2.0) + 70.0
                                                      }];
    } else {
        [[CardViewHelper sharedInstance] hideCardViewWithTag:cardTag];
    }
    
}

#pragma mark - BookContentGridLayoutDelegate methods

- (void)bookContentGridLayoutDidFinish {
    DLog();
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

#pragma mark - CKSaveableContent methods

- (BOOL)contentSaveRequired {
    return ![self.updatedPage CK_equalsIgnoreCase:self.page];
}

- (void)contentPerformSave:(BOOL)save {
    if (save && [self contentSaveRequired]) {
        [self renamePage];
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
    [self updateContentTitleViewWithTitle:value];
    self.updatedPage = value;
    [self.editingHelper updateEditingView:self.contentTitleView];
}

- (id)editViewControllerInitialValue {
    return [self.page uppercaseString];
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self applyScrollingEffectsOnCategoryView];
}

#pragma mark - UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self showRecipeAtIndexPath:indexPath];
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    NSInteger numItems = 0;
    numItems = [self.recipes count];
    return numItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CKRecipe *recipe = [self.recipes objectAtIndex:indexPath.item];
    BookContentGridType gridType = [self gridTypeForRecipe:recipe];
    NSString *cellId = [self cellIdentifierForGridType:gridType];
    
    BookRecipeGridCell *recipeCell = (BookRecipeGridCell *)[self.collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    
    [recipeCell configureRecipe:recipe book:self.book];
    
    // Configure image.
    [self configureImageForRecipeCell:recipeCell recipe:recipe indexPath:indexPath];
    
    return recipeCell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionReusableView *reusableView = [self.collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kContentHeaderId forIndexPath:indexPath];
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


#pragma mark - Private 

- (void)initImageView {
    self.imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
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
}

- (void)initOverlay {
    UIView *overlayView = [[UIView alloc] initWithFrame:self.view.bounds];
    overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    overlayView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
    overlayView.alpha = 0.0;    // Start off clear.
    [self.view addSubview:overlayView];
    self.overlayView = overlayView;
}

- (void)loadFeaturedRecipe {
    CKRecipe *featuredRecipe = [self.delegate featuredRecipeForBookContentViewControllerForPage:self.page];
    NSString *loadingName = [NSString stringWithFormat:@"%@_FeaturedRecipe", self.page];
    
    [[CKPhotoManager sharedInstance] imageForRecipe:featuredRecipe size:self.imageView.bounds.size name:loadingName
                                           progress:^(CGFloat progressRatio, NSString *name) {
                                               DLog(@"image progress[%f]", progressRatio);
                                           } thumbCompletion:^(UIImage *thumbImage, NSString *name) {
                                               self.imageView.image = thumbImage;
                                           } completion:^(UIImage *image, NSString *name) {
                                               if ([name isEqualToString:loadingName]) {
                                                   self.imageView.image = image;
                                               }
                                           }];
}

- (void)configureImageForRecipeCell:(BookRecipeGridCell *)recipeCell recipe:(CKRecipe *)recipe
                          indexPath:(NSIndexPath *)indexPath {
    
    if ([recipe hasPhotos]) {
        CGSize imageSize = [BookRecipeGridCell imageSize];
        
        
        [[CKPhotoManager sharedInstance] thumbImageForRecipe:recipe size:imageSize name:recipe.objectId
                                                    progress:^(CGFloat progressRatio, NSString *name) {
                                                    } completion:^(UIImage *thumbImage, NSString *name) {
                                                        if ([name isEqualToString:recipe.objectId]) {
                                                            [recipeCell configureImage:thumbImage];
                                                        }
                                                    }];
    } else {
        [recipeCell configureImage:nil];
    }
}

- (void)showRecipeAtIndexPath:(NSIndexPath *)indexPath {
    CKRecipe *recipe = [self.recipes objectAtIndex:indexPath.item];
    [self.bookPageDelegate bookPageViewControllerShowRecipe:recipe];
}

- (void)applyScrollingEffectsOnCategoryView {
    CGRect visibleFrame = [ViewHelper visibleFrameForCollectionView:self.collectionView];
    [self.delegate bookContentViewControllerScrolledOffset:visibleFrame.origin.y page:self.page];
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
    
    DLog(@"recipe[%@] gridType[%d]", recipe.name, gridType);

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
                                                                     // Unabel to delete.
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
                                                                                                 characterLimit:15];
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
}

@end
