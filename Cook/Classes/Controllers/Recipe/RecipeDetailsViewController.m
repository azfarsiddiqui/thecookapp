//
//  RecipeDetailsViewController.m
//  SnappingScrollViewDemo
//
//  Created by Jeff Tan-Ang on 8/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "RecipeDetailsViewController.h"
#import "CKRecipe.h"
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
#import "Theme.h"
#import "CKPhotoPickerViewController.h"
#import "AppHelper.h"
#import "UIImage+ProportionalFill.h"
#import "NSString+Utilities.h"
#import "CKProgressView.h"
#import "BookNavigationHelper.h"
#import "CKServerManager.h"
#import "CKPhotoManager.h"
#import "UIColor+Expanded.h"

typedef NS_ENUM(NSUInteger, SnapViewport) {
    SnapViewportTop,
    SnapViewportBottom,
    SnapViewportBelow
};

@interface RecipeDetailsViewController () <UIScrollViewDelegate, UIGestureRecognizerDelegate,
    CKRecipeSocialViewDelegate, RecipeSocialViewControllerDelegate, RecipeDetailsViewDelegate,
    CKEditingTextBoxViewDelegate, CKPhotoPickerViewControllerDelegate, CKPrivacySliderViewDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) CKRecipe *recipe;
@property (nonatomic, strong) RecipeDetails *recipeDetails;
@property (nonatomic, strong) CKBook *book;
@property (nonatomic, weak) id<BookModalViewControllerDelegate> modalDelegate;

// Blurring artifacts.
@property (nonatomic, assign) BOOL blur;
@property (nonatomic, strong) UIImageView *blurredImageView;
@property (nonatomic, strong) CALayer *blurredMaskLayer;

// Content and panning related.
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *topShadowView;
@property (nonatomic, strong) UIView *placeholderHeaderView;    // Used to as white backing for the header until image fades in.
@property (nonatomic, strong) UIImageView *contentImageView;
@property (nonatomic, strong) RecipeDetailsView *recipeDetailsView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, assign) SnapViewport currentViewport;
@property (nonatomic, assign) SnapViewport previousViewport;
@property (nonatomic, assign) BOOL draggingDown;
@property (nonatomic, assign) BOOL animating;
@property (nonatomic, assign) BOOL pullingBottom;

// Normal controls.
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *editButton;
@property (nonatomic, strong) UIButton *shareButton;
@property (nonatomic, strong) CKLikeView *likeButton;
@property (nonatomic, strong) CKRecipeSocialView *socialView;

// Editing.
@property (nonatomic, assign) BOOL editMode;
@property (nonatomic, assign) BOOL addMode;
@property (nonatomic, assign) BOOL locatingInProgress;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) CKPrivacySliderView *privacyView;
@property (nonatomic, strong) UIView *photoButtonView;
@property (nonatomic, strong) CKEditingViewHelper *editingHelper;
@property (nonatomic, strong) CKPhotoPickerViewController *photoPickerViewController;
@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) CKProgressView *progressView;

// Social layer.
@property (nonatomic, strong) RecipeSocialViewController *socialViewController;

@end

@implementation RecipeDetailsViewController

#define kButtonInsets       UIEdgeInsetsMake(22.0, 10.0, 15.0, 20.0)
#define kEditButtonInsets   UIEdgeInsetsMake(20.0, 5.0, 0.0, 5.0)
#define kSnapOffset         100.0
#define kBounceOffset       10.0
#define kContentTopOffset   94.0
#define kHeaderHeight       280.0
#define kDragRatio          0.9
#define kContentImageOffset (UIOffset){ 0.0, -13.0 }

- (void)dealloc {
    [self.scrollView removeObserver:self forKeyPath:@"frame"];
}

