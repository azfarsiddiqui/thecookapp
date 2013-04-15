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
#import "ViewHelper.h"
#import "ParsePhotoStore.h"
#import "CKUserProfilePhotoView.h"
#import "Theme.h"
#import "CKRecipeSocialView.h"
#import "MRCEnumerable.h"
#import "Ingredient.h"
#import "RecipeSocialViewController.h"
#import "CKPopoverViewController.h"
#import "CKEditViewController.h"
#import "CKEditingTextBoxView.h"
#import "CKEditingViewHelper.h"
#import "CKTextFieldEditViewController.h"
#import "CKPhotoPickerViewController.h"
#import "UIImage+ProportionalFill.h"
#import "CKEditingTextBoxView.h"
#import "AppHelper.h"

typedef enum {
	PhotoWindowHeightMin,
	PhotoWindowHeightMid,
	PhotoWindowHeightMax,
	PhotoWindowHeightFullScreen,
} PhotoWindowHeight;

@interface RecipeViewController () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate,
    CKRecipeSocialViewDelegate, CKPopoverViewControllerDelegate, CKEditViewControllerDelegate,
    CKEditingTextBoxViewDelegate, CKPhotoPickerViewControllerDelegate>

@property (nonatomic, strong) CKRecipe *recipe;
@property (nonatomic, strong) CKBook *book;
@property(nonatomic, assign) id<BookModalViewControllerDelegate> modalDelegate;
@property (nonatomic, strong) CKPopoverViewController *popoverViewController;

@property (nonatomic, strong) UIView *topShadowView;
@property (nonatomic, strong) UIView *contentContainerView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *windowView;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) CKUserProfilePhotoView *profilePhotoView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *servesCookView;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, assign) PhotoWindowHeight photoWindowHeight;
@property (nonatomic, assign) PhotoWindowHeight previousPhotoWindowHeight;
@property (nonatomic, assign) BOOL editMode;
@property (nonatomic, assign) BOOL saveRequired;
@property (nonatomic, strong) UIView *navContainerView;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *editButton;
@property (nonatomic, strong) UIButton *shareButton;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *storyLabel;
@property (nonatomic, strong) UILabel *methodLabel;
@property (nonatomic, strong) UILabel *ingredientsLabel;
@property (nonatomic, strong) UILabel *photoLabel;
@property (nonatomic, strong) CKRecipeSocialView *socialView;

@property (nonatomic, strong) ParsePhotoStore *parsePhotoStore;

@property (nonatomic, strong) CKEditViewController *editViewController;
@property (nonatomic, strong) CKEditingViewHelper *editingHelper;

@property (nonatomic, strong) CKPhotoPickerViewController *photoPickerViewController;
@property (nonatomic, strong) UIImage *recipeImageToUpload;

@end

@implementation RecipeViewController

#define kWindowMinHeight        70.0
#define kWindowMidHeight        260.0
#define kWindowMinSnapOffset    175.0
#define kWindowMaxSnapOffset    400.0
#define kWindowBounceOffset     10.0
#define kPhotoOffset            20.0

#define kHeaderHeight           210.0
#define kContentMaxHeight       468.0
#define kContentMaxWidth        660.0
#define kContentCellId          @"kContentCellId"
#define kWindowSection          0
#define kContentSection         1

#define kButtonInsets  UIEdgeInsetsMake(15.0, 20.0, 15.0, 20.0)

- (id)initWithRecipe:(CKRecipe *)recipe book:(CKBook *)book {
    if (self = [super init]) {
        self.recipe = recipe;
        self.book = book;
        self.parsePhotoStore = [[ParsePhotoStore alloc]init];
        self.editingHelper = [[CKEditingViewHelper alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight;
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self initContentContainerView];
    [self initHeaderView];
    [self initTableView];
    [self initContentView];
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
            
            // Fade in the top shadow.
            [UIView animateWithDuration:0.4
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 self.topShadowView.alpha = 1.0;
                             }
                             completion:^(BOOL finished) {
                             }];
            
            // Load stuff.
            [self updateButtons];
            [self loadPhoto];
            [self loadData];
        }];
        
        
    } else {
    }
}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"Content Offset: %@", NSStringFromCGPoint(scrollView.contentOffset));
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kContentCellId forIndexPath:indexPath];
    cell.contentView.backgroundColor = [Theme recipeViewBackgroundColour];
