//
//  RecipeDetailsViewController.m
//  SnappingScrollViewDemo
//
//  Created by Jeff Tan-Ang on 8/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "RecipeDetailsViewController.h"
#import "CKRecipe.h"
#import "CKRecipeImage.h"
#import "CKRecipePin.h"
#import "RecipeDetails.h"
#import "RecipeDetailsView.h"
#import "ViewHelper.h"
#import "CKBookCover.h"
#import "CKBook.h"
#import "ImageHelper.h"
#import "EventHelper.h"
#import "CKLikeView.h"
#import "CKPrivacySliderView.h"
#import "CKRecipeSocialView.h"
#import "CKEditingViewHelper.h"
#import "RecipeSocialViewController.h"
#import "RecipeShareViewController.h"
#import "Theme.h"
#import "CKPhotoPickerViewController.h"
#import "AppHelper.h"
#import "UIImage+ProportionalFill.h"
#import "NSString+Utilities.h"
#import "BookNavigationHelper.h"
#import "CKLocationManager.h"
#import "CKPhotoManager.h"
#import "CKActivityIndicatorView.h"
#import "RecipeImageView.h"
#import "ModalOverlayHelper.h"
#import "ProgressOverlayViewController.h"
#import "AnalyticsHelper.h"
#import "CKNavigationController.h"
#import "CKLocation.h"
#import "PinRecipeViewController.h"
#import "CKBookManager.h"
#import "ProfileViewController.h"
#import "RecipeFooterView.h"

typedef NS_ENUM(NSUInteger, SnapViewport) {
    SnapViewportTop,
    SnapViewportBottom,
    SnapViewportBelow
};

@interface RecipeDetailsViewController () <UIScrollViewDelegate, UIGestureRecognizerDelegate,
    CKRecipeSocialViewDelegate, RecipeSocialViewControllerDelegate, RecipeDetailsViewDelegate,
    CKEditingTextBoxViewDelegate, CKPhotoPickerViewControllerDelegate, CKPrivacySliderViewDelegate,
    RecipeImageViewDelegate, UIAlertViewDelegate, RecipeShareViewControllerDelegate, CKNavigationControllerDelegate,
    PinRecipeViewControllerDelegate>

@property (nonatomic, strong) CKRecipe *recipe;
@property (nonatomic, strong) CKUser *currentUser;
@property (nonatomic, strong) RecipeDetails *recipeDetails;
@property (nonatomic, strong) CKBook *book;
@property (nonatomic, weak) id<BookModalViewControllerDelegate> modalDelegate;

// Content and panning related.
@property (nonatomic, strong) UIScrollView *imageScrollView;
@property (nonatomic, strong) RecipeImageView *imageView;
@property (nonatomic, strong) CKActivityIndicatorView *activityView;
@property (nonatomic, strong) UIImageView *topShadowView;
@property (nonatomic, strong) UIView *placeholderHeaderView;    // Used to as white backing for the header until image fades in.
@property (nonatomic, strong) UIImageView *contentImageView;
@property (nonatomic, strong) RecipeDetailsView *recipeDetailsView;
@property (nonatomic, strong) RecipeFooterView *recipeFooterView;
@property (nonatomic, strong) UIImageView *recipeFooterDividerView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, assign) SnapViewport currentViewport;
@property (nonatomic, assign) SnapViewport previousViewport;
@property (nonatomic, assign) BOOL draggingDown;
@property (nonatomic, assign) BOOL animating;
@property (nonatomic, assign) BOOL pullingBottom;
@property (nonatomic, assign) BOOL zoomedLevel;

// Normal controls.
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *editButton;
@property (nonatomic, strong) UIButton *shareButton;
@property (nonatomic, strong) UIButton *pinButton;
@property (nonatomic, strong) CKLikeView *likeButton;
@property (nonatomic, strong) CKRecipeSocialView *socialView;

// Editing.
@property (nonatomic, assign) BOOL editMode;
@property (nonatomic, assign) BOOL addMode;
@property (nonatomic, assign) BOOL locatingInProgress;
@property (nonatomic, assign) BOOL isDeleteRecipeImage;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) CKPrivacySliderView *privacyView;
@property (nonatomic, strong) UIView *photoButtonView;
@property (nonatomic, strong) CKEditingViewHelper *editingHelper;
@property (nonatomic, strong) CKPhotoPickerViewController *photoPickerViewController;
@property (nonatomic, strong) ProgressOverlayViewController *saveOverlayViewController;

// Social layer.
@property (nonatomic, strong) CKNavigationController *cookNavigationController;
@property (nonatomic, strong) RecipeSocialViewController *socialViewController;

// Share layer.
@property (nonatomic, strong) RecipeShareViewController *shareViewController;

// Add layer.
@property (nonatomic, strong) PinRecipeViewController *pinRecipeViewController;

// Alerts
@property (nonatomic, strong) UIAlertView *cancelAlert;
@property (nonatomic, strong) UIAlertView *deleteAlert;
@property (nonatomic, strong) UIAlertView *pinAlert;

// Stats
@property (nonatomic, assign) BOOL liked;
@property (nonatomic, strong) CKRecipePin *recipePin;

// Close flag, to prevent hiding of things when view should be closed
@property (nonatomic, assign) BOOL isClosed;

@end

@implementation RecipeDetailsViewController

#define kButtonInsets       UIEdgeInsetsMake(26.0, 10.0, 15.0, 12.0)
#define kEditButtonInsets   UIEdgeInsetsMake(12.0, -9.0, -17.0, -9.0)
#define kSnapOffset         100.0
#define kBounceOffset       10.0
#define kContentTopOffset   80.0
#define kFooterTopGap       25.0
#define kFooterBottomGap    25.0
#define kDragRatio          0.9
#define kIconGap            18.0
#define kContentImageOffset (UIOffset){ 0.0, -13.0 }

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithRecipe:(CKRecipe *)recipe {
    return [self initWithRecipe:recipe book:recipe.book];
}

- (id)initWithRecipe:(CKRecipe *)recipe book:(CKBook *)book {
    if (self = [super init]) {
        self.recipe = recipe;
        self.book = book;   // Can be in a different book if pinned or liked.
        self.editingHelper = [[CKEditingViewHelper alloc] init];
        self.currentUser = [CKUser currentUser];
    }
    return self;
}

- (id)initWithBook:(CKBook *)book page:(NSString *)page {
    if (self = [self initWithRecipe:[CKRecipe recipeForBook:book page:page]]) {
        self.addMode = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    self.isClosed = NO;
    self.isDeleteRecipeImage = NO;
    [self initImageView];
    [self initScrollView];
    [self initRecipeDetails];
    
    // Register left screen edge for shortcut to close.
    UIScreenEdgePanGestureRecognizer *leftEdgeGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self
                                                                                                          action:@selector(screenEdgePanned:)];
    leftEdgeGesture.edges = UIRectEdgeLeft;
    leftEdgeGesture.delegate = self;
    [self.view addGestureRecognizer:leftEdgeGesture];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didBecomeInactive)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:[UIApplication sharedApplication]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSDictionary *dimensions = @{@"isOwner" : [NSString stringWithFormat:@"%i", ([[CKUser currentUser].objectId isEqualToString:self.recipe.user.objectId])]};
    [AnalyticsHelper trackEventName:@"Viewed recipe" params:dimensions];
}

#pragma mark - PinRecipeViewControllerDelegate methods

- (void)pinRecipeViewControllerCloseRequested{
    if (self.pinRecipeViewController) {
        [self showAddOverlay:NO];
    }
}

- (void)pinRecipeViewControllerPinnedWithRecipePin:(CKRecipePin *)recipePin {
    self.recipePin = recipePin;
    [self updatePinnedButton];
}

#pragma mark - CKNavigationControllerDelegate methods

- (void)cookNavigationControllerCloseRequested {
    if (self.socialViewController) {
        [self showSocialOverlay:NO];
    }
}

#pragma mark - BookModalViewController methods

- (void)setModalViewControllerDelegate:(id<BookModalViewControllerDelegate>)modalViewControllerDelegate {
    self.modalDelegate = modalViewControllerDelegate;
}

- (void)bookModalViewControllerWillAppear:(NSNumber *)appearNumber {
    
    // TODO Refactor and move this status bar light post to somewhere else. Notifications do not need this.
    if (!self.disableStatusBarUpdate) {
        [EventHelper postStatusBarChangeForLight:[appearNumber boolValue]];
    }
}

- (void)bookModalViewControllerDidAppear:(NSNumber *)appearNumber {
    DLog();
    
    if ([appearNumber boolValue]) {
        
        // Snap to the start viewport.
        [self snapToViewport:[self startViewPort] animated:YES completion:^{
            
            [self loadData];
            
            // Add mode?
            if (self.addMode) {
//                [self performSelector:@selector(enableEditModeWithoutInformingRecipeDetailsView) withObject:nil afterDelay:0.0];
                
                // No buttons to start off with in add-mode.
                [self updateButtonsWithAlpha:0.0];
                [self performSelector:@selector(enableEditMode) withObject:nil afterDelay:0.0];
            } else {
                [self updateButtons];
            }

        }];
        
    } else {
        
    }
}

#pragma mark - RecipeDetailsViewDelegate methods

- (void)recipeDetailsViewEditing:(BOOL)editing {
    
    // Fade cancel/save buttons.
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.cancelButton.alpha = editing ? 0.0 : 1.0;
                         self.saveButton.alpha = editing ? 0.0 : 1.0;
                         self.deleteButton.alpha = editing ? 0.0 : 1.0;
                     }
                     completion:^(BOOL finished)  {
                     }];
}

- (void)recipeDetailsViewUpdated {
    [self updateRecipeDetailsView];
}

- (BOOL)recipeDetailsViewAddMode {
    return self.addMode;
}

- (void)recipeDetailsProfileTapped:(ProfileViewController *)bookViewController {
    [self hideButtons];
    bookViewController.closeBlock = ^(BOOL isClosed){
        [self updateButtons];
    };
    [bookViewController showOverlayOnViewController:self];
}

