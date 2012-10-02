//
//  CKDashboardViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 26/09/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKDashboardViewController.h"
#import "CKDashboardFlowLayout.h"
#import "CKDashboardBookCell.h"

@interface CKDashboardViewController ()

@property (nonatomic, assign) BOOL firstBenchtop;
@property (nonatomic, assign) BOOL snapActivated;
@property (nonatomic, retain) UIView *backgroundView;

- (void)initBackground;
- (NSIndexPath *)nextSnapIndexPath;
- (void)resetScrollView;
- (void)snapDashboard;
- (void)parallaxScrollBackground;
- (CGFloat)backgroundAvailableScrollWidth;
- (CGRect)backgroundFrameForView:(UIView *)view translation:(CGPoint)translation;

@end

@implementation CKDashboardViewController

#define kBookCellId             @"BookCell"
#define kBackgroundAvailOffset  50.0

- (void)dealloc {
    [self.collectionView removeObserver:self forKeyPath:@"contentSize"];
    [self.collectionView removeObserver:self forKeyPath:@"contentOffset"];
}

- (id)init {
    if (self = [super initWithCollectionViewLayout:[[CKDashboardFlowLayout alloc] init]]) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight;
    
    [self initBackground];
    
    self.collectionView.frame = CGRectMake(self.collectionView.frame.origin.x,
                                           self.collectionView.frame.origin.y,
                                           self.collectionView.frame.size.width,
                                           self.view.bounds.size.height);
    
    // Important so that if contentSize is smaller than viewport, that it still bounces.
    self.collectionView.alwaysBounceHorizontal = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    [self.collectionView registerClass:[CKDashboardBookCell class] forCellWithReuseIdentifier:kBookCellId];
    self.firstBenchtop = YES;
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else {
        return 6;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CKDashboardBookCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kBookCellId
                                                                                forIndexPath:indexPath];
    [cell setText:[NSString stringWithFormat:@"Book [%d][%d]", indexPath.section, indexPath.item]];
    return cell;
}

#pragma mark - UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didSelectItemAtIndexPath: %@", indexPath);
    
    if (!self.firstBenchtop) {
        
        [collectionView scrollToItemAtIndexPath:indexPath
                               atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                       animated:YES];
    }

}

