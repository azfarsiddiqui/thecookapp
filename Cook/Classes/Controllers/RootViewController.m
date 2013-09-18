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
#import "BookNavigationViewControllerDelegate.h"
#import "CKBook.h"
#import "SettingsViewController.h"
#import "BookModalViewController.h"
#import "WelcomeViewController.h"
#import "EventHelper.h"
#import "RecipeDetailsViewController.h"
#import "BookNavigationHelper.h"
#import "BookNavigationStackViewController.h"
#import "BookTitleViewController.h"
#import "DashboardTutorialViewController.h"
#import "ImageHelper.h"

@interface RootViewController () <WelcomeViewControllerDelegate, BenchtopViewControllerDelegate, BookCoverViewControllerDelegate,
    UIGestureRecognizerDelegate, BookNavigationViewControllerDelegate, DashboardTutorialViewControllerDelegate,
    SettingsViewControllerDelegate>

@property (nonatomic, strong) PagingBenchtopViewController *benchtopViewController;
@property (nonatomic, strong) StoreViewController *storeViewController;
@property (nonatomic, strong) SettingsViewController *settingsViewController;
@property (nonatomic, strong) WelcomeViewController *welcomeViewController;
@property (nonatomic, strong) BookCoverViewController *bookCoverViewController;
@property (nonatomic, strong) BookNavigationStackViewController *bookNavigationViewController;
@property (nonatomic, strong) BookTitleViewController *snapshotBookTitleViewController;
@property (nonatomic, strong) DashboardTutorialViewController *tutorialViewController;
@property (nonatomic, strong) UIViewController *bookModalViewController;
@property (nonatomic, assign) BOOL storeMode;
@property (nonatomic, assign) BOOL lightStatusBar;
@property (nonatomic, strong) CKBook *selectedBook;
@property (nonatomic, assign) CGFloat benchtopHideOffset;   // Keeps track of default benchtop offset.
@property (nonatomic, assign) BOOL panEnabled;
@property (nonatomic, assign) NSUInteger benchtopLevel;
@property (nonatomic, strong) UIView *modalOverlayView;
@property (nonatomic, strong) UIView *benchtopOverlayView;  // Darker overlay to dim the benchtop between levels.
@property (nonatomic, strong) UIImageView *defaultImageView;

@end

@implementation RootViewController

#define kDragRatio                      0.25
#define kSnapHeight                     50.0
#define kBounceOffset                   30.0
#define kStoreLevel                     2
#define kBenchtopLevel                  1
#define kSettingsLevel                  0
#define kOverlayViewAlpha               0.5
#define kBookScaleTransform             0.9
#define kMaxBenchtopOverlayAlpha        1.0

- (void)dealloc {
    [EventHelper unregisterStatusBarChange:self];
    [EventHelper unregisterLogout:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Default splash.
    self.defaultImageView = [[UIImageView alloc] initWithImage:[ImageHelper imageFromDiskNamed:@"cook_defaultimage" type:@"png"]];
    self.defaultImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:self.defaultImageView];
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight;
    
    // Drag to pull
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
    panGesture.delegate = self;
    [self.view addGestureRecognizer:panGesture];
    
    // Light status bar.
    self.lightStatusBar = YES;
    
    // Register login/logout events.
    [EventHelper registerLogout:self selector:@selector(loggedOut:)];
    [EventHelper registerStatusBarChange:self selector:@selector(statusBarChanged:)];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self initViewControllers];
//    [self loadSampleRecipe];
}

- (void)didReceiveMemoryWarning {
    DLog();
    [super didReceiveMemoryWarning];
    [self.defaultImageView removeFromSuperview];
    self.defaultImageView = nil;
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

// Need this here so subsequent VC's use it.
- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.lightStatusBar ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault;
}

#pragma mark - WelcomeViewControllerDelegate methods

- (void)welcomeViewControllerGetStartedReached {
    
    __weak RootViewController *weakSelf = self;
    [self dismissWelcomeViewCompletion:^{
        weakSelf.panEnabled = YES;
        [weakSelf.benchtopViewController loadBenchtop:YES];
    }];
    
}

#pragma mark - BenchtopViewControllerDelegate methods

- (void)openBookRequestedForBook:(CKBook *)book centerPoint:(CGPoint)centerPoint {
    [self openBook:book centerPoint:centerPoint];
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
    DLog();
}

- (void)benchtopFirstTimeLaunched {
//    [self performIntroPan];
}

