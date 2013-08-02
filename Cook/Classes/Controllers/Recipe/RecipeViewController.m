//
//  RecipeViewController.m
//  RecipeViewPrototype
//
//  Created by Jeff Tan-Ang on 9/04/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "RecipeViewController.h"
#import "CKRecipe.h"
#import "CKBook.h"
#import "CKBookCover.h"
#import "ViewHelper.h"
#import "ParsePhotoStore.h"
#import "CKUserProfilePhotoView.h"
#import "Theme.h"
#import "CKRecipeSocialView.h"
#import "MRCEnumerable.h"
#import "Ingredient.h"
#import "RecipeSocialViewController.h"
#import "CKEditViewController.h"
#import "CKEditingTextBoxView.h"
#import "CKEditingViewHelper.h"
#import "CKTextFieldEditViewController.h"
#import "CKPhotoPickerViewController.h"
#import "UIImage+ProportionalFill.h"
#import "CKEditingTextBoxView.h"
#import "AppHelper.h"
#import "CKImageEditViewController.h"
#import "CKTextViewEditViewController.h"
#import "CKLabelEditViewController.h"
#import "BookNavigationHelper.h"
#import "NSString+Utilities.h"
#import "CKProgressView.h"
#import "CategoryListEditViewController.h"
#import "IngredientListEditViewController.h"
#import "ServesAndTimeEditViewController.h"
#import "RecipeClipboard.h"
#import "CKPrivacyView.h"
#import "IngredientsView.h"
#import "CKLabel.h"
#import "BookSocialViewController.h"
#import "CKLikeView.h"
#import "CKPrivacySliderView.h"

typedef enum {
	PhotoWindowHeightMin,
	PhotoWindowHeightMid,
	PhotoWindowHeightMax,
	PhotoWindowHeightFullScreen,
} PhotoWindowHeight;

@interface RecipeViewController () <UIGestureRecognizerDelegate, CKRecipeSocialViewDelegate,
    CKEditViewControllerDelegate, CKEditingTextBoxViewDelegate, CKPhotoPickerViewControllerDelegate,
    CKPrivacySliderViewDelegate, BookSocialViewControllerDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) CKRecipe *recipe;
@property (nonatomic, strong) RecipeClipboard *clipboard;
@property (nonatomic, strong) CKBook *book;
@property(nonatomic, assign) id<BookModalViewControllerDelegate> modalDelegate;

@property (nonatomic, strong) UIImageView *topShadowView;
@property (nonatomic, strong) UIView *contentContainerView;
@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UICollectionView *collectionView;

// Header view.
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) CKUserProfilePhotoView *profilePhotoView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) CKLabel *categoryLabel;

// Content view.
@property (nonatomic, strong) CKLabel *titleLabel;
@property (nonatomic, strong) CKLabel *storyLabel;
@property (nonatomic, strong) CKLabel *methodLabel;
@property (nonatomic, strong) UILabel *ingredientsLabel;
@property (nonatomic, strong) IngredientsView *ingredientsView;

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *servesCookView;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIView *servingIngredientsDividerView;
@property (nonatomic, assign) PhotoWindowHeight photoWindowHeight;
@property (nonatomic, assign) PhotoWindowHeight previousPhotoWindowHeight;
@property (nonatomic, assign) BOOL addMode;
@property (nonatomic, assign) BOOL editMode;
@property (nonatomic, assign) BOOL saveRequired;
@property (nonatomic, assign) BOOL saveInProgress;
@property (nonatomic, assign) BOOL contentPullActivated;
@property (nonatomic, strong) UIView *navContainerView;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *editButton;
@property (nonatomic, strong) UIButton *shareButton;
@property (nonatomic, strong) CKLikeView *likeButton;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong) UILabel *photoLabel;
@property (nonatomic, strong) CKRecipeSocialView *socialView;
@property (nonatomic, strong) CKProgressView *progressView;
@property (nonatomic, strong) CKPrivacySliderView *privacyView;
@property (nonatomic, strong) ParsePhotoStore *parsePhotoStore;

@property (nonatomic, strong) CKEditViewController *editViewController;
@property (nonatomic, strong) CKEditingViewHelper *editingHelper;

@property (nonatomic, strong) CKPhotoPickerViewController *photoPickerViewController;
@property (nonatomic, strong) UIImage *recipeImageToUpload;

@property (nonatomic, strong) BookSocialViewController *bookSocialViewController;

@end

@implementation RecipeViewController

#define kWindowMinHeight        70.0
#define kWindowMidHeight        260.0
#define kWindowMinSnapOffset    175.0
#define kWindowMidSnapOffset    285.0
#define kWindowMaxSnapOffset    400.0
#define kWindowBounceOffset     10.0
#define kPhotoOffset            20.0

#define kNavContainerHeight     100.0
#define kHeaderHeight           210.0
#define kContentMaxHeight       468.0
#define kContentMaxWidth        685.0
#define kLeftDividerGap         18.0

#define kButtonInsets           UIEdgeInsetsMake(25.0, 10.0, 15.0, 10.0)
#define kContentLeftFrame       CGRectMake(0.0, 0.0, 255.0, 0.0)
#define kContentRightFrame      CGRectMake(265.0, 0.0, 420.0, 0.0)
#define kContentInsets          UIEdgeInsetsMake(20.0, 20.0, 20.0, 20.0)

#define kServesTag              122
#define kPrepCookTag            123

- (id)initWithBook:(CKBook *)book category:(CKCategory *)category {
    if (self = [self initWithRecipe:nil book:book]) {
        self.recipe = [CKRecipe recipeForBook:book category:category];
    }
    return self;
}

- (id)initWithRecipe:(CKRecipe *)recipe {
    return [self initWithRecipe:recipe book:recipe.book];
}