#pragma mark - CKEditingTextBoxViewDelegate methods

- (void)editingTextBoxViewTappedForEditingView:(UIView *)editingView {
    
    // Photo picker
    if (editingView == self.photoButtonView) {
        [self snapToViewport:SnapViewportBelow animated:YES completion:^{
            [self showPhotoPicker:YES];
        }];
    }
}

- (void)editingTextBoxViewSaveTappedForEditingView:(UIView *)editingView {
}

#pragma mark - CKPhotoPickerViewControllerDelegate methods

- (void)photoPickerViewControllerSelectedImage:(UIImage *)image {
    
    // Present the image.
    [self loadImageViewWithPhoto:image];
    
    // Save photo to be uploaded.
    self.recipeDetails.image = image;
    
    // Close and revert to mid height.
    [self showPhotoPicker:NO completion:^{
        [self snapToViewport:SnapViewportBottom animated:YES];
    }];
}

- (void)photoPickerViewControllerCloseRequested {
    
    // Close and revert to mid height.
    [self showPhotoPicker:NO completion:^{
        [self snapToViewport:SnapViewportBottom animated:YES];
        
    }];
}

- (void)photoPickerViewControllerDeleteRequested
{
    [self loadImageViewWithPhoto:[CKBookCover recipeEditBackgroundImageForCover:self.book.cover]
                     placeholder:YES];
    self.recipeDetails.image = nil;
    self.recipeDetails.saveRequired = YES;
    self.isDeleteRecipeImage = YES;
}

#pragma mark - RecipeSocialViewControllerDelegate methods

- (void)recipeSocialViewControllerCloseRequested {
    [self showSocialOverlay:NO];
}

- (CKLikeView *)recipeSocialViewControllerLikeView {
    return self.likeButton;
}

#pragma mark - RecipeShareViewControllerDelegate method6s

- (void)recipeShareViewControllerCloseRequested {
    [self showShareOverlay:NO];
}

