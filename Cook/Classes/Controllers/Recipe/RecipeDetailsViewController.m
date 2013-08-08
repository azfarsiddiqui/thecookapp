//
//  RecipeDetailsViewController.m
//  SnappingScrollViewDemo
//
//  Created by Jeff Tan-Ang on 8/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "RecipeDetailsViewController.h"
#import "CKRecipe.h"
#import "ParsePhotoStore.h"
#import "ViewHelper.h"
#import "CKBookCover.h"
#import "CKBook.h"

typedef NS_ENUM(NSUInteger, SnapViewport) {
    SnapViewportTop,
    SnapViewportBottom,
    SnapViewportBelow
};

@interface RecipeDetailsViewController () <UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) CKRecipe *recipe;
@property (nonatomic, weak) id<BookModalViewControllerDelegate> modalDelegate;
@property (nonatomic, strong) ParsePhotoStore *photoStore;

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *topShadowView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

@property (nonatomic, assign) BOOL draggingDown;
@property (nonatomic, assign) BOOL editMode;
@property (nonatomic, assign) SnapViewport currentViewport;
@property (nonatomic, assign) SnapViewport previousViewport;

@end

@implementation RecipeDetailsViewController

#define kSnapOffset     100.0
#define kBounceOffset   10.0
#define kDragRatio      0.9

- (id)initWithRecipe:(CKRecipe *)recipe {
    if (self = [super init]) {
        self.recipe = recipe;
        self.photoStore = [[ParsePhotoStore alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    
    [self initImageView];
    [self initScrollView];
}

#pragma mark - BookModalViewController methods

- (void)setModalViewControllerDelegate:(id<BookModalViewControllerDelegate>)modalViewControllerDelegate {
    self.modalDelegate = modalViewControllerDelegate;
}

- (void)bookModalViewControllerWillAppear:(NSNumber *)appearNumber {
    DLog();
}

- (void)bookModalViewControllerDidAppear:(NSNumber *)appearNumber {
    DLog();
    if ([appearNumber boolValue]) {
        
        // Snap to the start viewport.
        [self snapToViewport:[self startViewPort] animated:YES completion:^{
            
            // Load stuff.
            [self loadData];
            
        }];
        
    } else {
        
    }
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    BOOL shouldReceiveTouch = YES;
    
    // Ignore taps on background image view when in edit mode.
    if (self.editMode && gestureRecognizer.view == self.imageView) {
        shouldReceiveTouch = NO;
    }
    
    return shouldReceiveTouch;
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    return YES;
}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //    NSLog(@"contentOffset %f", scrollView.contentOffset.y);
    
    CGRect contentFrame = self.scrollView.frame;
    CGPoint contentOffset = scrollView.contentOffset;
    
    // Scroll view is now pulling its own frame down.
    if (contentOffset.y <= 0) {
        
        // Dragging myself down.
        contentFrame.origin.y -= contentOffset.y * kDragRatio;
        contentFrame.origin.y = MIN([self offsetForViewport:SnapViewportBottom], contentFrame.origin.y);
        self.scrollView.frame = contentFrame;
        self.draggingDown = YES;
        
    } else if (self.draggingDown) {
        
        // Maintain contentOffset to stay fixed at top while dragging down.
        CGRect bounds = self.scrollView.bounds;
        bounds.origin.y = 0.0;
        self.scrollView.bounds = bounds;
        
        // If drag up while dragging down, also move the panel up with it.
        if (contentOffset.x >= 0) {
            contentFrame.origin.y -= contentOffset.y * kDragRatio;
            contentFrame.origin.y = MAX([self offsetForViewport:SnapViewportTop], contentFrame.origin.y);
            self.scrollView.frame = contentFrame;
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    NSLog(@"scrollViewDidEndDragging willDecelerate[%@]", decelerate ? @"YES" : @"NO");
    [self panSnapIfRequired];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSLog(@"scrollViewDidEndDecelerating");
    [self panSnapIfRequired];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    NSLog(@"scrollViewDidEndScrollingAnimation");
    [self panSnapIfRequired];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    NSLog(@"scrollViewWillEndDragging velocity[%@]", NSStringFromCGPoint(velocity));
}

#pragma mark - Properties



#pragma mark - Private methods

- (void)initImageView {
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    imageView.alpha = 0.0;
    [self.view addSubview:imageView];
    self.imageView = imageView;
    
    // Top shadow.
    UIImageView *topShadowView = [ViewHelper topShadowView];
    topShadowView.alpha = 0.0;
    [self.view insertSubview:topShadowView aboveSubview:self.imageView];
    self.topShadowView = topShadowView;
    
    // Register tap on background image for tap expand.
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped:)];
    tapGesture.delegate = self;
    [self.imageView addGestureRecognizer:tapGesture];
}

- (void)initScrollView {
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:(CGRect){
        self.view.bounds.origin.x,
        self.view.bounds.origin.y,
        self.view.bounds.size.width,
        self.view.bounds.size.height - [self offsetForViewport:SnapViewportTop]
    }];
    scrollView.contentSize = (CGSize){ self.view.bounds.size.width, 1200.0 };
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    scrollView.alwaysBounceVertical = YES;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.delegate = self;
    scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    scrollView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;
    
    UILabel *label = [self createLabelWithText:@"TOP"];
    label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    label.frame = (CGRect) {
        floorf((scrollView.bounds.size.width - label.frame.size.width) / 2.0),
        scrollView.bounds.origin.y,
        label.frame.size.width,
        label.frame.size.height
    };
    [scrollView addSubview:label];
    
    UILabel *botLabel = [self createLabelWithText:@"BOTTOM"];
    botLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    botLabel.frame = (CGRect) {
        floorf((scrollView.bounds.size.width - botLabel.frame.size.width) / 2.0),
        scrollView.contentSize.height- botLabel.frame.size.height,
        botLabel.frame.size.width,
        botLabel.frame.size.height
    };
    [scrollView addSubview:botLabel];
    
    // Register a concurrent panGesture to drag panel up and down.
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
    panGestureRecognizer.delegate = self;
    [scrollView addGestureRecognizer:panGestureRecognizer];
    self.panGesture = panGestureRecognizer;
    
    // Start at bottom viewport.
    [self snapToViewport:SnapViewportBelow animated:NO];
}

- (void)loadData {
    [self loadPhoto];
}

- (void)loadPhoto {
    if ([self.recipe hasPhotos]) {
        [self.photoStore imageForParseFile:[self.recipe imageFile]
                                      size:self.imageView.bounds.size
                                completion:^(UIImage *image) {
                                    [self loadImageViewWithPhoto:image placeholder:NO];
                                }];
    } else {
        
        // Load placeholder editing background based on book cover.
        [self loadImageViewWithPhoto:[CKBookCover recipeEditBackgroundImageForCover:self.recipe.book.cover]
                         placeholder:YES];
    }
    
}

- (void)loadImageViewWithPhoto:(UIImage *)image placeholder:(BOOL)placeholder {
    self.imageView.image = image;
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.topShadowView.alpha = placeholder ? 0.0 : 1.0;
                         self.imageView.alpha = 1.0;
                     }
                     completion:^(BOOL finished)  {
                     }];
}