//    cell.contentView.backgroundColor = [UIColor greenColor];
    
    // Reset the contentView.
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.contentView.frame = CGRectMake(floorf((cell.contentView.bounds.size.width - self.contentView.frame.size.width) / 2.0),
                                        0.0,
                                        self.contentView.frame.size.width,
                                        self.contentView.frame.size.height);
    [cell.contentView addSubview:self.contentView];
    return cell;
}

#pragma mark - UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kContentMaxHeight;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Unselectable.
    return nil;
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    BOOL shouldReceive = !self.editMode;
    return shouldReceive;
}

#pragma mark - CKRecipeSocialViewDelegate methods

- (void)recipeSocialViewTapped {
    RecipeSocialViewController *socialViewController = [[RecipeSocialViewController alloc] initWithRecipe:self.recipe];
    CKPopoverViewController *popoverViewController = [[CKPopoverViewController alloc] initWithContentViewController:socialViewController
                                                                                                           delegate:self];
    [popoverViewController showInView:self.view direction:CKPopoverViewControllerTop
                              atPoint:CGPointMake(self.socialView.center.x,
                                                  self.socialView.frame.origin.y + self.socialView.frame.size.height + 10.0)];
    self.popoverViewController = popoverViewController;
}

#pragma mark - CKPopoverViewControllerDelegate methods

- (void)popoverViewController:(CKPopoverViewController *)popoverViewController willAppear:(BOOL)appear {
}

- (void)popoverViewController:(CKPopoverViewController *)popoverViewController didAppear:(BOOL)appear {
    if (!appear) {
        self.popoverViewController = nil;
    }
}

#pragma mark - CKEditingTextBoxViewDelegate methods

- (void)editingTextBoxViewTappedForEditingView:(UIView *)editingView {
    if (editingView == self.titleLabel) {
        CKTextFieldEditViewController *editViewController = [[CKTextFieldEditViewController alloc] initWithEditView:editingView
                                                                                                           delegate:self
                                                                                                      editingHelper:self.editingHelper
                                                                                                              white:YES
                                                                                                              title:@"Name"
                                                                                                     characterLimit:30];
        editViewController.fontSize = 48.0;
        [editViewController performEditing:YES];
        self.editViewController = editViewController;
        
    } else if (editingView == self.photoLabel) {
        
        [self snapContentToPhotoWindowHeight:PhotoWindowHeightFullScreen completion:^{
            [self showPhotoPicker:YES];
        }];
    }
}

#pragma mark - CKEditViewControllerDelegate methods

- (void)editViewControllerWillAppear:(BOOL)appear {
    DLog(@"%@", appear ? @"YES" : @"NO");
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

- (void)editViewControllerEditRequested {
    // TODO REMOVE
}

- (void)editViewControllerUpdateEditView:(UIView *)editingView value:(id)value {
    
    if (editingView == self.titleLabel) {
        
        // Get updated value and update label.
        NSString *text = (NSString *)value;
        if (![text isEqualToString:self.titleLabel.text]) {
            
            // Update title.
            [self setTitle:text];
            
            // Mark save is required.
            self.saveRequired = YES;
            
            // Update the editing wrapper.
            [self.editingHelper updateEditingView:self.titleLabel animated:NO];
        }
    }
    
}

#pragma mark - CKPhotoPickerViewControllerDelegate methods

- (void)photoPickerViewControllerSelectedImage:(UIImage *)image {
    // Present the image.
    UIImage *croppedImage = [image imageCroppedToFitSize:self.backgroundImageView.bounds.size];
    self.backgroundImageView.image = croppedImage;
    
    // Save photo to be uploaded.
    self.recipeImageToUpload = image;
    
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

#pragma mark - Lazy getters.

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [ViewHelper buttonWithImage:[UIImage imageNamed:@"cook_book_icon_close_white.png"]
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
        _editButton = [ViewHelper buttonWithImage:[UIImage imageNamed:@"cook_book_icon_edit.png"]
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
        _shareButton = [ViewHelper buttonWithImage:[UIImage imageNamed:@"cook_book_icon_share_white.png"]
                                           target:self
                                         selector:@selector(shareTapped:)];
        _shareButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin;
        _shareButton.frame = CGRectMake(self.view.frame.size.width - kButtonInsets.right - _shareButton.frame.size.width,
                                       kButtonInsets.top,
                                       _shareButton.frame.size.width,
                                       _shareButton.frame.size.height);
    }
    return _shareButton;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [ViewHelper buttonWithImage:[UIImage imageNamed:@"cook_customise_btns_cancel.png"]
                                             target:self
                                           selector:@selector(cancelTapped:)];
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
        _saveButton = [ViewHelper buttonWithImage:[UIImage imageNamed:@"cook_customise_btns_done.png"]
                                            target:self
                                          selector:@selector(saveTapped:)];
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
                                                  text:[NSString stringWithFormat:@"Serves %d", self.recipe.numServes]];
        UIView *prepCookView = [self iconTextViewForIcon:[UIImage imageNamed:@"cook_book_icon_time.png"]
                                                  text:[NSString stringWithFormat:@"Prep %dm | Cook %dm",
                                                        self.recipe.prepTimeInMinutes, self.recipe.cookingTimeInMinutes]];
        CGRect prepCookFrame = prepCookView.frame;
        prepCookFrame.origin.y = servesView.frame.origin.y + servesView.frame.size.height + iconOffset;
        prepCookView.frame = prepCookFrame;
        
        _servesCookView = [[UIView alloc] initWithFrame:CGRectUnion(servesView.frame, prepCookView.frame)];
        [_servesCookView addSubview:servesView];
        [_servesCookView addSubview:prepCookView];
    }
    return _servesCookView;
}