- (id)initWithRecipe:(CKRecipe *)recipe {
    if (self = [super init]) {
        self.recipe = recipe;
        self.book = recipe.book;
        self.editingHelper = [[CKEditingViewHelper alloc] init];
        self.blur = YES;
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
    
    [self initImageView];
    [self initScrollView];
    [self initRecipeDetails];
}

#pragma mark - BookModalViewController methods

- (void)setModalViewControllerDelegate:(id<BookModalViewControllerDelegate>)modalViewControllerDelegate {
    self.modalDelegate = modalViewControllerDelegate;
}

- (void)bookModalViewControllerWillAppear:(NSNumber *)appearNumber {
    [EventHelper postStatusBarChangeForLight:[appearNumber boolValue]];
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
    UIImage *croppedImage = [image imageCroppedToFitSize:self.imageView.bounds.size];
    [self loadImageViewWithPhoto:croppedImage];
    
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

#pragma mark - RecipeSocialViewControllerDelegate methods

- (void)recipeSocialViewControllerCloseRequested {
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

#pragma mark - CKPrivacySliderViewDelegate methods

- (void)privacySelectedPrivateForSliderView:(CKNotchSliderView *)sliderView {
    self.recipeDetails.privacy = CKPrivacyPrivate;
    self.saveButton.enabled = YES;
}

- (void)privacySelectedFriendsForSliderView:(CKNotchSliderView *)sliderView {
    [self.recipe clearLocation];
    self.recipeDetails.privacy = CKPrivacyFriends;
    self.saveButton.enabled = YES;
}

- (void)privacySelectedGlobalForSliderView:(CKNotchSliderView *)sliderView {
    
    // Locating is in progress.
    if (self.locatingInProgress) {
        return;
    }
    self.locatingInProgress = YES;
    
    // Disable save button until location is obtained.
    self.saveButton.enabled = NO;
    
    [[CKServerManager sharedInstance] requestForCurrentLocation:^(double latitude, double longitude){
        self.recipeDetails.privacy = CKPrivacyGlobal;
        [self.recipe setLocation:[[CLLocation alloc] initWithLatitude:latitude longitude:longitude]];
        self.saveButton.enabled = YES;
        self.locatingInProgress = NO;
    } failure:^(NSError *error) {
        self.saveButton.enabled = YES;
        self.locatingInProgress = NO;
    }];
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    BOOL shouldReceiveTouch = YES;
    
    if (gestureRecognizer.view == self.imageView) {
        
        CGPoint tappedLocation = [touch locationInView:self.imageView];
        CGPoint location = [self.imageView convertPoint:tappedLocation toView:self.view];
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
        
    }
    
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
    if (!self.pullingBottom) {
        [self panSnapIfRequired];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//    NSLog(@"scrollViewDidEndDecelerating");
    if (!self.pullingBottom) {
        [self panSnapIfRequired];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
//    NSLog(@"scrollViewDidEndScrollingAnimation");
    if (!self.pullingBottom) {
        [self panSnapIfRequired];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
//    NSLog(@"scrollViewWillEndDragging velocity[%@]", NSStringFromCGPoint(velocity));
}

#pragma mark - UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    // OK Button tapped.
    if (buttonIndex == 1) {
        [self deleteRecipe];
    }
    
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
        
        if (self.likeButton) {
            _shareButton.frame = CGRectMake(self.likeButton.frame.origin.x - 15.0 - _shareButton.frame.size.width,
                                            kButtonInsets.top,
                                            _shareButton.frame.size.width,
                                            _shareButton.frame.size.height);
        } else {
            _shareButton.frame = CGRectMake(self.view.frame.size.width - kButtonInsets.right - _shareButton.frame.size.width,
                                            kButtonInsets.top,
                                            _shareButton.frame.size.width,
                                            _shareButton.frame.size.height);
            
        }
    }
    return _shareButton;
}

- (CKLikeView *)likeButton {
    if (![self.book isOwner] && !_likeButton) {
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
            cameraImageView.frame.origin.x + cameraImageView.frame.size.width - 18.0,
            floorf((cameraImageView.frame.size.height - photoLabel.frame.size.height) / 2.0),
            photoLabel.frame.size.width,
            photoLabel.frame.size.height
        };
        photoLabel.frame = photoLabelFrame;
        
        UIEdgeInsets contentInsets = (UIEdgeInsets){
            -8.0, -18.0, -9.0, 6.0
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
            kButtonInsets.top,
            _privacyView.frame.size.width,
            _privacyView.frame.size.height};
    }
    return _privacyView;
}

#pragma mark - Private methods

- (void)initImageView {
    
    UIOffset motionOffset = [ViewHelper standardMotionOffset];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:(CGRect){
        self.view.bounds.origin.x - motionOffset.horizontal,
        self.view.bounds.origin.y - motionOffset.vertical,
        self.view.bounds.size.width + (motionOffset.horizontal * 2.0),
        self.view.bounds.size.height + (motionOffset.vertical * 2.0)
    }];
    imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    imageView.alpha = 0.0;
    [self.view addSubview:imageView];
    self.imageView = imageView;
    
    if (self.blur) {
        UIImageView *blurredImageView = [[UIImageView alloc] initWithFrame:imageView.bounds];
        blurredImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self.imageView addSubview:blurredImageView];
        self.blurredImageView = blurredImageView;
        
        // Setting up mask
        self.blurredMaskLayer = [CALayer layer];
        self.blurredMaskLayer.frame = CGRectZero;
        self.blurredMaskLayer.backgroundColor = [UIColor blackColor].CGColor;
        self.blurredImageView.layer.mask = self.blurredMaskLayer;

    }
    
    // Top shadow.
    UIImageView *topShadowView = [ViewHelper topShadowViewForView:self.view];
    topShadowView.alpha = 0.0;
    [self.view insertSubview:topShadowView aboveSubview:self.imageView];
    self.topShadowView = topShadowView;
    
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
    
    // Register tap on background image for tap expand.
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped:)];
    tapGesture.delegate = self;
    self.imageView.userInteractionEnabled = YES;
    [self.imageView addGestureRecognizer:tapGesture];
    
    // Motion effects.
    [ViewHelper applyDraggyMotionEffectsToView:self.imageView];
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
    
    // Set up a placeholder view so that it can back the whiteColor before blurredImage fades in.
    self.placeholderHeaderView = [[UIView alloc] initWithFrame:(CGRect){
        self.scrollView.bounds.origin.x,
        self.scrollView.bounds.origin.y,
        self.contentImageView.bounds.size.width,
        kHeaderHeight
    }];
    self.placeholderHeaderView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
    self.placeholderHeaderView.backgroundColor = [Theme recipeGridImageBackgroundColour];  // White colour to start off with then fade out.
    [self.scrollView addSubview:self.placeholderHeaderView];
    
    // Register a concurrent panGesture to drag panel up and down.
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
    panGestureRecognizer.delegate = self;
    [scrollView addGestureRecognizer:panGestureRecognizer];
    self.panGesture = panGestureRecognizer;
    
    // Start observing the frame of scrollView.
    [scrollView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
    
    // Start at bottom viewport.
    [self snapToViewport:SnapViewportBelow animated:NO];
}

