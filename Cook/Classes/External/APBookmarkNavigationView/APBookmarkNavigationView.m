//
//  APBookmarkNavigationView.m
//  APBookmarkNavigationViewDemo
//
//  Created by Jeff Tan-Ang on 20/06/12.
//  Copyright (c) 2012 Apps Perhaps Pty Ltd. All rights reserved.
//

#import "APBookmarkNavigationView.h"

@interface APBookmarkNavigationView()

@property (nonatomic, retain) NSArray *options;
@property (nonatomic, assign) id<APBookmarkNavigationViewDelegate> delegate;
@property (nonatomic, assign) BOOL shown;
@property (nonatomic, retain) UIView *optionContainerView;
@property (nonatomic, assign) CGRect startPanFrame;

- (void)initOptions;
- (void)initInteractions;
- (void)tapped:(UITapGestureRecognizer *)tapGesture;
- (void)panned:(UIPanGestureRecognizer *)panGesture;
- (CGRect)pannedFrameForTranslation:(CGPoint)translation;
- (CGRect)frameForShow:(BOOL)show;
- (CGFloat)heightForOptions;
- (UIView *)optionViewFromString:(NSString *)option;
- (void)optionTapped:(UITapGestureRecognizer *)tapGesture;

@end

@implementation APBookmarkNavigationView

@synthesize options = _options;
@synthesize delegate = _delegate;
@synthesize shown = _shown;
@synthesize optionContainerView = _optionContainerView;
@synthesize startPanFrame = _startPanFrame;

#define kBookmarkMinSize            CGSizeMake(80.0, 70.0)
#define kBookmarkOptionHeight       44.0
#define kBookmarkOptionInsets       UIEdgeInsetsMake(20.0, 0.0, kBookmarkMinSize.height, 0.0)
#define kBookmarkOptionTagBase      360
#define kBookmarkPanRatio           0.25
#define kBookmarkPanStretchRatio    0.1
#define kBookmarkPanShowRatio       0.1
#define kBookmarkPanHideRatio       0.12

- (id)initWithOptions:(NSArray *)options delegate:(id<APBookmarkNavigationViewDelegate>)delegate {
    if (self = [super initWithFrame:CGRectMake(0.0, 0.0, kBookmarkMinSize.width, kBookmarkMinSize.height)]) {
        self.options = options;
        self.delegate = delegate;
        
        self.backgroundColor = [UIColor darkGrayColor];
        self.clipsToBounds = YES;   // Important so that optionContainerView gets clipped at top.
        
        [self initOptions];
        [self initInteractions];
    }
    return self;
}

- (void)show:(BOOL)show animated:(BOOL)animated {
    NSLog(@"show:%@ animated:%@", show ? @"YES" : @"NO", animated ? @"YES" : @"NO");
    CGRect frameForShow = [self frameForShow:show];
    if (animated) {
        [UIView animateWithDuration:0.15 
                              delay:0.0 
                            options:UIViewAnimationCurveEaseIn
                         animations:^{
                             self.frame = frameForShow;
                         } 
                         completion:^(BOOL finished) {
                             self.shown = show;
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
    CGFloat heightForOptions = [self heightForOptions];
    UIView *optionContainerView = [[UIView alloc] initWithFrame:CGRectMake(self.bounds.origin.x, 
                                                                           self.bounds.size.height - kBookmarkOptionInsets.bottom - heightForOptions, 
                                                                           self.bounds.size.width, 
                                                                           heightForOptions)];
    optionContainerView.backgroundColor = [UIColor clearColor];
    optionContainerView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin; // Anchor at bottom of parent.
    
    // Now add the options.
    CGFloat yOffset = 0.0;
    for (NSUInteger optionIndex = 0; optionIndex < [self.options count]; optionIndex++) {
        id option = [self.options objectAtIndex:optionIndex];
        UIView *optionView = nil;
        
        if ([option isKindOfClass:[NSString class]]) {
            optionView = [self optionViewFromString:option];
        } else if ([option isKindOfClass:[UIView class]]) {
            optionView = option;
        }
        
        if (optionView) {
            
            // Make it tappable.
            optionView.userInteractionEnabled = YES;
            optionView.tag = kBookmarkOptionTagBase + optionIndex;
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self 
                                                                                         action:@selector(optionTapped:)];
            [optionView addGestureRecognizer:tapGesture];
            
            // Position within bookmark.
            optionView.frame = CGRectMake(floorf((self.bounds.size.width - optionView.frame.size.width) / 2), 
                                          yOffset, 
                                          optionView.frame.size.width, 
                                          optionView.frame.size.height);
            [optionContainerView addSubview:optionView];
            yOffset += optionView.frame.size.height;
        }
    }
    
    [self addSubview:optionContainerView];
    self.optionContainerView = optionContainerView;
}

- (void)initInteractions {
    
    // Tap on tip to show/hide.
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [self addGestureRecognizer:tapGesture];
    
    // Drag to pull
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
    panGesture.delegate = self;
    [self addGestureRecognizer:panGesture];
    
}

- (void)tapped:(UITapGestureRecognizer *)tapGesture {
    CGPoint tapPoint = [tapGesture locationInView:self];
    if (CGRectContainsPoint(CGRectMake(self.bounds.origin.x, 
                                       self.bounds.size.height - kBookmarkMinSize.height, 
                                       kBookmarkMinSize.width, 
                                       kBookmarkMinSize.height), 
                            tapPoint)) {
        [self show:!self.shown animated:YES];
    }
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
                                  kBookmarkOptionInsets.top + [self heightForOptions] + kBookmarkOptionInsets.bottom);
    } else {
        frameForShow = CGRectMake(self.frame.origin.x, 
                                  self.frame.origin.y, 
                                  kBookmarkMinSize.width, 
                                  kBookmarkMinSize.height);
    }
    return frameForShow;
}

- (CGFloat)heightForOptions {
    return [self.options count] * kBookmarkOptionHeight;
}

- (UIView *)optionViewFromString:(NSString *)option {
    UIFont *optionFont = [UIFont boldSystemFontOfSize:14.0];
    CGSize optionSize = [option sizeWithFont:optionFont 
                           constrainedToSize:CGSizeMake(self.bounds.size.width, kBookmarkOptionHeight) 
                               lineBreakMode:UILineBreakModeTailTruncation];
    UIView *optionView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.bounds.size.width, kBookmarkOptionHeight)];
    optionView.backgroundColor = [UIColor clearColor];
    
    // Label
    UILabel *optionLabel = [[UILabel alloc] initWithFrame:CGRectMake(floorf((optionView.bounds.size.width - optionSize.width) / 2), 
                                                                     floorf((optionView.bounds.size.height - optionSize.height) / 2), 
                                                                     optionSize.width, 
                                                                     optionSize.height)];
    optionLabel.backgroundColor = [UIColor clearColor];
    optionLabel.font = optionFont;
    optionLabel.textColor = [UIColor whiteColor];
    optionLabel.shadowColor = [UIColor blackColor];
    optionLabel.shadowOffset = CGSizeMake(0.0, 1.0);
    optionLabel.text = option;
    [optionView addSubview:optionLabel];
    
    return optionView;
}

- (void)optionTapped:(UITapGestureRecognizer *)tapGesture {
    UIView *tappedView = [tapGesture view];
    NSUInteger tappedIndex = tappedView.tag - kBookmarkOptionTagBase;
    [self.delegate bookmarkDidSelectOptionAtIndex:tappedIndex];
}

@end