- (UILabel *)photoLabel {
    if (!_photoLabel) {
        _photoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _photoLabel.font = [UIFont boldSystemFontOfSize:16.0];
        _photoLabel.backgroundColor = [UIColor clearColor];
        _photoLabel.textColor = [UIColor blackColor];
        _photoLabel.text = @"PHOTO";
        [_photoLabel sizeToFit];
        _photoLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin;
        [_photoLabel setFrame:CGRectMake(floorf((self.view.bounds.size.width - _photoLabel.frame.size.width) / 2.0),
                                         floorf((kWindowMidHeight - _photoLabel.frame.size.height) / 2.0) + 20.0,
                                         _photoLabel.frame.size.width,
                                         _photoLabel.frame.size.height)];
    }
    return _photoLabel;
}

#pragma mark - Private methods

- (NSString *)ingredientsText {
    NSArray *ingredientsDisplay = [self.recipe.ingredients collect:^id(Ingredient *ingredient) {
        return [NSString stringWithFormat:@"%@ %@",
                ingredient.measurement ? ingredient.measurement : @"",
                ingredient.name ? ingredient.name : @""];
    }];
    return [ingredientsDisplay componentsJoinedByString:@""];
}

- (UIView *)iconTextViewForIcon:(UIImage *)icon text:(NSString *)text {
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
    [servesLabel sizeToFit];
    
    // Position them
    CGFloat maxHeight = MAX(servesIconView.frame.size.height, servesLabel.frame.size.height) + edgeInsets.top + edgeInsets.bottom;
    servesIconView.frame = CGRectMake(edgeInsets.left,
                                      floorf((maxHeight - servesIconView.frame.size.height) / 2.0),
                                      servesIconView.frame.size.width,
                                      servesIconView.frame.size.height);
    servesLabel.frame = CGRectMake(servesIconView.frame.origin.x + servesIconView.frame.size.width + iconTextGap,
                                   floorf((maxHeight - servesLabel.frame.size.height) / 2.0),
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
        [self snapContentToPhotoWindowHeight:[self nextDownPhotoWindowHeight]];
    } else if (direction == UISwipeGestureRecognizerDirectionDown) {
        [self snapContentToPhotoWindowHeight:[self nextUpPhotoWindowHeight]];
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
    [self snapContentToPhotoWindowHeight:photoWindowHeight];
}

- (void)snapContentToPhotoWindowHeight:(PhotoWindowHeight)photoWindowHeight {
    [self snapContentToPhotoWindowHeight:photoWindowHeight completion:NULL];
}

- (void)snapContentToPhotoWindowHeight:(PhotoWindowHeight)photoWindowHeight completion:(void (^)())completion {
    CGFloat snapDuration = 0.15;
    CGFloat bounceDuration = 0.2;
    
    // Remember previous/current state.
    self.previousPhotoWindowHeight = self.photoWindowHeight;
    self.photoWindowHeight = photoWindowHeight;
    
    // Target contentFrame to snap to.
    CGRect contentFrame = [self contentFrameForPhotoWindowHeight:photoWindowHeight];
    CGRect imageFrame = [self imageFrameForPhotoWindowHeight:photoWindowHeight];
    
    // Figure out the required bounce in the same direction.
    CGFloat bounceOffset = kWindowBounceOffset;
    bounceOffset *= (self.photoWindowHeight > self.previousPhotoWindowHeight) ? 1.0 : -1.0;
    CGRect bounceFrame = contentFrame;
    bounceFrame.origin.y += bounceOffset;
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
                                              
                                              // Run completion block.
                                              if (completion != NULL) {
                                                  completion();
                                              }
                          
                                          }];
                     }];
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
    UIView *contentContainerView = [[UIView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x,
                                                                            kWindowMidHeight,
                                                                            self.view.bounds.size.width,
                                                                            self.view.bounds.size.height - kWindowMidHeight)];
    contentContainerView.backgroundColor = [UIColor clearColor];
    contentContainerView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:contentContainerView];
    self.contentContainerView = contentContainerView;
    
    // Register pan on the content container.
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
    panGesture.delegate = self;
    [contentContainerView addGestureRecognizer:panGesture];
    
    // Register swipes.
    UISwipeGestureRecognizer *upSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swiped:)];
    upSwipeGesture.delegate = self;
    upSwipeGesture.direction = UISwipeGestureRecognizerDirectionDown;
    [contentContainerView addGestureRecognizer:upSwipeGesture];
    
    UISwipeGestureRecognizer *downSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swiped:)];
    downSwipeGesture.delegate = self;
    downSwipeGesture.direction = UISwipeGestureRecognizerDirectionDown;
    [contentContainerView addGestureRecognizer:downSwipeGesture];
}