- (UIImage *)recipeShareViewControllerImageRequested {
    UIImage *image = nil;
    if ([self.recipe hasPhotos]) {
        image = self.imageView.image;
    }
    return image;
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

#pragma mark - CKPrivacySliderViewDelegate methods

- (void)privacySelectedPrivateForSliderView:(CKNotchSliderView *)sliderView {
    DLog(@"Selected Private Policy");
    self.recipeDetails.privacy = CKPrivacyPrivate;
    self.recipeDetails.location = nil;
    [self updateShareButton];
}

- (void)privacySelectedFriendsForSliderView:(CKNotchSliderView *)sliderView {
    DLog(@"Selected Friends Privacy");
    self.recipeDetails.privacy = CKPrivacyFriends;
    self.recipeDetails.location = nil;
    [self updateShareButton];
}

- (void)privacySelectedPublicForSliderView:(CKNotchSliderView *)sliderView {
    DLog(@"Selected Public Privacy");
    
    // Locating is in progress.
    if (self.locatingInProgress) {
        return;
    }
    self.locatingInProgress = YES;
    
    // Set it to public.
    self.recipeDetails.privacy = CKPrivacyPublic;
    
    [[CKLocationManager sharedInstance] requestForCurrentLocation:^(CKLocation *location) {
        
        // Remember the location that was returned.
        DLog(@"Got location %@", location);
        
        // Do we still want this to be public, user might have slid away while it is being located.
        if (sliderView.currentNotchIndex == CKPrivacyPublic) {
            self.recipeDetails.location = location;
        }
        
        self.locatingInProgress = NO;
    } failure:^(NSError *error) {
        
        DLog(@"Unable to get location %@", [error localizedDescription]);
        self.locatingInProgress = NO;
    }];
    
    [self updateShareButton];
}

#pragma mark - RecipeImageViewDelegate methods

- (BOOL)recipeImageViewShouldTapAtPoint:(CGPoint)point {
    BOOL shouldReceiveTouch = YES;
    CGPoint location = [self.imageView convertPoint:point toView:self.view];
    CGRect navFrame = self.view.bounds;
    navFrame.size.height = self.closeButton.frame.origin.y + self.closeButton.frame.size.height;
    
    if (self.editMode) {
        
        // No taps on edit mode.
        shouldReceiveTouch = NO;
        
    } else if (self.currentViewport != SnapViewportBelow
               && CGRectContainsPoint(navFrame, location)) {
        
        // No taps when not in fullscreen mode, and touch is in the nav area.
        shouldReceiveTouch = NO;
    }
    
    return shouldReceiveTouch;
}

- (void)recipeImageViewTapped {
    if (self.imageScrollView.zoomScale == 1.0) {
        [self toggleImage];
    }
}

- (void)recipeImageViewDoubleTappedAtPoint:(CGPoint)point {
    CGFloat scale = (self.imageScrollView.zoomScale == 1.0) ? 2.0 : 1.0;
    CGRect zoomFrame = [self zoomFrameForScale:scale withCenter:point];
    [self.imageScrollView zoomToRect:zoomFrame animated:YES];
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    BOOL shouldReceiveTouch = YES;
    return shouldReceiveTouch;
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    return YES;
}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    NSLog(@"contentOffset %f", scrollView.contentOffset.y);
//    NSLog(@"scrollView.frame.origin.y %f", scrollView.frame.origin.y);
    
    if (scrollView != self.scrollView) {
        return;
    }
    
    CGRect contentFrame = self.scrollView.frame;
    CGSize contentSize = self.scrollView.contentSize;
    CGPoint contentOffset = scrollView.contentOffset;
    self.pullingBottom = NO;
    
    // Scroll view is now pulling its own frame down.
    if (!self.scrollView.decelerating && contentOffset.y <= 0) {
        
        // Dragging myself down.
        contentFrame.origin.y -= contentOffset.y * kDragRatio;
        contentFrame.origin.y = MIN([self offsetForViewport:SnapViewportBottom], contentFrame.origin.y);
        self.scrollView.frame = contentFrame;
        [self updateDependentViews];
        self.draggingDown = YES;
        
    } else if (self.draggingDown) {
        
        // Maintain contentOffset to stay fixed at top while dragging down.
        CGRect bounds = self.scrollView.bounds;
        bounds.origin.y = 0.0;
        self.scrollView.bounds = bounds;
        
        // If drag up while dragging down, also move the panel up with it.
        if (contentOffset.x >= 0) {
            contentFrame.origin.y -= contentOffset.y * kDragRatio;
            contentFrame.origin.y = MAX([self offsetForViewport:SnapViewportTop], contentFrame.origin.y);
            self.scrollView.frame = contentFrame;
            [self updateDependentViews];
        }
        
    } else if (contentOffset.y > contentSize.height - contentFrame.size.height) {
        self.pullingBottom = YES;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
//    NSLog(@"scrollViewWillBeginDragging");
//    NSLog(@"scrollEnabled: %@", scrollView.scrollEnabled ? @"YES" : @"NO");
//    NSLog(@"panGesture   : %@", self.panGesture.enabled ? @"YES" : @"NO");
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
//    NSLog(@"scrollViewDidEndDragging willDecelerate[%@]", decelerate ? @"YES" : @"NO");
    if (scrollView != self.scrollView) {
        return;
    }
    
    if (!self.pullingBottom) {
        [self panSnapIfRequired];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//    NSLog(@"scrollViewDidEndDecelerating");
    
    if (scrollView != self.scrollView) {
        return;
    }
    
    if (!self.pullingBottom) {
        [self panSnapIfRequired];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
//    NSLog(@"scrollViewDidEndScrollingAnimation");
    
    if (scrollView != self.scrollView) {
        return;
    }
    
    if (!self.pullingBottom) {
        [self panSnapIfRequired];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
//    NSLog(@"scrollViewWillEndDragging velocity[%@]", NSStringFromCGPoint(velocity));
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    if (scrollView == self.imageScrollView) {
        return self.imageView;
    } else {
        return nil;
    }
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    if (scrollView == self.imageScrollView) {
        self.zoomedLevel = (scrollView.zoomScale == 2.0);
    }
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale {
    if (scrollView == self.imageScrollView && scale == 1.0 && !self.zoomedLevel) {
        [self toggleImage];
    }
}

#pragma mark - UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (alertView == self.deleteAlert && buttonIndex == 1) {
        
        // OK Button tapped on delete.
        [self deleteRecipe];
        
    } else if (alertView == self.cancelAlert) {
        
        if (buttonIndex == 1) {
            //Close tapped
            if (self.addMode) {
                [self closeRecipeView];
            } else {
                [self initRecipeDetails];
                [self enableEditMode:NO];
            }
        }
        
    } else if (alertView == self.pinAlert && buttonIndex == 1) {
        
        // OK Button tapped on remove pin.
        [self deletePin];
        
    }
        
    // Clear alerts.
    self.pinAlert = nil;
    self.cancelAlert = nil;
    self.deleteAlert = nil;
}

#pragma mark - KVO methods

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change
                        context:(void *)context {
    
	if (object == self.scrollView && [keyPath isEqualToString:@"frame"]) {
        [self updateDependentViews];
	} else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - Properties

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [ViewHelper buttonWithImage:[UIImage imageNamed:@"cook_book_inner_icon_back_light.png"]
                                     selectedImage:[UIImage imageNamed:@"cook_book_inner_icon_back_light_onpress.png"]
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
                                    selectedImage:[UIImage imageNamed:@"cook_book_inner_icon_edit_light_onpress.png"]
                                           target:self
                                         selector:@selector(editTapped:)];
        _editButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin;
        _editButton.frame = CGRectMake(self.shareButton.frame.origin.x - kIconGap - _editButton.frame.size.width,
                                       kButtonInsets.top,
                                       _editButton.frame.size.width,
                                       _editButton.frame.size.height);
    }
    return _editButton;
}

- (UIButton *)shareButton {
    if (!_shareButton && [self.recipe isShareable]) {
        
        BOOL private = [self.recipe isPrivate];
        UIImage *shareImage = private ? [UIImage imageNamed:@"cook_book_inner_icon_secret_light.png"] : [UIImage imageNamed:@"cook_book_inner_icon_share_light.png"];
        UIImage *shareImageSelected = private ? [UIImage imageNamed:@"cook_book_inner_icon_secret_light_onpress.png"] : [UIImage imageNamed:@"cook_book_inner_icon_share_light_onpress.png"];
        _shareButton = [ViewHelper buttonWithImage:shareImage
                                     selectedImage:shareImageSelected
                                            target:private ?  nil : self
                                          selector:private ? nil : @selector(shareTapped:)];
        _shareButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin;
        _shareButton.frame = CGRectMake(self.view.frame.size.width - kButtonInsets.right - _shareButton.frame.size.width,
                                        kButtonInsets.top,
                                        _shareButton.frame.size.width,
                                        _shareButton.frame.size.height);
        
    }
    return _shareButton;
}

- (CKLikeView *)likeButton {
    if (!_likeButton && ![self.recipe isOwner]) {
        _likeButton = [[CKLikeView alloc] initWithRecipe:self.recipe];
        _likeButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin;
        _likeButton.frame = [self resolveFrameForLikeButton:_likeButton];
    }
    return _likeButton;
}

- (UIButton *)pinButton {
    if (!_pinButton && ![self.recipe isOwner] && [self.recipe isPublic]) {
        _pinButton = [ViewHelper buttonWithImage:[self imageForPinned:NO]
                                   selectedImage:[self imageForPinnedOnpress:NO]
                                          target:self
                                        selector:@selector(pinTapped:)];
        _pinButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin;
        
        if (self.shareButton) {
            _pinButton.frame = CGRectMake(self.shareButton.frame.origin.x - kIconGap - _pinButton.frame.size.width,
                                          kButtonInsets.top,
                                          _pinButton.frame.size.width,
                                          _pinButton.frame.size.height);
        } else {
            _pinButton.frame = CGRectMake(self.view.frame.size.width - kButtonInsets.right - _pinButton.frame.size.width,
                                          kButtonInsets.top,
                                          _pinButton.frame.size.width,
                                          _pinButton.frame.size.height);
        }
    }
    return _pinButton;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [ViewHelper cancelButtonWithTarget:self selector:@selector(cancelTapped:)];
        _cancelButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
        [_cancelButton setFrame:CGRectMake(kEditButtonInsets.left,
                                           kEditButtonInsets.top,
                                           _cancelButton.frame.size.width,
                                           _cancelButton.frame.size.height)];
    }
    return _cancelButton;
}

- (UIButton *)saveButton {
    if (!_saveButton) {
        _saveButton = [ViewHelper okButtonWithTarget:self selector:@selector(saveTapped:)];
        _saveButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin;
        [_saveButton setFrame:CGRectMake(self.view.bounds.size.width - _saveButton.frame.size.width - kEditButtonInsets.right,
                                         kEditButtonInsets.top,
                                         _saveButton.frame.size.width,
                                         _saveButton.frame.size.height)];
    }
    return _saveButton;
}

- (UIButton *)deleteButton {
    if (!_deleteButton && !self.addMode) {
        _deleteButton = [ViewHelper deleteButtonWithTarget:self selector:@selector(deleteTapped:)];
        _deleteButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin;
        [_deleteButton setFrame:CGRectMake(self.view.bounds.size.width - _deleteButton.frame.size.width - kEditButtonInsets.right,
                                           self.view.bounds.size.height - _deleteButton.frame.size.height - kEditButtonInsets.bottom,
                                           _deleteButton.frame.size.width,
                                           _deleteButton.frame.size.height)];
    }
    return _deleteButton;
}

- (CKRecipeSocialView *)socialView {
    if (!_socialView) {
        _socialView = [[CKRecipeSocialView alloc] initWithRecipe:self.recipe delegate:self];;
    }
    return _socialView;
}

- (UIView *)photoButtonView {
    if (!_photoButtonView) {
        
        UIImageView *cameraImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_customise_icon_photo.png"]];
        CGRect cameraImageFrame = cameraImageView.frame;
        
        UILabel *photoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        photoLabel.font = [Theme editPhotoFont];
        photoLabel.textColor = [Theme editPhotoColour];
        photoLabel.textAlignment = NSTextAlignmentCenter;
        photoLabel.backgroundColor = [UIColor clearColor];
        photoLabel.text = @"PHOTO";
        [photoLabel sizeToFit];
        CGRect photoLabelFrame = photoLabel.frame;
        photoLabelFrame = (CGRect){
            cameraImageView.frame.origin.x + cameraImageView.frame.size.width + 6.0,
            floorf((cameraImageView.frame.size.height - photoLabel.frame.size.height) / 2.0) + 2.0,
            photoLabel.frame.size.width,
            photoLabel.frame.size.height
        };
        photoLabel.frame = photoLabelFrame;
        
        UIEdgeInsets contentInsets = (UIEdgeInsets){
            0.0, 0.0, 0.0, 0.0
        };
        CGRect frame = CGRectUnion(cameraImageView.frame, photoLabel.frame);
        _photoButtonView = [[UIView alloc] initWithFrame:frame];
        _photoButtonView.backgroundColor = [UIColor clearColor];
        [_photoButtonView addSubview:cameraImageView];
        [_photoButtonView addSubview:photoLabel];
        cameraImageFrame.origin.x += contentInsets.left;
        cameraImageFrame.origin.y += contentInsets.top;
        photoLabelFrame.origin.x += contentInsets.left;
        photoLabelFrame.origin.y += contentInsets.top;
        frame.size.height += contentInsets.top + contentInsets.bottom;
        frame.size.width += contentInsets.left + contentInsets.right;
        cameraImageView.frame = cameraImageFrame;
        photoLabel.frame = photoLabelFrame;
        _photoButtonView.frame = frame;
        
        // Disable interaction for CKEditing to take over.
        _photoButtonView.userInteractionEnabled = NO;
    }
    return _photoButtonView;
}

- (CKPrivacySliderView *)privacyView {
    if (!_privacyView) {
        _privacyView = [[CKPrivacySliderView alloc] initWithDelegate:self];
        _privacyView.frame = (CGRect){
            floorf((self.view.bounds.size.width - _privacyView.frame.size.width) / 2.0),
            kButtonInsets.top - 14.0,
            _privacyView.frame.size.width,
            _privacyView.frame.size.height};
    }
    return _privacyView;
}

#pragma mark - Background notification methods

- (void)didBecomeInactive {
    //If backgrounding, remove photo picker to prevent crash
    if (self.photoPickerViewController)
    {
        [self showPhotoPicker:NO];
    }
}

#pragma mark - Private methods

- (void)initImageView {
    
    UIOffset motionOffset = [ViewHelper standardMotionOffset];
    
    UIScrollView *imageScrollView = [[UIScrollView alloc] initWithFrame:(CGRect){
        self.view.bounds.origin.x - motionOffset.horizontal,
        self.view.bounds.origin.y - motionOffset.vertical,
        self.view.bounds.size.width + (motionOffset.horizontal * 2.0),
        self.view.bounds.size.height + (motionOffset.vertical * 2.0)
    }];
    imageScrollView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    imageScrollView.contentSize = imageScrollView.bounds.size;
    imageScrollView.alwaysBounceHorizontal = YES;
    imageScrollView.alwaysBounceVertical = YES;
    imageScrollView.maximumZoomScale = 1.0; // 1 to start off with, then toggled to 2 in fullscreen mode.
    imageScrollView.minimumZoomScale = 1.0;
    imageScrollView.bouncesZoom = YES;   // Allow more than zoom scale but bounces back.
    imageScrollView.delegate = self;
    imageScrollView.scrollEnabled = NO;    // Not scrollable to start off with.
    [self.view addSubview:imageScrollView];
    self.imageScrollView = imageScrollView;
    
    RecipeImageView *imageView = [[RecipeImageView alloc] initWithFrame:self.imageScrollView.bounds];
    imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    imageView.alpha = 0.0;
    imageView.userInteractionEnabled = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.delegate = self;
    [self.imageScrollView addSubview:imageView];
    self.imageView = imageView;
    
    // Top shadow view.
    self.topShadowView = [ViewHelper topShadowViewForView:self.view subtle:YES];
    self.topShadowView.alpha = 0.0;
    [self.view insertSubview:self.topShadowView aboveSubview:self.imageView];
    
    // Photo button to be hidden for editMode.
    CGRect photoButtonFrame = self.photoButtonView.frame;
    photoButtonFrame.origin = (CGPoint){
        floorf((imageView.bounds.size.width - photoButtonFrame.size.width) / 2.0),
        floorf((imageView.bounds.size.height - photoButtonFrame.size.height) / 2.0)
    };
    self.photoButtonView.frame = photoButtonFrame;
    self.photoButtonView.alpha = [self currentAlphaForPhotoButtonView];
    self.photoButtonView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin;
    [self.imageView addSubview:self.photoButtonView];
    
    // Activity spinner at the center.
    self.activityView = [[CKActivityIndicatorView alloc] initWithStyle:CKActivityIndicatorViewStyleSmall];
    self.activityView.hidesWhenStopped = YES;
    self.activityView.center = self.imageView.center;
    self.activityView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin;
    [self.imageScrollView addSubview:self.activityView];
    
    // Motion effects.
    [ViewHelper applyDraggyMotionEffectsToView:self.imageScrollView];
}

- (void)initScrollView {
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:(CGRect){
        self.view.bounds.origin.x,
        self.view.bounds.origin.y,
        self.view.bounds.size.width,
        self.view.bounds.size.height - [self offsetForViewport:SnapViewportTop]
    }];
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    scrollView.alwaysBounceVertical = YES;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.delegate = self;
//    scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    scrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;
    
    // Build the same sized backgroundView to follow the scrollView along in the back.
    UIImage *contentBackgroundImage = [[UIImage imageNamed:@"cook_book_recipe_background_tile.png"]
                                       resizableImageWithCapInsets:(UIEdgeInsets){
                                           228.0, 1.0, 1.0, 1.0
                                       }];
    UIImageView *contentImageView = [[UIImageView alloc] initWithFrame:(CGRect){
        self.scrollView.frame.origin.x,
        self.scrollView.frame.origin.y - kContentTopOffset,
        self.scrollView.frame.size.width,
        self.scrollView.frame.size.height + kContentTopOffset   // Needs this offset to compensate for top.
    }];
    contentImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    contentImageView.image = contentBackgroundImage;
    [self.view insertSubview:contentImageView belowSubview:self.scrollView];
    self.contentImageView = contentImageView;
    
    // Register a concurrent panGesture to drag panel up and down.
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
    panGestureRecognizer.delegate = self;
    [scrollView addGestureRecognizer:panGestureRecognizer];
    self.panGesture = panGestureRecognizer;
    
    // Start observing the frame of scrollView.
    // [scrollView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
    
    // Start at bottom viewport.
    [self snapToViewport:SnapViewportBelow animated:NO];
}