- (void)updateDependentViews {
    CGRect contentFrame = self.scrollView.frame;
    
    // Update imageView.
    CGRect imageFrame = self.imageView.frame;
    imageFrame.origin.y = (contentFrame.origin.y - imageFrame.size.height) / 2.0;
    self.imageView.frame = imageFrame;
    
    // Fade in/out photo button if in edit mode.
    if (self.editMode) {
        CGFloat requiredAlpha = [self currentAlphaForPhotoButtonView];
        self.photoButtonView.alpha = requiredAlpha;
        CKEditingTextBoxView *photoBoxView = [self.editingHelper textBoxViewForEditingView:self.photoButtonView];
        photoBoxView.alpha = requiredAlpha;
    }
    
    // Update backgroundImageView.
    CGRect contentBackgroundFrame = self.contentImageView.frame;
    contentBackgroundFrame.origin.y = contentFrame.origin.y + kContentImageOffset.vertical;
    self.contentImageView.frame = contentBackgroundFrame;
    
    // Dynamic blur.
    [self performDynamicBlur];
}

- (void)loadData {
    [self loadPhoto];
}

- (void)loadPhoto {
    if ([self.recipe hasPhotos]) {
        
        
        [[CKPhotoManager sharedInstance] imageForRecipe:self.recipe size:self.imageView.bounds.size name:@"RecipePhoto"
                                               progress:^(CGFloat progressRatio, NSString *name) {
                                               } thumbCompletion:^(UIImage *thumbImage, NSString *name) {
                                                   [self loadImageViewWithPhoto:thumbImage placeholder:NO];
                                               } completion:^(UIImage *image, NSString *name) {
                                                   [self loadImageViewWithPhoto:image placeholder:NO];
                                               }];
    } else {
        
        // Load placeholder editing background based on book cover.
        [self loadImageViewWithPhoto:[CKBookCover recipeEditBackgroundImageForCover:self.recipe.book.cover]
                         placeholder:YES];
    }
    
}

- (void)loadImageViewWithPhoto:(UIImage *)image {
    [self loadImageViewWithPhoto:image placeholder:NO];
}