- (id)initWithRecipe:(CKRecipe *)recipe book:(CKBook *)book {
    if (self = [super init]) {
        self.addMode = (recipe == nil);
        self.recipe = recipe;
        self.book = book;
        self.parsePhotoStore = [[ParsePhotoStore alloc]init];
        self.editingHelper = [[CKEditingViewHelper alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    DLog(@"%@", self.recipe);
    self.view.backgroundColor = [UIColor clearColor];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self initContentContainerView];
    [self initHeaderView];
    [self initContentView];
    [self initScrollView];
    [self initBackgroundImageView];
    [self initStartState];
}

#pragma mark - BookModalViewController methods

- (void)setModalViewControllerDelegate:(id<BookModalViewControllerDelegate>)modalViewControllerDelegate {
    self.modalDelegate = modalViewControllerDelegate;
}

- (void)bookModalViewControllerWillAppear:(NSNumber *)appearNumber {
    if ([appearNumber boolValue]) {

    } else {
        [self hideButtons];
    }
}

- (void)bookModalViewControllerDidAppear:(NSNumber *)appearNumber {
    if ([appearNumber boolValue]) {
        
        // Start window height state.
        PhotoWindowHeight startWindowHeight = [self startWindowHeight];
        
        // Snap to required width.
        [self snapContentToPhotoWindowHeight:startWindowHeight completion:^{
            
            // Load stuff.
            [self updateButtons];
            [self loadPhoto];
            [self loadData];
            
            // Add mode?
            if (self.addMode) {
                [self performSelector:@selector(enableEditMode) withObject:nil afterDelay:0.0];
            }

        }];
        
        
    } else {
        
    }
}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    DLog(@"scrollView.contentOffset.y [%f]", scrollView.contentOffset.y);
    if (scrollView.contentOffset.y < 0) {
        self.contentPullActivated = YES;
        [self panWithTranslation:(CGPoint){ 0.0, -scrollView.contentOffset.y }];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate && self.contentPullActivated) {
        [self panSnapIfRequiredBounce:NO];
        
        self.contentPullActivated = NO;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (self.contentPullActivated) {
        [self panSnapIfRequiredBounce:NO];
        self.contentPullActivated = NO;
    }
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    BOOL shouldReceiveTouch = YES;
    
    // Ignore taps on background image view when in edit mode.
    if (self.editMode && gestureRecognizer.view == self.backgroundImageView) {
        shouldReceiveTouch = NO;
    }
    
    return shouldReceiveTouch;
}

#pragma mark - BookSocialViewControllerDelegate methods

- (void)bookSocialViewControllerCloseRequested {
    [self showSocialOverlay:NO];
}

#pragma mark - CKRecipeSocialViewDelegate methods

- (void)recipeSocialViewTapped {
    [self showSocialOverlay:YES];
}

- (void)recipeSocialViewUpdated:(CKRecipeSocialView *)socialView {
    socialView.frame = (CGRect){
        floorf((self.view.bounds.size.width - socialView.frame.size.width) / 2.0),
        kButtonInsets.top,
        socialView.frame.size.width,
        socialView.frame.size.height
    };
}

#pragma mark - CKEditingTextBoxViewDelegate methods

- (void)editingTextBoxViewTappedForEditingView:(UIView *)editingView {
    if (editingView == self.photoLabel) {
        
        [self snapContentToPhotoWindowHeight:PhotoWindowHeightFullScreen bounce:NO completion:^{
            [self showPhotoPicker:YES];
        }];
        
    } else if (editingView == self.titleLabel) {
        CKTextFieldEditViewController *editViewController = [[CKTextFieldEditViewController alloc] initWithEditView:editingView
                                                                                                           delegate:self
                                                                                                      editingHelper:self.editingHelper
                                                                                                              white:YES
                                                                                                              title:@"Name"
                                                                                                     characterLimit:30];
        editViewController.font = [UIFont fontWithName:@"BrandonGrotesque-Bold" size:48.0];
        [editViewController performEditing:YES];
        self.editViewController = editViewController;
        
    } else if (editingView == self.categoryLabel) {
        
        // Get the current category from the book, check from currentCategories first which is populated by the
        // category list editor. Otherwise, default to current label.
        CKCategory *currentCategory = [self.book.currentCategories detect:^BOOL(CKCategory *category) {
            return [self.categoryLabel.text CK_equalsIgnoreCase:category.name];
        }];
        if (currentCategory == nil) {
            currentCategory = self.recipe.category;
        }
        
        CategoryListEditViewController *editViewController = [[CategoryListEditViewController alloc] initWithEditView:self.categoryLabel
                                                                                                                 book:self.book
                                                                                                     selectedCategory:currentCategory
                                                                                                             delegate:self
                                                                                                        editingHelper:self.editingHelper
                                                                                                                white:YES];
        editViewController.canAddItems = NO;
        editViewController.canDeleteItems = NO;
        editViewController.canReorderItems = NO;
        [editViewController performEditing:YES];
        self.editViewController = editViewController;
        
    } else if (editingView == self.storyLabel) {
        
        CKTextViewEditViewController *editViewController = [[CKTextViewEditViewController alloc] initWithEditView:editingView
                                                                                                         delegate:self
                                                                                                    editingHelper:self.editingHelper
                                                                                                            white:YES
                                                                                                            title:@"Story"
                                                                                                   characterLimit:120];
        ((CKTextViewEditViewController *)editViewController).numLines = 2;
        editViewController.textViewFont = [UIFont fontWithName:@"BrandonGrotesque-Regular" size:30.0];
        [editViewController performEditing:YES];
        self.editViewController = editViewController;
        
    } else if (editingView == self.methodLabel) {
        
        CKTextViewEditViewController *editViewController = [[CKTextViewEditViewController alloc] initWithEditView:self.methodLabel
                                                                                                         delegate:self
                                                                                                    editingHelper:self.editingHelper
                                                                                                            white:YES
                                                                                                            title:@"Method"];
        editViewController.textViewFont = [UIFont fontWithName:@"BrandonGrotesque-Regular" size:30.0];
        [editViewController performEditing:YES];
        self.editViewController = editViewController;
    
    } else if (editingView == self.servesCookView) {
        
        ServesAndTimeEditViewController *editViewController = [[ServesAndTimeEditViewController alloc] initWithEditView:editingView
                                                                                                        recipeClipboard:self.clipboard
                                                                                                               delegate:self
                                                                                                          editingHelper:self.editingHelper
                                                                                                                  white:YES];
        [editViewController performEditing:YES];
        self.editViewController = editViewController;
        
    } else if (editingView == self.ingredientsView) {
        
        IngredientListEditViewController *editViewController = [[IngredientListEditViewController alloc] initWithEditView:editingView delegate:self items:self.clipboard.ingredients editingHelper:self.editingHelper white:YES title:@"Ingredients"];
        editViewController.canAddItems = YES;
        editViewController.canDeleteItems = YES;
        editViewController.canReorderItems = YES;
        editViewController.allowSelection = NO;
        [editViewController performEditing:YES];
        self.editViewController = editViewController;
    }
}

#pragma mark - CKEditViewControllerDelegate methods

- (void)editViewControllerWillAppear:(BOOL)appear {
    DLog(@"%@", appear ? @"YES" : @"NO");
    
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.cancelButton.alpha = appear ? 0.0 : 1.0;
                         self.saveButton.alpha = appear ? 0.0 : 1.0;
                     }
                     completion:^(BOOL finished) {
                     }];
}

- (void)editViewControllerDidAppear:(BOOL)appear {
    DLog(@"%@", appear ? @"YES" : @"NO");
    if (!appear) {
        [self.editViewController.view removeFromSuperview];
        self.editViewController = nil;
    }
}

- (void)editViewControllerDismissRequested {
    [self.editViewController performEditing:NO];
}

- (void)editViewControllerUpdateEditView:(UIView *)editingView value:(id)value {
    
    if (editingView == self.titleLabel) {
        [self saveTitleValue:value];
    } else if (editingView == self.categoryLabel) {
        [self saveCategoryValue:value];
    } else if (editingView == self.storyLabel) {
        [self saveStoryValue:value];
    } else if (editingView == self.servesCookView) {
        [self saveServesPrepCookValue:value];
    } else if (editingView == self.methodLabel) {
        [self saveMethodValue:value];
    } else if (editingView == self.ingredientsView) {
        [self saveIngredientsValue:value];
    }
    
}

#pragma mark - CKPhotoPickerViewControllerDelegate methods

- (void)photoPickerViewControllerSelectedImage:(UIImage *)image {
    
    // Present the image.
    UIImage *croppedImage = [image imageCroppedToFitSize:self.backgroundImageView.bounds.size];
    [self loadImageViewWithPhoto:croppedImage];
    
    // Save photo to be uploaded.
    self.recipeImageToUpload = image;
    self.saveRequired = YES;
    
    // Update edit photo label.
    self.photoLabel.text = @"EDIT PHOTO";
    [self.photoLabel sizeToFit];

    // Close and revert to mid height.
    [self showPhotoPicker:NO completion:^{
        [self snapContentToPhotoWindowHeight:PhotoWindowHeightMid];
        
    }];
}

- (void)photoPickerViewControllerCloseRequested {
    
    // Close and revert to mid height.
    [self showPhotoPicker:NO completion:^{
        [self snapContentToPhotoWindowHeight:PhotoWindowHeightMid];
        
    }];
}

#pragma mark - CKPrivacySliderViewDelegate methods

- (void)privacyViewSelectedPrivateMode:(BOOL)privateMode {
    self.clipboard.privacyMode = privateMode;
    self.saveRequired = (self.clipboard.privacyMode != self.recipe.privacy);
}

- (void)privacySelectedPrivateForSliderView:(CKNotchSliderView *)sliderView {
}

- (void)privacySelectedFriendsForSliderView:(CKNotchSliderView *)sliderView {
}

- (void)privacySelectedGlobalForSliderView:(CKNotchSliderView *)sliderView {
}

#pragma mark - Properties

- (UIView *)contentContainerView {
    if (!_contentContainerView) {
        _contentContainerView = [[UIView alloc] initWithFrame:(CGRect){
            self.view.bounds.origin.x,
            kWindowMidHeight,
            self.view.bounds.size.width,
            self.view.bounds.size.height - kWindowMidHeight}];
        _contentContainerView.backgroundColor = [UIColor clearColor];
        _contentContainerView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth;
    }
    return _contentContainerView;
}

- (UIView *)headerView {
    if (!_headerView) {
        UIImage *headerImage = [[UIImage imageNamed:@"cook_recipe_background_tile.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:52.0];
        _headerView = [[UIImageView alloc] initWithImage:headerImage];
        _headerView.frame = (CGRect){
            self.contentContainerView.bounds.origin.x,
            self.contentContainerView.bounds.origin.y,
            self.contentContainerView.bounds.size.width,
            kHeaderHeight};
        _headerView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth;
        _headerView.backgroundColor = [UIColor clearColor];
        _headerView.userInteractionEnabled = YES;
    }
    return _headerView;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [ViewHelper buttonWithImage:[UIImage imageNamed:@"cook_book_inner_icon_close_light.png"]
                                            target:self
                                          selector:@selector(closeTapped:)];
        _closeButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
        [_closeButton setFrame:CGRectMake(kButtonInsets.left,
                                          kButtonInsets.top,
                                          _closeButton.frame.size.width,
                                          _closeButton.frame.size.height)];
    }
    return _closeButton;
}

- (UIButton *)editButton {
    if (!_editButton && [self canEditRecipe]) {
        _editButton = [ViewHelper buttonWithImage:[UIImage imageNamed:@"cook_book_inner_icon_edit_light.png"]
                                                    target:self
                                                  selector:@selector(editTapped:)];
        _editButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin;
        _editButton.frame = CGRectMake(self.shareButton.frame.origin.x - 15.0 - _editButton.frame.size.width,
                                      kButtonInsets.top,
                                      _editButton.frame.size.width,
                                      _editButton.frame.size.height);
    }
    return _editButton;
}

- (UIButton *)shareButton {
    if (!_shareButton) {
        _shareButton = [ViewHelper buttonWithImage:[UIImage imageNamed:@"cook_book_inner_icon_share_light.png"]
                                            target:self
                                          selector:@selector(shareTapped:)];
        _shareButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin;
        _shareButton.frame = CGRectMake(self.likeButton.frame.origin.x - 15.0 - _shareButton.frame.size.width,
                                        kButtonInsets.top,
                                        _shareButton.frame.size.width,
                                        _shareButton.frame.size.height);
    }
    return _shareButton;
}

- (CKLikeView *)likeButton {
    if (!_likeButton) {
        _likeButton = [[CKLikeView alloc] initWithRecipe:self.recipe];
        _likeButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin;
        _likeButton.frame = CGRectMake(self.view.frame.size.width - kButtonInsets.right - _likeButton.frame.size.width,
                                       kButtonInsets.top,
                                       _likeButton.frame.size.width,
                                       _likeButton.frame.size.height);
    }
    return _likeButton;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [ViewHelper cancelButtonWithTarget:self selector:@selector(cancelTapped:)];
        _cancelButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
        [_cancelButton setFrame:CGRectMake(kButtonInsets.left,
                                           kButtonInsets.top,
                                           _cancelButton.frame.size.width,
                                           _cancelButton.frame.size.height)];
    }
    return _cancelButton;
}

