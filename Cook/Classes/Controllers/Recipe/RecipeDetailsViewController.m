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
#import "ParsePhotoStore.h"
#import "ViewHelper.h"
#import "CKBookCover.h"
#import "CKBook.h"
#import "ImageHelper.h"
#import "EventHelper.h"
#import "CKLikeView.h"
#import "CKPrivacySliderView.h"
#import "CKRecipeSocialView.h"
#import "CKEditingViewHelper.h"
#import "BookSocialViewController.h"
#import "Theme.h"

typedef NS_ENUM(NSUInteger, SnapViewport) {
    SnapViewportTop,
    SnapViewportBottom,
    SnapViewportBelow
};

@interface RecipeDetailsViewController () <UIScrollViewDelegate, UIGestureRecognizerDelegate,
    CKRecipeSocialViewDelegate, BookSocialViewControllerDelegate, RecipeDetailsViewDelegate>

@property (nonatomic, strong) CKRecipe *recipe;
@property (nonatomic, strong) RecipeDetails *recipeDetails;
@property (nonatomic, strong) CKBook *book;
@property (nonatomic, weak) id<BookModalViewControllerDelegate> modalDelegate;
@property (nonatomic, strong) ParsePhotoStore *photoStore;

// Blurring artifacts.
@property (nonatomic, assign) BOOL blur;
@property (nonatomic, strong) UIImageView *blurredImageView;    // As reference to sample from.
@property (nonatomic, strong) UIView *blurredImageSnapshotView;
@property (nonatomic, strong) UIView *blurredHeaderView;

// Content and panning related.
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *topShadowView;
@property (nonatomic, strong) UIImageView *contentImageView;
@property (nonatomic, strong) RecipeDetailsView *recipeDetailsView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, assign) SnapViewport currentViewport;
@property (nonatomic, assign) SnapViewport previousViewport;
@property (nonatomic, assign) BOOL draggingDown;
@property (nonatomic, assign) BOOL animating;

// Normal controls.
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *editButton;
@property (nonatomic, strong) UIButton *shareButton;
@property (nonatomic, strong) CKLikeView *likeButton;
@property (nonatomic, strong) CKRecipeSocialView *socialView;

// Editing.
@property (nonatomic, assign) BOOL editMode;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong) CKPrivacySliderView *privacyView;
@property (nonatomic, strong) UIView *photoButtonView;
@property (nonatomic, strong) CKEditingViewHelper *editingHelper;

// Social layer.
@property (nonatomic, strong) BookSocialViewController *bookSocialViewController;

@end

@implementation RecipeDetailsViewController

#define kButtonInsets       UIEdgeInsetsMake(22.0, 10.0, 15.0, 20.0)
#define kSnapOffset         100.0
#define kBounceOffset       10.0
#define kContentTopOffset   64.0
#define kHeaderHeight       230.0
#define kDragRatio          0.9
#define kContentImageOffset (UIOffset){ 0.0, -13.0 }