- (void)loadImageViewWithPhoto:(UIImage *)image placeholder:(BOOL)placeholder {
    self.imageView.image = image;
    
    if (self.blur) {
        self.blurredImageView.image = [ImageHelper blurredRecipeImage:image];
    }
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.topShadowView.alpha = placeholder ? 0.0 : 1.0;
                         self.imageView.alpha = 1.0;
                         self.placeholderHeaderView.alpha = 0.0;
                     }
                     completion:^(BOOL finished)  {
                         [self.placeholderHeaderView removeFromSuperview];
                         self.placeholderHeaderView = nil;
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
    NSLog(@"snapToViewport [%d] fromViewport[%d]", viewport, self.currentViewport);
    
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
                                 
                                 // Make an explicit CA transaction that synchronises with UIView animation.
                                 [CATransaction begin];
                                 [CATransaction setAnimationDuration:bounceDuration];
                                 [CATransaction setAnimationTimingFunction:[self timingFunctionFromViewport:currentViewport toViewport:viewport]];
                                 self.blurredMaskLayer.frame = [self blurredFrameForProposedScrollViewBounds:bounceFrame];
                                 [CATransaction commit];
                                 
                                 self.scrollView.frame = bounceFrame;
                                 [self updateButtonsWithBounceOffset:buttonBounceOffset];
                             }
                             completion:^(BOOL finished) {
                                 
                                 // Rest on intended frame.
                                 [UIView animateWithDuration:0.1
                                                       delay:0.0
                                                     options:UIViewAnimationOptionCurveEaseIn
                                                  animations:^{
                                                      
                                                      // Bounce back
                                                      [CATransaction begin];
                                                      [CATransaction setAnimationDuration:0.1];
                                                      [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
                                                      self.blurredMaskLayer.frame = [self blurredFrameForProposedScrollViewBounds:frame];
                                                      [CATransaction commit];
                                                      
                                                      self.scrollView.frame = frame;
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
                                 
                                 // Make an explicit CA transaction that synchronises with UIView animation.
                                 [CATransaction begin];
                                 [CATransaction setAnimationDuration:duration];
                                 [CATransaction setAnimationTimingFunction:[self timingFunctionFromViewport:currentViewport toViewport:viewport]];
                                 self.blurredMaskLayer.frame = [self blurredFrameForProposedScrollViewBounds:frame];
                                 [CATransaction commit];
                                 
                                 self.scrollView.frame = frame;
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
    
    NSLog(@"duration %f", duration);
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
            offset = self.view.bounds.size.height - kHeaderHeight;
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

- (SnapViewport)startViewPort {
    SnapViewport startViewPort = SnapViewportBottom;
    if (self.addMode) {
        startViewPort = SnapViewportBottom;
    } else if ([self.recipe hasPhotos]) {
        startViewPort = SnapViewportBottom;
    }
    
    return startViewPort;
}

- (void)imageTapped:(UITapGestureRecognizer *)tapGesture {
    if (self.animating) {
        return;
    }
    self.animating = YES;
    
    // Figure out fullscreen or previous viewport
    SnapViewport toggleViewport = (self.currentViewport == SnapViewportBelow) ? self.previousViewport : SnapViewportBelow;
    BOOL fullscreen = (toggleViewport == SnapViewportBelow);
    
    [self snapToViewport:toggleViewport animated:YES completion:^{
        
        // Fade in/out the buttons based on fullscreen mode or not.
        [UIView animateWithDuration:0.2
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.closeButton.alpha = fullscreen ? 0.0 : 1.0;
                             self.socialView.alpha = fullscreen ? 0.0 : 1.0;
                             self.editButton.alpha = fullscreen ? 0.0 : 1.0;
                             self.shareButton.alpha = fullscreen ? 0.0 : 1.0;
                             self.likeButton.alpha = fullscreen ? 0.0 : 1.0;
                         }
                         completion:^(BOOL finished)  {
                             self.animating = NO;
                         }];
    }];
}

- (BOOL)canEditRecipe {
    return ([self.book isOwner]);
}

- (void)updateButtons {
    [self updateButtonsWithAlpha:1.0];
}

- (void)hideButtons {
    [self updateButtonsWithAlpha:0.0];
}

- (void)updateButtonsWithAlpha:(CGFloat)alpha {
    if (self.editMode) {
        
        // Prep photo edit button to be transitioned in.
        [self.editingHelper wrapEditingView:self.photoButtonView delegate:self white:YES editMode:NO animated:NO];
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
        [self.view addSubview:self.closeButton];
        [self.view addSubview:self.socialView];
        [self.view addSubview:self.editButton];
        [self.view addSubview:self.shareButton];
        [self.view addSubview:self.likeButton];
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
                         self.privacyView.alpha = self.editMode ? alpha : 0.0;
                         
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
                             [self.likeButton removeFromSuperview];
                             
                             // Select the privacy level.
                             [self.privacyView selectNotch:self.recipeDetails.privacy animated:YES];
                             
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
    self.privacyView.transform = transform;
    self.cancelButton.transform = transform;
    self.saveButton.transform = transform;
    self.deleteButton.transform = transform;
}

- (void)showSocialOverlay:(BOOL)show {
    if (show) {
        [self hideButtons];
        self.socialViewController = [[RecipeSocialViewController alloc] initWithRecipe:self.recipe delegate:self];
        self.socialViewController.view.frame = self.view.bounds;
        self.socialViewController.view.alpha = 0.0;
        [self.view addSubview:self.socialViewController.view];
    }
    [UIView animateWithDuration:show? 0.3 : 0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.socialViewController.view.alpha = show ? 1.0 : 0.0;
                     }
                     completion:^(BOOL finished) {
                         if (!show) {
                             [self.socialViewController.view removeFromSuperview];
                             self.socialViewController = nil;
                             [self updateButtons];
                         }
                     }];
}

- (void)closeTapped:(id)sender {
    [self closeRecipeView];
}

- (void)closeRecipeView {
    [self hideButtons];
    [self fadeOutBackgroundImageThenClose];
}

- (void)fadeOutBackgroundImageThenClose {
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.topShadowView.alpha = 0.0;
                         self.imageView.alpha = 0.0;
                     }
                     completion:^(BOOL finished)  {
                         [self.modalDelegate closeRequestedForBookModalViewController:self];
                     }];
}

- (void)editTapped:(id)sender {
    [self enableEditMode];
}

- (void)shareTapped:(id)sender {
    DLog();
}

- (void)cancelTapped:(id)sender {
    if (self.addMode) {
        [self closeRecipeView];
    } else {
        [self initRecipeDetails];
        [self enableEditMode:NO];
    }
}

- (void)saveTapped:(id)sender {
    [self saveRecipe];
}

- (void)deleteTapped:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Delete Recipe?" message:nil delegate:self
                                              cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [alertView show];
}

