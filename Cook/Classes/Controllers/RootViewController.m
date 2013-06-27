//
//  CKViewController.m
//  BenchtopDemo
//
//  Created by Jeff Tan-Ang on 29/11/12.
//  Copyright (c) 2012 Cook App Pty Ltd. All rights reserved.
//

#import "RootViewController.h"
#import "PagingBenchtopViewController.h"
#import "StoreViewController.h"
#import "BenchtopViewControllerDelegate.h"
#import "BookCoverViewController.h"
#import "BookNavigationViewController.h"
#import "CKBook.h"
#import "SettingsViewController.h"
#import "TestViewController.h"
#import "BookModalViewController.h"
#import "WelcomeViewController.h"
#import "EventHelper.h"
#import "RecipeViewController.h"
#import "BookNavigationHelper.h"

@interface RootViewController () <BenchtopViewControllerDelegate, BookCoverViewControllerDelegate,
    UIGestureRecognizerDelegate, BookNavigationViewControllerDelegate, WelcomeViewControllerDelegate>

@property (nonatomic, strong) PagingBenchtopViewController *benchtopViewController;
@property (nonatomic, strong) StoreViewController *storeViewController;
@property (nonatomic, strong) SettingsViewController *settingsViewController;
@property (nonatomic, strong) WelcomeViewController *welcomeViewController;
@property (nonatomic, strong) BookCoverViewController *bookCoverViewController;
@property (nonatomic, strong) BookNavigationViewController *bookNavigationViewController;
@property (nonatomic, strong) UIViewController *bookModalViewController;
@property (nonatomic, assign) BOOL storeMode;
@property (nonatomic, strong) CKBook *selectedBook;
@property (nonatomic, assign) CGFloat benchtopHideOffset;   // Keeps track of default benchtop offset.
@property (nonatomic, assign) BOOL panEnabled;
@property (nonatomic, assign) NSUInteger benchtopLevel;
@property (nonatomic, strong) UIView *overlayView;

@end

@implementation RootViewController

#define kDragRatio                      0.2
#define kSnapHeight                     30.0
#define kBounceOffset                   30.0
#define kStoreHideTuckOffset            69.0
#define kStoreShadowOffset              43.0
#define kStoreShowAdjustment            340.0
#define kSettingsOffsetBelowBenchtop    35.0
#define kStoreLevel                     2
#define kBenchtopLevel                  1
#define kSettingsLevel                  0
#define kOverlayViewAlpha               0.3
#define kBookScaleTransform             0.9

- (void)dealloc {
    [EventHelper unregisterLogout:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight;
    
    // Drag to pull
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
    panGesture.delegate = self;
    [self.view addGestureRecognizer:panGesture];
    
    // Register login/logout events.
    [EventHelper registerLogout:self selector:@selector(loggedOut:)];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self initViewControllers];
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark - BenchtopViewControllerDelegate methods

- (void)openBookRequestedForBook:(CKBook *)book {
    [self openBook:book];
}

- (void)editBookRequested:(BOOL)editMode {
    [self enableEditMode:editMode];
}

- (void)panEnabledRequested:(BOOL)enable {
    self.panEnabled = enable;
}

- (void)panToBenchtopForSelf:(UIViewController *)viewController {
    if (viewController == self.storeViewController) {
        [self snapToLevel:kStoreLevel];
    } else if (viewController == self.benchtopViewController) {
        [self snapToLevel:kBenchtopLevel];
    } else if (viewController == self.settingsViewController) {
        [self snapToLevel:kSettingsLevel];
    }
}

- (NSInteger)currentBenchtopLevel {
    return self.benchtopLevel;
}

- (void)deleteModeToggled:(BOOL)deleteMode {
    [self showStoreShelf:!deleteMode animated:NO];
}

#pragma mark - BookCoverViewControllerDelegate methods

- (void)bookCoverViewWillOpen:(BOOL)open {
    
    if (!open) {
        // Restore shelf that was hidden in didOpen
        self.storeViewController.view.hidden = NO;
        [self.bookNavigationViewController.view removeFromSuperview];
        self.bookNavigationViewController = nil;

    }
    
    // Pass on event to the benchtop to hide the book.
    [self.benchtopViewController bookWillOpen:open];
}

- (void)bookCoverViewDidOpen:(BOOL)open {
    if (open) {
        
        // Create book navigation.
        BookNavigationViewController *bookNavigationViewController = [[BookNavigationViewController alloc] initWithBook:self.selectedBook
                                                                                                               delegate:self];
        bookNavigationViewController.view.frame = self.view.bounds;
        [self.view addSubview:bookNavigationViewController.view];
        self.bookNavigationViewController = bookNavigationViewController;
        
        // Inform the helper that coordinates book navigation and any updated recipes.
        [BookNavigationHelper sharedInstance].bookNavigationViewController = bookNavigationViewController;
        
        // Hide shelf to reduce visual complexity.
        self.storeViewController.view.hidden = YES;
        
        // Scale it up the rest of the way to fullscreen.
        bookNavigationViewController.view.transform = CGAffineTransformMakeScale(kBookScaleTransform, kBookScaleTransform);
        [UIView animateWithDuration:0.4
                              delay:0.1
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             bookNavigationViewController.view.transform = CGAffineTransformIdentity;
                         }
                         completion:^(BOOL finished) {
            
                         }];
        
    } else {
        
        // Remove the book cover.
        [self.bookCoverViewController cleanUpLayers];
        [self.bookCoverViewController.view removeFromSuperview];
        self.bookCoverViewController = nil;
        
        // Cleanup book navigation helper.
        [BookNavigationHelper sharedInstance].bookNavigationViewController = nil;
    }
    
    // Pass on event to the benchtop to restore the book.
    [self.benchtopViewController bookDidOpen:open];
}