- (BOOL)benchtopInLibrary {
    return (self.benchtopLevel == kStoreLevel);
}

- (BOOL)benchtopInSettings {
    return (self.benchtopLevel == kSettingsLevel);
}

#pragma mark - BookCoverViewControllerDelegate methods

- (void)bookCoverViewWillOpen:(BOOL)open {
    
    // Disable panning on book open.
    self.panEnabled = !open;
    
    // Fade the store away.
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.storeViewController.view.alpha = open ? 0.0 : 1.0;
                     }
                     completion:^(BOOL finished) {
                     }];
    
    if (!open) {
        
        // Show the bookCoverVC.
        self.bookCoverViewController.view.hidden = NO;
        
        self.storeViewController.view.hidden = NO;
        [self.bookNavigationViewController.view removeFromSuperview];
        self.bookNavigationViewController = nil;
        
        // Always light status bar when book closed.
        [self updateStatusBarLight:YES];
    }
    
    // Pass on event to the benchtop to hide the book.
    [self.benchtopViewController bookWillOpen:open];
}

- (void)bookCoverViewDidOpen:(BOOL)open {
    if (open) {
        
        // Create book navigation.
        BookNavigationStackViewController *bookNavigationViewController = [[BookNavigationStackViewController alloc] initWithBook:self.selectedBook
                                                                                                                         delegate:self];
        bookNavigationViewController.view.frame = self.view.bounds;
        [self.view addSubview:bookNavigationViewController.view];
        self.bookNavigationViewController = bookNavigationViewController;
        
        // Inform the helper that coordinates book navigation and any updated recipes.
        [BookNavigationHelper sharedInstance].bookNavigationViewController = bookNavigationViewController;
        
        // Scale it up the rest of the way to fullscreen.
        bookNavigationViewController.view.transform = CGAffineTransformMakeScale(kBookScaleTransform, kBookScaleTransform);
        [bookNavigationViewController updateBinderAlpha:1.0];
        
        [UIView animateWithDuration:0.3
                              delay:0.1
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             bookNavigationViewController.view.transform = CGAffineTransformIdentity;
                             [bookNavigationViewController updateBinderAlpha:0.0];
                         }
                         completion:^(BOOL finished) {
                             
                             // Hide the bookCoverVC.
                             self.bookCoverViewController.view.hidden = YES;
                             
                             // Inform benchtop of didOpen.
                             [self.benchtopViewController bookDidOpen:open];
                             
                         }];
        
    } else {
        
        // Pass on event to the benchtop to restore the book.
        [self.benchtopViewController bookDidOpen:open];
        
        // Remove the book cover.
        [self.bookCoverViewController cleanUpLayers];
        [self.bookCoverViewController.view removeFromSuperview];
        self.bookCoverViewController = nil;
        
        // Cleanup book navigation helper.
        [BookNavigationHelper sharedInstance].bookNavigationViewController = nil;
        
        // Nil out the bookTitleVC for snapshotting.
        self.snapshotBookTitleViewController = nil;
    }
    
}

- (CGPoint)bookCoverCenterPoint {
    return self.view.center;
}

- (UIView *)bookCoverViewInsideSnapshotView {
    return [self.snapshotBookTitleViewController.view snapshotViewAfterScreenUpdates:YES];
}

- (UIImage *)bookCoverViewInsideSnapshotImage {
    return [ImageHelper imageFromView:self.snapshotBookTitleViewController.view];
}

#pragma mark - BookNavigationViewControllerDelegate methods

- (void)bookNavigationControllerCloseRequested {
    [self performCloseBookAnimationWithBinder:NO];
}

- (void)bookNavigationControllerCloseRequestedWithBinder {
    [self performCloseBookAnimationWithBinder:YES];
}

- (void)bookNavigationControllerRecipeRequested:(CKRecipe *)recipe {
    [self viewRecipe:recipe];
}

- (void)bookNavigationControllerAddRecipeRequestedForPage:(NSString *)page {
    [self addRecipeForBook:self.selectedBook page:page];
}

- (UIView *)bookNavigationSnapshot {
    return [self.benchtopViewController.view snapshotViewAfterScreenUpdates:YES];
}

#pragma mark - DashboardTutorialViewControllerDelegate methods

- (void)dashboardTutorialViewControllerDismissRequested {
    [self showTutorialView:NO];
}

#pragma mark - BookModalViewControllerDelegate methods

- (void)closeRequestedForBookModalViewController:(UIViewController *)viewController {
    [self hideModalViewController:viewController];
}

