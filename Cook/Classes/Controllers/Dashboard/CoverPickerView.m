//
//  ColourPickerView.m
//  Cook
//
//  Created by Jeff Tan-Ang on 4/12/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "CoverPickerView.h"
#import "CKBookCover.h"
#import "ViewHelper.h"

@interface CoverPickerView () <UIGestureRecognizerDelegate>

@property (nonatomic, assign) id<CoverPickerViewDelegate> delegate;
@property (nonatomic, strong) UIImageView *overlayView;
@property (nonatomic, strong) UIView *sliderView;
@property (nonatomic, strong) UIImageView *sliderContentView;
@property (nonatomic, strong) NSArray *availableCovers;
@property (nonatomic, strong) NSMutableArray *coverViews;
@property (nonatomic, assign) NSInteger *selectedCoverIndex;
@property (nonatomic, assign) BOOL animating;

@end

@implementation CoverPickerView

#define kMinSize        CGSizeMake(67.0, 61.0)
#define kMaxSize        CGSizeMake(67.0, 101.0)
#define kUnitWidth      80.0
#define kCoverOffset    CGPointMake(27.0, 17.0)
#define kSliderOffset   CGPointMake(27.0, 43.0)

- (id)initWithCover:(NSString *)cover delegate:(id<CoverPickerViewDelegate>)delegate {
    if (self = [super initWithFrame:CGRectZero]) {
        self.delegate = delegate;
        self.cover = cover;
        self.availableCovers = [CKBookCover covers];
        self.backgroundColor = [UIColor clearColor];
        
        // Overlay image which determines the width of the control.
        UIImage *overlayImage = [[UIImage imageNamed:@"cook_customise_colour_bar_overlay.png"] stretchableImageWithLeftCapWidth:45 topCapHeight:0];
        UIImageView *overlayView = [[UIImageView alloc] initWithImage:overlayImage];
        self.overlayView = overlayView;
        self.frame = CGRectMake(0.0, 0.0, (kCoverOffset.x * 2.0) + kUnitWidth * [self.availableCovers count], overlayView.frame.size.height);
        overlayView.frame = self.bounds;
        [self addSubview:overlayView];

        [self initCovers];
    }
    return self;
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return NO;
}

#pragma mark - Properties

- (UIView *)sliderView {
    if (!_sliderView) {
        
        // Slider overlay.
        UIImageView *sliderOverlayView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_customise_colour_picker_overlay.png"]];
        
        // Slider container view.
        _sliderView = [[UIView alloc] initWithFrame:sliderOverlayView.frame];
        _sliderView.userInteractionEnabled = YES;
        [self insertSubview:_sliderView aboveSubview:self.overlayView];
        
        // Add content then overlay.
        [_sliderView addSubview:self.sliderContentView];
        [_sliderView addSubview:sliderOverlayView];
        
        // Register drag on the slider.
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(sliderPanned:)];
        [_sliderView addGestureRecognizer:panGesture];

    }
    return _sliderView;
}

- (UIImageView *)sliderContentView {
    if (!_sliderContentView) {
        _sliderContentView = [[UIImageView alloc] initWithImage:[CKBookCover thumbSliderContentImageForCover:self.cover]];
        _sliderContentView.frame = CGRectMake(26.0, 16.0, _sliderContentView.frame.size.width, _sliderContentView.frame.size.height);
    }
    return _sliderContentView;
}

#pragma mark - Private methods

- (void)initCovers {
    
    self.coverViews = [NSMutableArray arrayWithCapacity:[self.availableCovers count]];
    CGFloat offset = kCoverOffset.x;
    
    for (NSString *cover in self.availableCovers) {
        
        UIImage *coverImage = [self imageForCover:cover];
        UIImageView *coverImageView = [[UIImageView alloc] initWithImage:coverImage];
        coverImageView.userInteractionEnabled = YES;
        coverImageView.frame = CGRectMake(offset, kCoverOffset.y, kUnitWidth, coverImageView.frame.size.height);
        [self insertSubview:coverImageView belowSubview:self.overlayView];
        [self.coverViews addObject:coverImageView];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(coverTapped:)];
        [coverImageView addGestureRecognizer:tapGesture];
        
        offset += coverImageView.frame.size.width;
    }
    
    // Select the given cover.
    NSUInteger selectedIndex = [self.availableCovers indexOfObject:self.cover];
    [self selectCoverAtIndex:selectedIndex informDelegate:NO animated:NO];
}