#pragma mark - UICollectionViewDelegateFlowLayout methods

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (section == 0) {
        return UIEdgeInsetsMake(155.0, 362.0, 155.0, 0.0);
    } else {
        return UIEdgeInsetsMake(155.0, 300.0, 155.0, 362.0);
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView.isDragging) {
        
        //[self parallaxScrollBackground];
        
        CGRect visibleRect = CGRectMake(scrollView.contentOffset.x,
                                        scrollView.contentOffset.y,
                                        scrollView.bounds.size.width,
                                        scrollView.bounds.size.height);
        
        NSIndexPath *nextSnapIndexPath = [self nextSnapIndexPath];
        UICollectionViewCell *nextSnapCell = [self.collectionView cellForItemAtIndexPath:nextSnapIndexPath];
        
        if (nextSnapCell && CGRectContainsRect(visibleRect, nextSnapCell.frame)) {
            if (!self.snapActivated) {
                NSLog(@"Snap deactivated for item %d", nextSnapIndexPath.item);
            }
            self.snapActivated = YES;
        } else {
            if (self.snapActivated) {
                NSLog(@"Snap deactivated for item %d", nextSnapIndexPath.item);
            }
            self.snapActivated = NO;
        }
                
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset {
    
    // If snap was activated, then do not perform any let-go-restore animation.
    if (self.snapActivated) {
        *targetContentOffset = self.collectionView.contentOffset;
    } 
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    if (self.snapActivated) {
        [self snapDashboard];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    
    if (self.snapActivated) {
        [self resetScrollView];
    }
}

#pragma mark - KVO methods.

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change
                       context:(void *)context {
    
    // Decorate reminder button if changed.
    if ([keyPath isEqualToString:@"contentOffset"]) {
        
        CGPoint contentOffset = self.collectionView.contentOffset;
        CGSize contentSize = self.collectionView.contentSize;
        
        // Update the positioning of the background to achieve the parallax effect.
        CGRect backgroundFrame = self.backgroundView.frame;
        
        // 100 => -59.0
        // 50  => -30.0
        CGFloat backgroundOffset = self.firstBenchtop? 0.0 : -30.0;
        
        if ((self.firstBenchtop && contentOffset.x >= 0.0) || (!self.firstBenchtop && contentOffset.x <= contentSize.width - self.collectionView.bounds.size.width)) {
            
            backgroundFrame.origin.x = floorf(-contentOffset.x * (kBackgroundAvailOffset / self.collectionView.bounds.size.width) + backgroundOffset);
            self.backgroundView.frame = backgroundFrame;
            
        }
        
        NSLog(@"*** contentOffset %@ first [%@] snap [%@]", NSStringFromCGPoint(contentOffset), self.firstBenchtop ? @"YES" : @"NO", self.snapActivated ? @"YES" : @"NO");
        NSLog(@"*** backgroundFrame %@", NSStringFromCGRect(backgroundFrame));
        
    } else if ([keyPath isEqualToString:@"contentSize"]) {
        
        CGSize contentSize = self.collectionView.contentSize;
        NSLog(@"*** contentSize %@", NSStringFromCGSize(contentSize));
        
        // Update the width of the background.
        CGRect backgroundFrame = self.backgroundView.frame;
        backgroundFrame.size.width = contentSize.width + kBackgroundAvailOffset;
        self.backgroundView.frame = backgroundFrame;
        
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - Private methods


- (void)initBackground {
    
    // Tiled background
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x,
                                                                      self.view.bounds.origin.y,
                                                                      self.view.bounds.size.width + kBackgroundAvailOffset,
                                                                      self.view.bounds.size.height)];
    backgroundView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight;
    backgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ff_dash_bg_tile.png"]];
    [self.view insertSubview:backgroundView belowSubview:self.collectionView];
    self.backgroundView = backgroundView;
    
    // Woodgrain overlay.
    UIImageView *overlayImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ff_dash_bg_overlay.png"]];
    overlayImageView.autoresizingMask = UIViewAutoresizingNone;
    [self.view insertSubview:overlayImageView aboveSubview:backgroundView];
    
    // Observe changes in contentSize and contentOffset.
    [self.collectionView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:NULL];
    [self.collectionView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:NULL];
}

- (NSIndexPath *)nextSnapIndexPath {
    NSIndexPath *nextSnapIndexPath = nil;
    if (self.firstBenchtop) {
        nextSnapIndexPath = [NSIndexPath indexPathForItem:0 inSection:1];
    } else {
        nextSnapIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    }
    return nextSnapIndexPath;
}

- (void)resetScrollView {
    ((CKDashboardFlowLayout *)self.collectionView.collectionViewLayout).nextDashboard = self.firstBenchtop;
    [self.collectionView setContentOffset:CGPointMake(0.0, 0.0) animated:NO];
    
    if (self.snapActivated) {
        self.snapActivated = NO;
        self.firstBenchtop = !self.firstBenchtop;
    }
}

- (void)snapDashboard {
    
    CGSize itemSize = [CKDashboardFlowLayout itemSize];
    
    // Center on the next snap book.
    CGFloat requiredOffset = floorf((self.view.bounds.size.width - (itemSize.width * 3)) / 2.0) - floorf((self.view.bounds.size.width - itemSize.width) / 2.0);
    if (self.firstBenchtop) {
        NSUInteger bookSlotIndex = 3;
        requiredOffset += (itemSize.width * bookSlotIndex - 1);
    } else {
        requiredOffset -= itemSize.width;
    }
    
    CGPoint scrollToPoint = CGPointMake(requiredOffset, self.collectionView.contentOffset.y);
    
    // Works
    [self.collectionView setContentOffset:scrollToPoint animated:YES];
    
    CGRect backgroundFrame = self.backgroundView.frame;
    if (self.firstBenchtop) {
        backgroundFrame.origin.x = -kBackgroundAvailOffset;
    } else {
        backgroundFrame.origin.x = 0.0;
    }
    
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationCurveEaseIn
                     animations:^{
                         //self.backgroundView.frame = backgroundFrame;
                     }
                     completion:^(BOOL finished) {
                         NSLog(@"Snap BG %@", NSStringFromCGPoint(backgroundFrame.origin));
                     }];

}

- (void)parallaxScrollBackground {
    CGPoint contentOffset = self.collectionView.contentOffset;
    
    // Ignore if we're on the edges.
    if ((self.firstBenchtop && contentOffset.x <= 0.0)
        || (!self.firstBenchtop && contentOffset.x >= 0.0)) {
        return;
    }
    
    CGRect backgroundFrame = self.backgroundView.frame;
    CGFloat backgroundOrigin = backgroundFrame.origin.x;
    if (self.firstBenchtop) {
        backgroundOrigin = - (self.collectionView.contentOffset.x) * ((backgroundFrame.size.width - self.view.bounds.size.width) / self.view.bounds.size.width);
    } else {
        backgroundOrigin = -kBackgroundAvailOffset - (self.collectionView.contentOffset.x) * ((backgroundFrame.size.width - self.view.bounds.size.width) / self.view.bounds.size.width);
//        backgroundOrigin = -(self.collectionView.contentOffset.x + 600.0) * ((backgroundFrame.size.width - self.view.bounds.size.width) / self.view.bounds.size.width);
    }
    
    backgroundFrame.origin.x = backgroundOrigin;
    self.backgroundView.frame = backgroundFrame;
     
    NSLog(@"Parallax %@", NSStringFromCGPoint(backgroundFrame.origin));
}

- (CGFloat)backgroundAvailableScrollWidth {
    return self.view.bounds.size.width - self.backgroundView.frame.size.width;
}

- (CGRect)backgroundFrameForView:(UIView *)view translation:(CGPoint)translation {
    CGRect currentFrame = view.frame;
    CGFloat xOffset = currentFrame.origin.x + (translation.x * 0.05);
    if (xOffset > 0.0) {
        xOffset = 0.0;
    } else if (xOffset < floorf(self.view.bounds.size.width - self.backgroundView.frame.size.width)) {
        xOffset = floorf(self.view.bounds.size.width - self.backgroundView.frame.size.width);
    }
    return CGRectMake(xOffset,
                      currentFrame.origin.y,
                      currentFrame.size.width,
                      currentFrame.size.height);
}

@end
