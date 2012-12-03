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

@interface RootViewController () <BenchtopViewControllerDelegate, BookCoverViewControllerDelegate,
    BookViewControllerDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) BenchtopCollectionViewController *benchtopViewController;
@property (nonatomic, strong) StoreViewController *storeViewController;
@property (nonatomic, strong) BookCoverViewController *bookCoverViewController;
@property (nonatomic, strong) BookViewController *bookViewController;
@property (nonatomic, assign) BOOL storeMode;
@property (nonatomic, strong) CKBook *selectedBook;
@property (nonatomic, assign) CGFloat benchtopHideOffset;   // Keeps track of default benchtop offset.

@end

@implementation RootViewController

#define kDragRatio              0.2
#define kSnapHeight             30.0
#define kBounceOffset           30.0
#define kStoreHideTuckOffset    52.0
#define kStoreShadowOffset      31.0
#define kStoreShowAdjustment    100.0

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
    DLog();
    [self openBook:book];
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
    
    // Ignore pan gesture if no VC's set up.
    if (self.storeViewController && self.benchtopViewController) {
        return YES;
    } else {
        return NO;
    }
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
}

- (void)snapIfRequired {
    BOOL toggleMode = NO;
    BOOL currentStoreMode = self.storeMode;
    
    if (self.storeMode
        && CGRectIntersection(self.view.bounds, self.benchtopViewController.view.frame).size.height > self.benchtopHideOffset + kSnapHeight) {
        
        toggleMode = YES;
        currentStoreMode = NO;
        
    } else if (!self.storeMode
               && CGRectIntersection(self.view.bounds, self.storeViewController.view.frame).size.height > (kStoreHideTuckOffset + kStoreShadowOffset + kSnapHeight)) {
        
        toggleMode = YES;
        currentStoreMode = YES;
        
    }
    
    BOOL bounce = (toggleMode && currentStoreMode);
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationCurveEaseIn
                     animations:^{
                         self.storeViewController.view.frame = [self storeFrameForShow:currentStoreMode
                                                                                bounce:bounce];
                         self.benchtopViewController.view.frame = [self benchtopFrameForShow:!currentStoreMode
                                                                                      bounce:bounce];
                     }
                     completion:^(BOOL finished) {
                         
                         // Extra bounce back animation when toggling between modes.
                         if (bounce) {
                             [UIView animateWithDuration:0.2
                                                   delay:0.0
                                                 options:UIViewAnimationCurveEaseIn
                                              animations:^{
                                                  self.storeViewController.view.frame = [self storeFrameForShow:currentStoreMode];
                                                  self.benchtopViewController.view.frame = [self benchtopFrameForShow:!currentStoreMode];
                                              }
                                              completion:^(BOOL finished) {
                                                  self.benchtopHideOffset = CGRectIntersection(self.view.bounds, self.benchtopViewController.view.frame).size.height;
                                              }];
                         }
                         
                         // Inform toggle.
                         if (toggleMode) {
                             self.storeMode = !self.storeMode;
                             
                             // Enable the toggled area.
                             [self.storeViewController enable:self.storeMode];
                             [self.benchtopViewController enable:!self.storeMode];
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
                                      self.view.bounds.origin.y - kStoreShowAdjustment,
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
        CGRect storeFrame = [self storeFrameForShow:!show bounce:bounce];
        CGRect hideFrame = CGRectMake(self.view.bounds.origin.x,
                                      storeFrame.origin.y + storeFrame.size.height - kStoreShadowOffset,
                                      self.view.bounds.size.width,
                                      self.view.bounds.size.height);
        if (bounce) {
            hideFrame.origin.y -= kBounceOffset;
        }
        
        return hideFrame;
    }
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
    self.storeViewController = [[StoreViewController alloc] init];
    self.storeViewController.delegate = self;
    self.storeViewController.view.frame = [self storeFrameForShow:NO];
    [self.view addSubview:self.storeViewController.view];
    
    self.benchtopViewController = [[BenchtopCollectionViewController alloc] init];
    self.benchtopViewController.delegate = self;
    self.benchtopViewController.view.frame = [self benchtopFrameForShow:YES];
    [self.view insertSubview:self.benchtopViewController.view belowSubview:self.storeViewController.view];
    [self.benchtopViewController enable:YES];
}

@end