#pragma mark - BookNavigationViewControllerDelegate methods

- (void)bookNavigationControllerCloseRequested {
    
    // Scale it down then let the book cover close.
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.bookNavigationViewController.view.transform = CGAffineTransformMakeScale(kBookScaleTransform, kBookScaleTransform);
                     }
                     completion:^(BOOL finished) {
                         [self.bookCoverViewController openBook:NO];
                     }];
}

- (void)bookNavigationControllerRecipeRequested:(CKRecipe *)recipe {
    [self viewRecipe:recipe];
}

- (void)bookNavigationControllerAddRecipeRequested {
    [self addRecipeForBook:self.selectedBook];
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return self.panEnabled;
}

#pragma mark - BookModalViewControllerDelegate methods

- (void)closeRequestedForBookModalViewController:(UIViewController *)viewController {
    [self hideModalViewController:viewController];
}

#pragma mark - WelcomeViewControllerDelegate methods

- (void)welcomeViewControllerLoggedIn {
    [self showLoginView:NO];
}

#pragma mark - Private methods

- (void)panned:(UIPanGestureRecognizer *)panGesture {
    CGPoint translation = [panGesture translationInView:self.view];
    
    if (panGesture.state == UIGestureRecognizerStateBegan) {
    } else if (panGesture.state == UIGestureRecognizerStateChanged) {
        [self panWithTranslation:translation];
	} else if (panGesture.state == UIGestureRecognizerStateEnded) {
        [self snapIfRequired];
    }
    
    [panGesture setTranslation:CGPointZero inView:self.view];
}

- (void)panWithTranslation:(CGPoint)translation {
    CGFloat panOffset = ceilf(translation.y * kDragRatio);
    self.storeViewController.view.frame = [self frame:self.storeViewController.view.frame translatedOffset:panOffset];
    self.benchtopViewController.view.frame = [self frame:self.benchtopViewController.view.frame translatedOffset:panOffset];
    self.settingsViewController.view.frame = [self frame:self.settingsViewController.view.frame translatedOffset:panOffset];
}

- (void)snapIfRequired {
    NSUInteger toggleLevel = self.benchtopLevel;
    
    if (self.benchtopLevel == kStoreLevel
        && CGRectIntersection(self.view.bounds,
                              self.benchtopViewController.view.frame).size.height > kStoreHideTuckOffset + kStoreShowAdjustment + kSnapHeight) {
        
        toggleLevel = kBenchtopLevel;
        
    } else if (self.benchtopLevel == kBenchtopLevel
               && CGRectIntersection(self.view.bounds,
                                     self.storeViewController.view.frame).size.height > (kStoreHideTuckOffset + kStoreShadowOffset + kSnapHeight)) {
        
        toggleLevel = kStoreLevel;
        
    } else if (self.benchtopLevel == kBenchtopLevel
               && CGRectIntersection(self.view.bounds,
                                     self.settingsViewController.view.frame).size.height > 0) {
        
        toggleLevel = kSettingsLevel;
        
    } else if (self.benchtopLevel == kSettingsLevel
               && CGRectIntersection(self.view.bounds,
                                     self.settingsViewController.view.frame).size.height < (self.settingsViewController.view.frame.size.height * 0.75)) {
        
        // Toggle to level 1 if moved more than 1/3.
        toggleLevel = kBenchtopLevel;
    }
    
    DLog("Snap to Level: %d", toggleLevel);
    [self snapToLevel:toggleLevel];
}