- (void)updateDependentViews {
    CGRect contentFrame = self.scrollView.frame;
    
    // Update imageScrollView/imageView.
    CGRect imageScrollViewFrame = self.imageScrollView.frame;
    imageScrollViewFrame.origin.y = (contentFrame.origin.y - imageScrollViewFrame.size.height) / 2.0;
    self.imageScrollView.frame = imageScrollViewFrame;
    
    // Fade in/out photo button if in edit mode.
    if (self.editMode) {
        CGFloat requiredAlpha = [self currentAlphaForPhotoButtonView];
        self.photoButtonView.alpha = requiredAlpha;
        CKEditingTextBoxView *photoBoxView = [self.editingHelper textBoxViewForEditingView:self.photoButtonView];
        photoBoxView.alpha = requiredAlpha;
    }
    
    // Fade in/out activity view.
    if (!self.activityView.hidden) {
        CGFloat requiredAlpha = [self currentAlphaForPhotoButtonView];
        self.activityView.alpha = requiredAlpha;
    }
    
    // Update backgroundImageView.
    CGRect contentBackgroundFrame = self.contentImageView.frame;
    contentBackgroundFrame.origin.y = contentFrame.origin.y + kContentImageOffset.vertical;
    self.contentImageView.frame = contentBackgroundFrame;
}

- (void)loadData {
    [self loadPhoto];
    
    // Get stats and log pageView.
    self.pinButton.enabled = NO;
    self.likeButton.enabled = NO;
    
    if ([self.recipe persisted]) {
        [self.recipe infoAndViewedWithCompletion:^(BOOL liked, CKRecipePin *recipePin) {
            self.liked = liked;
            self.recipePin = recipePin;
            DLog(@"Recipe liked[%@] pinned[%@]", [NSString CK_stringForBoolean:self.liked], [NSString CK_stringForBoolean:(self.recipePin != nil)])
            
            [self updatePinnedButton];
            [self.likeButton markAsLiked:self.liked];
            
            self.pinButton.enabled = self.currentUser ? YES : NO;
            self.likeButton.enabled = self.currentUser ? YES : NO;
            
        } failure:^(NSError *error) {
            // Ignore error.
        }];
    }
}

- (void)loadPhoto {
    
    // Load placeholder first.
    [self loadImageViewWithPhoto:[CKBookCover recipeEditBackgroundImageForCover:self.book.cover]
                     placeholder:YES];
    
    if ([self.recipe hasPhotos]) {
        
        // Start the spinner.
        [self.activityView startAnimating];
        
        [[CKPhotoManager sharedInstance] imageForRecipe:self.recipe size:self.imageView.bounds.size name:@"RecipePhoto"
                                               progress:^(CGFloat progressRatio, NSString *name) {
                                               } thumbCompletion:^(UIImage *thumbImage, NSString *name) {
                                                   
                                                   [self loadImageViewWithPhoto:thumbImage placeholder:NO];
                                                   
                                               } completion:^(UIImage *image, NSString *name) {
                                                   
                                                   [self loadImageViewWithPhoto:image placeholder:NO];
                                                   
                                                   // Stop spinner.
                                                   [self.activityView stopAnimating];
                                               }];
    } else {
        
        if ([self.modalDelegate respondsToSelector:@selector(fullScreenLoadedForBookModalViewController:)] && !self.isClosed) {
            [self.modalDelegate fullScreenLoadedForBookModalViewController:self];
        }
    }
    
}

- (void)loadImageViewWithPhoto:(UIImage *)image {
    [self loadImageViewWithPhoto:image placeholder:NO];
}

- (void)loadImageViewWithPhoto:(UIImage *)image placeholder:(BOOL)placeholder {
    self.imageView.image = image;
    self.imageView.placeholder = placeholder;
    self.topShadowView.image = [ViewHelper topShadowImageSubtle:placeholder];
    
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.topShadowView.alpha = 1.0;
                         self.imageView.alpha = 1.0;
                         self.placeholderHeaderView.alpha = 0.0;
                     }
                     completion:^(BOOL finished)  {
                         [self.placeholderHeaderView removeFromSuperview];
                         self.placeholderHeaderView = nil;
                         
                         // Inform delegate fullscreen has been loaded.
                         if ([self.modalDelegate respondsToSelector:@selector(fullScreenLoadedForBookModalViewController:)] && !self.isClosed) {
                             [self.modalDelegate fullScreenLoadedForBookModalViewController:self];
                         }
                         
                     }];
}

- (void)snapToViewport:(SnapViewport)viewport  {
    [self snapToViewport:viewport animated:YES];
}

- (void)snapToViewport:(SnapViewport)viewport animated:(BOOL)animated {
    [self snapToViewport:viewport animated:animated completion:nil];
}

- (void)snapToViewport:(SnapViewport)viewport completion:(void (^)())completion {
    [self snapToViewport:viewport animated:YES completion:completion];
}

- (void)snapToViewport:(SnapViewport)viewport animated:(BOOL)animated completion:(void (^)())completion {
//    NSLog(@"snapToViewport [%d] fromViewport[%d]", viewport, self.currentViewport);
    
    // Set the required offset for the given viewport.
    CGRect frame = self.scrollView.frame;
    frame.origin.y = [self offsetForViewport:viewport];
    
    // Scroll enabled at the given viewport?
    BOOL scrollEnabled = [self scrollEnabledAtViewport:viewport];
    
    // Pan gesture enabled at the given viewport?
    BOOL panEnabld = [self panEnabledAtViewport:viewport];
    
    SnapViewport currentViewport = self.currentViewport;
    
    // Determine if a bounce is required.
    CGRect bounceFrame = [self bounceFrameFromViewport:currentViewport toViewport:viewport];
    BOOL bounceRequired = !CGRectIsEmpty(bounceFrame);
    UIOffset buttonBounceOffset = [self buttonsBounceOffsetFromViewport:currentViewport toViewport:viewport];
    
    // Remember previous and current viewports.
    self.currentViewport = viewport;
    self.previousViewport = currentViewport;
    
    if (animated) {
        
        if (bounceRequired) {
            
            CGFloat bounceDuration = [self animationDurationFromViewport:currentViewport toViewport:viewport];
            
            // Do a bounce.
            [UIView animateWithDuration:bounceDuration
                                  delay:0.0
                                options:[self animationCurveFromViewport:currentViewport toViewport:viewport]
                             animations:^{
                                 
                                 self.scrollView.frame = bounceFrame;
                                 [self updateDependentViews];
                                 
                                 [self updateButtonsWithBounceOffset:buttonBounceOffset];
                             }
                             completion:^(BOOL finished) {
                                 
                                 // Rest on intended frame.
                                 [UIView animateWithDuration:0.1
                                                       delay:0.0
                                                     options:UIViewAnimationOptionCurveEaseIn
                                                  animations:^{
                                                      
                                                      self.scrollView.frame = frame;
                                                      [self updateDependentViews];
                                                      
                                                      [self updateButtonsWithBounceOffset:UIOffsetZero];
                                                  }
                                                  completion:^(BOOL finished) {
                                                      self.scrollView.scrollEnabled = scrollEnabled;
                                                      self.panGesture.enabled = panEnabld;
                                                      self.draggingDown = NO;
                                                      
                                                      if (completion != nil) {
                                                          completion();
                                                      }
                                                  }];
                             }];
        } else {
            
            CGFloat duration = [self animationDurationFromViewport:currentViewport toViewport:viewport];
            
            [UIView animateWithDuration:duration
                                  delay:0.0
                                options:[self animationCurveFromViewport:currentViewport toViewport:viewport]
                             animations:^{
                                 
                                 self.scrollView.frame = frame;
                                 [self updateDependentViews];
                             }
                             completion:^(BOOL finished) {
                                 self.scrollView.scrollEnabled = scrollEnabled;
                                 self.panGesture.enabled = panEnabld;
                                 self.draggingDown = NO;
                                 if (completion != nil) {
                                     completion();
                                 }
                             }];
        }
        
    } else {
        self.scrollView.frame = frame;
        [self updateDependentViews];
        self.scrollView.scrollEnabled = scrollEnabled;
        self.panGesture.enabled = panEnabld;
        self.draggingDown = NO;
        if (completion != nil) {
            completion();
        }
    }
}

- (UIViewAnimationOptions)animationCurveFromViewport:(SnapViewport)fromViewport toViewport:(SnapViewport)toViewport {
    UIViewAnimationOptions animationCurve = UIViewAnimationOptionCurveEaseIn;
    if (toViewport == SnapViewportTop) {
        
        // Fast to top.
        animationCurve = UIViewAnimationOptionCurveEaseOut;
        
    } else if (toViewport == SnapViewportBottom) {
        
        // Slow down to bottom.
        animationCurve = UIViewAnimationOptionCurveEaseOut;
        
    } else if (toViewport == SnapViewportBelow) {
        
        // Fast to below.
        animationCurve = UIViewAnimationOptionCurveEaseIn;
    }
    
    return animationCurve;
}