- (UIButton *)saveButton {
    if (!_saveButton) {
        _saveButton = [ViewHelper okButtonWithTarget:self selector:@selector(saveTapped:)];
        _saveButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin;
        [_saveButton setFrame:CGRectMake(self.view.bounds.size.width - _saveButton.frame.size.width - kButtonInsets.right,
                                         kButtonInsets.top,
                                         _saveButton.frame.size.width,
                                         _saveButton.frame.size.height)];
    }
    return _saveButton;
}

- (UIView *)servesCookView {
    if (!_servesCookView) {
        
        CGFloat iconOffset = -2.0;
        UIView *servesView = [self iconTextViewForIcon:[UIImage imageNamed:@"cook_book_icon_serves.png"]
                                                  text:[self servesDisplayFor:self.recipe.numServes]
                                                   tag:kServesTag];
        
        UIView *prepCookView = [self iconTextViewForIcon:[UIImage imageNamed:@"cook_book_icon_time.png"]
                                                  text:[self prepCookDisplayForPrepMinutes:self.recipe.prepTimeInMinutes
                                                                               cookMinutes:self.recipe.cookingTimeInMinutes]
                                                     tag:kPrepCookTag];
        CGRect prepCookFrame = prepCookView.frame;
        prepCookFrame.origin.y = servesView.frame.origin.y + servesView.frame.size.height + iconOffset;
        prepCookView.frame = prepCookFrame;
        
        _servesCookView = [[UIView alloc] initWithFrame:CGRectUnion(servesView.frame, prepCookView.frame)];
        _servesCookView.userInteractionEnabled = NO;
        [_servesCookView addSubview:servesView];
        [_servesCookView addSubview:prepCookView];
    }
    return _servesCookView;
}

- (UILabel *)photoLabel {
    if (!_photoLabel) {
        _photoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _photoLabel.font = [Theme editPhotoFont];
        _photoLabel.backgroundColor = [UIColor clearColor];
        _photoLabel.textColor = [Theme editPhotoColour];
        _photoLabel.text = [self.recipe hasPhotos] ? @"EDIT PHOTO" : @"ADD PHOTO";
        [_photoLabel sizeToFit];
        _photoLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin;
        [_photoLabel setFrame:CGRectMake(floorf((self.backgroundImageView.bounds.size.width - _photoLabel.frame.size.width) / 2.0),
                                         floorf((self.backgroundImageView.bounds.size.height - _photoLabel.frame.size.height) / 2.0) + kPhotoOffset,
                                         _photoLabel.frame.size.width,
                                         _photoLabel.frame.size.height)];
    }
    return _photoLabel;
}

- (CKPrivacySliderView *)privacyView {
    if (!_privacyView) {
        _privacyView = [[CKPrivacySliderView alloc] initWithDelegate:self];
        _privacyView.frame = (CGRect){
            floorf((self.view.bounds.size.width - _privacyView.frame.size.width) / 2.0),
            kButtonInsets.top,
            _privacyView.frame.size.width,
            _privacyView.frame.size.height};
    }
    return _privacyView;
}

- (UIImageView *)backgroundImageView {
    if (!_backgroundImageView) {
        _backgroundImageView = [[UIImageView alloc] initWithImage:nil];
        _backgroundImageView.userInteractionEnabled = YES;
        _backgroundImageView.backgroundColor = [UIColor clearColor];
        _backgroundImageView.frame = self.view.bounds;
        _backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    }
    return _backgroundImageView;
}

- (UIImageView *)topShadowView {
    if (!_topShadowView) {
        _topShadowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_book_inner_darkenphoto_strip.png"]];
        _topShadowView.frame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, _topShadowView.frame.size.height);
        _topShadowView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth;
    }
    return _topShadowView;
}

#pragma mark - Private methods

- (NSString *)ingredientsText {
    return [self ingredientsTextForIngredients:self.recipe.ingredients];
}

- (NSString *)ingredientsTextForIngredients:(NSArray *)ingredients {
    NSArray *ingredientsDisplay = [ingredients collect:^id(Ingredient *ingredient) {
        return [NSString stringWithFormat:@"%@ %@",
                ingredient.measurement ? ingredient.measurement : @"",
                ingredient.name ? ingredient.name : @""];
    }];
    return [ingredientsDisplay componentsJoinedByString:@""];
}

- (UIView *)iconTextViewForIcon:(UIImage *)icon text:(NSString *)text tag:(NSInteger)tag {
    UIView *iconTextView = [[UIView alloc] initWithFrame:CGRectZero];;
    CGFloat iconTextGap = 8.0;
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(2.0, 2.0, 2.0, 2.0);
    
    // Icon view.
    UIImageView *servesIconView = [[UIImageView alloc] initWithImage:icon];
    
    // Text label.
    UILabel *servesLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    servesLabel.font = [Theme servesFont];
    servesLabel.textColor = [Theme servesColor];
    servesLabel.backgroundColor = [UIColor clearColor];
    servesLabel.shadowOffset = CGSizeMake(0.0, 1.0);
    servesLabel.shadowColor = [UIColor whiteColor];
    servesLabel.text = text;
    servesLabel.tag = tag;
    [servesLabel sizeToFit];
    
    // Position them
    CGFloat maxHeight = MAX(servesIconView.frame.size.height, servesLabel.frame.size.height) + edgeInsets.top + edgeInsets.bottom;
    servesIconView.frame = CGRectMake(edgeInsets.left,
                                      floorf((maxHeight - servesIconView.frame.size.height) / 2.0),
                                      servesIconView.frame.size.width,
                                      servesIconView.frame.size.height);
    servesLabel.frame = CGRectMake(servesIconView.frame.origin.x + servesIconView.frame.size.width + iconTextGap,
                                   floorf((maxHeight - servesLabel.frame.size.height) / 2.0) + 1.0,
                                   servesLabel.frame.size.width,
                                   servesLabel.frame.size.height);
    CGRect combinedFrame = CGRectUnion(servesIconView.frame, servesLabel.frame);
    iconTextView.frame = CGRectMake(0.0, 0.0, edgeInsets.left + combinedFrame.size.width + edgeInsets.right, maxHeight);
    [iconTextView addSubview:servesIconView];
    [iconTextView addSubview:servesLabel];
    
    return iconTextView;
}

- (void)swiped:(UISwipeGestureRecognizer *)swipeGesture {
    UISwipeGestureRecognizerDirection direction = swipeGesture.direction;
    if (direction == UISwipeGestureRecognizerDirectionUp) {
        [self snapContentToPhotoWindowHeight:[self nextUpPhotoWindowHeight]];
    } else if (direction == UISwipeGestureRecognizerDirectionDown) {
        [self snapContentToPhotoWindowHeight:[self nextDownPhotoWindowHeight]];
    }
}

- (PhotoWindowHeight)nextUpPhotoWindowHeight {
    PhotoWindowHeight nextWindowHeight = PhotoWindowHeightMid;
    switch (self.photoWindowHeight) {
        case PhotoWindowHeightMin:
            nextWindowHeight = PhotoWindowHeightMin;
            break;
        case PhotoWindowHeightMid:
            nextWindowHeight = PhotoWindowHeightMin;
            break;
        case PhotoWindowHeightMax:
            nextWindowHeight = PhotoWindowHeightMid;
            break;
        default:
            break;
    }
    return nextWindowHeight;
}

- (PhotoWindowHeight)nextDownPhotoWindowHeight {
    PhotoWindowHeight nextWindowHeight = PhotoWindowHeightMid;
    switch (self.photoWindowHeight) {
        case PhotoWindowHeightMin:
            nextWindowHeight = PhotoWindowHeightMid;
            break;
        case PhotoWindowHeightMid:
            nextWindowHeight = PhotoWindowHeightMax;
            break;
        case PhotoWindowHeightMax:
            nextWindowHeight = PhotoWindowHeightMax;
            break;
        default:
            break;
    }
    return nextWindowHeight;
}

- (void)panned:(UIPanGestureRecognizer *)panGesture {
    CGPoint translation = [panGesture translationInView:self.view];
    
    if (panGesture.state == UIGestureRecognizerStateBegan) {
    } else if (panGesture.state == UIGestureRecognizerStateChanged) {
        [self panWithTranslation:translation];
	} else if (panGesture.state == UIGestureRecognizerStateEnded) {
        [self panSnapIfRequired];
    }
    
    [panGesture setTranslation:CGPointZero inView:self.view];
}