- (void)snapToLevel:(NSUInteger)benchtopLevel {
    [self snapToLevel:benchtopLevel completion:^{}];
}

- (void)snapToLevel:(NSUInteger)benchtopLevel completion:(void (^)())completion {
    
    BOOL toggleMode = (self.benchtopLevel != benchtopLevel);
    CGRect storeFrame = [self storeFrameForLevel:benchtopLevel];
    CGRect benchtopFrame = [self benchtopFrameForLevel:benchtopLevel];
    CGRect settingsFrame = [self settingsFrameForLevel:benchtopLevel];
    
    // Add a bounce for toggling between levels.
    if (toggleMode) {
        BOOL forwardBounce = benchtopLevel > self.benchtopLevel;
        storeFrame.origin.y += forwardBounce ? kBounceOffset : -kBounceOffset;
        benchtopFrame.origin.y += forwardBounce ? kBounceOffset : -kBounceOffset;
        settingsFrame.origin.y += forwardBounce ? kBounceOffset : -kBounceOffset;
    }
    
    // Forward bounce duration.
    CGFloat forwardDuration = 0.25;
    CGFloat bounceDuration = 0.2;
    
    // Speed up to Settings, and returning from Settings.
    if (benchtopLevel == kSettingsLevel || (benchtopLevel == kBenchtopLevel && self.benchtopLevel == kSettingsLevel)) {
        forwardDuration = 0.2;
        bounceDuration = 0.15;
    }
    
    [UIView animateWithDuration:forwardDuration
                          delay:0.0
                        options:UIViewAnimationCurveEaseIn
                     animations:^{
                         self.storeViewController.view.frame = storeFrame;
                         self.benchtopViewController.view.frame = benchtopFrame;
                         self.settingsViewController.view.frame = settingsFrame;
                     }
                     completion:^(BOOL finished) {
                         
                         if (toggleMode) {
                             [UIView animateWithDuration:bounceDuration
                                                   delay:0.0
                                                 options:UIViewAnimationCurveEaseIn
                                              animations:^{
                                                  self.storeViewController.view.frame = [self storeFrameForLevel:benchtopLevel];;
                                                  self.benchtopViewController.view.frame = [self benchtopFrameForLevel:benchtopLevel];
                                                  self.settingsViewController.view.frame = [self settingsFrameForLevel:benchtopLevel];
                                              }
                                              completion:^(BOOL finished) {
                                                  self.benchtopLevel = benchtopLevel;
                                                  [self.storeViewController enable:benchtopLevel == kStoreLevel];
                                                  [self.benchtopViewController enable:benchtopLevel == kBenchtopLevel];
                                                  completion();
                                              }];
                         } else {
                             self.benchtopLevel = benchtopLevel;
                         }
                         
                     }];
}

- (CGRect)frame:(CGRect)frame translatedOffset:(CGFloat)offset {
    frame.origin.y += offset;
    return frame;
}

- (CGRect)storeFrameForShow:(BOOL)show {
    return [self storeFrameForShow:show bounce:NO];
}

- (CGRect)benchtopFrameForShow:(BOOL)show {
    return [self benchtopFrameForShow:show bounce:NO];
}

- (CGRect)storeFrameForShow:(BOOL)show bounce:(BOOL)bounce {
    if (show) {
        
        // Show frame is just the top of the view bounds.
        CGRect showFrame = CGRectMake(self.view.bounds.origin.x,
                                      self.view.bounds.size.height - self.storeViewController.view.frame.size.height - kStoreShowAdjustment,
                                      self.view.bounds.size.width,
                                      self.storeViewController.view.frame.size.height);
        if (bounce) {
            showFrame.origin.y += kBounceOffset;
        }
        return showFrame;
        
    } else {
        
        // Hidden frame is above view bounds but lowered to show the bottom shelf.
        CGRect hideFrame = CGRectMake(self.view.bounds.origin.x,
                                      -self.storeViewController.view.frame.size.height + kStoreHideTuckOffset,
                                      self.view.bounds.size.width,
                                      self.storeViewController.view.frame.size.height);
        if (bounce) {
            hideFrame.origin.y -= kBounceOffset;
        }
        return hideFrame;
    }
}