#pragma mark - SettingsViewControllerDelegate methods

- (void)settingsViewControllerSignInRequested {
    [self snapToLevel:kBenchtopLevel completion:^{
        [self.benchtopViewController showLoginViewSignUp:NO];
    }];
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return self.panEnabled;
}

#pragma mark - Private methods

- (void)performCloseBookAnimationWithBinder:(BOOL)binder {
    
    // [self.bookCoverViewController loadSnapshotView:[self.bookNavigationViewController.view snapshotViewAfterScreenUpdates:YES]];
    [self.bookCoverViewController loadSnapshotImage:[ImageHelper imageFromView:self.bookNavigationViewController.view opaque:YES scaling:YES]];
    
    // Let the bookCoverVC above to have a chance of loadinging the snapshot first.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        
        if (binder) {
            [self.bookNavigationViewController updateBinderAlpha:0.0];
        }
        
        // Scale it down then let the book cover close.
        [UIView animateWithDuration:0.2
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.bookNavigationViewController.view.transform = CGAffineTransformMakeScale(kBookScaleTransform, kBookScaleTransform);
                             if (binder) {
                                 [self.bookNavigationViewController updateBinderAlpha:1.0];
                             }
                         }
                         completion:^(BOOL finished) {
                             [self.bookCoverViewController openBook:NO];
                         }];
    });
}

- (void)panned:(UIPanGestureRecognizer *)panGesture {
    CGPoint translation = [panGesture translationInView:self.view];
    
    if (panGesture.state == UIGestureRecognizerStateBegan || panGesture.state == UIGestureRecognizerStateChanged) {
        [self panWithTranslation:translation];
	} else if (panGesture.state == UIGestureRecognizerStateEnded) {
        [self snapIfRequired];
    }
    
    [panGesture setTranslation:CGPointZero inView:self.view];
}

- (void)panWithTranslation:(CGPoint)translation {
    
    // Cap the panning.
    if (self.benchtopViewController.view.frame.origin.y >= [self.storeViewController visibleHeight] + 80.0
        || self.benchtopViewController.view.frame.origin.y <= -(self.settingsViewController.view.frame.size.height * 2.0)) {
        return;
    }
    
    CGFloat panOffset = ceilf(translation.y * kDragRatio);
    self.storeViewController.view.frame = [self frame:self.storeViewController.view.frame translatedOffset:panOffset];
    self.benchtopViewController.view.frame = [self frame:self.benchtopViewController.view.frame translatedOffset:panOffset];
    self.settingsViewController.view.frame = [self frame:self.settingsViewController.view.frame translatedOffset:panOffset];
    
    // Analog fade.
    CGRect storeIntersection = CGRectIntersection(self.view.bounds, self.storeViewController.view.frame);
    CGFloat storeOffset = storeIntersection.size.height - [self.storeViewController bottomShadowHeight];
    CGRect settingsIntersection = CGRectIntersection(self.view.bounds, self.settingsViewController.view.frame);
    CGFloat settingsOffset = settingsIntersection.size.height;
    if (storeOffset > 0) {
        self.benchtopOverlayView.alpha = MIN((storeOffset / [self.storeViewController visibleHeight]) * kMaxBenchtopOverlayAlpha, kMaxBenchtopOverlayAlpha);
    } else if (settingsOffset > 0) {
        self.benchtopOverlayView.alpha = MIN((settingsOffset / self.settingsViewController.view.frame.size.height) * kMaxBenchtopOverlayAlpha, kMaxBenchtopOverlayAlpha);
    } else {
        self.benchtopOverlayView.alpha = 0.0;
    }
    
    // Status bar toggle as store is getting shown.
    if (storeIntersection.size.height - [self.storeViewController bottomShadowHeight] > 15.0) {
        [self updateStatusBarLight:NO];
    } else {
        [self updateStatusBarLight:YES];
    }
    
}

