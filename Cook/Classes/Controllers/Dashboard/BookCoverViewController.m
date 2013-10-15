//
//  BookCoverViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 19/11/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "BookCoverViewController.h"
#import "CKBookCoverView.h"
#import "CKBookCover.h"
#import "BenchtopBookCoverViewCell.h"
#import "NSString+Utilities.h"
#import "EventHelper.h"
#import "Theme.h"
#import "ImageHelper.h"
#import "AppHelper.h"

@interface BookCoverViewController ()

@property (nonatomic, strong) CKBook *book;
@property (nonatomic, assign) BOOL mine;
@property (nonatomic, weak) id<BookCoverViewControllerDelegate> delegate;
@property (nonatomic, assign) CGPoint centerPoint;
@property (nonatomic, strong) UIView *bookCoverView;
@property (nonatomic, strong) CALayer *rootBookLayer;
@property (nonatomic, strong) CALayer *bookCoverLayer;
@property (nonatomic, strong) CALayer *bookCoverContentsLayer;
@property (nonatomic, strong) CALayer *leftOpenLayer;
@property (nonatomic, strong) CALayer *rightOpenLayer;
@property (nonatomic, strong) CALayer *leftContentsLayer;
@property (nonatomic, strong) CALayer *rightContentsLayer;
@property (nonatomic, assign) BOOL opened;

@end

@implementation BookCoverViewController

#define RADIANS(degrees)                ((degrees * (float)M_PI) / 180.0f)
#define kBookContentInset               (UIEdgeInsets){ 26.0, 64.0, 64.0, 64.0 }
#define kBookOutlineShadowInset         (UIEdgeInsets){ 16.0, 44.0, 54.0, 44.0 }
#define kSmallBookContentInset          (UIEdgeInsets){ 8.0, 17.0, 12.0, 17.0 }
#define kSmallBookOutlineShadowInset    (UIEdgeInsets){ 9.0, 26.0, 30.0, 26.0 }

- (id)initWithBook:(CKBook *)book delegate:(id<BookCoverViewControllerDelegate>)delegate {
    return [self initWithBook:book mine:NO delegate:delegate];
}