- (void)panWithTranslation:(CGPoint)translation {
    CGFloat dragRatio = 0.5;
    CGFloat panOffset = ceilf(translation.y * dragRatio);
    CGRect contentFrame = self.contentContainerView.frame;
    contentFrame.origin.y += panOffset;
    
    // Adjust height of contentFrame.
    if (contentFrame.origin.y <= kWindowMinHeight) {
        contentFrame.origin.y = kWindowMinHeight;
    }
    contentFrame.size.height = self.view.bounds.size.height - contentFrame.origin.y;
    
    // Background image frame.
    CGRect imageFrame = self.backgroundImageView.frame;
    imageFrame.origin.y = floorf((contentFrame.origin.y - imageFrame.size.height) / 2.0) + kPhotoOffset;
    
    self.contentContainerView.frame = contentFrame;
    self.backgroundImageView.frame = imageFrame;
}

- (void)panSnapIfRequired {
    [self panSnapIfRequiredBounce:YES];
}

- (void)panSnapIfRequiredBounce:(BOOL)bounce {
    CGRect contentFrame = self.contentContainerView.frame;
    PhotoWindowHeight photoWindowHeight = PhotoWindowHeightMid;
    
    if (contentFrame.origin.y <= kWindowMinSnapOffset) {
        
        // Collapse photo to min height.
        photoWindowHeight = PhotoWindowHeightMin;
        
    } else if (contentFrame.origin.y > kWindowMaxSnapOffset) {
        
        // Expand photo.
        photoWindowHeight = PhotoWindowHeightMax;
        
    } else {
        
        // Restore to default mid.
        photoWindowHeight = PhotoWindowHeightMid;
    }
    
    // Snap animation.
    [self snapContentToPhotoWindowHeight:photoWindowHeight bounce:bounce completion:NULL];
}

- (void)snapContentToPhotoWindowHeight:(PhotoWindowHeight)photoWindowHeight {
    [self snapContentToPhotoWindowHeight:photoWindowHeight completion:NULL];
}

- (void)snapContentToPhotoWindowHeight:(PhotoWindowHeight)photoWindowHeight completion:(void (^)())completion {
    [self snapContentToPhotoWindowHeight:photoWindowHeight bounce:YES completion:completion];
}

- (void)snapContentToPhotoWindowHeight:(PhotoWindowHeight)photoWindowHeight bounce:(BOOL)bounce
                            completion:(void (^)())completion {
    
    // Disable bounce when going to full PhotoWindowHeight
    if (photoWindowHeight == PhotoWindowHeightFullScreen) {
        bounce = NO;
    }
    
    CGFloat snapDuration = 0.15;
    CGFloat bounceDuration = 0.2;
    CGFloat noBounceDuration = 0.2;
    
    // Remember previous/current state.
    self.previousPhotoWindowHeight = self.photoWindowHeight;
    self.photoWindowHeight = photoWindowHeight;
    
    // Target contentFrame to snap to.
    CGRect contentFrame = [self contentFrameForPhotoWindowHeight:photoWindowHeight];
    CGRect imageFrame = [self imageFrameForPhotoWindowHeight:photoWindowHeight];
    
    // Bounce?
    if (bounce) {
        
        // Figure out the required bounce in the same direction.
        CGFloat bounceOffset = kWindowBounceOffset;
        bounceOffset *= (self.photoWindowHeight > self.previousPhotoWindowHeight) ? 1.0 : -1.0;
        CGRect bounceFrame = contentFrame;
        bounceFrame.origin.y += bounceOffset;
        bounceFrame.size.height += kWindowBounceOffset; // Add the offset as height so we don't get a gap at bottom.
        
        CGRect imageBounceFrame = imageFrame;
        imageBounceFrame.origin.y += bounceOffset;
        
        // Animate to the contentFrame via a bounce.
        [UIView animateWithDuration:snapDuration
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.contentContainerView.frame = bounceFrame;
                             self.backgroundImageView.frame = imageBounceFrame;
                         }
                         completion:^(BOOL finished) {
                             
                             // Rest on the target contentFrame.
                             [UIView animateWithDuration:bounceDuration
                                                   delay:0.0
                                                 options:UIViewAnimationOptionCurveEaseIn
                                              animations:^{
                                                  self.contentContainerView.frame = contentFrame;
                                                  self.backgroundImageView.frame = imageFrame;
                                              }
                                              completion:^(BOOL finished) {
                                                  
                                                  // Update buttons when toggling between fullscreen modes.
                                                  if (self.previousPhotoWindowHeight == PhotoWindowHeightFullScreen
                                                      || self.photoWindowHeight == PhotoWindowHeightFullScreen) {
                                                      [self updateButtons];
                                                  }
                                                  
                                                  // Body scrollEnabled only in max content mode.
                                                  self.scrollView.scrollEnabled = (self.photoWindowHeight == PhotoWindowHeightMin);
                                                  
                                                  // Run completion block.
                                                  if (completion != NULL) {
                                                      completion();
                                                  }
                                                  
                                              }];
                         }];
        
    } else {
        
        // Animate to the contentFrame without a bounce.
        [UIView animateWithDuration:noBounceDuration
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.contentContainerView.frame = contentFrame;
                             self.backgroundImageView.frame = imageFrame;
                         }
                         completion:^(BOOL finished) {
                          
                              // Update buttons when toggling between fullscreen modes.
                              if (self.previousPhotoWindowHeight == PhotoWindowHeightFullScreen
                                  || self.photoWindowHeight == PhotoWindowHeightFullScreen) {
                                  [self updateButtons];
                              }
                              
                             // Body scrollEnabled only in max content mode.
                             self.scrollView.scrollEnabled = (self.photoWindowHeight == PhotoWindowHeightMin);
                             
                              // Run completion block.
                              if (completion != NULL) {
                                  completion();
                              }
                         }];
    }
    
}

- (CGRect)contentFrameForPhotoWindowHeight:(PhotoWindowHeight)photoWindowHeight {
    CGRect contentFrame = self.contentContainerView.frame;
    switch (photoWindowHeight) {
        case PhotoWindowHeightMin:
            contentFrame.origin.y = kWindowMinHeight;
            contentFrame.size.height = self.view.bounds.size.height - kWindowMinHeight;
            break;
        case PhotoWindowHeightMid:
            contentFrame.origin.y = kWindowMidHeight;
            contentFrame.size.height = self.view.bounds.size.height - kWindowMidHeight;
            break;
        case PhotoWindowHeightMax:
            contentFrame.origin.y = self.view.bounds.size.height - self.headerView.frame.size.height;
            contentFrame.size.height = self.view.bounds.size.height - kWindowMidHeight;
            break;
        case PhotoWindowHeightFullScreen:
            contentFrame.origin.y = self.view.bounds.size.height;
            contentFrame.size.height = self.view.bounds.size.height - kWindowMidHeight;
            break;
        default:
            contentFrame.origin.y = kWindowMidHeight;
            contentFrame.size.height = self.view.bounds.size.height - kWindowMidHeight;
            break;
    }
    return contentFrame;
}

- (CGRect)imageFrameForPhotoWindowHeight:(PhotoWindowHeight)photoWindowHeight {
    CGRect imageFrame = self.backgroundImageView.frame;
    switch (photoWindowHeight) {
        case PhotoWindowHeightMin:
            imageFrame.origin.y = floorf((kWindowMinHeight - imageFrame.size.height) / 2.0) + kPhotoOffset;
            break;
        case PhotoWindowHeightMid:
            imageFrame.origin.y = floorf((kWindowMidHeight - imageFrame.size.height) / 2.0) + kPhotoOffset;
            break;
        case PhotoWindowHeightMax:
            imageFrame.origin.y = floorf((self.view.bounds.size.height - self.headerView.frame.size.height - imageFrame.size.height) / 2.0) + kPhotoOffset;
            break;
        case PhotoWindowHeightFullScreen:
            imageFrame.origin.y = self.view.bounds.origin.y;
            break;
        default:
            imageFrame.origin.y = floorf((kWindowMidHeight - imageFrame.size.height) / 2.0) + kPhotoOffset;
            break;
    }
    return imageFrame;
}

- (void)initContentContainerView {
    [self.view addSubview:self.contentContainerView];
    
    // Register pan on the content container.
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
    panGesture.delegate = self;
    [self.contentContainerView addGestureRecognizer:panGesture];
    
    // Register swipes.
    UISwipeGestureRecognizer *upSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swiped:)];
    upSwipeGesture.delegate = self;
    upSwipeGesture.direction = UISwipeGestureRecognizerDirectionUp;
    [self.contentContainerView addGestureRecognizer:upSwipeGesture];
    
    UISwipeGestureRecognizer *downSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swiped:)];
    downSwipeGesture.delegate = self;
    downSwipeGesture.direction = UISwipeGestureRecognizerDirectionDown;
    [self.contentContainerView addGestureRecognizer:downSwipeGesture];
}