- (void)snapIfRequired {
    NSUInteger toggleLevel = self.benchtopLevel;
    
    if (self.benchtopLevel == kStoreLevel
        && CGRectIntersection(self.view.bounds,
                              self.storeViewController.view.frame).size.height < [self.storeViewController visibleHeight] - kSnapHeight) {
        
        toggleLevel = kBenchtopLevel;
        
    } else if (self.benchtopLevel == kBenchtopLevel
               && CGRectIntersection(self.view.bounds,
                                     self.storeViewController.view.frame).size.height > ([self.storeViewController bottomShadowHeight] + kSnapHeight)) {
        
        toggleLevel = kStoreLevel;
        
    } else if (self.benchtopLevel == kBenchtopLevel
               && CGRectIntersection(self.view.bounds,
                                     self.settingsViewController.view.frame).size.height > kSnapHeight) {
        
        toggleLevel = kSettingsLevel;
        
    } else if (self.benchtopLevel == kSettingsLevel
               && CGRectIntersection(self.view.bounds,
                                     self.settingsViewController.view.frame).size.height < self.settingsViewController.view.frame.size.height - kSnapHeight) {
        
        toggleLevel = kBenchtopLevel;
    }
    
//    DLog("Snap to Level: %d", toggleLevel);
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
                         self.benchtopOverlayView.alpha = (benchtopLevel == kBenchtopLevel) ? 0.0: kMaxBenchtopOverlayAlpha;
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
                                                  [self.storeViewController enable:(benchtopLevel == kStoreLevel)];
                                                  [self.benchtopViewController enable:(benchtopLevel == kBenchtopLevel)];
                                                  
                                                  // Black status bar only in store mode.
                                                  [self updateStatusBarLight:(benchtopLevel != kStoreLevel)];

                                                  completion();
                                              }];
                         } else {
                             self.benchtopLevel = benchtopLevel;
                             
                             // Black status bar only in store mode.
                             [self updateStatusBarLight:(benchtopLevel != kStoreLevel)];
                             
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
        
        // Show frame is above the full height offset by the visible height.
        CGRect showFrame = CGRectMake(self.view.bounds.origin.x,
                                      self.storeViewController.view.frame.size.height + [self.storeViewController visibleHeight],
                                      self.view.bounds.size.width,
                                      self.storeViewController.view.frame.size.height);
        if (bounce) {
            showFrame.origin.y += kBounceOffset;
        }
        return showFrame;
        
    } else {
        
        // Hidden frame is above view bounds but lowered to show the bottom shelf.
        CGRect hideFrame = CGRectMake(self.view.bounds.origin.x,
                                      -self.storeViewController.view.frame.size.height + [self.storeViewController bottomShadowHeight],
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
        
        // Hidden frame is just below the store visible height.
        CGRect hideFrame = CGRectMake(self.view.bounds.origin.x,
                                      [self.storeViewController visibleHeight],
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
                           self.view.bounds.origin.y - self.storeViewController.view.frame.size.height + [self.storeViewController visibleHeight],
                           self.view.bounds.size.width,
                           self.storeViewController.view.frame.size.height);
    } else if (level == kBenchtopLevel) {
        frame = CGRectMake(self.view.bounds.origin.x,
                           -self.storeViewController.view.frame.size.height + [self.storeViewController bottomShadowHeight],
                           self.view.bounds.size.width,
                           self.storeViewController.view.frame.size.height);
    } else if (level == kSettingsLevel) {
        frame = CGRectMake(self.view.bounds.origin.x,
                           self.view.bounds.origin.y - self.view.bounds.size.height - self.settingsViewController.view.frame.size.height - [self.storeViewController bottomShadowHeight],
                           self.view.bounds.size.width,
                           self.storeViewController.view.frame.size.height);
    }
    
//    DLog(@"level [%d] %@", level, NSStringFromCGRect(frame));
    return frame;
}