- (CGRect)benchtopFrameForShow:(BOOL)show bounce:(BOOL)bounce {
    if (show) {
        
        // Show frame is just the current bounds.
        CGRect showFrame = self.view.bounds;
        if (bounce) {
            showFrame.origin.y -= kBounceOffset;
        }
        
        return showFrame;
        
    } else {
        
        // Hidden frame depends on the store frame.
        CGRect storeFrame = [self storeFrameForShow:!show bounce:NO];
        CGRect hideFrame = CGRectMake(self.view.bounds.origin.x,
                                      storeFrame.origin.y + storeFrame.size.height - kStoreShadowOffset,
                                      self.view.bounds.size.width,
                                      self.view.bounds.size.height);
        if (bounce) {
            hideFrame.origin.y += kBounceOffset;
        }
        
        return hideFrame;
    }
}

- (CGRect)storeFrameForLevel:(NSUInteger)level {
    CGRect frame = CGRectZero;
    
    if (level == kStoreLevel) {
        frame = CGRectMake(self.view.bounds.origin.x,
                           self.view.bounds.size.height - self.storeViewController.view.frame.size.height - [self.storeViewController visibleHeight],
                           self.view.bounds.size.width,
                           self.storeViewController.view.frame.size.height);
    } else if (level == kBenchtopLevel) {
        frame = CGRectMake(self.view.bounds.origin.x,
                           -self.storeViewController.view.frame.size.height + [self.storeViewController bottomShelfTrayHeight] + [self.storeViewController bottomShadowHeight],
                           self.view.bounds.size.width,
                           self.storeViewController.view.frame.size.height);
    } else if (level == kSettingsLevel) {
        frame = CGRectMake(self.view.bounds.origin.x,
                           self.view.bounds.size.height - self.settingsViewController.view.frame.size.height - self.view.bounds.size.height - kSettingsOffsetBelowBenchtop - self.storeViewController.view.frame.size.height + kStoreHideTuckOffset,
                           self.view.bounds.size.width,
                           self.storeViewController.view.frame.size.height);
    }
    
    DLog(@"level [%d] %@", level, NSStringFromCGRect(frame));
    return frame;
}

- (CGRect)benchtopFrameForLevel:(NSUInteger)level {
    CGRect frame = CGRectZero;
    
    if (level == kStoreLevel) {
        frame = CGRectMake(self.view.bounds.origin.x,
                           self.storeViewController.view.frame.origin.y + self.storeViewController.view.frame.size.height - [self.storeViewController bottomShelfTrayHeight] - [self.storeViewController bottomShadowHeight],
                           self.view.bounds.size.width,
                           self.view.bounds.size.height);
    } else if (level == kBenchtopLevel) {
        frame = self.view.bounds;
    } else if (level == kSettingsLevel) {
        frame = CGRectMake(self.view.bounds.origin.x,
                           self.view.bounds.origin.y - self.settingsViewController.view.frame.size.height,
                           self.view.bounds.size.width,
                           self.view.bounds.size.height);
    }
    
    DLog(@"level [%d] %@", level, NSStringFromCGRect(frame));
    return frame;
}

- (CGRect)settingsFrameForLevel:(NSUInteger)level {
    CGRect frame = CGRectZero;
    
    if (level == kStoreLevel) {
        frame = CGRectMake(self.view.bounds.origin.x,
                           self.benchtopViewController.view.frame.origin.y + self.benchtopViewController.view.frame.size.height,
                           self.view.bounds.size.width,
                           self.settingsViewController.view.frame.size.height);
    } else if (level == kBenchtopLevel) {
        frame = CGRectMake(self.view.bounds.origin.x,
                           self.view.bounds.size.height,
                           self.view.bounds.size.width,
                           self.settingsViewController.view.frame.size.height);
    } else if (level == kSettingsLevel) {
        frame = CGRectMake(self.view.bounds.origin.x,
                           self.view.bounds.size.height - self.settingsViewController.view.frame.size.height,
                           self.view.bounds.size.width,
                           self.settingsViewController.view.frame.size.height);
    }
    
    DLog(@"level [%d] %@", level, NSStringFromCGRect(frame));
    return frame;
}

- (CGRect)editFrameForStore {
    CGRect storeFrame = [self storeFrameForShow:NO];
    storeFrame.origin.y -= kStoreHideTuckOffset;
    return storeFrame;
}