- (void)initHeaderView {
    CGFloat xOffset = 50.0;
    
    [self.contentContainerView addSubview:self.headerView];
    
    // Profile photo.
    CKUserProfilePhotoView *profilePhotoView = [[CKUserProfilePhotoView alloc] initWithUser:self.book.user
                                                                                profileSize:ProfileViewSizeSmall];
    self.profilePhotoView = profilePhotoView;
    
    // User name
    NSString *name = [self.book.user.name uppercaseString];
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    nameLabel.font = [Theme userNameFont];
    nameLabel.textColor = [Theme userNameColor];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.shadowOffset = CGSizeMake(0.0, 1.0);
    nameLabel.shadowColor = [UIColor whiteColor];
    nameLabel.text = name;
    [nameLabel sizeToFit];
    self.nameLabel = nameLabel;
    
    // Lay them out side-by-side.
    CGFloat photoNameOffset = 10.0;
    CGFloat combinedWidth = profilePhotoView.frame.size.width + 5.0 + nameLabel.frame.size.width;
    nameLabel.frame = (CGRect){
        floorf((self.headerView.bounds.size.width - combinedWidth) / 2.0) + profilePhotoView.frame.size.width + photoNameOffset,
        xOffset,
        nameLabel.frame.size.width,
        nameLabel.frame.size.height};
    profilePhotoView.frame = (CGRect){
        floorf((self.headerView.bounds.size.width - combinedWidth) / 2.0),
        nameLabel.center.y - floorf(profilePhotoView.frame.size.height / 2.0) - 2.0,
        profilePhotoView.frame.size.width,
        profilePhotoView.frame.size.height};
    [self.headerView addSubview:profilePhotoView];
    [self.headerView addSubview:nameLabel];
    
    // Category label for edit mode.
    CKLabel *categoryLabel = [[CKLabel alloc] initWithFrame:CGRectZero placeholder:@"CATEGORY" minSize:CGSizeZero];
    categoryLabel.font = [Theme userNameFont];
    categoryLabel.textColor = [Theme userNameColor];
    categoryLabel.placeholderFont = [Theme userNameFont];
    categoryLabel.placeholderColour = [Theme userNameColor];
    categoryLabel.textAlignment = NSTextAlignmentCenter;
    categoryLabel.backgroundColor = [UIColor clearColor];
    categoryLabel.shadowOffset = CGSizeMake(0.0, 1.0);
    categoryLabel.shadowColor = [UIColor whiteColor];
    categoryLabel.hidden = YES;
    [self.headerView addSubview:categoryLabel];
    self.categoryLabel = categoryLabel;
    [self setCategory:self.recipe.category.name];
    
    // Recipe title.
    CKLabel *titleLabel = [[CKLabel alloc] initWithFrame:CGRectZero placeholder:nil defaultText:@"RECIPE NAME"
                                                 minSize:CGSizeMake(kContentMaxWidth - xOffset, 0.0)];
    titleLabel.font = [Theme recipeNameFont];
    titleLabel.textColor = [Theme recipeNameColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
    titleLabel.shadowColor = [UIColor whiteColor];
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth;
    [self.headerView addSubview:titleLabel];
    self.titleLabel = titleLabel;
    [self setTitle:[self.recipe.name uppercaseString]];
    
    // Recipe story.
    CKLabel *storyLabel = [[CKLabel alloc] initWithFrame:CGRectZero placeholder:@"ABOUT THIS RECIPE"
                                                 minSize:CGSizeMake(kContentMaxWidth - xOffset, 0.0)];
    storyLabel.font = [Theme storyFont];
    storyLabel.textColor = [Theme storyColor];
    storyLabel.placeholderColour = storyLabel.textColor;
    storyLabel.placeholderFont = storyLabel.font;
    storyLabel.numberOfLines = 2;
    storyLabel.textAlignment = NSTextAlignmentCenter;
    storyLabel.backgroundColor = [UIColor clearColor];
    storyLabel.shadowOffset = CGSizeMake(0.0, 1.0);
    storyLabel.shadowColor = [UIColor whiteColor];
    storyLabel.userInteractionEnabled = NO;
    storyLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
    [self.headerView addSubview:storyLabel];
    self.storyLabel = storyLabel;
    [self setStory:self.recipe.story];

    // Register tap on headerView for tap expand.
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerTapped:)];
    tapGesture.delegate = self;
    [self.headerView addGestureRecognizer:tapGesture];
}

- (void)initScrollView {
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(self.contentContainerView.bounds.origin.x,
                                                                              self.headerView.frame.origin.y + self.headerView.frame.size.height,
                                                                              self.contentContainerView.bounds.size.width,
                                                                              self.contentContainerView.bounds.size.height - self.headerView.frame.size.height)];
    scrollView.backgroundColor = [Theme recipeViewBackgroundColour];
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight;
    scrollView.alwaysBounceVertical = YES;
    scrollView.delegate = self;
    scrollView.scrollEnabled = NO;
    [self.contentContainerView addSubview:scrollView];
    self.scrollView = scrollView;
    
    // Add content to the middle.
    self.contentView.frame = CGRectMake(floorf((scrollView.bounds.size.width - self.contentView.frame.size.width) / 2.0),
                                        0.0,
                                        self.contentView.frame.size.width,
                                        self.contentView.frame.size.height);
    scrollView.contentSize = self.contentView.bounds.size;
    [scrollView addSubview:self.contentView];
}

- (void)initContentView {
    
    // Content containerView.
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, kContentMaxWidth, 0.0)];
    contentView.backgroundColor = [UIColor clearColor];
    
    // Left Container: Serves + Divider + Ingredients
    UIView *leftContainerView = [[UIView alloc] initWithFrame:kContentLeftFrame];
    leftContainerView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    leftContainerView.backgroundColor = [UIColor clearColor];
    [contentView addSubview:leftContainerView];
    
    // Left Container: Serves & Cook
    self.servesCookView.frame = CGRectMake(kContentInsets.left,
                                           kContentInsets.top,
                                           leftContainerView.bounds.size.width - kContentInsets.left - kContentInsets.right,
                                           self.servesCookView.frame.size.height);
    [leftContainerView addSubview:self.servesCookView];
    
    // Left Container: Divider.
    UIImageView *dividerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_recipe_details_divider.png"]];
    dividerImageView.frame = CGRectMake(floorf((leftContainerView.bounds.size.width - dividerImageView.frame.size.width) / 2.0),
                                        self.servesCookView.frame.origin.y + self.servesCookView.frame.size.height + kLeftDividerGap,
                                        dividerImageView.frame.size.width,
                                        dividerImageView.frame.size.height);
    [leftContainerView addSubview:dividerImageView];
    self.servingIngredientsDividerView = dividerImageView;
    
    // Left Container: Ingredients.
    CGSize availableSize = CGSizeMake(leftContainerView.bounds.size.width - kContentInsets.left - kContentInsets.right,
                                      130.0);
    IngredientsView *ingredientsView = [[IngredientsView alloc] initWithIngredients:self.recipe.ingredients
                                                                               size:availableSize];
    ingredientsView.frame = CGRectMake(kContentInsets.left,
                                       self.servingIngredientsDividerView.frame.origin.y + self.servingIngredientsDividerView.frame.size.height + kLeftDividerGap,
                                       ingredientsView.frame.size.width,
                                       ingredientsView.frame.size.height);
    [leftContainerView addSubview:ingredientsView];
    self.ingredientsView = ingredientsView;
    
    // Update leftContainer frame.
    [self sizeToFitForColumnView:leftContainerView];
    
    // Right Container: Method
    UIView *rightContainerView = [[UIView alloc] initWithFrame:kContentRightFrame];
    rightContainerView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    rightContainerView.backgroundColor = [UIColor clearColor];
    [contentView addSubview:rightContainerView];
    
    // Right Frame.
    CGSize methodAvailableSize = CGSizeMake(rightContainerView.bounds.size.width - kContentInsets.left - kContentInsets.right, MAXFLOAT);
    NSAttributedString *storyDisplay = [self attributedTextForText:self.recipe.method font:[Theme methodFont] colour:[Theme methodColor]];
    CKLabel *methodLabel = [[CKLabel alloc] initWithFrame:CGRectZero placeholder:@"METHOD" minSize:CGSizeMake(150.0, 220.0)];
    methodLabel.numberOfLines = 0;
    methodLabel.lineBreakMode = NSLineBreakByWordWrapping;
    methodLabel.textAlignment = NSTextAlignmentLeft;
    methodLabel.backgroundColor = [UIColor clearColor];
    methodLabel.attributedText = storyDisplay;
    methodLabel.userInteractionEnabled = NO;
    CGSize size = [methodLabel sizeThatFits:methodAvailableSize];
    methodLabel.frame = CGRectMake(kContentInsets.left, kContentInsets.top, methodAvailableSize.width, size.height);
    [rightContainerView addSubview:methodLabel];
    self.methodLabel = methodLabel;
    
    // Update rightContainerView frame.
    [self sizeToFitForColumnView:rightContainerView];
    [self sizeToFitForDetailView:contentView];

    self.contentView = contentView;
}

- (void)initBackgroundImageView {
    [self.view insertSubview:self.backgroundImageView belowSubview:self.contentContainerView];
    
    // Top shadow.
    [self.view insertSubview:self.topShadowView aboveSubview:self.backgroundImageView];
    self.topShadowView.alpha = 0.0;
    
    // Register tap on background image for tap expand.
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(windowTapped:)];
    tapGesture.delegate = self;
    [self.backgroundImageView addGestureRecognizer:tapGesture];
}

- (void)headerTapped:(UITapGestureRecognizer *)tapGesture {
    PhotoWindowHeight photoWindowHeight = PhotoWindowHeightMid;
    switch (self.photoWindowHeight) {
        case PhotoWindowHeightMin:
            photoWindowHeight = PhotoWindowHeightMid;
            break;
        case PhotoWindowHeightMid:
            photoWindowHeight = PhotoWindowHeightMin;
            break;
        case PhotoWindowHeightMax:
            photoWindowHeight = PhotoWindowHeightMid;
            break;
        default:
            break;
    }
    [self snapContentToPhotoWindowHeight:photoWindowHeight];
}

