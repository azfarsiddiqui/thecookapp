//
//  APBookmarkNavigationView.m
//  APBookmarkNavigationViewDemo
//
//  Created by Jeff Tan-Ang on 20/06/12.
//  Copyright (c) 2012 Apps Perhaps Pty Ltd. All rights reserved.
//

#import "APBookmarkNavigationView.h"

@interface APBookmarkNavigationView()

@property (nonatomic, assign) id<APBookmarkNavigationViewDelegate> delegate;
@property (nonatomic, assign) BOOL shown;
@property (nonatomic, strong) UIView *optionContainerView;
@property (nonatomic, assign) CGRect startPanFrame;
@property (nonatomic, assign) CGSize initialSize;

@end

@implementation APBookmarkNavigationView

#define kBookmarkContentInsets      UIEdgeInsetsMake(40.0, 3.0, 1.0, 3.0)
#define kBookmarkImageTopOffset     8.0
#define kBookmarkOptionTagBase      360
#define kBookmarkPanRatio           0.25
#define kBookmarkPanStretchRatio    0.2
#define kBookmarkPanShowRatio       0.1
#define kBookmarkPanHideRatio       0.12

- (id)initWithDelegate:(id<APBookmarkNavigationViewDelegate>)delegate {
    if (self = [super initWithFrame:CGRectZero]) {
        
        UIImage *bookmarkImage = [[UIImage imageNamed:@"cook_book_bookmark.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:38.0];
        UIImageView *bookmarkImageView = [[UIImageView alloc] initWithImage:bookmarkImage];
        bookmarkImageView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight;
        bookmarkImageView.frame = CGRectMake(0.0,
                                             -kBookmarkImageTopOffset,
                                             bookmarkImageView.frame.size.width,
                                             bookmarkImageView.frame.size.height);
        self.frame = CGRectMake(0.0, 0.0, bookmarkImageView.frame.size.width, bookmarkImageView.frame.size.height - kBookmarkImageTopOffset);
        [self addSubview:bookmarkImageView];
        
        self.initialSize = self.frame.size;
        self.delegate = delegate;
        
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;   // Important so that optionContainerView gets clipped at top.
        
        [self initOptions];
        [self initInteractions];
    }
    return self;
}

- (void)show:(BOOL)show animated:(BOOL)animated {
    NSLog(@"show:%@ animated:%@", show ? @"YES" : @"NO", animated ? @"YES" : @"NO");
    CGRect frameForShow = [self frameForShow:show];
    CGFloat hideBounceOffset = 5.0;
    if (animated) {
        [UIView animateWithDuration:0.15 
                              delay:0.0 
                            options:UIViewAnimationCurveEaseIn
                         animations:^{
                             
                             if (show) {
                                 self.frame = frameForShow;
                             } else {
                                 
                                 // Bounce back
                                 self.frame = CGRectMake(frameForShow.origin.x,
                                                         frameForShow.origin.y - hideBounceOffset,
                                                         frameForShow.size.width,
                                                         frameForShow.size.height);
                             }
                         }
                         completion:^(BOOL finished) {
                             if (show) {
                                 self.shown = show;
                             } else {
                                 [UIView animateWithDuration:0.1
                                                       delay:0.0
                                                     options:UIViewAnimationCurveEaseIn
                                                  animations:^{
                                                      self.frame = frameForShow;
                                                  } completion:^(BOOL finished) {
                                                      self.shown = show;
                                                  }];
                             }
                             
                         }];
    } else {
        self.frame = frameForShow;
        self.shown = show;
    }
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark - Private methods

- (void)initOptions {
    
    // Container view.
    UIView *optionContainerView = [[UIView alloc] initWithFrame:CGRectMake(kBookmarkContentInsets.left,
                                                                           kBookmarkContentInsets.top,
                                                                           self.bounds.size.width - kBookmarkContentInsets.left - kBookmarkContentInsets.right,
                                                                           self.bounds.size.height)];
    optionContainerView.backgroundColor = [UIColor clearColor];
    optionContainerView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin; // Anchor at bottom of parent.
    
    NSUInteger numOptions = [self.delegate bookmarkNumberOfOptions];
    
    // Now add the options.
    CGFloat yOffset = 0.0;
    CGFloat optionGap = 22.0;
    for (NSUInteger optionIndex = 0; optionIndex < numOptions; optionIndex++) {
        
        UIView *optionView = [self optionViewForIndex:optionIndex];
        optionView.backgroundColor = [UIColor clearColor];
        optionView.frame = CGRectMake(floorf((optionContainerView.bounds.size.width - optionView.frame.size.width) / 2.0),
                                      yOffset,
                                      optionView.frame.size.width,
                                      optionView.frame.size.height);
        yOffset += optionView.frame.size.height;
        if (optionIndex != numOptions - 1) {
            yOffset += optionGap;
        }
        [optionContainerView addSubview:optionView];
    }
    
    // Update the container frame.
    optionContainerView.frame = CGRectMake(optionContainerView.frame.origin.x,
                                           -yOffset,
                                           optionContainerView.frame.size.width,
                                           yOffset);
    
    [self addSubview:optionContainerView];
    self.optionContainerView = optionContainerView;
}

- (void)initInteractions {
    
    // Tap on tip to show/hide.
    UIView *toggleView = [[UIView alloc] initWithFrame:self.bounds];
    toggleView.frame = self.bounds;
    toggleView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self addSubview:toggleView];
    UITapGestureRecognizer *tapGestesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [toggleView addGestureRecognizer:tapGestesture];
    
    // Drag to pull
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
//    panGesture.delegate = self;
    [self addGestureRecognizer:panGesture];
    
}

- (void)tapped:(UITapGestureRecognizer *)tapGesture {
    [self show:!self.shown animated:YES];
}

- (void)panned:(UIPanGestureRecognizer *)panGesture {
    
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        
        // Remember the startPanFrame.
        self.startPanFrame = self.frame;
        
    } else if (panGesture.state == UIGestureRecognizerStateChanged) {
        
        CGPoint translation = [panGesture translationInView:self];
        self.frame = [self pannedFrameForTranslation:translation];
        
	} else if (panGesture.state == UIGestureRecognizerStateEnded) {
        
        CGPoint translation = [panGesture translationInView:self];
        if (translation.y < 0) {
            
            // Any upward pan is to hide it.
            [self show:NO animated:YES];
            
        } else {
            
            // Downward pans
            CGRect showFrame = [self frameForShow:YES];
            CGRect hideFrame = [self frameForShow:NO];
            CGFloat currentHeight = self.frame.size.height;
            
            if (self.shown && currentHeight > (showFrame.size.height + (kBookmarkPanHideRatio * showFrame.size.height))) {
                
                // Stretch below to bounce back.
                [self show:NO animated:YES];
                
            } else if (!self.shown && currentHeight > (hideFrame.size.height + (kBookmarkPanShowRatio * showFrame.size.height))) {
                
                // Stretch past to show.
                [self show:YES animated:YES];
                
            } else {
                
                // Restore to minimised state.
                [self show:NO animated:YES];
            }
        }
        
        // Reset the start frame.
        self.startPanFrame = CGRectZero;
    }
}

- (CGRect)pannedFrameForTranslation:(CGPoint)translation {
    CGRect pannedFrame = CGRectZero;
    CGRect showFrame = [self frameForShow:YES];
    
    if (translation.y < 0 || self.shown) {
        
        // Pan resistance if it was upward or already shown.
        pannedFrame = CGRectMake(self.frame.origin.x,
                                 self.frame.origin.y,
                                 self.frame.size.width,
                                 self.startPanFrame.size.height + ceilf(translation.y * kBookmarkPanRatio));
    } else {
        
        if (self.frame.size.height >= showFrame.size.height) {
            
            CGFloat difference = (self.startPanFrame.size.height + translation.y) - showFrame.size.height;
            
            // Introduce resistance once we exceeded the showFrame: intended height - difference ratio.
            pannedFrame = CGRectMake(self.frame.origin.x,
                                     self.frame.origin.y,
                                     self.frame.size.width,
                                     self.startPanFrame.size.height + translation.y - ceilf(difference * (1.0 - kBookmarkPanStretchRatio)));
        } else {
            
            // Linear pan down.
            pannedFrame = CGRectMake(self.frame.origin.x,
                                     self.frame.origin.y,
                                     self.frame.size.width,
                                     self.startPanFrame.size.height + ceilf(translation.y * 0.8));
        }
        
    }
    
    return pannedFrame;
}

- (CGRect)frameForShow:(BOOL)show {
    CGRect frameForShow = CGRectZero;
    if (show) {
        frameForShow = CGRectMake(self.frame.origin.x, 
                                  self.frame.origin.y, 
                                  self.frame.size.width, 
                                  kBookmarkContentInsets.top + self.optionContainerView.frame.size.height + kBookmarkContentInsets.bottom + self.initialSize.height);
    } else {
        frameForShow = CGRectMake(self.frame.origin.x, 
                                  self.frame.origin.y, 
                                  self.initialSize.width,
                                  self.initialSize.height);
    }
    return frameForShow;
}

- (UIView *)optionViewForIndex:(NSUInteger)optionIndex {
    UIView *optionView = [self.delegate bookmarkOptionViewAtIndex:optionIndex];
    NSString *optionValue = [self.delegate bookmarkOptionLabelAtIndex:optionIndex];
    CGFloat gap = 3.0;
    
    UIFont *optionFont = [UIFont boldSystemFontOfSize:10.0];
    CGSize optionSize = [optionValue sizeWithFont:optionFont
                                constrainedToSize:self.bounds.size
                                    lineBreakMode:NSLineBreakByTruncatingTail];
    
    // Container view.
    UIButton *optionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    optionButton.frame = CGRectMake(0.0,
                                           0.0,
                                           self.bounds.size.width,
                                           optionView.frame.size.height + gap + optionSize.height);
    optionButton.backgroundColor = [UIColor clearColor];
    [optionButton addTarget:self action:@selector(optionHeld:) forControlEvents:UIControlEventTouchDown];
    [optionButton addTarget:self action:@selector(optionTapped:) forControlEvents:UIControlEventTouchCancel];
    [optionButton addTarget:self action:@selector(optionTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    // Option view.
    optionView.frame = CGRectMake(floorf((optionButton.bounds.size.width - optionView.frame.size.width) / 2.0),
                                  0.0,
                                  optionView.frame.size.width,
                                  optionView.frame.size.height);
    [optionButton addSubview:optionView];
    
    // Label
    UILabel *optionLabel = [[UILabel alloc] initWithFrame:CGRectMake(floorf((optionButton.bounds.size.width - optionSize.width) / 2),
                                                                     optionView.frame.origin.y + optionView.frame.size.height + gap,
                                                                     optionSize.width,
                                                                     optionSize.height)];
    optionLabel.backgroundColor = [UIColor clearColor];
    optionLabel.font = optionFont;
    optionLabel.textColor = [UIColor whiteColor];
    optionLabel.shadowColor = [UIColor blackColor];
    optionLabel.shadowOffset = CGSizeMake(0.0, 1.0);
    optionLabel.text = optionValue;
    [optionButton addSubview:optionLabel];
    
    // Make it tappable.
    optionButton.userInteractionEnabled = YES;
    optionButton.tag = kBookmarkOptionTagBase + optionIndex;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(optionTapped:)];
    [optionView addGestureRecognizer:tapGesture];
    
    return optionButton;
}

- (void)optionHeld:(id)sender {
    UIView *tappedView = (UIView *)sender;
    tappedView.alpha = 0.7;
}

- (void)optionTapped:(id)sender {
    UIView *tappedView = (UIView *)sender;
    NSUInteger tappedIndex = tappedView.tag - kBookmarkOptionTagBase;
    DLog(@"OPTION TAPPED: %d", tappedIndex);
    tappedView.alpha = 1.0;
    [self.delegate bookmarkDidSelectOptionAtIndex:tappedIndex];
}

- (void)optionReleased:(id)sender {
    UIView *tappedView = (UIView *)sender;
    tappedView.alpha = 1.0;
}

@end