- (CGRect)benchtopFrameForLevel:(NSUInteger)level {
    CGRect frame = CGRectZero;
    
    if (level == kStoreLevel) {
        frame = CGRectMake(self.view.bounds.origin.x,
                           [self.storeViewController visibleHeight] - [self.storeViewController bottomShadowHeight],
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
    
//    DLog(@"level [%d] %@", level, NSStringFromCGRect(frame));
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
    
//    DLog(@"level [%d] %@", level, NSStringFromCGRect(frame));
    return frame;
}

- (CGRect)editFrameForStore {
    CGRect storeFrame = [self storeFrameForShow:NO];
    return storeFrame;
}

- (void)openBook:(CKBook *)book centerPoint:(CGPoint)centerPoint {
    
    self.selectedBook = book;
    self.snapshotBookTitleViewController = [[BookTitleViewController alloc] initWithBook:book snapshot:YES delegate:nil];
    self.snapshotBookTitleViewController.view.hidden = NO;
    
// Looks like this doesn't affect the snapshotting.
//    [self.view addSubview:self.snapshotBookTitleViewController.view];
//    [self.view sendSubviewToBack:self.snapshotBookTitleViewController.view];
    
    // Open book.
    BookCoverViewController *bookCoverViewController = [[BookCoverViewController alloc] initWithBook:book delegate:self];
    bookCoverViewController.view.frame = self.view.bounds;
    [self.view addSubview:bookCoverViewController.view];
    [bookCoverViewController openBook:YES centerPoint:centerPoint];
    self.bookCoverViewController = bookCoverViewController;
    
}

- (void)initViewControllers {
    BOOL isLoggedIn = [self isLoggedIn];
    [self initBenchtop];
    if (!isLoggedIn) {
        [self showLoginView:YES];
    }
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
    
    // Benchtop overlay to be hidden to start off with.
    self.benchtopOverlayView = [[UIImageView alloc] initWithImage:[ImageHelper imageFromDiskNamed:@"cook_dash_overlay" type:@"png"]];
    self.benchtopOverlayView.alpha = 0.0;
    [self.view insertSubview:self.benchtopOverlayView aboveSubview:self.benchtopViewController.view];
    
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
        _settingsViewController = [[SettingsViewController alloc] initWithDelegate:self];
    }
    return _settingsViewController;
}

- (void)viewRecipe:(CKRecipe *)recipe {
    RecipeDetailsViewController *recipeViewController = [[RecipeDetailsViewController alloc] initWithRecipe:recipe];
    [self showModalViewController:recipeViewController];
}

- (void)addRecipeForBook:(CKBook *)book page:(NSString *)page {
    RecipeDetailsViewController *recipeViewController = [[RecipeDetailsViewController alloc] initWithBook:self.selectedBook page:page];
    [self showModalViewController:recipeViewController];
}

- (void)showModalViewController:(UIViewController *)modalViewController {
    
    // Modal view controller has to be a UIViewController and confirms to BookModalViewControllerDelegate
    if (![modalViewController isKindOfClass:[UIViewController class]]
        && ![modalViewController conformsToProtocol:@protocol(BookModalViewController)]) {
        DLog(@"Not UIViewController or conforms to BookModalViewController protocol.");
        return;
    }
    
    // Prepare the dimView
    self.modalOverlayView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.modalOverlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.modalOverlayView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:kOverlayViewAlpha];
    self.modalOverlayView.alpha = 0.0;
    [self.view addSubview:self.modalOverlayView];
    
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
    
    // Inform book navigation it is about to become inactive.
    // [self.bookNavigationViewController setActive:NO];
    
    // Book scale/translate transform.
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(0.9, 0.9);
    CGAffineTransform bookTransform = scaleTransform;
    
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options:UIViewAnimationCurveEaseIn
                     animations:^{
                         
                         // Scale the book back.
                         self.bookNavigationViewController.view.transform = bookTransform;
                         self.bookCoverViewController.view.transform = bookTransform;
                     
                         // Fade in overlay.
                         self.modalOverlayView.alpha = 1.0;
                     
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
                         self.modalOverlayView.alpha = 0.0;
                         self.bookNavigationViewController.view.transform = CGAffineTransformIdentity;
                         self.bookCoverViewController.view.transform = CGAffineTransformIdentity;
                         modalViewController.view.transform = CGAffineTransformMakeTranslation(0.0, self.view.bounds.size.height);
                     }
                     completion:^(BOOL finished)  {
                         [modalViewController performSelector:@selector(bookModalViewControllerDidAppear:)
                                                   withObject:[NSNumber numberWithBool:NO]];
                         
                         // Get rid of overlay.
                         [self.modalOverlayView removeFromSuperview];
                         self.modalOverlayView = nil;
                         
                         // Get rid of modalVC and reference to it.
                         [modalViewController.view removeFromSuperview];
                         self.bookModalViewController = nil;
                         
                     }];
}

- (BOOL)isLoggedIn {
    return [CKUser isLoggedIn];
}

- (void)enable:(BOOL)enable {
//    DLog(@"enable: %@", enable ? @"YES" : @"NO");
    self.panEnabled = enable;

    // Enable/disable benchtop
    [self.benchtopViewController enable:enable];
}

- (void)statusBarChanged:(NSNotification *)notification {
    if ([EventHelper lightStatusBarChangeUpdateOnly:notification]) {
        [self updateStatusBarLight:self.lightStatusBar];
    } else {
        [self updateStatusBarLight:[EventHelper lightStatusBarChangeForNotification:notification]];
    }
}

- (void)loggedOut:(NSNotification *)notification {
    [self snapToLevel:kBenchtopLevel];
}