- (void)snapToViewport:(SnapViewport)viewport  {
    [self snapToViewport:viewport animated:YES];
}

- (void)snapToViewport:(SnapViewport)viewport animated:(BOOL)animated {
    [self snapToViewport:viewport animated:animated completion:nil];
}

- (void)snapToViewport:(SnapViewport)viewport completion:(void (^)())completion {
    [self snapToViewport:viewport animated:YES completion:completion];
}

- (void)snapToViewport:(SnapViewport)viewport animated:(BOOL)animated completion:(void (^)())completion {
    
    // Set the required offset for the given viewport.
    CGRect frame = self.scrollView.frame;
    frame.origin.y = [self offsetForViewport:viewport];
    
    // Scroll enabled at the given viewport?
    BOOL scrollEnabled = [self scrollEnabledAtViewport:viewport];
    
    SnapViewport currentViewport = self.currentViewport;
    
    // Determine if a bounce is required.
    CGRect bounceFrame = [self bounceFrameFromViewport:currentViewport toViewport:viewport];
    BOOL bounceRequired = !CGRectIsEmpty(bounceFrame);
    
    // Remmeber previous and current viewports.
    self.previousViewport = currentViewport;
    self.currentViewport = viewport;
    
    if (animated) {
        
        if (bounceRequired) {
            
            // Do a bounce.
            [UIView animateWithDuration:[self animationDurationFromViewport:currentViewport toViewport:viewport]
                                  delay:0.0
                                options:[self animationCurveFromViewport:currentViewport toViewport:viewport]
                             animations:^{
                                 self.scrollView.frame = bounceFrame;
                             }
                             completion:^(BOOL finished) {
                                 
                                 // Rest on intended frame.
                                 [UIView animateWithDuration:0.1
                                                       delay:0.0
                                                     options:UIViewAnimationOptionCurveEaseIn
                                                  animations:^{
                                                      self.scrollView.frame = frame;
                                                  }
                                                  completion:^(BOOL finished) {
                                                      self.scrollView.scrollEnabled = scrollEnabled;
                                                      self.draggingDown = NO;
                                                      
                                                      if (completion != nil) {
                                                          completion();
                                                      }
                                                  }];
                             }];
        } else {
            
            [UIView animateWithDuration:[self animationDurationFromViewport:currentViewport toViewport:viewport]
                                  delay:0.0
                                options:[self animationCurveFromViewport:currentViewport toViewport:viewport]
                             animations:^{
                                 self.scrollView.frame = frame;
                             }
                             completion:^(BOOL finished) {
                                 self.scrollView.scrollEnabled = scrollEnabled;
                                 self.draggingDown = NO;
                                 if (completion != nil) {
                                     completion();
                                 }
                             }];
        }
        
    } else {
        self.scrollView.frame = frame;
        self.scrollView.scrollEnabled = scrollEnabled;
        self.draggingDown = NO;
        if (completion != nil) {
            completion();
        }
    }
}

