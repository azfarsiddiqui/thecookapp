//
//  CKViewController.m
//  BenchtopDemo
//
//  Created by Jeff Tan-Ang on 29/11/12.
//  Copyright (c) 2012 Cook App Pty Ltd. All rights reserved.
//

#import "RootViewController.h"
#import "BenchtopCollectionViewController.h"
#import "StoreViewController.h"
#import "BenchtopViewControllerDelegate.h"
#import "BookCoverViewController.h"
#import "BookViewController.h"
#import "CKBook.h"
#import "SettingsViewController.h"

@interface RootViewController () <BenchtopViewControllerDelegate, BookCoverViewControllerDelegate,
    BookViewControllerDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) BenchtopCollectionViewController *benchtopViewController;
@property (nonatomic, strong) StoreViewController *storeViewController;
@property (nonatomic, strong) SettingsViewController *settingsViewController;
@property (nonatomic, strong) BookCoverViewController *bookCoverViewController;
@property (nonatomic, strong) BookViewController *bookViewController;
@property (nonatomic, assign) BOOL storeMode;
@property (nonatomic, strong) CKBook *selectedBook;
@property (nonatomic, assign) CGFloat benchtopHideOffset;   // Keeps track of default benchtop offset.
@property (nonatomic, assign) BOOL panEnabled;
@property (nonatomic, assign) NSUInteger benchtopLevel;

@end

@implementation RootViewController

#define kDragRatio                      0.2
#define kSnapHeight                     30.0
#define kBounceOffset                   30.0
#define kStoreHideTuckOffset            52.0
#define kStoreShadowOffset              31.0
#define kStoreShowAdjustment            35.0
#define kSettingsOffsetBelowBenchtop    0.0

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight;
    
    // Drag to pull
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
    panGesture.delegate = self;
    [self.view addGestureRecognizer:panGesture];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // If the current user is not persisted, i.e. new, then create a book first.
    CKUser *currentUser = [CKUser currentUser];
    if (![currentUser persisted]) {
        
        // TODO Tutorial.
        [CKBook createBookForUser:currentUser
                         succeess:^{
                             [self initViewControllers];
                         } failure:^(NSError *error) {
                             // TODO Handle initial creation error.
                         }];
        
    } else {
        [self initViewControllers];
    }
    
}

#pragma mark - BenchtopViewControllerDelegate methods

- (void)openBookRequestedForBook:(CKBook *)book {
    [self openBook:book];
}

- (void)editBookRequested:(BOOL)editMode {
    [self enableEditMode:editMode];
}

#pragma mark - BookCoverViewControllerDelegate methods

- (void)bookCoverViewWillOpen:(BOOL)open {
    
    if (!open) {
        [self.bookViewController.view removeFromSuperview];
        self.bookViewController = nil;
    }
    
    // Pass on event to the benchtop to hide the book.
    [self.benchtopViewController bookWillOpen:open];
}

- (void)bookCoverViewDidOpen:(BOOL)open {
    if (open) {
        
        // Add the book view.
        BookViewController *bookViewController = [[BookViewController alloc] initWithBook:self.selectedBook
                                                                                 delegate:self];
        [self.view addSubview:bookViewController.view];
        self.bookViewController = bookViewController;
        
    } else {
        
        // Remove the book cover.
        [self.bookCoverViewController cleanUpLayers];
        [self.bookCoverViewController.view removeFromSuperview];
        self.bookCoverViewController = nil;
        
    }
    
    // Pass on event to the benchtop to restore the book.
    [self.benchtopViewController bookDidOpen:open];
}

#pragma mark - BookViewControllerDelegate methods