- (void)updateStatusBarLight:(BOOL)light {
    if (self.lightStatusBar == light) {
        return;
    }
    self.lightStatusBar = light;
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)showLoginView:(BOOL)show {
    
    if (show) {
        
        // Recreate the login.
        WelcomeViewController *welcomeViewController = [[WelcomeViewController alloc] initWithDelegate:self];
        welcomeViewController.view.frame = self.view.bounds;
        welcomeViewController.view.alpha = 0.0;
        [self.view addSubview:welcomeViewController.view];
        self.welcomeViewController = welcomeViewController;
        
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.welcomeViewController.view.alpha = 1.0;
                         }
                         completion:^(BOOL finished) {
                         }];
        
    } else {
        
        [self dismissWelcomeViewCompletion:^{
            [self showTutorialView:YES];
        }];
    }
    
}

- (void)dismissWelcomeViewCompletion:(void (^)())completion {
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.welcomeViewController.view.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         [self.welcomeViewController.view removeFromSuperview];
                         self.welcomeViewController = nil;
                         completion();
                     }];
}

- (CGAffineTransform)bookScaleTransform {
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(kBookScaleTransform, kBookScaleTransform);
    CGAffineTransform translateTransform = CGAffineTransformMakeTranslation(0.0, 10.0);
    return CGAffineTransformConcat(scaleTransform, translateTransform);
}

- (void)loadSampleRecipe {
    
    // cFmMoF95S2 NASI GORENG
    // bafbyvhtSj VATAPA
    [CKRecipe recipeForObjectId:@"bafbyvhtSj"
                        success:^(CKRecipe *recipe){
                            [self viewRecipe:recipe];
                        }
                        failure:^(NSError *error) {
                            DLog(@"error %@", [error localizedDescription]);
                        }];
}

- (void)showTutorialView:(BOOL)show {
    if (show) {
        self.tutorialViewController = [[DashboardTutorialViewController alloc] initWithDelegate:self];
        self.tutorialViewController.view.alpha = 0.0;
        self.tutorialViewController.view.frame = self.view.bounds;
        [self.view addSubview:self.tutorialViewController.view];
    }
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.tutorialViewController.view.alpha = show ? 1.0 : 0.0;
                     }
                     completion:^(BOOL finished) {
                         if (!show) {
                             [self.tutorialViewController.view removeFromSuperview];
                             self.tutorialViewController = nil;
                         }
                     }];

}

- (void)performIntroPan {
    CGFloat panOffset = 40.0;
    
    CGAffineTransform downTransform = CGAffineTransformMakeTranslation(0.0, panOffset);
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(0.98, 0.98);
    CGAffineTransform upTransform = CGAffineTransformMakeTranslation(0.0, -panOffset);
    CGAffineTransform plompTransform = CGAffineTransformConcat(downTransform, scaleTransform);
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.storeViewController.view.transform = plompTransform;
                         self.benchtopViewController.view.transform = plompTransform;
                         self.settingsViewController.view.transform = plompTransform;
                     }
                     completion:^(BOOL finished) {
                         
                         [UIView animateWithDuration:0.3
                                               delay:0.0
                                             options:UIViewAnimationOptionCurveEaseOut
                                          animations:^{
                                              self.storeViewController.view.transform = upTransform;
                                              self.benchtopViewController.view.transform = upTransform;
                                              self.settingsViewController.view.transform = upTransform;
                                          }
                                          completion:^(BOOL finished) {
                                              
                                              [UIView animateWithDuration:0.2
                                                                    delay:0.0
                                                                  options:UIViewAnimationOptionCurveEaseIn
                                                               animations:^{
                                                                   self.storeViewController.view.transform = CGAffineTransformIdentity;
                                                                   self.benchtopViewController.view.transform = CGAffineTransformIdentity;
                                                                   self.settingsViewController.view.transform = CGAffineTransformIdentity;
                                                               }
                                                               completion:^(BOOL finished) {
                                                               }];
                                          }];
                     }];
}

- (void)performIntroDynamics {
    UIDynamicAnimator *animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    UIAttachmentBehavior *spring = [[UIAttachmentBehavior alloc] initWithItem:self.benchtopViewController.view offsetFromCenter:(UIOffset){0.0, 20.0} attachedToAnchor:self.view.center];
    [animator addBehavior:spring];
    self.benchtopViewController.view.center = (CGPoint){ self.benchtopViewController.view.center.x, self.benchtopViewController.view.center.y + 20.0 };
}

@end