- (id)initWithBook:(CKBook *)book mine:(BOOL)mine delegate:(id<BookCoverViewControllerDelegate>)delegate {
    if (self = [super init]) {
        self.book = book;
        self.mine = mine;
        self.delegate = delegate;
        self.showInsideCover = NO;
        self.showInsideCoverLegacy = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight;
    
    CKBookCoverView *bookCoverView = [[CKBookCoverView alloc] init];
    [bookCoverView loadBook:self.book editable:NO];

    self.bookCoverView = bookCoverView;
}

- (void)openBook:(BOOL)open {
    [self openBook:open centerPoint:CGPointZero];
}

- (void)openBook:(BOOL)open centerPoint:(CGPoint)centerPoint {
    if (open) {
        self.centerPoint = centerPoint;
        [self initLayers];
    }
    [self.delegate bookCoverViewWillOpen:open];
    [self animateBookOpen:open];
}

- (void)cleanUpLayers {
    [self.rightOpenLayer removeFromSuperlayer];
    [self.leftOpenLayer removeFromSuperlayer];
    [self.bookCoverLayer removeFromSuperlayer];
    [self.rootBookLayer removeFromSuperlayer];
}

- (void)loadSnapshotView:(UIView *)snapshotView {
    if (!self.showInsideCover) {
        return;
    }
    
    // Left image.
    UIGraphicsBeginImageContextWithOptions((CGSize){ (snapshotView.bounds.size.width / 2.0), snapshotView.bounds.size.height}, NO, 0);
    BOOL leftDone = [snapshotView drawViewHierarchyInRect:(CGRect){
        0.0,
        0.0,
        snapshotView.frame.size.width,
        snapshotView.frame.size.height
    } afterScreenUpdates:YES];
    UIImage *leftImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.leftOpenLayer.contents = (id)leftImage.CGImage;
    DLog(@"Drawn leftImage %@", leftDone ? @"YES" : @"NO");
    
    // Right image.
    UIGraphicsBeginImageContextWithOptions((CGSize){snapshotView.bounds.size.width/2.0, snapshotView.bounds.size.height}, NO, 0);
    BOOL rightDone = [snapshotView drawViewHierarchyInRect:(CGRect){
        -(snapshotView.frame.size.width / 2.0),
        0.0,
        snapshotView.frame.size.width,
        snapshotView.frame.size.height
    } afterScreenUpdates:YES];
    UIImage *rightImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.rightOpenLayer.contents = (id)rightImage.CGImage;
    DLog(@"Drawn rightImage %@", rightDone ? @"YES" : @"NO");
    
    DLog(@"Loaded snapshotView");
}

- (void)loadSnapshotImage:(UIImage *)snapshotImage {
    if (!self.showInsideCoverLegacy) {
        return;
    }
    
    CGFloat screenScale = [[AppHelper sharedInstance] screenScale];
    CGRect screenFrame = [[AppHelper sharedInstance] fullScreenFrame];
    
    // Left image.
    UIImage *leftImage = [ImageHelper slicedImage:snapshotImage frame:(CGRect){
        0.0,
        0.0,
        (screenFrame.size.width / 2.0) * screenScale,
        screenFrame.size.height * screenScale
    }];
    UIGraphicsEndImageContext();
    self.leftContentsLayer.contentsScale = screenScale;
    self.leftContentsLayer.contents = (id)leftImage.CGImage;
    
    // Right image.
    UIImage *rightImage = [ImageHelper slicedImage:snapshotImage frame:(CGRect){
        (screenFrame.size.width / 2.0) * screenScale,
        0.0,
        (screenFrame.size.width / 2.0) * screenScale,
        screenFrame.size.height * screenScale
    }];
    self.rightContentsLayer.contentsScale = screenScale;
    self.rightContentsLayer.contents = (id)rightImage.CGImage;
}

#pragma mark - CAAnimation delegate methods

- (void)animationDidStart:(CAAnimation *)theAnimation {
    DLog(@"Open book starting: %@", [NSString CK_stringForBoolean:self.opened]);
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
    DLog(@"Open book finished: %@", [NSString CK_stringForBoolean:self.opened]);
    
//    if (!self.opened) {
//        [self.rootBookLayer removeAllAnimations];
//    [self.leftOpenLayer removeAllAnimations];
//        [self.bookCoverLayer removeAllAnimations];
//    }
    
    [self.delegate bookCoverViewDidOpen:self.opened];
}

#pragma mark - Private methods

- (void)initLayers {
    
    // Book root layer.
    CALayer *rootBookLayer = [CALayer layer];
    rootBookLayer.anchorPoint = CGPointMake(0.5, 0.5);
    rootBookLayer.frame = self.bookCoverView.bounds;
    rootBookLayer.position = (CGPoint) {
        floorf((self.view.bounds.size.width) / 2.0),
        floorf((self.view.bounds.size.height) / 2.0) + 10.0
    };
    rootBookLayer.backgroundColor = [UIColor clearColor].CGColor;
    [self.view.layer addSublayer:rootBookLayer];
    self.rootBookLayer = rootBookLayer;
    
    // Opened RHS layer: outline - shadow.
    CALayer *rightOpenLayer = [CALayer layer];
    rightOpenLayer.anchorPoint = CGPointMake(0.5, 0.5);
    rightOpenLayer.position = CGPointMake(floorf(self.rootBookLayer.bounds.size.width / 2),
                                          floorf(self.rootBookLayer.bounds.size.height / 2));
    rightOpenLayer.frame = CGRectMake(rootBookLayer.bounds.origin.x,
                                      rootBookLayer.bounds.origin.y,
                                      rootBookLayer.bounds.size.width,
                                      rootBookLayer.bounds.size.height);
    rightOpenLayer.backgroundColor = [Theme bookCoverInsideBackgroundColour].CGColor;
    
    // RHS outline: outline + shadow.
    UIImage *rightOutlineImage = [CKBookCover outlineImageForCover:self.book.cover left:NO];
    CALayer *rightOutlineLayer = [CALayer layer];
    rightOutlineLayer.frame = (CGRect){
        rightOpenLayer.bounds.origin.x,
         -kSmallBookOutlineShadowInset.top,
        rightOpenLayer.bounds.size.width + kSmallBookOutlineShadowInset.right,
        rightOpenLayer.bounds.size.height + kSmallBookOutlineShadowInset.top + kSmallBookOutlineShadowInset.bottom
    };
    rightOutlineLayer.contents = (id)rightOutlineImage.CGImage;
    [rightOpenLayer addSublayer:rightOutlineLayer];

    // RHS contents.
    CALayer *rightContentsLayer = [CALayer layer];
    rightContentsLayer.frame = (CGRect){
        rightOpenLayer.bounds.origin.x,
        kSmallBookContentInset.top,
        rightOpenLayer.bounds.size.width - kSmallBookContentInset.right,
        rightOpenLayer.bounds.size.height - kSmallBookContentInset.top - kSmallBookContentInset.bottom
    };
    rightContentsLayer.contents = (id)[UIImage imageNamed:@"cook_book_inner_page_right.png"].CGImage;
    [rightOpenLayer addSublayer:rightContentsLayer];
    self.rightContentsLayer = rightContentsLayer;
    
    [self.rootBookLayer addSublayer:rightOpenLayer];
    self.rightOpenLayer = rightOpenLayer;
    
    // Book cover layer.
    CALayer *rootBookCoverLayer = [CATransformLayer layer];
    rootBookCoverLayer.anchorPoint = CGPointMake(0.0, 0.5);
    rootBookCoverLayer.frame = self.rootBookLayer.bounds;
    rootBookCoverLayer.position = CGPointMake(0.0, floorf(self.rootBookLayer.bounds.size.height / 2));
    rootBookCoverLayer.doubleSided = YES;
    
    // Opened LHS layer.
    CALayer *leftOpenLayer = [CALayer layer];
    leftOpenLayer.anchorPoint = CGPointMake(0.5, 0.5);
    leftOpenLayer.frame = rootBookCoverLayer.bounds;
    leftOpenLayer.backgroundColor = [Theme bookCoverInsideBackgroundColour].CGColor;
    leftOpenLayer.doubleSided = NO;
    leftOpenLayer.transform = CATransform3DMakeRotation(RADIANS(180.0), 0.0, 1.0, 0.0);
    
    // RHS outline.
    UIImage *leftOutlineImage = [CKBookCover outlineImageForCover:self.book.cover left:YES];
    CALayer *leftOutlineLayer = [CALayer layer];
    leftOutlineLayer.frame = (CGRect){
        -kSmallBookOutlineShadowInset.left,
        -kSmallBookOutlineShadowInset.top,
        leftOpenLayer.bounds.size.width + kSmallBookOutlineShadowInset.left,
        leftOpenLayer.bounds.size.height + kSmallBookOutlineShadowInset.top + kSmallBookOutlineShadowInset.bottom
    };
    leftOutlineLayer.contents = (id)leftOutlineImage.CGImage;
    [leftOpenLayer addSublayer:leftOutlineLayer];
    
    // LHS contents.
    CALayer *leftContentsLayer = [CALayer layer];
    leftContentsLayer.frame = (CGRect){
        kSmallBookContentInset.left,
        kSmallBookContentInset.top,
        leftOpenLayer.bounds.size.width - kSmallBookContentInset.left,
        leftOpenLayer.bounds.size.height - kSmallBookContentInset.top - kSmallBookContentInset.bottom
    };
    leftContentsLayer.contents = (id)[UIImage imageNamed:@"cook_book_inner_page_left.png"].CGImage;
    [leftOpenLayer addSublayer:leftContentsLayer];
    self.leftContentsLayer = leftContentsLayer;
    
    [rootBookCoverLayer addSublayer:leftOpenLayer];
    self.leftOpenLayer = leftOpenLayer;
    
    // Front book cover contents.
    CALayer *bookCoverContentsLayer = [CALayer layer];
    bookCoverContentsLayer.anchorPoint = CGPointMake(0.0, 0.0);
    bookCoverContentsLayer.frame = rootBookCoverLayer.bounds;
    bookCoverContentsLayer.doubleSided = NO;
    [rootBookCoverLayer addSublayer:bookCoverContentsLayer];
    self.bookCoverContentsLayer = bookCoverContentsLayer;
    
    // Attach book cover view
    self.bookCoverView.layer.frame = bookCoverContentsLayer.bounds;
    [self.bookCoverContentsLayer addSublayer:self.bookCoverView.layer];

    [self.rootBookLayer addSublayer:rootBookCoverLayer];
    self.bookCoverLayer = rootBookCoverLayer;
    
    // Inside snapshot.
    [self loadSnapshotView];
    [self loadSnapshotImage];
}

- (void)animateBookOpen:(BOOL)open {
    DLog(@"open: %@", [NSString CK_stringForBoolean:open]);
    if (self.opened == open) {
        return;
    }
    self.opened = open;
    
    // Root book animation changes.
    CGPoint rootBookStartPoint = CGPointMake(0.5, 0.5);
    CGPoint rootBookEndPoint = CGPointMake(0.0, 0.515); // Some magic number to take into account the 10pt that was shifted down.
    CGFloat requiredScaleY = [self bookContentsHeightRatio];
    
    // Some magic value to match it against the edge of the book.
    CGFloat requiredScaleX = [self bookContentsWidthRatio];
    
    CATransform3D rootBookScaleUpTransform = CATransform3DMakeScale(requiredScaleX, requiredScaleY, 1.0);
    CATransform3D rootBookScaleDownTransform = CATransform3DIdentity;
    CATransform3D openBookTransform = CATransform3DMakeRotation(RADIANS(180), 0.0f, -1.0f, 0.0f);
    CGFloat zDistance = 1000;
    openBookTransform.m34 = 1 / zDistance;
    CATransform3D closeBookTransform = CATransform3DIdentity;
    
    // Grab media time for timing our animations.
    CFTimeInterval rootMediaTime = [self.rootBookLayer convertTime:CACurrentMediaTime() fromLayer:nil];
    CGFloat duration = 0.6;
    if (!open) {
        duration += 0.1;
    }
    CGFloat shiftEndOffset = 0.05;
    CGFloat scaleUpStartOffset = 0.05;
    CGFloat flipStartOffset = 0.1;
    CGFloat scaleDownEndOffset = 0.0;
    CGFloat flipEndOffset = 0.1;
    
    // Shift right/left
    CABasicAnimation *translateAnimation = [CABasicAnimation animationWithKeyPath:@"anchorPoint"];
    translateAnimation.fromValue = [NSValue valueWithCGPoint:open ? rootBookStartPoint : rootBookEndPoint];
    translateAnimation.toValue = [NSValue valueWithCGPoint:open ? rootBookEndPoint : rootBookStartPoint];
    translateAnimation.beginTime = 0.0;
    translateAnimation.duration = open ? (duration - shiftEndOffset) : duration;
    translateAnimation.fillMode = kCAFillModeBoth;
    translateAnimation.timingFunction = [CAMediaTimingFunction functionWithName:open ? kCAMediaTimingFunctionEaseIn : kCAMediaTimingFunctionEaseOut];
    translateAnimation.removedOnCompletion = NO;
    
    // Scale up/down
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    scaleAnimation.fromValue = [NSValue valueWithCATransform3D:open ? rootBookScaleDownTransform : rootBookScaleUpTransform];
    scaleAnimation.toValue = [NSValue valueWithCATransform3D:open ? rootBookScaleUpTransform : rootBookScaleDownTransform];
    scaleAnimation.beginTime = open ? scaleUpStartOffset : 0.0;
    scaleAnimation.duration = open ? (duration - scaleUpStartOffset) : (duration - scaleDownEndOffset);
    scaleAnimation.fillMode = kCAFillModeBoth;
    scaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:open ? kCAMediaTimingFunctionEaseIn : kCAMediaTimingFunctionEaseOut];
    scaleAnimation.removedOnCompletion = NO;
    
    // Combine shift+right
    CAAnimationGroup *groupAnimation = [CAAnimationGroup animation];
    groupAnimation.duration = duration;
    [groupAnimation setAnimations:[NSArray arrayWithObjects:translateAnimation, scaleAnimation, nil]];
//    [groupAnimation setAnimations:[NSArray arrayWithObjects:translateAnimation, nil]];
    groupAnimation.removedOnCompletion = NO;
    groupAnimation.fillMode = kCAFillModeBoth;
    
    // Flip open/close
    CABasicAnimation *flipAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    flipAnimation.beginTime = open ? (rootMediaTime + flipStartOffset) : rootMediaTime;
    flipAnimation.duration = open ? (duration - flipStartOffset) : (duration - flipEndOffset);
    flipAnimation.fromValue = [NSValue valueWithCATransform3D:open ? closeBookTransform : openBookTransform];
    flipAnimation.toValue = [NSValue valueWithCATransform3D:open ? openBookTransform : closeBookTransform];
    flipAnimation.fillMode = kCAFillModeBoth;
    flipAnimation.timingFunction = [CAMediaTimingFunction functionWithName:open ? kCAMediaTimingFunctionEaseIn : kCAMediaTimingFunctionEaseOut];
    flipAnimation.removedOnCompletion = open ? NO : YES;    // Fixes the flicker when it the flip finishes.
    flipAnimation.additive = YES;
    flipAnimation.delegate = self;
    
    // Run the animation.
    [CATransaction lock];
    [CATransaction begin];
    [self.rootBookLayer addAnimation:groupAnimation forKey:nil];
    [self.bookCoverLayer addAnimation:flipAnimation forKey:@"transform"];
    [CATransaction commit];
    [CATransaction unlock];
}