- (void)saveRecipe {
    
    DLog(@"saveRequired: %@", [NSString CK_stringForBoolean:self.recipeDetails.saveRequired]);
    if (self.recipeDetails.saveRequired) {
        
        // Transfer updated values to the current recipe.
        [self.recipeDetails updateToRecipe:self.recipe];
        
        // Enable save mode to hide all buttons and show black overlay.
        [self enableSaveMode:YES];
        
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
    [self enableSaveMode:YES completion:^{
        
        // Keep a weak reference of the progressView for tracking of updates.
        __weak CKProgressView *weakProgressView = self.progressView;
        [weakProgressView setProgress:0.1 completion:^{
            
            // Deletes in the background.
            [self.recipe deleteInBackground:^{
                
                // Finished deleting, now ask book to relayout.
                [weakProgressView setProgress:0.9];
                
                // Ask the opened book to relayout.
                [[BookNavigationHelper sharedInstance] updateBookNavigationWithDeletedRecipe:self.recipe
                                                                                  completion:^{
                                                                               
                                                                                   // 100%
                                                                                   [weakProgressView setProgress:1.0 delay:0.5 completion:^{
                                                                                       [self closeRecipeView];
                                                                                   }];
                                                                               
                                                                               }];
                
            } failure:^(NSError *error) {
                DLog(@"Error [%@]", [error localizedDescription]);
                [self enableSaveMode:NO];
                [self enableEditMode:NO];
            }];
            
        }];
        
        
    }];
    
}

- (void)saveRecipeWithImageStartProgress:(CGFloat)startProgress endProgress:(CGFloat)endProgress {
    [self saveRecipeWithImageStartProgress:startProgress endProgress:endProgress completion:nil failure:nil];
}

- (void)saveRecipeWithImageStartProgress:(CGFloat)startProgress endProgress:(CGFloat)endProgress
                              completion:(void (^)())completion failure:(void (^)(NSError *))failure {
    
    // Keep a weak reference of the progressView for tracking of updates.
    __weak CKProgressView *weakProgressView = self.progressView;
    
    [self.recipe saveWithImage:self.recipeDetails.image
                 startProgress:startProgress
                   endProgress:endProgress
                      progress:^(int percentDone) {
                          [weakProgressView setProgress:(percentDone / 100.0) animated:YES];
                      }
                    completion:^{
                        
                        // Ask the opened book to relayout.
                        [[BookNavigationHelper sharedInstance] updateBookNavigationWithRecipe:self.recipe
                                                                                   completion:^{
                                                                                       
                                                                                       // Set 100% progress completion.
                                                                                       [weakProgressView setProgress:1.0 delay:0.5 completion:^{
                                                                                           
                                                                                           // Run completion.
                                                                                           if (completion != nil) {
                                                                                               completion();
                                                                                           }
                                                                                           
                                                                                       }];
                                                                                       
                                                                                   }];
                    } failure:^(NSError *error) {
                           
                           // Run failure.
                           if (failure != nil) {
                               failure(error);
                           }
                           
                    }];
}


- (void)initRecipeDetails {
    
    // TODO testing missing data.
//    self.recipe.story = nil;
//    self.recipe.name = nil;
//    self.recipe.method = nil;
//    self.recipe.ingredients = nil;
    
    // Create transfer object to display/edit.
    self.recipeDetails = [[RecipeDetails alloc] initWithRecipe:self.recipe];
    
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
        [self enableEditModeWithoutInformingRecipeDetailsView:enable];
        [self.recipeDetailsView enableEditMode:enable];
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
    self.scrollView.contentSize = self.recipeDetailsView.frame.size;
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
    if (show) {
        self.overlayView = [[UIView alloc] initWithFrame:self.view.bounds];
        self.overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.overlayView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.7];
        self.overlayView.userInteractionEnabled = YES;  // To block touches.
        self.overlayView.alpha = 0.0;
        [self.view addSubview:self.overlayView];
        
        // Add progress view.
        CGFloat statusBarOffset = 20.0;
        CGFloat topOffset = [self offsetForViewport:SnapViewportTop];
        CKProgressView *progressView = [[CKProgressView alloc] initWithWidth:300.0];
        progressView.frame = CGRectMake(floorf((self.overlayView.bounds.size.width - progressView.frame.size.width) / 2.0),
                                        statusBarOffset + floorf((topOffset - statusBarOffset - progressView.frame.size.height) / 2.0),
                                        progressView.frame.size.width,
                                        progressView.frame.size.height);
        [self.overlayView addSubview:progressView];
        self.progressView = progressView;
    }
    
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.overlayView.alpha = show ? 1.0 : 0.0;
                     }
                     completion:^(BOOL finished) {
                         if (show) {
                             
                             // Mark 10% progress to start off with.
                             [self.progressView setProgress:0.1];
                             
                         } else {
                             
                             [self.overlayView removeFromSuperview];
                             self.overlayView = nil;
                         }
                         
                         if (completion != nil) {
                             completion();
                         }
                     }];
}