- (CAMediaTimingFunction *)timingFunctionFromViewport:(SnapViewport)fromViewport toViewport:(SnapViewport)toViewport {
    NSString *timingFunction = kCAMediaTimingFunctionEaseIn;
    if (toViewport == SnapViewportTop) {
        
        // Fast to top.
        timingFunction = kCAMediaTimingFunctionEaseOut;
        
    } else if (toViewport == SnapViewportBottom) {
        
        // Slow down to bottom.
        timingFunction = kCAMediaTimingFunctionEaseOut;
        
    } else if (toViewport == SnapViewportBelow) {
        
        // Fast to below.
        timingFunction = kCAMediaTimingFunctionEaseIn;
    }
    
    return [CAMediaTimingFunction functionWithName:timingFunction];
}

- (CGFloat)animationDurationFromViewport:(SnapViewport)fromViewport toViewport:(SnapViewport)toViewport {
    CGFloat duration = 0.25;
    CGFloat offset = [self offsetForViewport:toViewport];
    
    if (toViewport == SnapViewportTop) {
        
        // Fast to top.
        duration = 0.25;
        
        if (fromViewport != SnapViewportBelow) {
            
            CGFloat distance = ABS(self.scrollView.frame.origin.y - offset);
            CGFloat totalDistance = [self offsetForViewport:SnapViewportBottom] - offset;
            CGFloat durationRatio = distance / totalDistance;
            duration = MAX(duration * durationRatio, 0.15);
        }
        
        
    } else if (toViewport == SnapViewportBottom) {
        
        // Slow down to bottom.
        duration = 0.22;
        
    } else if (toViewport == SnapViewportBelow) {
        
        // Fast to below.
        duration = 0.25;
    }
    
//    NSLog(@"duration %f", duration);
    return duration;
}

- (CGRect)bounceFrameFromViewport:(SnapViewport)fromViewport toViewport:(SnapViewport)toViewport {
    CGRect bounceFrame = CGRectZero;
    
    // Bounce if going from bottom/below to top only.
    if ((fromViewport == SnapViewportBottom || fromViewport == SnapViewportBelow)
        && (toViewport == SnapViewportTop)) {
        
        bounceFrame = self.scrollView.frame;
        bounceFrame.origin.y = [self offsetForViewport:toViewport];
        bounceFrame.origin.y -= kBounceOffset;
        bounceFrame.size.height += kBounceOffset;   // To offset the gap at the bottom.
        
    }
    
    return bounceFrame;
}

- (UIOffset)buttonsBounceOffsetFromViewport:(SnapViewport)fromViewport toViewport:(SnapViewport)toViewport {
    UIOffset offset = UIOffsetZero;
    
    // Bounce if going from bottom/below to top only.
    if ((fromViewport == SnapViewportBottom || fromViewport == SnapViewportBelow)
        && (toViewport == SnapViewportTop)) {
  
// TODO Disabled button bouncing.
//        offset.vertical -= kBounceOffset;
    }
    
    return offset;
}

- (CGFloat)offsetForViewport:(SnapViewport)viewport {
    CGFloat offset = 0.0;
    switch (viewport) {
        case SnapViewportTop:
            offset = kContentTopOffset;
            break;
        case SnapViewportBottom:
            offset = self.view.bounds.size.height - [self headerHeight];
            break;
        case SnapViewportBelow:
            offset = self.view.bounds.size.height;
            break;
        default:
            break;
    }
    return offset;
}

- (BOOL)scrollEnabledAtViewport:(SnapViewport)viewport {
    
    // Scroll enabled at top of viewport only.
    return (viewport == SnapViewportTop);
}

- (BOOL)panEnabledAtViewport:(SnapViewport)viewport {
    
    // Pan enabled at bottom of viewport only.
    return (viewport == SnapViewportBottom);
}

- (void)panned:(UIPanGestureRecognizer *)panGesture {
    CGPoint translation = [panGesture translationInView:self.scrollView];
    
    if (panGesture.state == UIGestureRecognizerStateBegan) {
    } else if (panGesture.state == UIGestureRecognizerStateChanged) {
        [self panWithTranslation:translation.y];
	} else if (panGesture.state == UIGestureRecognizerStateEnded) {
        [self panSnapIfRequired];
    }
    
    [panGesture setTranslation:CGPointZero inView:self.view];
}

- (void)panWithTranslation:(CGFloat)translation {
    CGFloat dragRatio = kDragRatio;
    CGFloat panOffset = ceilf(translation * dragRatio);
    
    // Drag up and down the panel when panGesture is in effect.
    CGRect contentFrame = self.scrollView.frame;
    
    // Add additional drag past the bottom offset.
    if (contentFrame.origin.y + panOffset > [self offsetForViewport:SnapViewportBottom]) {
        panOffset *= 0.15;
    }
    
    contentFrame.origin.y += panOffset;
    contentFrame.origin.y = MAX([self offsetForViewport:SnapViewportTop], contentFrame.origin.y);
    contentFrame.origin.y = MIN([self offsetForViewport:SnapViewportBottom] + 50, contentFrame.origin.y);
    self.scrollView.frame = contentFrame;
    
    // Disable scrollview when at top.
    self.scrollView.scrollEnabled = (contentFrame.origin.y == [self offsetForViewport:SnapViewportTop]);
    
    [self updateDependentViews];
}

- (void)panSnapIfRequired {
    CGRect contentFrame = self.scrollView.frame;
    
    CGFloat criticalOffset = [self snapCriticalOffsetForViewport:self.currentViewport];
    
    if (self.currentViewport == SnapViewportTop) {
        if (contentFrame.origin.y > criticalOffset) {
            
            // Snap to the bottom viewport.
            [self snapToViewport:SnapViewportBottom animated:YES];
            
        } else {
            
            // Restore the panel up.
            [self snapToViewport:SnapViewportTop animated:YES];
            self.panGesture.enabled = NO;
            
        }
    } else if (self.currentViewport == SnapViewportBottom) {
        if (contentFrame.origin.y < criticalOffset) {
            
            // Snap to top viewport.
            [self snapToViewport:SnapViewportTop animated:YES];
            self.panGesture.enabled = NO;
            
        } else {
            
            // Restore the panel down.
            [self snapToViewport:SnapViewportBottom animated:YES];
            self.panGesture.enabled = YES;
        }
    }
}

- (CGFloat)snapCriticalOffsetForViewport:(SnapViewport)viewport {
    CGFloat offset = 0.0;
    switch (viewport) {
        case SnapViewportTop:
            offset = [self offsetForViewport:SnapViewportTop] + kSnapOffset;
            break;
        case SnapViewportBottom:
            offset = [self offsetForViewport:SnapViewportBottom] - kSnapOffset;
            break;
        case SnapViewportBelow:
            break;
        default:
            break;
    }
    return offset;
}

- (UILabel *)createLabelWithText:(NSString *)text {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor blackColor];
    label.font = [UIFont boldSystemFontOfSize:40.0];
    label.text = text;
    [label sizeToFit];
    return label;
}

- (void)toggleImage {
    if (self.animating) {
        return;
    }
    self.animating = YES;
    
    // Figure out fullscreen or previous viewport
    SnapViewport toggleViewport = (self.currentViewport == SnapViewportBelow) ? self.previousViewport : SnapViewportBelow;
    BOOL fullscreen = (toggleViewport == SnapViewportBelow);
    
    [self snapToViewport:toggleViewport animated:YES completion:^{
        
        // Toggle double-tap mode when in fullscreen mode.
        self.imageView.enableDoubleTap = fullscreen;
        
        // Turn on zoomable in belowmode.
        self.imageScrollView.scrollEnabled = fullscreen;
        
        // Opaque background so when you zoom less, you don't get a clear background.
        self.imageScrollView.backgroundColor = fullscreen ? [UIColor blackColor] : [UIColor clearColor];
        
        // Fade in/out the buttons based on fullscreen mode or not.
        [UIView animateWithDuration:0.2
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             if (!fullscreen) {
                                 [self.imageScrollView setZoomScale:1.0 animated:NO];
                             }
                             if (!self.imageView.placeholder) {
                                 self.topShadowView.alpha =  fullscreen ? 0.0 : 1.0;
                             }
                             self.closeButton.alpha = fullscreen ? 0.0 : 1.0;
                             self.socialView.alpha = fullscreen ? 0.0 : 1.0;
                             self.editButton.alpha = fullscreen ? 0.0 : 1.0;
                             self.shareButton.alpha = fullscreen ? 0.0 : 1.0;
                             self.likeButton.alpha = fullscreen ? 0.0 : 1.0;
                             self.pinButton.alpha = fullscreen ? 0.0 : 1.0;
                         }
                         completion:^(BOOL finished)  {
                             self.animating = NO;
                             
                             // Zoomable only in fullscreen mode.
                             self.imageScrollView.maximumZoomScale = fullscreen ? 2.0 : 1.0;
                         }];
    }];
}

- (BOOL)canEditRecipe {
    return ([self.recipe isOwner:self.currentUser] && [self.book isOwner:self.currentUser]);
}

- (void)updateButtons {
    [self updateButtonsWithAlpha:1.0];
}

- (void)hideButtons {
    [self updateButtonsWithAlpha:0.0];
}