- (void)loadSnapshotView {
    if (!self.showInsideCover) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(bookCoverViewInsideSnapshotView)]) {
        [self loadSnapshotView:[self.delegate bookCoverViewInsideSnapshotView]];
    }
}

- (void)loadSnapshotImage {
    if (!self.showInsideCoverLegacy) {
        return;
    }
    
    // TODO Disable live snapshotting.
//    if ([self.delegate respondsToSelector:@selector(bookCoverViewInsideSnapshotImage)]) {
//        [self loadSnapshotImage:[self.delegate bookCoverViewInsideSnapshotImage]];
//    }
}

- (CGFloat)bookContentsHeightRatio {
    
    // The ratio required to scale the contents of the book to 0.9
//    return (0.9 * self.view.bounds.size.height) / [self bookContentsHeight];
    return 1.62;
}

- (CGFloat)bookContentsWidthRatio {
    
    // The ratio required to scale the contents of the book to 0.9
//    return (0.9 * floorf(self.view.bounds.size.width / 2.0)) / [self bookContentsWidth];
    return 1.53;
}

- (CGFloat)bookContentsHeight {
    return self.bookCoverView.bounds.size.height - (kBookContentInset.top - kBookOutlineShadowInset.top) - (kBookContentInset.bottom - kBookOutlineShadowInset.bottom);
//    return self.bookCoverView.bounds.size.height - kBookContentInset.top - kBookContentInset.bottom;
}

- (CGFloat)bookContentsWidth {
    return self.bookCoverView.bounds.size.width - (kBookContentInset.left - kBookOutlineShadowInset.left) - (kBookContentInset.right - kBookOutlineShadowInset.right);
//    return self.bookCoverView.bounds.size.width - kBookContentInset.top - kBookContentInset.bottom;
}

@end