- (void)bookViewControllerCloseRequested {
    [self.bookCoverViewController openBook:NO];
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    BOOL enabled = NO;
    
    // Enable panning when pan enabled and all VC's setup.
    if (self.panEnabled && self.storeViewController && self.benchtopViewController) {
        enabled = YES;
    }
    
    return enabled;
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
    
    if (self.benchtopLevel == 2
        && CGRectIntersection(self.view.bounds, self.benchtopViewController.view.frame).size.height > self.benchtopHideOffset + kSnapHeight) {
        
        toggleLevel = 1;
        
    } else if (self.benchtopLevel == 1
               && CGRectIntersection(self.view.bounds, self.storeViewController.view.frame).size.height > (kStoreHideTuckOffset + kStoreShadowOffset + kSnapHeight)) {
        
        toggleLevel = 2;
        
    } else if (self.benchtopLevel == 1
               && CGRectIntersection(self.view.bounds, self.settingsViewController.view.frame).size.height > (self.settingsViewController.view.frame.size.height * 0.33)) {
        
        toggleLevel = 0;
        
    } else if (self.benchtopLevel == 0
               && CGRectIntersection(self.view.bounds, self.settingsViewController.view.frame).size.height < (self.settingsViewController.view.frame.size.height * 0.75)) {
        
        // Toggle to level 1 if moved more than 1/3.
        toggleLevel = 1;
    }
    
    BOOL toggleMode = (self.benchtopLevel != toggleLevel);
    CGRect storeFrame = [self storeFrameForLevel:toggleLevel];
    CGRect benchtopFrame = [self benchtopFrameForLevel:toggleLevel];
    CGRect settingsFrame = [self settingsFrameForLevel:toggleLevel];
    
    // Add a bounce for toggling between levels.
    if (toggleMode) {
        BOOL forwardBounce = toggleLevel > self.benchtopLevel;
        storeFrame.origin.y += forwardBounce ? kBounceOffset : -kBounceOffset;
        benchtopFrame.origin.y += forwardBounce ? kBounceOffset : -kBounceOffset;
        settingsFrame.origin.y += forwardBounce ? kBounceOffset : -kBounceOffset;
    }
    
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationCurveEaseIn
                     animations:^{
                         self.storeViewController.view.frame = storeFrame;
                         self.benchtopViewController.view.frame = benchtopFrame;
                         self.settingsViewController.view.frame = settingsFrame;
                     }
                     completion:^(BOOL finished) {
                         
                         if (toggleMode) {
                             [UIView animateWithDuration:0.2
                                                   delay:0.0
                                                 options:UIViewAnimationCurveEaseIn
                                              animations:^{
                                                  self.storeViewController.view.frame = [self storeFrameForLevel:toggleLevel];;
                                                  self.benchtopViewController.view.frame = [self benchtopFrameForLevel:toggleLevel];
                                                  self.settingsViewController.view.frame = [self settingsFrameForLevel:toggleLevel];
                                              }
                                              completion:^(BOOL finished) {
                                                  self.benchtopLevel = toggleLevel;
                                                 [self.storeViewController enable:(self.benchtopLevel == 2)];
                                                 [self.benchtopViewController enable:(self.benchtopLevel == 1)];
                                              }];
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
    
    if (level == 2) {
        frame = CGRectMake(self.view.bounds.origin.x,
                           self.view.bounds.size.height - self.storeViewController.view.frame.size.height - kStoreShowAdjustment,
                           self.view.bounds.size.width,
                           self.storeViewController.view.frame.size.height);
    } else if (level == 1) {
        frame = CGRectMake(self.view.bounds.origin.x,
                           -self.storeViewController.view.frame.size.height + kStoreHideTuckOffset,
                           self.view.bounds.size.width,
                           self.storeViewController.view.frame.size.height);
    } else if (level == 0) {
        frame = CGRectMake(self.view.bounds.origin.x,
                           self.view.bounds.size.height - self.settingsViewController.view.frame.size.height - self.benchtopViewController.view.frame.size.height + kSettingsOffsetBelowBenchtop - self.storeViewController.view.frame.size.height + kStoreHideTuckOffset,
                           self.view.bounds.size.width,
                           self.storeViewController.view.frame.size.height);
    }
    
    return frame;
}

- (CGRect)benchtopFrameForLevel:(NSUInteger)level {
    CGRect frame = CGRectZero;
    
    if (level == 2) {
        frame = CGRectMake(self.view.bounds.origin.x,
                           self.view.bounds.size.height - kStoreShowAdjustment - kStoreShadowOffset,
                           self.view.bounds.size.width,
                           self.benchtopViewController.view.frame.size.height);
    } else if (level == 1) {
        frame = self.view.bounds;
    } else if (level == 0) {
        frame = CGRectMake(self.view.bounds.origin.x,
                           self.view.bounds.size.height - self.settingsViewController.view.frame.size.height - self.benchtopViewController.view.frame.size.height + kSettingsOffsetBelowBenchtop,
                           self.view.bounds.size.width,
                           self.benchtopViewController.view.frame.size.height);
    }
    
    return frame;
}

- (CGRect)settingsFrameForLevel:(NSUInteger)level {
    CGRect frame = CGRectZero;
    
    if (level == 2) {
        frame = CGRectMake(self.view.bounds.origin.x,
                           self.view.bounds.size.height - kStoreShowAdjustment - kStoreShadowOffset + self.benchtopViewController.view.frame.size.height - kSettingsOffsetBelowBenchtop,
                           self.view.bounds.size.width,
                           self.settingsViewController.view.frame.size.height);
    } else if (level == 1) {
        frame = CGRectMake(self.view.bounds.origin.x,
                           self.view.bounds.size.height + kSettingsOffsetBelowBenchtop,
                           self.view.bounds.size.width,
                           self.settingsViewController.view.frame.size.height);
    } else if (level == 0) {
        frame = CGRectMake(self.view.bounds.origin.x,
                           self.view.bounds.size.height - self.settingsViewController.view.frame.size.height,
                           self.view.bounds.size.width,
                           self.settingsViewController.view.frame.size.height);
    }
    
    DLog(@"Settings Frame: %@", NSStringFromCGRect(frame));
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

- (void)initViewControllers {
    
    // Start off on the middle level.
    self.benchtopLevel = 1;
    
    // Store on Level 2
    self.storeViewController.view.frame = [self storeFrameForLevel:self.benchtopLevel];
    [self.view addSubview:self.storeViewController.view];
    
    // Benchtop on Level 1
    self.benchtopViewController.view.frame = [self benchtopFrameForLevel:self.benchtopLevel];
    [self.view insertSubview:self.benchtopViewController.view belowSubview:self.storeViewController.view];
    [self.benchtopViewController enable:YES];
    
    // Settings on Level 0
    self.settingsViewController.view.frame = [self settingsFrameForLevel:self.benchtopLevel];
    [self.view addSubview:self.settingsViewController.view];
    
    // Enable pan by default.
    self.panEnabled = YES;
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

- (BenchtopCollectionViewController *)benchtopViewController {
    if (_benchtopViewController == nil) {
        _benchtopViewController = [[BenchtopCollectionViewController alloc] init];
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

@end