- (id)initWithRecipe:(CKRecipe *)recipe {
    if (self = [super init]) {
        self.recipe = recipe;
        self.book = recipe.book;
        self.photoStore = [[ParsePhotoStore alloc] init];
        self.editingHelper = [[CKEditingViewHelper alloc] init];
        self.blur = NO;
        [self initRecipeDetails];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    
    [self initImageView];
    [self initRecipeDetailsView];
    [self initScrollView];
}

#pragma mark - BookModalViewController methods

- (void)setModalViewControllerDelegate:(id<BookModalViewControllerDelegate>)modalViewControllerDelegate {
    self.modalDelegate = modalViewControllerDelegate;
}

- (void)bookModalViewControllerWillAppear:(NSNumber *)appearNumber {
    DLog();
    [EventHelper postStatusBarChangeForLight:[appearNumber boolValue]];
}

- (void)bookModalViewControllerDidAppear:(NSNumber *)appearNumber {
    DLog();
    
    if ([appearNumber boolValue]) {
        
        // Snap to the start viewport.
        [self snapToViewport:[self startViewPort] animated:YES completion:^{
            
            // Load stuff.
            [self updateButtons];
            [self loadData];
            
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
                     }
                     completion:^(BOOL finished)  {
                     }];
}

- (void)recipeDetailsViewUpdated {
    [self updateRecipeDetailsView];
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    BOOL shouldReceiveTouch = YES;
    
    // Ignore taps on background image view when in edit mode.
    if (self.editMode && gestureRecognizer.view == self.imageView) {
        shouldReceiveTouch = NO;
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
    NSLog(@"contentOffset %f", scrollView.contentOffset.y);
    
    CGRect contentFrame = self.scrollView.frame;
    CGPoint contentOffset = scrollView.contentOffset;
    
    // Scroll view is now pulling its own frame down.
    if (contentOffset.y <= 0) {
        
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
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    NSLog(@"scrollViewWillBeginDragging");
    NSLog(@"scrollEnabled: %@", scrollView.scrollEnabled ? @"YES" : @"NO");
    NSLog(@"panGesture   : %@", self.panGesture.enabled ? @"YES" : @"NO");
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    NSLog(@"scrollViewDidEndDragging willDecelerate[%@]", decelerate ? @"YES" : @"NO");
    [self panSnapIfRequired];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSLog(@"scrollViewDidEndDecelerating");
    [self panSnapIfRequired];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    NSLog(@"scrollViewDidEndScrollingAnimation");
    [self panSnapIfRequired];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    NSLog(@"scrollViewWillEndDragging velocity[%@]", NSStringFromCGPoint(velocity));
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

#pragma mark - BookSocialViewControllerDelegate methods

- (void)bookSocialViewControllerCloseRequested {
    [self showSocialOverlay:NO];
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
        
        // Register tap onpress.
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoButtonTapped:)];
        [_photoButtonView addGestureRecognizer:tapGesture];
        
    }
    return _photoButtonView;
}

#pragma mark - Private methods

- (void)initImageView {
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    imageView.alpha = 0.0;
    [self.view addSubview:imageView];
    self.imageView = imageView;
    
    if (self.blur) {
        UIImageView *blurredImageView = [[UIImageView alloc] initWithFrame:imageView.frame];
        blurredImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.blurredImageView = blurredImageView;
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
    self.photoButtonView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin;
    [self.imageView addSubview:self.photoButtonView];
    self.photoButtonView.hidden = YES;
    
    // Register tap on background image for tap expand.
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped:)];
    tapGesture.delegate = self;
    self.imageView.userInteractionEnabled = YES;
    [self.imageView addGestureRecognizer:tapGesture];
}

- (void)initRecipeDetailsView {
    RecipeDetailsView *recipeDetailsView = [[RecipeDetailsView alloc] initWithRecipeDetails:self.recipeDetails
                                                                                   delegate:self];
    self.recipeDetailsView = recipeDetailsView;
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
    scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    scrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;
    
    // Add/or update the content view.
    [self updateRecipeDetailsView];
    
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
    
    if (self.blur) {
        UIView *blurredHeaderView = [[UIImageView alloc] initWithFrame:(CGRect){
            self.scrollView.frame.origin.x,
            self.scrollView.frame.origin.y,
            self.scrollView.frame.size.width,
            kHeaderHeight
        }];
        blurredHeaderView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
        blurredHeaderView.backgroundColor = [UIColor greenColor];
        [self.view insertSubview:blurredHeaderView belowSubview:contentImageView];
        self.blurredHeaderView = blurredHeaderView;
    }
    
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
    if (self.blur) {
        self.blurredImageView.frame = imageFrame;
    }
    
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
    if (self.blur) {
        CGRect blurredFrame = self.blurredHeaderView.frame;
        blurredFrame.origin.y = contentFrame.origin.y;
        self.blurredHeaderView.frame = blurredFrame;
        self.blurredImageView.frame = contentBackgroundFrame;
        CGRect intersection = CGRectIntersection(self.blurredHeaderView.frame, self.scrollView.frame);
        
        UIView *blurredSnapshotView = [self.blurredImageSnapshotView resizableSnapshotViewFromRect:intersection
                                                                                afterScreenUpdates:YES
                                                                                     withCapInsets:UIEdgeInsetsZero];
        blurredSnapshotView.frame = blurredFrame;
        blurredSnapshotView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
        [self.view insertSubview:blurredSnapshotView belowSubview:self.contentImageView];
        [self.blurredHeaderView removeFromSuperview];
        self.blurredHeaderView = blurredSnapshotView;
        DLog(@"Intersection %@", NSStringFromCGRect(intersection));
    }
    
}

- (void)loadData {
    [self loadPhoto];
}

- (void)loadPhoto {
    if ([self.recipe hasPhotos]) {
        [self.photoStore imageForParseFile:[self.recipe imageFile]
                                      size:self.imageView.bounds.size
                                completion:^(UIImage *image) {
                                    [self loadImageViewWithPhoto:image placeholder:NO];
                                }];
    } else {
        
        // Load placeholder editing background based on book cover.
        [self loadImageViewWithPhoto:[CKBookCover recipeEditBackgroundImageForCover:self.recipe.book.cover]
                         placeholder:YES];
    }
    
}

- (void)loadImageViewWithPhoto:(UIImage *)image placeholder:(BOOL)placeholder {
    self.imageView.image = image;
    if (self.blur) {
        self.blurredImageView.image = [ImageHelper blurredImage:image tintColour:nil];
        self.blurredImageSnapshotView = [self.blurredImageView snapshotViewAfterScreenUpdates:YES];
    }
    
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.topShadowView.alpha = placeholder ? 0.0 : 1.0;
                         self.imageView.alpha = 1.0;
                     }
                     completion:^(BOOL finished)  {
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
            
            // Do a bounce.
            [UIView animateWithDuration:[self animationDurationFromViewport:currentViewport toViewport:viewport]
                                  delay:0.0
                                options:[self animationCurveFromViewport:currentViewport toViewport:viewport]
                             animations:^{
                                 self.scrollView.frame = bounceFrame;
                                 [self updateButtonsWithBounceOffset:buttonBounceOffset];
                             }
                             completion:^(BOOL finished) {
                                 
                                 // Rest on intended frame.
                                 [UIView animateWithDuration:0.1
                                                       delay:0.0
                                                     options:UIViewAnimationOptionCurveEaseIn
                                                  animations:^{
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
            
            [UIView animateWithDuration:[self animationDurationFromViewport:currentViewport toViewport:viewport]
                                  delay:0.0
                                options:[self animationCurveFromViewport:currentViewport toViewport:viewport]
                             animations:^{
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
    if (self.recipe && ![self.recipe hasPhotos]) {
        startViewPort = SnapViewportTop;
    }
    
    // TODO comment this out after dev.
    startViewPort = SnapViewportTop;
    
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
        UIEdgeInsets contentInsets = [CKEditingViewHelper contentInsetsForEditMode:NO];
        [self.editingHelper wrapEditingView:self.photoButtonView delegate:nil white:YES editMode:NO animated:NO];
        CKEditingTextBoxView *photoBoxView = [self.editingHelper textBoxViewForEditingView:self.photoButtonView];
        self.photoButtonView.hidden = NO;
        self.photoButtonView.alpha = 0.0;
        photoBoxView.alpha = 0.0;
        
        self.cancelButton.alpha = 0.0;
        self.privacyView.alpha = 0.0;
        self.saveButton.alpha = 0.0;
        self.cancelButton.transform = CGAffineTransformMakeTranslation(0.0, -self.cancelButton.frame.size.height);
        self.saveButton.transform = CGAffineTransformMakeTranslation(0.0, -self.cancelButton.frame.size.height);
        [self.view addSubview:self.cancelButton];
        [self.view addSubview:self.privacyView];
        [self.view addSubview:self.saveButton];
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
                         
                         self.cancelButton.alpha = self.editMode ? alpha : 0.0;
                         self.saveButton.alpha = self.editMode ? alpha : 0.0;
                         self.cancelButton.transform = self.editMode ? CGAffineTransformIdentity : CGAffineTransformMakeTranslation(0.0, -self.cancelButton.frame.size.height);
                         self.saveButton.transform = self.editMode ? CGAffineTransformIdentity : CGAffineTransformMakeTranslation(0.0, -self.cancelButton.frame.size.height);
                     }
                     completion:^(BOOL finished)  {
                         if (self.editMode) {
                             [self.closeButton removeFromSuperview];
                             [self.socialView removeFromSuperview];
                             [self.editButton removeFromSuperview];
                             [self.shareButton removeFromSuperview];
                             [self.likeButton removeFromSuperview];
                         } else {
                             self.photoButtonView.hidden = YES;
                             [self.editingHelper unwrapEditingView:self.photoButtonView];

                             [self.cancelButton removeFromSuperview];
                             [self.saveButton removeFromSuperview];
                             [self.privacyView removeFromSuperview];
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
    [self enableEditMode:YES];
}

- (void)shareTapped:(id)sender {
    DLog();
}

- (void)cancelTapped:(id)sender {
    DLog();
    [self initRecipeDetails];
    [self enableEditMode:NO];
}

- (void)saveTapped:(id)sender {
    DLog();
}

- (void)initRecipeDetails {
    self.recipeDetails = [[RecipeDetails alloc] initWithRecipe:self.recipe];
}

- (void)enableEditMode:(BOOL)enable {
    self.editMode = enable;
    
    // Prepare or discard recipe clipboard.
    [self updateButtons];
    [self.recipeDetailsView enableEditMode:enable];
}

- (void)updateRecipeDetailsView {
    self.scrollView.contentSize = self.recipeDetailsView.frame.size;
    self.recipeDetailsView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
    self.recipeDetailsView.frame = (CGRect){
        floorf((self.scrollView.bounds.size.width - self.recipeDetailsView.frame.size.width) / 2.0),
        self.scrollView.bounds.origin.y,
        self.recipeDetailsView.frame.size.width,
        self.recipeDetailsView.frame.size.height
    };
    NSLog(@"RecipeDetailsView %@", NSStringFromCGRect(self.recipeDetailsView.frame));
    
    if (!self.recipeDetailsView.superview) {
        [self.scrollView addSubview:self.recipeDetailsView];
    }
}

- (void)photoButtonTapped:(UITapGestureRecognizer *)tapGesture {
    DLog();
}

- (CGFloat)currentAlphaForPhotoButtonView {
    CGFloat topOffset = [self offsetForViewport:SnapViewportTop];
    CGFloat bottomOffset = [self offsetForViewport:SnapViewportBottom];
    CGFloat distance = bottomOffset - self.scrollView.frame.origin.y;
    CGFloat effectiveDistance = bottomOffset - topOffset;
    CGFloat requiredAlpha = 1.0 - (distance / effectiveDistance);
    return requiredAlpha;
}

@end