- (UIViewAnimationOptions)animationCurveFromViewport:(SnapViewport)fromViewport toViewport:(SnapViewport)toViewport {
    UIViewAnimationOptions animationCurve = UIViewAnimationOptionCurveEaseIn;
    if (toViewport == SnapViewportTop) {
        
        // Fast to top.
        animationCurve = UIViewAnimationOptionCurveEaseOut;
        
    } else if (toViewport == SnapViewportBottom) {
        
        // Slow down to bottom.
        animationCurve = UIViewAnimationOptionCurveEaseOut;
        
    } else if (toViewport == SnapViewportBelow) {
        
        // Fast to below.
        animationCurve = UIViewAnimationOptionCurveEaseIn;
    }
    
    return animationCurve;
}

- (CGFloat)animationDurationFromViewport:(SnapViewport)fromViewport toViewport:(SnapViewport)toViewport {
    CGFloat duration = 0.25;
    CGFloat offset = [self offsetForViewport:toViewport];
    
    if (toViewport == SnapViewportTop) {
        
        // Fast to top.
        duration = 0.25;
        
        CGFloat distance = ABS(self.scrollView.frame.origin.y - offset);
        CGFloat totalDistance = [self offsetForViewport:SnapViewportBottom] - offset;
        CGFloat durationRatio = distance / totalDistance;
        duration = MAX(duration * durationRatio, 0.15);
        
        
    } else if (toViewport == SnapViewportBottom) {
        
        // Slow down to bottom.
        duration = 0.22;
        
    } else if (toViewport == SnapViewportBelow) {
        
        // Fast to below.
        duration = 0.25;
    }
    
    NSLog(@"duration %f", duration);
    return duration;
}

- (CGRect)bounceFrameFromViewport:(SnapViewport)fromViewport toViewport:(SnapViewport)toViewport {
    CGRect bounceFrame = CGRectZero;
    
    // Bounce if going from bottom/below to top only.
    if ((fromViewport == SnapViewportBottom || fromViewport == SnapViewportBelow)
        && (toViewport == SnapViewportTop)) {
        
        bounceFrame = self.scrollView.frame;
        bounceFrame.origin.y = [self offsetForViewport:toViewport];
        bounceFrame.origin.y -= kBounceOffset;
        bounceFrame.size.height += kBounceOffset;   // To offset the gap at the bottom.
        
    }
    
    return bounceFrame;
}

- (BOOL)bounceRequiredForTargetViewport:(SnapViewport)viewport {
    BOOL bounce = NO;
    
    // Bounce if going from bottom/below to top only.
    if ((self.currentViewport == SnapViewportBottom || self.currentViewport == SnapViewportBelow)
        && (viewport == SnapViewportTop)) {
        
        bounce = YES;
    }
    
    return bounce;
}