- (void)updateButtonsWithAlpha:(CGFloat)alpha {
    
    // Hide navigation buttons.
    if (self.hideNavigation) {
        return;
    }
    
    if (self.editMode) {
        
        // Prep photo edit button to be transitioned in.
        [self.editingHelper wrapEditingView:self.photoButtonView contentInsets:(UIEdgeInsets){
            32.0, 32.0, 20.0, 41.0
        } delegate:self white:YES editMode:NO];
        CKEditingTextBoxView *photoBoxView = [self.editingHelper textBoxViewForEditingView:self.photoButtonView];
        self.photoButtonView.hidden = NO;
        self.photoButtonView.alpha = 0.0;
        photoBoxView.alpha = 0.0;
        
        self.cancelButton.alpha = 0.0;
        self.privacyView.alpha = 0.0;
        self.saveButton.alpha = 0.0;
        self.deleteButton.alpha = 0.0;
        self.cancelButton.transform = CGAffineTransformMakeTranslation(0.0, -self.cancelButton.frame.size.height);
        self.saveButton.transform = CGAffineTransformMakeTranslation(0.0, -self.saveButton.frame.size.height);
        self.deleteButton.transform = CGAffineTransformMakeTranslation(0.0, self.deleteButton.frame.size.height);
        [self.view addSubview:self.cancelButton];
        [self.view addSubview:self.privacyView];
        [self.view addSubview:self.saveButton];
        [self.view addSubview:self.deleteButton];
    } else {
        self.closeButton.alpha = 0.0;
        self.socialView.alpha = 0.0;
        self.editButton.alpha = 0.0;
        self.shareButton.alpha = 0.0;
        self.likeButton.alpha = 0.0;
        self.pinButton.alpha = 0.0;
        self.activityView.alpha = 0.0;
        [self.view addSubview:self.closeButton];
        [self.view addSubview:self.socialView];
        [self.view addSubview:self.editButton];
        [self.view addSubview:self.shareButton];
        [self.view addSubview:self.likeButton];
        [self.view addSubview:self.pinButton];
    }
    
    [UIView animateWithDuration:0.4
                          delay:0.1
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         
                         // Normal mode buttons.
                         self.closeButton.alpha = self.editMode ? 0.0 : alpha;
                         self.socialView.alpha = self.editMode ? 0.0 : alpha;
                         self.editButton.alpha = self.editMode ? 0.0 : alpha;
                         self.shareButton.alpha = self.editMode ? 0.0 : alpha;
                         self.likeButton.alpha = self.editMode ? 0.0 : alpha;
                         self.pinButton.alpha = self.editMode ? 0.0 : alpha;
                         self.privacyView.alpha = self.editMode ? alpha : 0.0;
                         self.activityView.alpha = self.editMode ? 0.0 : alpha;
                         
                         // Photo icon and textBox fade in/out
                         self.photoButtonView.alpha = self.editMode ? [self currentAlphaForPhotoButtonView] : 0.0;
                         CKEditingTextBoxView *photoBoxView = [self.editingHelper textBoxViewForEditingView:self.photoButtonView];
                         photoBoxView.alpha = self.editMode ? [self currentAlphaForPhotoButtonView] : 0.0;
                         
                         // Edit mode buttons.
                         self.cancelButton.alpha = self.editMode ? alpha : 0.0;
                         self.saveButton.alpha = self.editMode ? alpha : 0.0;
                         self.deleteButton.alpha = self.editMode ? alpha : 0.0;
                         self.cancelButton.transform = self.editMode ? CGAffineTransformIdentity : CGAffineTransformMakeTranslation(0.0, -self.cancelButton.frame.size.height);
                         self.saveButton.transform = self.editMode ? CGAffineTransformIdentity : CGAffineTransformMakeTranslation(0.0, -self.saveButton.frame.size.height);
                         self.deleteButton.transform = self.editMode ? CGAffineTransformIdentity : CGAffineTransformMakeTranslation(0.0, self.deleteButton.frame.size.height);
                     }
                     completion:^(BOOL finished)  {
                         if (self.editMode) {
                             [self.closeButton removeFromSuperview];
                             [self.socialView removeFromSuperview];
                             [self.editButton removeFromSuperview];
                             [self.shareButton removeFromSuperview];
                             [self.pinButton removeFromSuperview];
                             [self.likeButton removeFromSuperview];
                             
                             // Select the privacy level.
                             [self.privacyView selectNotch:self.recipeDetails.privacy animated:YES informDelegate:NO];
                             
                         } else {
                             self.photoButtonView.hidden = YES;
                             [self.editingHelper unwrapEditingView:self.photoButtonView];

                             [self.cancelButton removeFromSuperview];
                             [self.privacyView removeFromSuperview];
                             [self.saveButton removeFromSuperview];
                             [self.deleteButton removeFromSuperview];
                         }
                     }];
}

- (void)updateButtonsWithBounceOffset:(UIOffset)offset {
    CGAffineTransform transform = CGAffineTransformIdentity;
    if (!UIOffsetEqualToOffset(offset, UIOffsetZero)) {
        transform = CGAffineTransformMakeTranslation(offset.horizontal, offset.vertical);
    }
    self.closeButton.transform = transform;
    self.socialView.transform = transform;
    self.editButton.transform = transform;
    self.shareButton.transform = transform;
    self.likeButton.transform = transform;
    self.pinButton.transform = transform;
    self.privacyView.transform = transform;
    self.cancelButton.transform = transform;
    self.saveButton.transform = transform;
    self.deleteButton.transform = transform;
}

- (void)showSocialOverlay:(BOOL)show {
    if (show) {
        [self hideButtons];
        self.socialViewController = [[RecipeSocialViewController alloc] initWithRecipe:self.recipe delegate:self];
        self.cookNavigationController = [[CKNavigationController alloc] initWithRootViewController:self.socialViewController
                                                                                          delegate:self];        
    } else {
        self.view.userInteractionEnabled = YES;
        self.scrollView.userInteractionEnabled = YES;
        self.imageScrollView.userInteractionEnabled = YES;
    }
    [ModalOverlayHelper showModalOverlayForViewController:self.cookNavigationController
                                                     show:show
                                                animation:^{
                                                    
                                                } completion:^{
                                                    
                                                    if (show) {
                                                        self.view.userInteractionEnabled = NO;
                                                        self.scrollView.userInteractionEnabled = NO;
                                                        self.imageScrollView.userInteractionEnabled = NO;
                                                    } else {
                                                        
                                                        // Reattach the like view which was adopted by Social.
                                                        // Also updates the positioning for this view as it is right
                                                        // aligned on the social screen.
                                                        self.likeButton.alpha = 0.0;
                                                        self.likeButton.frame = [self resolveFrameForLikeButton:self.likeButton];
                                                        [self.view addSubview:self.likeButton];
                                                        
                                                        self.socialViewController = nil;
                                                        self.cookNavigationController = nil;
                                                        
                                                        [self updateButtons];
                                                    }
                                                }];
}

- (void)showAddOverlay:(BOOL)show {
    if (show) {
        [self hideButtons];
        CKBook *myBook = [[CKBookManager sharedInstance] myCurrentBook];
        self.pinRecipeViewController = [[PinRecipeViewController alloc] initWithRecipe:self.recipe book:myBook delegate:self];
    } else {
        self.view.userInteractionEnabled = YES;
        self.scrollView.userInteractionEnabled = YES;
        self.imageScrollView.userInteractionEnabled = YES;
    }
    [ModalOverlayHelper showModalOverlayForViewController:self.pinRecipeViewController
                                                     show:show
                                                animation:^{
                                                    
                                                } completion:^{
                                                    
                                                    if (show) {
                                                        self.view.userInteractionEnabled = NO;
                                                        self.scrollView.userInteractionEnabled = NO;
                                                        self.imageScrollView.userInteractionEnabled = NO;
                                                    } else {
                                                        self.pinRecipeViewController = nil;
                                                        [self updateButtons];
                                                    }
                                                }];
}

- (void)closeTapped:(id)sender {
    [self closeRecipeView];
}

- (void)closeRecipeView {
    self.isClosed = YES;
    [self hideButtons];
    [self fadeOutBackgroundImageThenClose];
}

- (void)fadeOutBackgroundImageThenClose {
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.topShadowView.alpha = 0.0;
                         self.imageScrollView.alpha = 0.0;
                     }
                     completion:^(BOOL finished)  {
                         [self.modalDelegate closeRequestedForBookModalViewController:self];
                     }];
}

- (void)editTapped:(id)sender {
    [self enableEditMode];
}

- (void)pinTapped:(id)sender {
    if (!self.currentUser) {
        return;
    }
    
    if (self.recipePin) {
        if ([self.book isOwner]) {
            self.pinAlert = [[UIAlertView alloc] initWithTitle:@"Remove Recipe?" message:nil delegate:self
                                             cancelButtonTitle:@"No" otherButtonTitles:@"Remove", nil];
        } else {
            self.pinAlert = [[UIAlertView alloc] initWithTitle:@"Remove Recipe?"
                                                       message:[NSString stringWithFormat:@"Already Added to %@", [self.recipePin.page uppercaseString]]
                                                      delegate:self
                                             cancelButtonTitle:@"No" otherButtonTitles:@"Remove", nil];
        }
        [self.pinAlert show];
    } else {
        [self showAddOverlay:YES];
    }
}

- (void)shareTapped:(id)sender {
    if (![self.recipe isShareable]) {
        return;
    }
    
    [self showShareOverlay:YES];
}

- (void)showShareOverlay:(BOOL)show {
    if (show) {
        [self hideButtons];
        self.shareViewController = [[RecipeShareViewController alloc] initWithRecipe:self.recipe delegate:self];
        self.shareViewController.view.frame = self.view.bounds;
        self.shareViewController.view.alpha = 0.0;
        [self.view addSubview:self.shareViewController.view];
    }
    [UIView animateWithDuration:show? 0.3 : 0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.shareViewController.view.alpha = show ? 1.0 : 0.0;
                     }
                     completion:^(BOOL finished) {
                         if (!show) {
                             [self.shareViewController.view removeFromSuperview];
                             self.shareViewController = nil;
                             [self updateButtons];
                         }
                     }];
}