- (void)openBook:(CKBook *)book {
    
    self.selectedBook = book;
    
    // Open book.
    BookCoverViewController *bookCoverViewController = [[BookCoverViewController alloc] initWithBook:book
                                                                                            delegate:self];
    bookCoverViewController.view.frame = self.view.bounds;
    [self.view addSubview:bookCoverViewController.view];
    [bookCoverViewController openBook:YES];
    self.bookCoverViewController = bookCoverViewController;
    
}

- (void)showStoreShelf:(BOOL)show animated:(BOOL)animated {
    CGAffineTransform transform = show ? CGAffineTransformIdentity : CGAffineTransformMakeTranslation(0.0, -kStoreHideTuckOffset);
    if (animated) {
        [UIView animateWithDuration:0.3
                              delay:show ? 0.1 : 0.2
                            options:show ? UIViewAnimationOptionCurveEaseOut : UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.storeViewController.view.transform = transform;
                         }
                         completion:^(BOOL finished) {
                         }];
    } else {
        self.storeViewController.view.transform = transform;
    }
}

- (void)initViewControllers {
    BOOL isLoggedIn = [self isLoggedIn];
    [self initBenchtop];
    [self showLoginView:!isLoggedIn];
    [self enable:isLoggedIn];
}

- (void)initBenchtop {
    
    // Start off on the middle level.
    self.benchtopLevel = 1;
    
    // Store on Level 2
    self.storeViewController.view.frame = [self storeFrameForLevel:self.benchtopLevel];
    [self.view addSubview:self.storeViewController.view];
    
    // Benchtop on Level 1
    self.benchtopViewController.view.frame = [self benchtopFrameForLevel:self.benchtopLevel];
    [self.view insertSubview:self.benchtopViewController.view belowSubview:self.storeViewController.view];
    
    // Settings on Level 0
    self.settingsViewController.view.frame = [self settingsFrameForLevel:self.benchtopLevel];
    [self.view addSubview:self.settingsViewController.view];
}

- (void)enableEditMode:(BOOL)enable {
    
    // Disable panning in edit mode.
    self.panEnabled = !enable;
    
    // Transition store mode in/out of the way.
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationCurveEaseIn
                     animations:^{
                         self.storeViewController.view.alpha = enable ? 0.0 : 1.0;
                         self.storeViewController.view.frame = enable ? [self editFrameForStore] : [self storeFrameForShow:NO];
                     }
                     completion:^(BOOL finished) {
                     }];
}

- (StoreViewController *)storeViewController {
    if (_storeViewController == nil) {
        _storeViewController = [[StoreViewController alloc] init];
        _storeViewController.delegate = self;
    }
    return _storeViewController;
}

- (PagingBenchtopViewController *)benchtopViewController {
    if (_benchtopViewController == nil) {
        _benchtopViewController = [[PagingBenchtopViewController alloc] init];
        _benchtopViewController.delegate = self;
    }
    return _benchtopViewController;
}

- (UIViewController *)settingsViewController {
    if (_settingsViewController == nil) {
        _settingsViewController = [[SettingsViewController alloc] init];
    }
    return _settingsViewController;
}

- (void)viewRecipe:(CKRecipe *)recipe {
    RecipeViewController *recipeViewController = [[RecipeViewController alloc] initWithRecipe:recipe book:self.selectedBook];
    [self showModalViewController:recipeViewController];
}

- (void)addRecipeForBook:(CKBook *)book {
    RecipeViewController *recipeViewController = [[RecipeViewController alloc] initWithBook:self.selectedBook];
    [self showModalViewController:recipeViewController];
}

