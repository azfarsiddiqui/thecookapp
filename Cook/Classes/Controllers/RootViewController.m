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

@interface RootViewController ()

@property (nonatomic, strong) BenchtopCollectionViewController *benchtopViewController;
@property (nonatomic, strong) StoreViewController *storeViewController;
@property (nonatomic, assign) BOOL storeMode;

@end

@implementation RootViewController

#define kDragRatio      0.2
#define kSnapHeight     20.0
#define kBounceOffset   50.0

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight;
    
    // Drag to pull
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
    [self.view addGestureRecognizer:panGesture];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    StoreViewController *storeViewController = [[StoreViewController alloc] init];
    storeViewController.view.frame = [self storeFrameForShow:NO];
    [self.view addSubview:storeViewController.view];
    self.storeViewController = storeViewController;
    
    BenchtopCollectionViewController *benchtopViewController = [[BenchtopCollectionViewController alloc] init];
    benchtopViewController.view.frame = [self benchtopFrameForShow:YES];
    [self.view addSubview:benchtopViewController.view];
    self.benchtopViewController = benchtopViewController;
    
    [benchtopViewController enable:YES];
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
        && CGRectIntersection(self.view.bounds, self.benchtopViewController.view.frame).size.height > kSnapHeight) {
        
        toggleMode = YES;
        currentStoreMode = NO;
        
    } else if (!self.storeMode
               && CGRectIntersection(self.view.bounds, self.storeViewController.view.frame).size.height > kSnapHeight) {
        
        toggleMode = YES;
        currentStoreMode = YES;
        
    }
    
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationCurveEaseIn
                     animations:^{
                         self.storeViewController.view.frame = [self storeFrameForShow:currentStoreMode bounce:toggleMode];
                         self.benchtopViewController.view.frame = [self benchtopFrameForShow:!currentStoreMode bounce:toggleMode];
                     }
                     completion:^(BOOL finished) {
                         
                         // Extra bounce back animation when toggling between modes.
                         if (toggleMode) {
                             [UIView animateWithDuration:0.25
                                                   delay:0.0
                                                 options:UIViewAnimationCurveEaseIn
                                              animations:^{
                                                  self.storeViewController.view.frame = [self storeFrameForShow:currentStoreMode];
                                                  self.benchtopViewController.view.frame = [self benchtopFrameForShow:!currentStoreMode];
                                              }
                                              completion:^(BOOL finished) {
                                                  if (toggleMode) {
                                                      self.storeMode = !self.storeMode;
                                                      
                                                      // Enable the toggled area.
                                                      [self.storeViewController enable:self.storeMode];
                                                      [self.benchtopViewController enable:!self.storeMode];
                                                  }
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
        if (bounce) {
            return CGRectMake(self.view.bounds.origin.x,
                              self.view.bounds.origin.y + kBounceOffset,
                              self.view.bounds.size.width,
                              self.view.bounds.size.height);
        } else {
            return self.view.bounds;
        }
    } else {
        if (bounce) {
            return CGRectMake(self.view.bounds.origin.x,
                              -self.view.bounds.size.height - kBounceOffset,
                              self.view.bounds.size.width,
                              self.view.bounds.size.height);
        } else {
            return CGRectMake(self.view.bounds.origin.x,
                              -self.view.bounds.size.height,
                              self.view.bounds.size.width,
                              self.view.bounds.size.height);
        }
    }
}

- (CGRect)benchtopFrameForShow:(BOOL)show bounce:(BOOL)bounce {
    if (show) {
        if (bounce) {
            return CGRectMake(self.view.bounds.origin.x,
                              self.view.bounds.origin.y - kBounceOffset,
                              self.view.bounds.size.width,
                              self.view.bounds.size.height);
        } else {
            return self.view.bounds;
        }
    } else {
        if (bounce) {
            return CGRectMake(self.view.bounds.origin.x,
                              self.view.bounds.size.height + kBounceOffset,
                              self.view.bounds.size.width,
                              self.view.bounds.size.height);
        } else {
            return CGRectMake(self.view.bounds.origin.x,
                              self.view.bounds.size.height,
                              self.view.bounds.size.width,
                              self.view.bounds.size.height);
        }
    }
}


@end