- (void)cancelTapped:(id)sender {
    if (self.addMode) {
        
        if ([self.recipeDetails saveRequired]) {
            self.cancelAlert = [[UIAlertView alloc] initWithTitle:@"Close without Saving?" message:nil delegate:self
                                                cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        } else {
            [self closeRecipeView];
        }
        
    } else {
        if ([self.recipeDetails saveRequired]) {
            self.cancelAlert = [[UIAlertView alloc] initWithTitle:@"Close without Saving?" message:nil delegate:self
                                                cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        } else {
            [self initRecipeDetails];
            [self enableEditMode:NO];
        }
    }
    
    if (self.cancelAlert) {
        [self.cancelAlert show];
    }

}

- (void)saveTapped:(id)sender {
    [self saveRecipe];
}

- (void)deleteTapped:(id)sender {
    self.deleteAlert = [[UIAlertView alloc] initWithTitle:@"Delete Recipe?" message:nil delegate:self
                                              cancelButtonTitle:@"No" otherButtonTitles:@"Delete", nil];
    [self.deleteAlert show];
}

- (void)saveRecipe {
    DLog(@"saveRequired: %@", [NSString CK_stringForBoolean:self.recipeDetails.saveRequired]);
    
    if (self.recipeDetails.saveRequired) {
        
        // If name or page is updated.
        if (!self.addMode && ([self.recipeDetails nameUpdated] || [self.recipeDetails pageUpdated])) {
            self.recipe.recipeUpdatedDateTime = [NSDate date];
        }
        //If has deleted image and no new image selected
        if (self.isDeleteRecipeImage)
        {
            [self.recipe.recipeImage deleteEventually];
            self.recipe.recipeImage = nil;
        }
        
        // Get any existing location from the original recipe.
        CKLocation *existingLocation = self.recipeDetails.originalRecipe.geoLocation;
        
        // Transfer updated values to the current recipe.
        [self.recipeDetails updateToRecipe:self.recipe];
        
        // Enable save mode to hide all buttons and show black overlay.
        [self enableSaveMode:YES];
        
        // If there was an existing geoLocation, delete it. A new location will be set if needed.
        if (existingLocation != nil) {
            
            // Delete this location eventually.
            [existingLocation deleteEventually];
        }
        
        // Save off the recipe that span 0.1 and 0.9 progress, with the remaining 0.1 for laying out the book.
        [self saveRecipeWithImageStartProgress:0.1
                                   endProgress:0.9
                                    completion:^{
                                        [self enableSaveMode:NO];
                                        [self enableEditMode:NO];
                                        self.addMode = NO;
                                    }
                                       failure:^(NSError *error) {
                                           [self enableSaveMode:NO];
                                           [self enableEditMode:NO];
                                           self.addMode = NO;
                                       }];
        
    } else {
        
        // Nothing to save.
        [self enableSaveMode:NO];
        [self enableEditMode:NO];
        self.addMode = NO;
    }
}

- (void)deleteRecipe {
    
    // Enable save mode to hide all buttons and show black overlay.
    [self enableDeleteMode:YES completion:^{
        
        [self.saveOverlayViewController updateProgress:0.1];
        
        // Deletes in the background.
        [self.recipe deleteInBackground:^{
            
            [self.saveOverlayViewController updateProgress:0.9];
            
            // Ask the opened book to relayout.
            [[BookNavigationHelper sharedInstance] updateBookNavigationWithDeletedRecipe:self.recipe
                                                                              completion:^{
                                                                           
                                                                                  __weak RecipeDetailsViewController *weakSelf = self;
                                                                                  [weakSelf.saveOverlayViewController updateProgress:1.0 delay:0.5 completion:^{
                                                                                      
                                                                                      [weakSelf enableDeleteMode:NO completion:^{
                                                                                          
                                                                                          [weakSelf closeRecipeView];
                                                                                          
                                                                                      }];
                                                                                  }];
                                                                              
                                                                           }];
            
        } failure:^(NSError *error) {
            DLog(@"Error [%@]", [error localizedDescription]);
            [self enableSaveMode:NO];
            [self enableEditMode:NO];
        }];
            
    }];
    
}
    
- (void)deletePin {
    if (!self.recipePin) {
        return;
    }
    
    // Enable unpin mode to hide all buttons and show black overlay.
    [self enableUnpinMode:YES completion:^{
        
        [self.saveOverlayViewController updateProgress:0.1];
        
        // Deletes in the background.
        [self.recipePin deleteInBackground:^{
            
            [self.saveOverlayViewController updateProgress:0.9];
            
            if ([self.book isOwner]) {
                // Ask the opened book to relayout.
                [[BookNavigationHelper sharedInstance] updateBookNavigationWithUnpinnedRecipe:self.recipePin
                                                                                   completion:^{
                                                                                       
                                                                                       __weak RecipeDetailsViewController *weakSelf = self;
                                                                                       [weakSelf.saveOverlayViewController updateProgress:1.0 delay:0.5 completion:^{
                                                                                           [weakSelf enableUnpinMode:NO completion:^{
                                                                                               [weakSelf closeRecipeView];
                                                                                               
                                                                                           }];
                                                                                       }];
                                                                                   }];
            } else {
                
                __weak RecipeDetailsViewController *weakSelf = self;
                [weakSelf.saveOverlayViewController updateProgress:1.0 delay:0.5 completion:^{
                    [weakSelf enableUnpinMode:NO completion:^{
                        
                        // Just nil it and update button.
                        weakSelf.recipePin = nil;
                        [weakSelf updatePinnedButton];
                        
                    }];
                }];
                
            }
            
        } failure:^(NSError *error) {
            DLog(@"Error [%@]", [error localizedDescription]);
            [self enableSaveMode:NO];
            [self enableEditMode:NO];
        }];
        
    }];
    
}

- (void)saveRecipeWithImageStartProgress:(CGFloat)startProgress endProgress:(CGFloat)endProgress {
    [self saveRecipeWithImageStartProgress:startProgress endProgress:endProgress completion:nil failure:nil];
}

- (void)saveRecipeWithImageStartProgress:(CGFloat)startProgress endProgress:(CGFloat)endProgress
                              completion:(void (^)())completion failure:(void (^)(NSError *))failure {
    [self.recipe saveWithImage:self.recipeDetails.image
                 startProgress:startProgress
                   endProgress:endProgress
                      progress:^(int percentDone) {
                          [self.saveOverlayViewController updateProgress:(percentDone / 100.0) animated:YES];
                          
                      }
                    completion:^{
                        
                        // Ask the opened book to relayout.
                        [[BookNavigationHelper sharedInstance] updateBookNavigationWithRecipe:self.recipe
                                                                                   completion:^{
                                                                                       
                                                                                       // Set 100% progress completion.
                                                                                       [self.saveOverlayViewController updateProgress:1.0 delay:0.5 completion:^{
                                                                                           // Run completion.
                                                                                           if (completion != nil) {
                                                                                               completion();
                                                                                           }
                                                                                           
                                                                                       }];
                                                                                   }];
                        //Analytics
                        NSDictionary *dimensions = @{@"isImage" : [NSString stringWithFormat:@"%@", self.recipeDetails.image ? @YES : @NO],
                                                     @"privacy" : [NSString stringWithFormat:@"%i", self.recipeDetails.privacy]};
                        [AnalyticsHelper trackEventName:@"Recipe Saved" params:dimensions];
                    } failure:^(NSError *error) {
                           
                           // Run failure.
                           if (failure != nil) {
                               failure(error);
                           }
                           
                    }];
}


- (void)initRecipeDetails {
    
    // Create transfer object to display/edit.
    self.recipeDetails = [[RecipeDetails alloc] initWithRecipe:self.recipe book:self.book];
    
    // Create a new RecipeDetailsView everytime, getting rid of the last one if it exists.
    [self.recipeDetailsView removeFromSuperview];
    self.recipeDetailsView = nil;
    self.recipeDetailsView = [[RecipeDetailsView alloc] initWithRecipeDetails:self.recipeDetails
                                                                     delegate:self];
    
    // Update the scrollView with the recipe details view.
    [self updateRecipeDetailsView];
}

- (void)enableEditMode {
    [self enableEditMode:YES];
}

- (void)enableEditMode:(BOOL)enable {
    
    if (!self.addMode && ([self.recipe hasMethod] || [self.recipe hasIngredients]) && self.currentViewport != SnapViewportTop) {
        
        // Snap to top first.
        [self snapToViewport:SnapViewportTop completion:^{
            [self enableEditModeWithoutInformingRecipeDetailsView:enable];
            [self.recipeDetailsView enableEditMode:enable];
        }];
        
    } else {
        [self snapToViewport:SnapViewportBottom completion:^{
            [self enableEditModeWithoutInformingRecipeDetailsView:enable];
            [self.recipeDetailsView enableEditMode:enable];
        }];
    }
}

- (void)enableEditModeWithoutInformingRecipeDetailsView {
    [self enableEditModeWithoutInformingRecipeDetailsView:YES];
}

- (void)enableEditModeWithoutInformingRecipeDetailsView:(BOOL)enable {
    self.editMode = enable;
    [self updateButtons];
}

- (void)enableSaveMode:(BOOL)saveEnabled {
    
    // Hide all buttons.
    if (saveEnabled) {
        [self hideButtons];
    }
    
    // Fade in/out the overlay.
    [self showProgressOverlayView:saveEnabled];
}

- (void)enableSaveMode:(BOOL)saveEnabled completion:(void (^)())completion {
    
    // Hide all buttons.
    if (saveEnabled) {
        [self hideButtons];
    }
    
    // Fade in/out the overlay.
    [self showProgressOverlayView:saveEnabled completion:completion];
}

- (void)enableDeleteMode:(BOOL)deleteMode completion:(void (^)())completion {
    
    // Hide all buttons.
    if (deleteMode) {
        [self hideButtons];
    }
    
    // Fade in/out the overlay.
    [self showProgressOverlayView:deleteMode title:@"DELETING" completion:completion];
}

- (void)enableUnpinMode:(BOOL)unpin completion:(void (^)())completion {
    
    // Hide all buttons.
    if (unpin) {
        [self hideButtons];
    } else {
        [self updateButtonsWithAlpha:1.0];
    }
    
    // Fade in/out the overlay.
    [self showProgressOverlayView:unpin title:@"REMOVING" completion:completion];
}

- (void)updateRecipeDetailsView {
    
    if (self.scrollView.contentOffset.y > 0) {
        
        [self.scrollView setContentOffset:CGPointZero animated:YES];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self resetRecipeDetailsView];
        });

    } else {
        [self resetRecipeDetailsView];
    }
}