- (void)windowTapped:(UITapGestureRecognizer *)tapGesture {
    PhotoWindowHeight photoWindowHeight = PhotoWindowHeightFullScreen;
    switch (self.photoWindowHeight) {
        case PhotoWindowHeightFullScreen:
            photoWindowHeight = self.previousPhotoWindowHeight;
            break;
        default:
            photoWindowHeight = photoWindowHeight;
            break;
    }
    
    [self snapContentToPhotoWindowHeight:photoWindowHeight];
}

- (void)updateButtons {
    [self updateButtonsWithAlpha:1.0];
}

- (void)hideButtons {
    [self updateButtonsWithAlpha:0.0];
}

- (void)updateButtonsWithAlpha:(CGFloat)alpha {
    if (!self.navContainerView) {
        UIView *navContainerView = [[UIView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x,
                                                                            self.view.bounds.origin.y,
                                                                            self.view.bounds.size.width,
                                                                            kNavContainerHeight)];
        navContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
        [self.view addSubview:navContainerView];
        self.navContainerView = navContainerView;
    }
    
    
    if (self.editMode) {
        self.cancelButton.alpha = 0.0;
        self.saveButton.alpha = 0.0;
        self.privacyView.alpha = 0.0;
        [self.navContainerView addSubview:self.cancelButton];
        [self.navContainerView addSubview:self.saveButton];
        [self.navContainerView addSubview:self.privacyView];
        
        // Photo label and its wrapping.
        self.photoLabel.alpha = 0.0;
        [self.backgroundImageView addSubview:self.photoLabel];
        [self.editingHelper wrapEditingView:self.photoLabel
                              contentInsets:UIEdgeInsetsMake(30.0, 30.0, 22.0, 40.0)
                                   delegate:self white:YES editMode:NO];
        
    } else {
        self.closeButton.alpha = 0.0;
        self.socialView.alpha = 0.0;
        self.editButton.alpha = 0.0;
        self.shareButton.alpha = 0.0;
        self.likeButton.alpha = 0.0;
        [self.navContainerView addSubview:self.closeButton];
        [self.navContainerView addSubview:self.socialView];
        [self.navContainerView addSubview:self.editButton];
        [self.navContainerView addSubview:self.shareButton];
        [self.navContainerView addSubview:self.likeButton];
    }
    
    // Buttons are hidden on full screen mode only.
    CGFloat buttonsVisibleAlpha = (self.photoWindowHeight == PhotoWindowHeightFullScreen) ? 0.0 : alpha;
    self.navContainerView.userInteractionEnabled = (buttonsVisibleAlpha != 0.0);
    
    // Get the edit wrapper for photoLabel.
    CKEditingTextBoxView *photoBoxView = [self.editingHelper textBoxViewForEditingView:self.photoLabel];
    
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.closeButton.alpha = self.editMode ? 0.0 : buttonsVisibleAlpha;
                         self.socialView.alpha = self.editMode ? 0.0 : buttonsVisibleAlpha;
                         self.editButton.alpha = self.editMode ? 0.0 : buttonsVisibleAlpha;
                         self.shareButton.alpha = self.editMode ? 0.0 : buttonsVisibleAlpha;
                         self.likeButton.alpha = self.editMode ? 0.0 : buttonsVisibleAlpha;
                         
                         self.cancelButton.alpha = self.editMode ? buttonsVisibleAlpha : 0.0;
                         self.privacyView.alpha = self.editMode ? buttonsVisibleAlpha : 0.0;
                         self.saveButton.alpha = self.editMode ? buttonsVisibleAlpha : 0.0;
                         self.photoLabel.alpha = self.editMode ? buttonsVisibleAlpha : 0.0;
                         photoBoxView.alpha = self.editMode ? buttonsVisibleAlpha : 0.0;
                         
                     }
                     completion:^(BOOL finished)  {
                         if (self.editMode) {
                             [self.closeButton removeFromSuperview];
                             [self.socialView removeFromSuperview];
                             [self.editButton removeFromSuperview];
                             [self.shareButton removeFromSuperview];
                             [self.likeButton removeFromSuperview];
                             
                             [UIView animateWithDuration:0.1
                                                   delay:0.0
                                                 options:UIViewAnimationOptionCurveEaseIn
                                              animations:^{
                                                  self.cancelButton.transform = CGAffineTransformIdentity;
                                                  self.saveButton.transform = CGAffineTransformIdentity;
                                              }
                                              completion:^(BOOL finished)  {
                                              }];
                         } else {
                             [self.cancelButton removeFromSuperview];
                             [self.saveButton removeFromSuperview];
                             [self.privacyView removeFromSuperview];
                             
                             // Unwrap editing wrapper.
                             [self.editingHelper unwrapEditingView:self.photoLabel];
                             [self.photoLabel removeFromSuperview];
                             
                             // Nil it so we can update its label.
                             _photoLabel = nil;
                         }
                     }];
}

- (void)closeTapped:(id)sender {
    [self hideButtons];
    self.view.backgroundColor = [UIColor clearColor];
    
    [self fadeOutBackgroundImageThenClose];
}

- (void)fadeOutBackgroundImageThenClose {
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.topShadowView.alpha = 0.0;
                         self.backgroundImageView.alpha = 0.0;
                     }
                     completion:^(BOOL finished)  {
                         [self.modalDelegate closeRequestedForBookModalViewController:self];
                     }];
}

- (void)editTapped:(id)sender {
    [self enableEditMode:YES];
}

- (void)shareTapped:(id)sender {
    DLog();
}

- (void)cancelTapped:(id)sender {
    if (self.addMode) {
        [self closeTapped:nil];
    } else {
        [self exitEditModeThenSave:NO];
    }
}

- (void)saveTapped:(id)sender {
    [self exitEditModeThenSave:YES];
}

- (void)loadPhoto {
    if ([self.recipe hasPhotos]) {
        [self.parsePhotoStore imageForParseFile:[self.recipe imageFile]
                                           size:self.backgroundImageView.bounds.size
                                     completion:^(UIImage *image) {
                                         [self loadImageViewWithPhoto:image];
        }];
    } else {
        
        // Load placeholder editing background based on book cover.
        [self loadImageViewWithPhoto:[CKBookCover recipeEditBackgroundImageForCover:self.book.cover]
                         placeholder:YES];
    }
    
}

- (void)loadImageViewWithPhoto:(UIImage *)image {
    [self loadImageViewWithPhoto:image placeholder:NO];
}

- (void)loadImageViewWithPhoto:(UIImage *)image placeholder:(BOOL)placeholder {
    self.backgroundImageView.alpha = 0.0;
    self.backgroundImageView.image = image;
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.topShadowView.alpha = placeholder ? 0.0 : 1.0;
                         self.backgroundImageView.alpha = 1.0;
                     }
                     completion:^(BOOL finished)  {
                         
                         // Set the background to be white opaque.
                         self.view.backgroundColor = [Theme recipeViewBackgroundColour];
                         
                     }];
}

- (void)initStartState {
    self.previousPhotoWindowHeight = PhotoWindowHeightFullScreen;
    self.photoWindowHeight = PhotoWindowHeightFullScreen;
    self.contentContainerView.frame = [self contentFrameForPhotoWindowHeight:self.photoWindowHeight];
    self.backgroundImageView.Frame = [self imageFrameForPhotoWindowHeight:self.photoWindowHeight];
    
    CGRect imageFrame = self.backgroundImageView.frame;
    imageFrame.origin.y = floorf((kWindowMidHeight - imageFrame.size.height) / 2.0);
    self.backgroundImageView.frame = imageFrame;
}

- (void)loadData {
    
    if (!self.addMode) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            
            self.socialView = [[CKRecipeSocialView alloc] initWithRecipe:self.recipe delegate:self];
            self.socialView.alpha = 0.0;
            [self.view addSubview:self.socialView];
            
            // Fade it in.
            [UIView animateWithDuration:0.4
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 self.socialView.alpha = 1.0;
                             }
                             completion:^(BOOL finished)  {
                             }];
        });
    }
}

- (BOOL)canEditRecipe {
    return ([self.book.user isEqual:[CKUser currentUser]]);
}

- (NSDictionary *)paragraphAttributesForFont:(UIFont *)font lineSpacing:(CGFloat)lineSpacing colour:(UIColor *)colour {
    NSLineBreakMode lineBreakMode = NSLineBreakByWordWrapping;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = lineBreakMode;
    paragraphStyle.lineSpacing = lineSpacing;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    
    return [NSDictionary dictionaryWithObjectsAndKeys:
            font, NSFontAttributeName,
            colour, NSForegroundColorAttributeName,
            paragraphStyle, NSParagraphStyleAttributeName,
            nil];
}

- (NSMutableAttributedString *)attributedTextForIngredients:(NSString *)text  {
    return [self attributedTextForText:text lineSpacing:5.0 font:[Theme ingredientsListFont] colour:[Theme ingredientsListColor]];
}

- (NSMutableAttributedString *)attributedTextForText:(NSString *)text font:(UIFont *)font colour:(UIColor *)colour {
    return [self attributedTextForText:text lineSpacing:10.0 font:font colour:colour];
}