- (void)initHeaderView {
    UIImage *headerImage = [[UIImage imageNamed:@"cook_recipe_background_tile.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:52.0];
    UIImageView *headerView = [[UIImageView alloc] initWithImage:headerImage];
    headerView.frame = CGRectMake(self.contentContainerView.bounds.origin.x,
                                  self.contentContainerView.bounds.origin.y,
                                  self.contentContainerView.bounds.size.width,
                                  kHeaderHeight);
    headerView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth;
    headerView.backgroundColor = [UIColor clearColor];
    headerView.userInteractionEnabled = YES;
    [self.contentContainerView addSubview:headerView];
    self.headerView = headerView;
    
    // Profile photo.
    CKUserProfilePhotoView *profilePhotoView = [[CKUserProfilePhotoView alloc] initWithUser:self.book.user
                                                                                profileSize:ProfileViewSizeSmall];
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
    
    // Lay them out side-by-side.
    CGFloat photoNameOffset = 10.0;
    CGFloat combinedWidth = profilePhotoView.frame.size.width + 5.0 + nameLabel.frame.size.width;
    nameLabel.frame = CGRectMake(floorf((headerView.bounds.size.width - combinedWidth) / 2.0) + profilePhotoView.frame.size.width + photoNameOffset,
                                 40.0,
                                 nameLabel.frame.size.width,
                                 nameLabel.frame.size.height);
    profilePhotoView.frame = CGRectMake(floorf((headerView.bounds.size.width - combinedWidth) / 2.0),
                                        nameLabel.center.y - floorf(profilePhotoView.frame.size.height / 2.0) - 2.0,
                                        profilePhotoView.frame.size.width,
                                        profilePhotoView.frame.size.height);
    self.profilePhotoView = profilePhotoView;
    [headerView addSubview:profilePhotoView];
    [headerView addSubview:nameLabel];
    
    // Recipe title.
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.font = [Theme recipeNameFont];
    titleLabel.textColor = [Theme recipeNameColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
    titleLabel.shadowColor = [UIColor whiteColor];
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth;
    [headerView addSubview:titleLabel];
    self.titleLabel = titleLabel;
    [self setTitle:[self.recipe.name uppercaseString]];
    
    // Recipe story.
    CGFloat titleStoryGap = 0.0;
    CGSize storyAvailableSize = CGSizeMake(kContentMaxWidth, headerView.bounds.size.height - titleLabel.frame.origin.y - titleLabel.frame.size.height);
    NSString *story = self.recipe.story;
    CGSize size = [story sizeWithFont:[Theme storyFont] constrainedToSize:storyAvailableSize lineBreakMode:NSLineBreakByWordWrapping];
    UILabel *storyLabel = [[UILabel alloc] initWithFrame:CGRectMake(floorf((headerView.bounds.size.width - size.width) / 2.0),
                                                                    titleLabel.frame.origin.y + titleLabel.frame.size.height + titleStoryGap,
                                                                    size.width,
                                                                    size.height)];
    storyLabel.font = [Theme storyFont];
    storyLabel.numberOfLines = 2;
    storyLabel.textAlignment = NSTextAlignmentCenter;
    storyLabel.textColor = [Theme storyColor];
    storyLabel.backgroundColor = [UIColor clearColor];
    storyLabel.shadowOffset = CGSizeMake(0.0, 1.0);
    storyLabel.shadowColor = [UIColor whiteColor];
    storyLabel.text = story;
    storyLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
    [headerView addSubview:storyLabel];
    self.storyLabel = storyLabel;

    // Register tap on headerView for tap expand.
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerTapped:)];
    tapGesture.delegate = self;
    [headerView addGestureRecognizer:tapGesture];
}

- (void)initTableView {
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(self.contentContainerView.bounds.origin.x,
                                                                           self.headerView.frame.origin.y + self.headerView.frame.size.height,
                                                                           self.contentContainerView.bounds.size.width,
                                                                           self.contentContainerView.bounds.size.height - self.headerView.frame.size.height)];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.userInteractionEnabled = NO;
    [self.contentContainerView addSubview:tableView];
    self.tableView = tableView;
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kContentCellId];
}