- (void)showModalViewController:(UIViewController *)modalViewController {
    
    // Modal view controller has to be a UIViewController and confirms to BookModalViewControllerDelegate
    if (![modalViewController isKindOfClass:[UIViewController class]]
        && ![modalViewController conformsToProtocol:@protocol(BookModalViewController)]) {
        DLog(@"Not UIViewController or conforms to BookModalViewController protocol.");
        return;
    }
    
    // Disable panning.
    self.panEnabled = NO;
    
    // Prepare the dimView
    UIView *overlayView = [[UIView alloc] initWithFrame:self.view.bounds];
    overlayView.backgroundColor = [UIColor blackColor];
    overlayView.alpha = 0.0;
    [self.view addSubview:overlayView];
    self.overlayView = overlayView;
    
    // Prepare the modalVC to be transitioned.
    modalViewController.view.frame = self.view.bounds;
    modalViewController.view.transform = CGAffineTransformMakeTranslation(0.0, self.view.bounds.size.height);
    [self.view addSubview:modalViewController.view];
    self.bookModalViewController = modalViewController;

    // Sets the modal view delegate for close callbacks.
    [modalViewController performSelector:@selector(setModalViewControllerDelegate:) withObject:self];
    
    // Inform will appear.
    [modalViewController performSelector:@selector(bookModalViewControllerWillAppear:)
                              withObject:[NSNumber numberWithBool:YES]];
    
    // Animate the book back, and slide up the modalVC.
    CGAffineTransform transform = [self bookScaleTransform];
    
    // Inform book navigation it is about to become inactive.
    [self.bookNavigationViewController setActive:NO];
    
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options:UIViewAnimationCurveEaseIn
                     animations:^{
                     
                         // Fade in overlay.
                         overlayView.alpha = kOverlayViewAlpha;
                     
                         // Scale back.
                         self.bookCoverViewController.view.transform = transform;
                         self.bookNavigationViewController.view.transform = transform;
                     
                         // Slide up the modal.
                         modalViewController.view.transform = CGAffineTransformIdentity;
                 }
                 completion:^(BOOL finished)  {
                        [modalViewController performSelector:@selector(bookModalViewControllerDidAppear:)
                                                  withObject:[NSNumber numberWithBool:YES]];
                 }];
}

- (void)hideModalViewController:(UIViewController *)modalViewController {
    
    // Inform will disappear.
    [modalViewController performSelector:@selector(bookModalViewControllerWillAppear:)
                              withObject:[NSNumber numberWithBool:NO]];
    
    // Animate the book back, and slide up the modalVC.
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options:UIViewAnimationCurveEaseIn
                     animations:^{
                         self.overlayView.alpha = 0.0;
                         self.bookNavigationViewController.view.transform = CGAffineTransformIdentity;
                         self.bookCoverViewController.view.transform = CGAffineTransformIdentity;
                         modalViewController.view.transform = CGAffineTransformMakeTranslation(0.0, self.view.bounds.size.height);
                     }
                     completion:^(BOOL finished)  {
                         [modalViewController performSelector:@selector(bookModalViewControllerDidAppear:)
                                                   withObject:[NSNumber numberWithBool:NO]];
                         
                         [self.overlayView removeFromSuperview];
                         self.overlayView = nil;
                         [modalViewController.view removeFromSuperview];
                         self.bookModalViewController = nil;
                         
                         // Book navigation becomes active.
                         // Inform book navigation it is about to become inactive.
                         [self.bookNavigationViewController setActive:YES];
                         
                         // Re-enable panning.
                         self.panEnabled = YES;
                     }];
}

- (BOOL)isLoggedIn {
    return [CKUser isLoggedIn];
}

- (void)enable:(BOOL)enable {
    self.panEnabled = enable;
    
    // Show store shelf only in enabled mode.
    [self showStoreShelf:enable animated:enable];
    
    // Enable/disable benchtop
    [self.benchtopViewController enable:enable];
}

- (void)loggedOut:(NSNotification *)notification {
    [self snapToLevel:kBenchtopLevel completion:^{
        [self showLoginView:YES];
    }];
}

- (void)showLoginView:(BOOL)show {
    
    if (show) {
        // Remove any existing one.
        [self.welcomeViewController.view removeFromSuperview];
        self.welcomeViewController = nil;
        
        // Recreate the login.
        WelcomeViewController *welcomeViewController = [[WelcomeViewController alloc] initWithDelegate:self];
        welcomeViewController.view.frame = self.view.bounds;
        welcomeViewController.view.alpha = 0.0;
        [self.view addSubview:welcomeViewController.view];
        self.welcomeViewController = welcomeViewController;
    }
    
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.welcomeViewController.view.alpha = show ? 1.0 : 0.0;
                     }
                     completion:^(BOOL finished) {
                         [self enable:!show];
                         
                         if (!show) {
                             [self.welcomeViewController.view removeFromSuperview];
                             self.welcomeViewController = nil;
                         } else {
                             [self.welcomeViewController enable:YES];
                         }
                     }];
    
}

- (CGAffineTransform)bookScaleTransform {
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(kBookScaleTransform, kBookScaleTransform);
    CGAffineTransform translateTransform = CGAffineTransformMakeTranslation(0.0, 10.0);
    return CGAffineTransformConcat(scaleTransform, translateTransform);
}

@end