- (void)resetRecipeDetailsView {
    
    // Footer?
    if (!self.addMode) {
        
        // Divider?
        if ([self.recipeDetails hasServes] || [self.recipeDetails hasMethod] || [self.recipeDetails hasIngredients]) {
            [self.recipeFooterDividerView removeFromSuperview];
            self.recipeFooterDividerView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_book_recipe_divider_tile.png"]];
            self.recipeFooterDividerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        }
        
        // Footer.
        if (!self.recipeFooterView) {
            self.recipeFooterView = [[RecipeFooterView alloc] init];
            self.recipeFooterView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
            [self.scrollView addSubview:self.recipeFooterView];
        }
        [self.recipeFooterView updateFooterWithRecipeDetails:self.recipeDetails];
        
        CGSize contentSize = self.recipeDetailsView.frame.size;
        contentSize.height += (self.recipeFooterDividerView ? kFooterTopGap : 0.0) + self.recipeFooterView.frame.size.height + kFooterBottomGap;
        contentSize.height = MAX(contentSize.height, 768.0 - kContentTopOffset); // UGH need to force 768.0 as autoresize hasn't kicked in for scrollView yet.
        self.scrollView.contentSize = contentSize;
        self.recipeFooterView.frame = (CGRect){
            floorf((self.scrollView.bounds.size.width - self.recipeFooterView.frame.size.width) / 2.0),
            contentSize.height - self.recipeFooterView.frame.size.height - kFooterBottomGap,
            self.recipeFooterView.frame.size.width,
            self.recipeFooterView.frame.size.height
        };
        
        // Position the divider.
        if (self.recipeFooterDividerView) {
            self.recipeFooterDividerView.frame = (CGRect){
                floorf((self.scrollView.bounds.size.width - self.recipeDetailsView.frame.size.width) / 2.0),
                self.recipeFooterView.frame.origin.y - kFooterTopGap,
                self.recipeDetailsView.frame.size.width,
                self.recipeFooterDividerView.frame.size.height
            };
            [self.scrollView addSubview:self.recipeFooterDividerView];
        }
        
    } else {
        [self.recipeFooterDividerView removeFromSuperview];
        self.recipeFooterDividerView = nil;
        [self.recipeFooterView removeFromSuperview];
        self.recipeFooterView = nil;
        self.scrollView.contentSize = self.recipeDetailsView.frame.size;
    }
    
    self.recipeDetailsView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
    self.recipeDetailsView.frame = (CGRect){
        floorf((self.scrollView.bounds.size.width - self.recipeDetailsView.frame.size.width) / 2.0),
        0.0,
        self.recipeDetailsView.frame.size.width,
        self.recipeDetailsView.frame.size.height
    };
    
    if (!self.recipeDetailsView.superview) {
        [self.scrollView addSubview:self.recipeDetailsView];
    }
}

- (CGFloat)currentAlphaForPhotoButtonView {
    CGFloat topOffset = [self offsetForViewport:SnapViewportTop];
    CGFloat bottomOffset = [self offsetForViewport:SnapViewportBottom];
    CGFloat distance = bottomOffset - self.scrollView.frame.origin.y;
    CGFloat effectiveDistance = bottomOffset - topOffset;
    CGFloat requiredAlpha = 1.0 - (distance / effectiveDistance);
    return requiredAlpha;
}

- (void)showPhotoPicker:(BOOL)show {
    [self showPhotoPicker:show completion:^{}];
}

- (void)showPhotoPicker:(BOOL)show completion:(void (^)())completion {
    
    if (show) {
        // Present photo picker fullscreen.
        UIView *rootView = [[AppHelper sharedInstance] rootView];
        UIImage *editingImage = [self.recipe hasPhotos] ? self.imageView.image : nil;
        CKPhotoPickerViewController *photoPickerViewController = [[CKPhotoPickerViewController alloc] initWithDelegate:self type:CKPhotoPickerImageTypeLandscape editImage:editingImage];
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
                             [self.photoPickerViewController.view removeFromSuperview];
                             self.photoPickerViewController = nil;
                         }
                         completion();
                     }];
}

- (void)showProgressOverlayView:(BOOL)show {
    [self showProgressOverlayView:show completion:nil];
}

- (void)showProgressOverlayView:(BOOL)show completion:(void (^)())completion {
    [self showProgressOverlayView:show title:@"SAVING" completion:completion];
}

- (void)showProgressOverlayView:(BOOL)show title:(NSString *)title completion:(void (^)())completion {
    if (show) {
        self.saveOverlayViewController = [[ProgressOverlayViewController alloc] initWithTitle:title];
    }
    [ModalOverlayHelper showModalOverlayForViewController:self.saveOverlayViewController
                                                     show:show
                                               completion:^{
                                                   if (!show) {
                                                       self.saveOverlayViewController = nil;
                                                   }
                                                   if (completion != nil) {
                                                       completion();
                                                   }
                                               }];
}

- (CGRect)zoomFrameForScale:(float)scale withCenter:(CGPoint)center {
    CGRect zoomRect;
    zoomRect.size.height = [self.imageScrollView frame].size.height / scale;
    zoomRect.size.width  = [self.imageScrollView frame].size.width  / scale;
    zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);
    return zoomRect;
}

- (void)screenEdgePanned:(UIScreenEdgePanGestureRecognizer *)edgeGesture {
    
    // If detected, then close the recipe.
    if (edgeGesture.state == UIGestureRecognizerStateBegan) {
        if (self.editMode) {
            [self cancelTapped:nil];
        } else if (self.currentViewport == SnapViewportBelow) {
            [self toggleImage];
        } else {
            [self closeRecipeView];
        }
    }
}

- (void)updateShareButton {
    if (self.shareButton) {
        BOOL shareable = [self.recipe isShareable];
        UIImage *shareImage = shareable ? [UIImage imageNamed:@"cook_book_inner_icon_share_light.png"] : [UIImage imageNamed:@"cook_book_inner_icon_secret_light.png"];
        [self.shareButton setBackgroundImage:shareImage forState:UIControlStateNormal];
        UIImage *shareImageSelected = shareable ? [UIImage imageNamed:@"cook_book_inner_icon_share_light_onpress.png"] : [UIImage imageNamed:@"cook_book_inner_icon_secret_light_onpress.png"];
        [self.shareButton setBackgroundImage:shareImageSelected forState:UIControlStateHighlighted];
        if (shareable && [[self.shareButton actionsForTarget:self forControlEvent:UIControlEventTouchUpInside] count] == 0) {
            [self.shareButton addTarget:self action:@selector(shareTapped:) forControlEvents:UIControlEventTouchUpInside];
        } else if (!shareable && [[self.shareButton actionsForTarget:self forControlEvent:UIControlEventTouchUpInside] count] > 0) {
            [self.shareButton removeTarget:self action:@selector(shareTapped:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
}

- (CGFloat)headerHeight {
    CGFloat headerHeight = 220.0;
//    return headerHeight;
    
    if ([self.recipeDetails hasStory]) {
        CGFloat maxStoryHeight = 50.0;
        headerHeight = self.recipeDetailsView.storyLabel.frame.origin.y + MIN(self.recipeDetailsView.storyLabel.frame.size.height, maxStoryHeight) + 15.0;
    } else if (self.addMode) {
        headerHeight = 265.0;
    }
    
    return headerHeight;
}

- (SnapViewport)startViewPort {
    SnapViewport startViewPort = SnapViewportTop;
    if (self.addMode) {
        startViewPort = SnapViewportBottom;
    } else if ([self.recipe hasPhotos]) {
        startViewPort = SnapViewportBottom;
    }
    
    return startViewPort;
}

- (void)updatePinnedButton {
    [self.pinButton setBackgroundImage:[self imageForPinned:(self.recipePin != nil)] forState:UIControlStateNormal];
    [self.pinButton setBackgroundImage:[self imageForPinnedOnpress:(self.recipePin != nil)] forState:UIControlStateHighlighted];
}

- (UIImage *)imageForPinned:(BOOL)pinned {
    return pinned ? [UIImage imageNamed:@"cook_book_inner_icon_minus_light.png"] : [UIImage imageNamed:@"cook_book_inner_icon_add_light.png"];
}

- (UIImage *)imageForPinnedOnpress:(BOOL)pinned {
    return pinned ? [UIImage imageNamed:@"cook_book_inner_icon_minus_light_onpress.png"] : [UIImage imageNamed:@"cook_book_inner_icon_add_light_onpress.png"];
}

- (CGRect)resolveFrameForLikeButton:(CKLikeView *)likeButton {
    CGRect likeFrame = CGRectZero;
    if (self.pinButton) {
        likeFrame = (CGRect){
            self.pinButton.frame.origin.x - kIconGap - likeButton.frame.size.width,
            kButtonInsets.top,
            likeButton.frame.size.width,
            likeButton.frame.size.height};
    } else if (self.shareButton) {
        likeFrame = (CGRect){
            self.pinButton.frame.origin.x - kIconGap - likeButton.frame.size.width,
            kButtonInsets.top,
            likeButton.frame.size.width,
            likeButton.frame.size.height};
    } else {
        likeFrame = (CGRect){
            self.view.frame.size.width - kButtonInsets.right - likeButton.frame.size.width,
            kButtonInsets.top,
            likeButton.frame.size.width,
            likeButton.frame.size.height
        };
    }
    return likeFrame;
}

@end