- (void)initContentView {
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(20.0, 20.0, 20.0, 20.0);
    CGRect leftFrame = CGRectMake(0.0, 0.0, 240.0, 0.0);
    CGRect rightFrame = CGRectMake(240.0, 0.0, 420.0, 0.0);
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, kContentMaxWidth, 0.0)];
    CGRect contentFrame = contentView.frame;
    
    CGFloat requiredLeftHeight = 0.0;
    CGFloat requiredRightHeight = 0.0;
    CGFloat dividerGap = 18.0;
    
    // Left Frame: Serves
    self.servesCookView.frame = CGRectMake(contentInsets.left,
                                           contentInsets.top,
                                           self.servesCookView.frame.size.width,
                                           self.servesCookView.frame.size.height);
    [contentView addSubview:self.servesCookView];
    requiredLeftHeight += contentInsets.top + self.servesCookView.frame.size.height;
    
    // Left Frame: Divider.
    UIImageView *dividerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_recipe_details_divider.png"]];
    dividerImageView.frame = CGRectMake(floorf((leftFrame.size.width - dividerImageView.frame.size.width) / 2.0),
                                        requiredLeftHeight + dividerGap,
                                        dividerImageView.frame.size.width,
                                        dividerImageView.frame.size.height);
    [contentView addSubview:dividerImageView];
    requiredLeftHeight += dividerGap + dividerImageView.frame.size.height;
    
    // Left Frame: Ingredients
    CGSize ingredientsAvailableSize = CGSizeMake(leftFrame.size.width - contentInsets.left - contentInsets.right, MAXFLOAT);
    NSAttributedString *ingredientsDisplay = [self attributedTextForText:[self ingredientsText] font:[Theme ingredientsListFont] colour:[Theme ingredientsListColor]];
    UILabel *ingredientsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    ingredientsLabel.numberOfLines = 0;
    ingredientsLabel.backgroundColor = [UIColor clearColor];
    ingredientsLabel.lineBreakMode = NSLineBreakByWordWrapping;
    ingredientsLabel.textAlignment = NSTextAlignmentLeft;
    ingredientsLabel.attributedText = ingredientsDisplay;
    CGSize size = [ingredientsLabel sizeThatFits:ingredientsAvailableSize];
    ingredientsLabel.frame = CGRectMake(leftFrame.origin.x + contentInsets.left + floorf((ingredientsAvailableSize.width - size.width) / 2.0),
                                        requiredLeftHeight + dividerGap,
                                        size.width,
                                        size.height);
    [contentView addSubview:ingredientsLabel];
    self.ingredientsLabel = ingredientsLabel;
    requiredLeftHeight += dividerGap + ingredientsLabel.frame.size.height;
    requiredLeftHeight += contentInsets.bottom;
    
    // Right Frame.
    CGSize methodAvailableSize = CGSizeMake(rightFrame.size.width - contentInsets.left - contentInsets.right, MAXFLOAT);
    NSAttributedString *storyDisplay = [self attributedTextForText:self.recipe.description font:[Theme methodFont] colour:[Theme methodColor]];
    UILabel *methodLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    methodLabel.numberOfLines = 0;
    methodLabel.lineBreakMode = NSLineBreakByWordWrapping;
    methodLabel.textAlignment = NSTextAlignmentLeft;
    methodLabel.backgroundColor = [UIColor clearColor];
    methodLabel.attributedText = storyDisplay;
    size = [methodLabel sizeThatFits:methodAvailableSize];
    methodLabel.frame = CGRectMake(rightFrame.origin.x + contentInsets.left + floorf((methodAvailableSize.width - size.width) / 2.0),
                                   rightFrame.origin.y + contentInsets.top,
                                   size.width,
                                   size.height);
    [contentView addSubview:methodLabel];
    self.methodLabel = methodLabel;
    
    requiredRightHeight += contentInsets.top + methodLabel.frame.size.height;
    requiredRightHeight += contentInsets.bottom;
    
    // Adjust contentView frame.
    contentFrame.size.height = MAX(requiredLeftHeight, requiredRightHeight);
    self.contentView.frame = contentFrame;
    self.contentView = contentView;
}