- (void)coverTapped:(UITapGestureRecognizer *)gesture {
    if (self.animating) {
        return;
    }
    
    UIView *sender = gesture.view;
    NSUInteger coverIndex = [self.coverViews indexOfObject:sender];
    [self selectCoverAtIndex:coverIndex];
}

- (void)selectCoverAtIndex:(NSUInteger)coverIndex {
    [self selectCoverAtIndex:coverIndex informDelegate:YES];
}

- (void)selectCoverAtIndex:(NSUInteger)coverIndex informDelegate:(BOOL)informDelegate {
    [self selectCoverAtIndex:coverIndex informDelegate:YES animated:YES];
}

- (void)selectCoverAtIndex:(NSUInteger)coverIndex informDelegate:(BOOL)informDelegate animated:(BOOL)animated {
    self.selectedCoverIndex = coverIndex;
    
    UIImageView *coverImageView = [self.coverViews objectAtIndex:coverIndex];
    NSString *selectedCover = [self.availableCovers objectAtIndex:coverIndex];
    
    if (animated) {
        self.animating = YES;
        [UIView animateWithDuration:0.2
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.sliderView.center = CGPointMake(coverImageView.center.x, kSliderOffset.y);
                         }
                         completion:^(BOOL finished) {
                             self.animating = NO;
                             
                             // Change content colour after arriving there.
                             [self changeSliderContentAtIndex:coverIndex];
                             if (informDelegate) {
                                 [self.delegate coverPickerSelected:selectedCover];
                             }
                         }];
    } else {
        
        // Change content colour after moving there.
        self.sliderView.center = CGPointMake(coverImageView.center.x, kSliderOffset.y);
        [self changeSliderContentAtIndex:coverIndex];
        if (informDelegate) {
            [self.delegate coverPickerSelected:selectedCover];
        }
    }
}

- (UIImage *)imageForCover:(NSString *)cover {
    return [[CKBookCover thumbImageForCover:cover] stretchableImageWithLeftCapWidth:0 topCapHeight:30];
}

- (void)sliderPanned:(UIPanGestureRecognizer *)panGesture {
    CGPoint translation = [panGesture translationInView:self];
    
    if (panGesture.state == UIGestureRecognizerStateBegan) {
    } else if (panGesture.state == UIGestureRecognizerStateChanged) {
        [self panWithTranslation:translation];
	} else if (panGesture.state == UIGestureRecognizerStateEnded) {
        [self panSnapIfRequired];
    }
    
    [panGesture setTranslation:CGPointZero inView:self];
}

- (void)panWithTranslation:(CGPoint)translation {
    CGRect sliderFrame = self.sliderView.frame;
    sliderFrame.origin.x += translation.x;
    
    if (sliderFrame.origin.x < 0) {
        sliderFrame.origin.x = 0;
    } else if (sliderFrame.origin.x + sliderFrame.size.width > self.bounds.size.width) {
        sliderFrame.origin.x = self.bounds.size.width - sliderFrame.size.width;
    }
    
    self.sliderView.frame = sliderFrame;
    [self changeSliderContentAtIndex:[self currentSelectedCoverIndex]];
}

- (void)panSnapIfRequired {
    [self detectCoverSelection];
}

- (void)detectCoverSelection {
    NSInteger selectedCoverIndex = [self currentSelectedCoverIndex];
    [self selectCoverAtIndex:selectedCoverIndex];
}

- (NSInteger)currentSelectedCoverIndex {
    CGRect sliderFrame = self.sliderView.frame;
    NSInteger selectedCoverIndex = 0;
    for (NSInteger coverIndex = 0; coverIndex < [self.coverViews count]; coverIndex++) {
        UIView *coverView = [self.coverViews objectAtIndex:coverIndex];
        CGRect coverFrame = coverView.frame;
        if (coverIndex == 0) {
            coverFrame.origin.x = kCoverOffset.x;
            coverFrame.size.width -= kCoverOffset.x;
        } else if (coverIndex == [self.coverViews count] - 1) {
            coverFrame.size.width -= kCoverOffset.x;
        }
        
        CGRect coverIntersection = CGRectIntersection(sliderFrame, coverFrame);
        if (coverIntersection.size.width > (kUnitWidth / 2.0)) {
            selectedCoverIndex = coverIndex;
            break;
        }
    }
    return selectedCoverIndex;
}

- (void)changeSliderContentAtIndex:(NSInteger)coverIndex {
    NSString *selectedCover = [self.availableCovers objectAtIndex:coverIndex];
    self.sliderContentView.image = [CKBookCover thumbSliderContentImageForCover:selectedCover];
}

@end