- (NSMutableAttributedString *)attributedTextForText:(NSString *)text lineSpacing:(CGFloat)lineSpacing
                                                font:(UIFont *)font colour:(UIColor *)colour {
    text = [text length] > 0 ? text : @"";
    NSDictionary *paragraphAttributes = [self paragraphAttributesForFont:font lineSpacing:lineSpacing colour:colour];
    return [[NSMutableAttributedString alloc] initWithString:text attributes:paragraphAttributes];
}

- (PhotoWindowHeight)startWindowHeight {
    PhotoWindowHeight windowHeight = PhotoWindowHeightMid;
    if (self.addMode) {
        windowHeight = PhotoWindowHeightMax;
    } else if (![self.recipe hasPhotos]) {
        windowHeight = PhotoWindowHeightMin;
    }
    return windowHeight;
}

- (void)enableEditMode {
    [self enableEditMode:YES];
}

- (void)enableEditMode:(BOOL)enable {
    self.editMode = enable;
    
    // Prepare or discard recipe clipboard.
    [self prepareClipboard:enable];
    [self updateButtons];
    
    // Hide/show appropriate labels.
    self.profilePhotoView.hidden = enable;
    self.nameLabel.hidden = enable;
    self.categoryLabel.hidden = !enable;
    self.servingIngredientsDividerView.hidden = enable;
    
    // Set fields to be editable/non
    if (enable) {
        [self.editingHelper wrapEditingView:self.categoryLabel
                              contentInsets:UIEdgeInsetsMake(25.0, 30.0, 17.0, 38.0)
                                   delegate:self white:YES editMode:NO];
        [self.editingHelper wrapEditingView:self.titleLabel
                              contentInsets:UIEdgeInsetsMake(8.0, 20.0, 2.0, 20.0)
                                   delegate:self white:YES];
        [self.editingHelper wrapEditingView:self.storyLabel
                              contentInsets:UIEdgeInsetsMake(18.0, 20.0, 10.0, 20.0)
                                   delegate:self white:YES];
        [self.editingHelper wrapEditingView:self.servesCookView
                              contentInsets:UIEdgeInsetsMake(20.0, 30.0, 10.0, 30.0)
                                   delegate:self white:YES];
        [self.editingHelper wrapEditingView:self.ingredientsView
                              contentInsets:UIEdgeInsetsMake(20.0, 30.0, 10.0, 30.0)
                                   delegate:self white:YES];
        [self.editingHelper wrapEditingView:self.methodLabel
                              contentInsets:UIEdgeInsetsMake(25.0, 30.0, 2.0, 20.0)
                                   delegate:self white:YES];
    } else {
        [self.editingHelper unwrapEditingView:self.categoryLabel];
        [self.editingHelper unwrapEditingView:self.titleLabel];
        [self.editingHelper unwrapEditingView:self.storyLabel];
        [self.editingHelper unwrapEditingView:self.servesCookView];
        [self.editingHelper unwrapEditingView:self.ingredientsView];
        [self.editingHelper unwrapEditingView:self.methodLabel];
    }
}

- (void)setTitle:(NSString *)title {
    self.titleLabel.text = title;
    [self.titleLabel sizeToFit];
    self.titleLabel.frame = CGRectMake(floorf((self.headerView.bounds.size.width - self.titleLabel.frame.size.width) / 2.0),
                                       self.profilePhotoView.frame.origin.y + self.profilePhotoView.frame.size.height,
                                       self.titleLabel.frame.size.width,
                                       self.titleLabel.frame.size.height);
}

- (void)setCategory:(NSString *)category {
    self.categoryLabel.text = [category uppercaseString];
    [self.categoryLabel sizeToFit];
    self.categoryLabel.frame = CGRectMake(floorf((self.headerView.bounds.size.width - self.categoryLabel.frame.size.width) / 2.0),
                                          35.0,
                                          self.categoryLabel.frame.size.width,
                                          self.categoryLabel.frame.size.height);
}

- (void)setStory:(NSString *)story {
    CGFloat titleStoryGap = 0.0;
    self.storyLabel.text = story;
    [self.storyLabel sizeToFit];
    self.storyLabel.frame = CGRectMake(floorf((self.headerView.bounds.size.width - self.storyLabel.frame.size.width) / 2.0),
                                       self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + titleStoryGap,
                                       self.storyLabel.frame.size.width,
                                       self.storyLabel.frame.size.height);
}

- (void)setMethod:(NSString *)method {
    CGRect containerFrame = self.methodLabel.superview.bounds;
    CGRect methodFrame = self.methodLabel.frame;
    CGSize methodAvailableSize = CGSizeMake(containerFrame.size.width - kContentInsets.left - kContentInsets.right, MAXFLOAT);
    NSAttributedString *methodDisplay = [self attributedTextForText:method font:[Theme methodFont] colour:[Theme methodColor]];
    self.methodLabel.attributedText = methodDisplay;
    CGSize size = [self.methodLabel sizeThatFits:methodAvailableSize];
    methodFrame.size.height = size.height;
    self.methodLabel.frame = methodFrame;
    
    // Size the container view to fit.
    [self sizeToFitForColumnView:self.methodLabel.superview];
    [self sizeToFitForDetailView:self.contentView];
}

- (void)setIngredients:(NSArray *)ingredients {
    [self.ingredientsView setIngredients:ingredients];
    
    // Size the container view to fit.
    [self sizeToFitForColumnView:self.ingredientsLabel.superview];
    [self sizeToFitForDetailView:self.contentView];
}

- (void)setServes:(NSInteger)serves {
    UILabel *servesLabel = (UILabel *)[self.servesCookView viewWithTag:kServesTag];
    servesLabel.text = [self servesDisplayFor:serves];
    [servesLabel sizeToFit];
}

- (void)setPrepMinutes:(NSInteger)prepMinutes cookMinutes:(NSInteger)cookMinutes {
    UILabel *prepCookLabel = (UILabel *)[self.servesCookView viewWithTag:kPrepCookTag];
    prepCookLabel.text = [self prepCookDisplayForPrepMinutes:prepMinutes cookMinutes:cookMinutes];
    [prepCookLabel sizeToFit];
}

- (void)showPhotoPicker:(BOOL)show {
    [self showPhotoPicker:show completion:^{}];
}

- (void)showPhotoPicker:(BOOL)show completion:(void (^)())completion {
    if (show) {
        // Present photo picker fullscreen.
        UIView *rootView = [[AppHelper sharedInstance] rootView];
        CKPhotoPickerViewController *photoPickerViewController = [[CKPhotoPickerViewController alloc] initWithDelegate:self];
        self.photoPickerViewController = photoPickerViewController;
        self.photoPickerViewController.view.alpha = 0.0;
        [rootView addSubview:self.photoPickerViewController.view];
    }
    
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.photoPickerViewController.view.alpha = show ? 1.0 : 0.0;
                     }
                     completion:^(BOOL finished) {
                         if (!show) {
                             [self cleanupPhotoPicker];
                         }
                         completion();
                     }];
}

- (void)cleanupPhotoPicker {
    [self.photoPickerViewController.view removeFromSuperview];
    self.photoPickerViewController = nil;
}

- (void)saveTitleValue:(id)value {
    
    // Get updated value and update label.
    NSString *text = [(NSString *)value uppercaseString];
    self.clipboard.name = text;
    
    if (![text isEqualToString:self.recipe.name]) {
        
        // Update title.
        [self setTitle:text];
        
        // Mark save is required.
        self.saveRequired = YES;
        
        // Update the editing wrapper.
        [self.editingHelper updateEditingView:self.titleLabel animated:NO];
    }
}

- (void)saveCategoryValue:(id)value {
    
    CKCategory *selectedCategory = (CKCategory *)value;
    NSArray *categories = [self.editViewController updatedValue];
    
    // Check if category has changed.
    if (![selectedCategory.name isEqualToString:self.categoryLabel.text]) {
        
        // Save it in the clipboard too.
        self.clipboard.category = selectedCategory;
        
        // Mark save is required.
        self.saveRequired = YES;
        
        // Update category.
        [self setCategory:selectedCategory.name];
        
        // Update the editing wrapper.
        [self.editingHelper updateEditingView:self.categoryLabel animated:NO];
        
    }
    
    // Check if all categories need to be saved.
    if ([self categoriesNeedSaving:categories]) {
        
        // Save it in the clipboard first.
        self.clipboard.categories = categories;
        
        // Mark save is required.
        self.saveRequired = YES;
    }
    
}

- (void)saveStoryValue:(id)value {
    
    // Get updated value and update label.
    NSString *text = (NSString *)value;
    self.clipboard.story = text;
    
    if (![text isEqualToString:self.recipe.story]) {
        
        // Update title.
        [self setStory:text];
        
        // Mark save is required.
        self.saveRequired = YES;
        
        // Update the editing wrapper.
        [self.editingHelper updateEditingView:self.storyLabel animated:NO];
    }

}

- (void)saveServesPrepCookValue:(id)value {
    
    NSInteger serves = self.clipboard.serves;
    NSInteger prepMinutes = self.clipboard.prepMinutes;
    NSInteger cookMinutes = self.clipboard.cookMinutes;
    
    if (self.recipe.numServes != serves || self.recipe.prepTimeInMinutes != prepMinutes
        || self.recipe.cookingTimeInMinutes != cookMinutes) {
        
        [self setServes:self.clipboard.serves];
        [self setPrepMinutes:self.clipboard.prepMinutes cookMinutes:self.clipboard.cookMinutes];
        
        // Mark save is required.
        self.saveRequired = YES;
        
        // Update the editing wrapper.
        [self.editingHelper updateEditingView:self.servesCookView animated:NO];
    }
}