- (void)initBackgroundImageView {
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:nil];
    backgroundImageView.userInteractionEnabled = YES;
    backgroundImageView.backgroundColor = [UIColor clearColor];
    backgroundImageView.frame = self.view.bounds;
    backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view insertSubview:backgroundImageView belowSubview:self.contentContainerView];
    self.backgroundImageView = backgroundImageView;
    
    // Top shadow.
    UIImageView *topShadowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_recipe_background_overlay.png"]];
    topShadowView.frame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, topShadowView.frame.size.height);
    topShadowView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth;
    [self.view insertSubview:topShadowView aboveSubview:self.backgroundImageView];
    topShadowView.alpha = 0.0;
    self.topShadowView = topShadowView;
    
    // Register tap on headerView for tap expand.
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(windowTapped:)];
    tapGesture.delegate = self;
    [backgroundImageView addGestureRecognizer:tapGesture];
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
                                                                            kWindowMinHeight)];
        navContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
        [self.view addSubview:navContainerView];
        self.navContainerView = navContainerView;
    }
    
    
    if (self.editMode) {
        self.cancelButton.alpha = 0.0;
        self.saveButton.alpha = 0.0;
        [self.navContainerView addSubview:self.cancelButton];
        [self.navContainerView addSubview:self.saveButton];
        
        // Photo label and its wrapping.
        self.photoLabel.alpha = 0.0;
        [self.view addSubview:self.photoLabel];
        [self.editingHelper wrapEditingView:self.photoLabel wrap:YES delegate:self white:YES animated:NO];
        
    } else {
        self.closeButton.alpha = 0.0;
        self.socialView.alpha = 0.0;
        self.editButton.alpha = 0.0;
        self.shareButton.alpha = 0.0;
        [self.navContainerView addSubview:self.closeButton];
        [self.navContainerView addSubview:self.socialView];
        [self.navContainerView addSubview:self.editButton];
        [self.navContainerView addSubview:self.shareButton];
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
                         
                         self.cancelButton.alpha = self.editMode ? buttonsVisibleAlpha : 0.0;
                         self.saveButton.alpha = self.editMode ? buttonsVisibleAlpha : 0.0;
                         self.photoLabel.alpha = self.editMode ? buttonsVisibleAlpha : 0.0;
                         photoBoxView.alpha = self.editMode ? buttonsVisibleAlpha : 0.0;
                         
                         if (self.editMode) {
                             self.cancelButton.transform = CGAffineTransformMakeScale(1.1, 1.1);
                             self.saveButton.transform = CGAffineTransformMakeScale(1.1, 1.1);
                         }
                     }
                     completion:^(BOOL finished)  {
                         if (self.editMode) {
                             [self.closeButton removeFromSuperview];
                             [self.socialView removeFromSuperview];
                             [self.editButton removeFromSuperview];
                             [self.shareButton removeFromSuperview];
                             
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
                             
                             // Unwrap editing wrapper.
                             [self.editingHelper wrapEditingView:self.photoLabel wrap:NO white:YES];
                             [self.photoLabel removeFromSuperview];
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
    self.saveRequired = NO;
    [self enableEditMode:NO];
}

- (void)saveTapped:(id)sender {
    
    // Save any changes off.
    if (self.saveRequired) {
        self.recipe.name = self.titleLabel.text;
        [self.recipe saveInBackground];
    }
    
    [self enableEditMode:NO];
    
    // Reset save flag.
    self.saveRequired = NO;
}

- (void)loadPhoto {
    if ([self.recipe hasPhotos]) {
        [self.parsePhotoStore imageForParseFile:[self.recipe imageFile]
                                           size:self.backgroundImageView.bounds.size
                                     completion:^(UIImage *image) {
                                         self.backgroundImageView.image = image;
                                         self.backgroundImageView.alpha = 0.0;
                                         [UIView animateWithDuration:0.4
                                                               delay:0.0
                                                             options:UIViewAnimationOptionCurveEaseIn
                                                          animations:^{
                                                              self.backgroundImageView.alpha = 1.0;
                                                          }
                                                          completion:^(BOOL finished)  {
                                                              
                                                              // Set the background to be white opaque.
                                                              self.view.backgroundColor = [Theme recipeViewBackgroundColour];
                                                              
                                                          }];
        }];
    }
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
    
    // TODO Load data.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        CKRecipeSocialView *socialView = [[CKRecipeSocialView alloc] initWithNumComments:0 numLikes:0 delegate:self];
        socialView.frame = CGRectMake(floorf((self.view.bounds.size.width - socialView.frame.size.width) / 2.0),
                                      kButtonInsets.top,
                                      socialView.frame.size.width,
                                      socialView.frame.size.height);
        socialView.alpha = 0.0;
        [self.view addSubview:socialView];
        self.socialView = socialView;
        
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

- (BOOL)canEditRecipe {
    return ([self.book.user isEqual:[CKUser currentUser]]);
}

- (NSDictionary *)paragraphAttributesForFont:(UIFont *)font colour:(UIColor *)colour {
    NSLineBreakMode lineBreakMode = NSLineBreakByWordWrapping;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = lineBreakMode;
    paragraphStyle.lineSpacing = 10.0;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    
    return [NSDictionary dictionaryWithObjectsAndKeys:
            font, NSFontAttributeName,
            colour, NSForegroundColorAttributeName,
            paragraphStyle, NSParagraphStyleAttributeName,
            nil];
}

- (NSMutableAttributedString *)attributedTextForText:(NSString *)text font:(UIFont *)font colour:(UIColor *)colour {
    text = [text length] > 0 ? text : @"";
    NSDictionary *paragraphAttributes = [self paragraphAttributesForFont:font colour:colour];
    return [[NSMutableAttributedString alloc] initWithString:text attributes:paragraphAttributes];
}

- (PhotoWindowHeight)startWindowHeight {
    PhotoWindowHeight windowHeight = PhotoWindowHeightMid;
    if (!self.recipe) {
        windowHeight = PhotoWindowHeightMid;
    } else if (![self.recipe hasPhotos]) {
        windowHeight = PhotoWindowHeightMin;
    }
    return windowHeight;
}

- (void)enableEditMode:(BOOL)enable {
    self.editMode = enable;
    
    // Snap to mid height then toggle buttons.
    if (enable && self.photoWindowHeight != PhotoWindowHeightMid) {
        [self snapContentToPhotoWindowHeight:kWindowMidHeight completion:^{
            [self updateButtons];
        }];
    } else {
        [self updateButtons];
    }
    
    // Set fields to be editable.
    [self.editingHelper wrapEditingView:self.titleLabel wrap:enable
                          contentInsets:UIEdgeInsetsMake(10.0, 20.0, 2.0, 20.0) delegate:self white:YES];
    
}

- (void)setTitle:(NSString *)title {
    self.titleLabel.text = title;
    [self.titleLabel sizeToFit];
    self.titleLabel.frame = CGRectMake(floorf((self.headerView.bounds.size.width - self.titleLabel.frame.size.width) / 2.0),
                                       self.profilePhotoView.frame.origin.y + self.profilePhotoView.frame.size.height + 10.0,
                                       self.titleLabel.frame.size.width,
                                       self.titleLabel.frame.size.height);
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

@end