- (void)performDynamicBlur {
    [self performDynamicBlurInsideTransaction:NO];
}

- (void)performDynamicBlurInsideTransaction:(BOOL)insideTransaction {
    [self performDynamicBlurInsideTransaction:insideTransaction proposedScrollViewBounds:self.scrollView.bounds];
}

- (void)performDynamicBlurInsideTransaction:(BOOL)insideTransaction proposedScrollViewBounds:(CGRect)scrollViewBounds {
    if (self.blur) {
        
        // From Fun with Masks: https://github.com/evanwdavis/Fun-with-Masks
        // Without the CATransaction the mask's frame setting is actually slighty animated, appearing to give it a delay as we scroll around.
        // This disables implicit animation.
        if (!insideTransaction) {
            [CATransaction begin];
            [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
        }
        self.blurredMaskLayer.frame = [self blurredFrameForProposedScrollViewBounds:scrollViewBounds];
        if (!insideTransaction) {
            [CATransaction commit];
        }
    }
}

- (CGRect)blurredFrameForProposedScrollViewBounds:(CGRect)bounds {
    CGRect headerFrame = (CGRect){
        bounds.origin.x,
        bounds.origin.y,
        bounds.size.width,
        kHeaderHeight
    };
    CGRect headerFrameRootView = [self.scrollView convertRect:headerFrame toView:self.view];
    return [self.view convertRect:headerFrameRootView toView:self.imageView];
}

@end