- (void)saveMethodValue:(id)value {
    
    // Get updated value and update label.
    NSString *text = (NSString *)value;
    self.clipboard.method = text;
    
    if (![text isEqualToString:self.recipe.method]) {
        
        // Update title.
        [self setMethod:text];
        
        // Mark save is required.
        self.saveRequired = YES;
        
        // Update the editing wrapper.
        [self.editingHelper updateEditingView:self.titleLabel animated:NO];
    }
    
}

- (void)saveIngredientsValue:(id)value {
    NSArray *ingredients = (NSArray *)value;
    self.clipboard.ingredients = ingredients;
    
    // Update ingredients.
    [self setIngredients:ingredients];
    
    // Mark as save required; figure out a way to not save without changes.
    self.saveRequired = YES;
    
    // Update the editing wrapper.
    [self.editingHelper updateEditingView:self.ingredientsLabel animated:NO];
}

- (void)exitEditModeThenSave:(BOOL)save {
    
    if (save) {
        
        // Save any changes off.
        if (self.saveRequired) {
            
            // Save form data to recipe.
            self.recipe.privacy = self.clipboard.privacyMode;
            self.recipe.name = self.clipboard.name;
            self.recipe.story = self.clipboard.story;
            self.recipe.method = self.clipboard.method;
            self.recipe.numServes = self.clipboard.serves;
            self.recipe.prepTimeInMinutes = self.clipboard.prepMinutes;
            self.recipe.cookingTimeInMinutes = self.clipboard.cookMinutes;
            self.recipe.ingredients = self.clipboard.ingredients;
            self.recipe.category = self.clipboard.category;
            
            // Reset edit flags.
            self.saveRequired = NO;
            [self enableEditMode:NO];
            
            // Saving...
            [self enableSaveMode:YES];
            
            // Show progress.
            CKProgressView *progressView = [[CKProgressView alloc] initWithWidth:300.0];
            progressView.frame = CGRectMake(floorf((self.headerView.bounds.size.width - progressView.frame.size.width) / 2.0),
                                            self.nameLabel.frame.origin.y,
                                            progressView.frame.size.width,
                                            progressView.frame.size.height);
            [self.headerView addSubview:progressView];
            self.progressView = progressView;
            
            // Mark 10% progress to start off with.
            [progressView setProgress:0.1];
            
            // Save categories first if we have changes.
            if ([self.clipboard.categories count] > 0) {
                
                [self.book saveCategories:self.clipboard.categories
                                  success:^{
                                      
                                      // Set categories progress done.
                                      [self.progressView setProgress:0.2 animated:YES];
                                      
                                      // Save off the recipe.
                                      [self saveRecipeWithImageStartProgress:0.2 endProgress:0.9];
                                      
                                  }
                                  failure:^(NSError *error) {
                                      [self enableSaveMode:NO];
                                  }];
                
            } else {
                
                // Save off the recipe.
                [self saveRecipeWithImageStartProgress:0.1 endProgress:0.9];
            }
            
        } else {
            
            // Reset edit flags.
            self.saveRequired = NO;
            [self enableEditMode:NO];
            
        }
        
    } else {
        
        // Restore value
        [self setTitle:self.recipe.name];
        [self setCategory:self.recipe.category.name];
        [self setStory:self.recipe.story];
        [self setMethod:self.recipe.method];
        [self setServes:self.recipe.numServes];
        [self setPrepMinutes:self.recipe.prepTimeInMinutes cookMinutes:self.recipe.cookingTimeInMinutes];
        [self setIngredients:self.recipe.ingredients];
        
        // Reset edit flags.
        self.saveRequired = NO;
        [self enableEditMode:NO];
    }
    
}

- (void)enableSaveMode:(BOOL)saveMode {
    self.profilePhotoView.hidden = saveMode;
    self.nameLabel.hidden = saveMode;
    self.saveInProgress = saveMode;
    self.editButton.hidden = saveMode;
    self.closeButton.hidden = saveMode;
    self.shareButton.hidden = saveMode;
    self.socialView.hidden = saveMode;
    if (!saveMode) {
        [self.progressView removeFromSuperview];
        self.progressView = nil;
    }
    self.saveInProgress = saveMode;
}

- (void)prepareClipboard:(BOOL)prepare {
    if (prepare) {
        self.clipboard = [[RecipeClipboard alloc] init];
        self.clipboard.privacyMode = self.recipe.privacy;
        self.clipboard.category = self.recipe.category;
        self.clipboard.name = self.recipe.name;
        self.clipboard.story = self.recipe.story;
        self.clipboard.method = self.recipe.method;
        self.clipboard.serves = self.recipe.numServes;
        self.clipboard.prepMinutes = self.recipe.prepTimeInMinutes;
        self.clipboard.cookMinutes = self.recipe.cookingTimeInMinutes;
        self.clipboard.ingredients = self.recipe.ingredients;
    } else {
        self.clipboard = nil;
    }
}

- (NSString *)servesDisplayFor:(NSInteger)serves {
    NSMutableString *servesDisplay = [NSMutableString stringWithString:@"Serves"];
    if (serves > 0) {
        [servesDisplay appendFormat:@" %d", serves];
    }
    return servesDisplay;
}

- (NSString *)prepCookDisplayForPrepMinutes:(NSInteger)prepMinutes cookMinutes:(NSInteger)cookMinutes {
    if (prepMinutes == 0 && cookMinutes == 0) {
        return @"Prep";
    } else {
        return [NSString stringWithFormat:@"Prep %dm | Cook %dm", prepMinutes, cookMinutes];
    }
}

- (void)sizeToFitForColumnView:(UIView *)containerView  {
    [self sizeToFitForContainerView:containerView
                             insets:(UIEdgeInsets){kContentInsets.top, 0.0, 0.0, kContentInsets.bottom}];
}

- (void)sizeToFitForDetailView:(UIView *)detailView  {
    [self sizeToFitForContainerView:detailView insets:UIEdgeInsetsZero];
    self.scrollView.contentSize = detailView.bounds.size;
}

- (void)sizeToFitForContainerView:(UIView *)containerView insets:(UIEdgeInsets)insets {
    CGRect containerFrame = containerView.frame;
    CGRect frame = CGRectZero;
    
    for (UIView *subview in containerView.subviews) {
        frame = CGRectUnion(frame, subview.frame);
    }
    
    containerFrame.size.height = frame.size.height;
    containerFrame.size.height += insets.top;
    containerFrame.size.height += insets.bottom;
    
    containerView.frame = containerFrame;
}

- (BOOL)categoriesNeedSaving:(NSArray *)categories {
    BOOL needSaving = NO;
    for (CKCategory *category in categories) {
        
        // Find the matching category in the list of existing categories.
        CKCategory *matchingCategory = [[self.book currentCategories] detect:^BOOL(CKCategory *existingCategory) {
            return [existingCategory.objectId isEqualToString:category.objectId];
        }];
        
        // If none was found, then we definitely need saving.
        // Otherwise check also if it has been renamed.
        if (matchingCategory == nil
            || ![matchingCategory.name isEqualToString:category.name]) {
            needSaving = YES;
            break;
        } 
    }
    return needSaving;
}

- (void)saveRecipeWithImageStartProgress:(CGFloat)startProgress endProgress:(CGFloat)endProgress {
    
    // Keep a weak reference of the progressView for tracking of updates.
    __weak CKProgressView *weakProgressView = self.progressView;
    
    [self.recipe saveWithImage:self.recipeImageToUpload startProgress:startProgress endProgress:endProgress
                      progress:^(int percentDone) {
                          [weakProgressView setProgress:(percentDone / 100.0) animated:YES];
                      }
                    completion:^{
                        
                        // Ask the opened book to relayout.
                        [[BookNavigationHelper sharedInstance] updateBookNavigationWithRecipe:self.recipe
                                                                                   completion:^{
                                                                                       
                                                                                       // Set 100% progress completion.
                                                                                       [weakProgressView setProgress:1.0 delay:0.5 completion:^{
                                                                                           [self enableSaveMode:NO];
                                                                                       }];
                                                                                   }];
                    }
                       failure:^(NSError *error) {
                           [self enableSaveMode:NO];
                       }];
}

- (void)showSocialOverlay:(BOOL)show {
    if (show) {
        [self hideButtons];
        self.bookSocialViewController = [[BookSocialViewController alloc] initWithRecipe:self.recipe delegate:self];
        self.bookSocialViewController.view.frame = self.view.bounds;
        self.bookSocialViewController.view.alpha = 0.0;
        [self.view addSubview:self.bookSocialViewController.view];
    }
    [UIView animateWithDuration:show? 0.3 : 0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.bookSocialViewController.view.alpha = show ? 1.0 : 0.0;
                     }
                     completion:^(BOOL finished) {
                         if (!show) {
                             [self.bookSocialViewController.view removeFromSuperview];
                             self.bookSocialViewController = nil;
                             [self updateButtons];
                         }
                     }];
}

@end