- (CGFloat)offsetForViewport:(SnapViewport)viewport {
    CGFloat offset = 0.0;
    switch (viewport) {
        case SnapViewportTop:
            offset = 70.0;
            break;
        case SnapViewportBottom:
            offset = 558.0;
            break;
        case SnapViewportBelow:
            offset = self.view.bounds.size.height;
            break;
        default:
            break;
    }
    return offset;
}

- (BOOL)scrollEnabledAtViewport:(SnapViewport)viewport {
    
    // Scroll enabled at top of viewport only.
    return (viewport == SnapViewportTop);
}

- (void)panned:(UIPanGestureRecognizer *)panGesture {
    CGPoint translation = [panGesture translationInView:self.scrollView];
    
    if (panGesture.state == UIGestureRecognizerStateBegan) {
    } else if (panGesture.state == UIGestureRecognizerStateChanged) {
        [self panWithTranslation:translation.y];
	} else if (panGesture.state == UIGestureRecognizerStateEnded) {
        [self panSnapIfRequired];
    }
    
    [panGesture setTranslation:CGPointZero inView:self.view];
}

- (void)panWithTranslation:(CGFloat)translation {
    CGFloat dragRatio = kDragRatio;
    CGFloat panOffset = ceilf(translation * dragRatio);
    
    // Drag up and down the panel when panGesture is in effect.
    CGRect contentFrame = self.scrollView.frame;
    
    // Add additional drag past the bottom offset.
    if (contentFrame.origin.y + panOffset > [self offsetForViewport:SnapViewportBottom]) {
        panOffset *= 0.15;
    }
    
    contentFrame.origin.y += panOffset;
    contentFrame.origin.y = MAX([self offsetForViewport:SnapViewportTop], contentFrame.origin.y);
    contentFrame.origin.y = MIN([self offsetForViewport:SnapViewportBottom] + 50, contentFrame.origin.y);
    self.scrollView.frame = contentFrame;
    
    // Disable scrollview when at top.
    self.scrollView.scrollEnabled = (contentFrame.origin.y == [self offsetForViewport:SnapViewportTop]);
}

- (void)panSnapIfRequired {
    CGRect contentFrame = self.scrollView.frame;
    
    CGFloat criticalOffset = [self snapCriticalOffsetForViewport:self.currentViewport];
    
    if (self.currentViewport == SnapViewportTop) {
        if (contentFrame.origin.y > criticalOffset) {
            
            // Snap to the bottom viewport.
            [self snapToViewport:SnapViewportBottom animated:YES];
            self.panGesture.enabled = YES;
            
        } else {
            
            // Restore the panel up.
            [self snapToViewport:SnapViewportTop animated:YES];
            self.panGesture.enabled = NO;
            
        }
    } else if (self.currentViewport == SnapViewportBottom) {
        if (contentFrame.origin.y < criticalOffset) {
            
            // Snap to top viewport.
            [self snapToViewport:SnapViewportTop animated:YES];
            self.panGesture.enabled = NO;
            
        } else {
            
            // Restore the panel down.
            [self snapToViewport:SnapViewportBottom animated:YES];
            self.panGesture.enabled = YES;
        }
    }
}

- (CGFloat)snapCriticalOffsetForViewport:(SnapViewport)viewport {
    CGFloat offset = 0.0;
    switch (viewport) {
        case SnapViewportTop:
            offset = [self offsetForViewport:SnapViewportTop] + kSnapOffset;
            break;
        case SnapViewportBottom:
            offset = [self offsetForViewport:SnapViewportBottom] - kSnapOffset;
            break;
        case SnapViewportBelow:
            break;
        default:
            break;
    }
    return offset;
}

- (UILabel *)createLabelWithText:(NSString *)text {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor blackColor];
    label.font = [UIFont boldSystemFontOfSize:40.0];
    label.text = text;
    [label sizeToFit];
    return label;
}

- (SnapViewport)startViewPort {
    SnapViewport startViewPort = SnapViewportBottom;
    if (self.recipe && ![self.recipe hasPhotos]) {
        startViewPort = SnapViewportTop;
    }
    return startViewPort;
}

- (void)imageTapped:(UITapGestureRecognizer *)tapGesture {
    SnapViewport viewport = SnapViewportBelow;
    switch (self.currentViewport) {
        case SnapViewportBelow:
            viewport = self.previousViewport;
            break;
        default:
            break;
    }
    [self snapToViewport:viewport animated:YES];
}

@end
