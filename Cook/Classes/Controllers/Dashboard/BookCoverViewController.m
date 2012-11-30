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
#import "BenchtopBookCell.h"
#import "NSString+Utilities.h"
#import "EventHelper.h"

@interface BookCoverViewController ()

@property (nonatomic, strong) CKBook *book;
@property (nonatomic, assign) BOOL mine;
@property (nonatomic, assign) id<BookCoverViewControllerDelegate> delegate;
@property (nonatomic, strong) UIView *bookCoverView;
@property (nonatomic, strong) CALayer *rootBookLayer;
@property (nonatomic, strong) CALayer *bookCoverLayer;
@property (nonatomic, strong) CALayer *bookCoverContentsLayer;
@property (nonatomic, strong) CALayer *leftOpenLayer;
@property (nonatomic, assign) BOOL opened;

@end

@implementation BookCoverViewController

#define RADIANS(degrees)        ((degrees * (float)M_PI) / 180.0f)

- (id)initWithBook:(CKBook *)book delegate:(id<BookCoverViewControllerDelegate>)delegate {
    return [self initWithBook:book mine:NO delegate:delegate];
}

- (id)initWithBook:(CKBook *)book mine:(BOOL)mine delegate:(id<BookCoverViewControllerDelegate>)delegate {
    if (self = [super init]) {
        self.book = book;
        self.mine = mine;
        self.delegate = delegate;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight;
    
    CGSize bookSize = [BenchtopBookCell cellSize];
    CKBookCoverView *bookCoverView = [[CKBookCoverView alloc] initWithFrame:CGRectMake(0.0, 0.0, bookSize.width, bookSize.height)];
    [bookCoverView setCover:self.book.cover illustration:self.book.illustration];
    [bookCoverView setTitle:self.book.name author:[self.book userName] caption:self.book.caption editable:NO];
    self.bookCoverView = bookCoverView;
}

- (void)openBook:(BOOL)open {
    DLog();
    if (open) {
        [self initLayers];
    }
    [self.delegate bookCoverViewWillOpen:open];
    [self animateBookOpen:open];
}

- (void)cleanUpLayers {
    [self.leftOpenLayer removeFromSuperlayer];
    [self.bookCoverLayer removeFromSuperlayer];
    [self.rootBookLayer removeFromSuperlayer];
}

#pragma mark - CAAnimation delegate methods

- (void)animationDidStart:(CAAnimation *)theAnimation {
    DLog(@"Open book starting: %@", [NSString CK_stringForBoolean:self.opened]);
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
    DLog(@"Open book finished: %@", [NSString CK_stringForBoolean:self.opened]);
    
//    if (!self.opened) {
        [self.rootBookLayer removeAllAnimations];
    [self.leftOpenLayer removeAllAnimations];
        [self.bookCoverLayer removeAllAnimations];
//    }
    [self.delegate bookCoverViewDidOpen:self.opened];
}

#pragma mark - Private methods

- (void)initLayers {
    
    // Book root layer.
    CALayer *rootBookLayer = [CALayer layer];
    rootBookLayer.anchorPoint = CGPointMake(0.5, 0.5);
    rootBookLayer.frame = self.bookCoverView.bounds;
    rootBookLayer.position = CGPointMake(floorf(self.view.bounds.size.width / 2), floorf(self.view.bounds.size.height / 2));
    rootBookLayer.backgroundColor = [UIColor clearColor].CGColor;
    [self.view.layer addSublayer:rootBookLayer];
    self.rootBookLayer = rootBookLayer;
    
    // Opened RHS layer.
    CGFloat radius = 5.0;
    CALayer *rightOpenLayer = [CALayer layer];
    rightOpenLayer.anchorPoint = CGPointMake(0.5, 0.5);
    rightOpenLayer.position = CGPointMake(floorf(self.rootBookLayer.bounds.size.width / 2),
                                          floorf(self.rootBookLayer.bounds.size.height / 2));
    rightOpenLayer.frame = CGRectMake(rootBookLayer.bounds.origin.x,
                                      rootBookLayer.bounds.origin.y - 1.0,
                                      rootBookLayer.bounds.size.width - 1.0,
                                      rootBookLayer.bounds.size.height - 2.0);
    rightOpenLayer.backgroundColor = [UIColor whiteColor].CGColor;
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, nil, CGRectGetMinX(rightOpenLayer.bounds), CGRectGetMidY(rightOpenLayer.bounds));
	CGPathAddArcToPoint(path, nil, CGRectGetMinX(rightOpenLayer.bounds), CGRectGetMinY(rightOpenLayer.bounds), CGRectGetMidX(rightOpenLayer.bounds), CGRectGetMinY(rightOpenLayer.bounds), 0.0);
	CGPathAddArcToPoint(path, nil, CGRectGetMaxX(rightOpenLayer.bounds), CGRectGetMinY(rightOpenLayer.bounds), CGRectGetMaxX(rightOpenLayer.bounds), CGRectGetMidY(rightOpenLayer.bounds), radius);
	CGPathAddArcToPoint(path, nil, CGRectGetMaxX(rightOpenLayer.bounds), CGRectGetMaxY(rightOpenLayer.bounds), CGRectGetMidX(rightOpenLayer.bounds), CGRectGetMaxY(rightOpenLayer.bounds), radius);
	CGPathAddArcToPoint(path, nil, CGRectGetMinX(rightOpenLayer.bounds), CGRectGetMaxY(rightOpenLayer.bounds), CGRectGetMinX(rightOpenLayer.bounds), CGRectGetMidY(rightOpenLayer.bounds), 0.0);
	CGPathCloseSubpath(path);
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
	[maskLayer setPath:path];
    rightOpenLayer.mask = nil;
    rightOpenLayer.mask = maskLayer;
    [self.rootBookLayer addSublayer:rightOpenLayer];
    
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
    leftOpenLayer.backgroundColor = [UIColor whiteColor].CGColor;
    leftOpenLayer.doubleSided = NO;
    leftOpenLayer.transform = CATransform3DMakeRotation(RADIANS(180.0), 0.0, 1.0, 0.0);
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
    [bookCoverContentsLayer addSublayer:self.bookCoverView.layer];

    [self.rootBookLayer addSublayer:rootBookCoverLayer];
    self.bookCoverLayer = rootBookCoverLayer;    
}

- (void)animateBookOpen:(BOOL)open {
    DLog(@"open: %@", [NSString CK_stringForBoolean:open]);
    if (self.opened == open) {
        return;
    }
    self.opened = open;
    
    // Root view to open the book in.
    UIView *rootView = self.view;
    
    // Root book animation changes.
    CGPoint rootBookStartPoint = CGPointMake(0.5, 0.5);
    CGPoint rootBookEndPoint = CGPointMake(0.0, 0.5);
    //    CGFloat requiredScale = (rootView.bounds.size.height - 19.0) / self.bounds.size.height; // 8top + 11bot gaps
    CGFloat requiredScale = rootView.bounds.size.height / self.bookCoverView.bounds.size.height;
    DLog(@"requiredScale: %f", requiredScale);
    CATransform3D rootBookScaleUpTransform = CATransform3DMakeScale(requiredScale, requiredScale, requiredScale);
    CATransform3D rootBookScaleDownTransform = CATransform3DIdentity;
    CATransform3D openBookTransform = CATransform3DMakeRotation(RADIANS(180), 0.0f, -1.0f, 0.0f);
    CGFloat zDistance = 1000;
    openBookTransform.m34 = 1 / zDistance;
    CATransform3D closeBookTransform = CATransform3DIdentity;
    
    // Grab media time for timing our animations.
    CFTimeInterval rootMediaTime = [self.rootBookLayer convertTime:CACurrentMediaTime() fromLayer:nil];
    CGFloat duration = 0.6;
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
    flipAnimation.removedOnCompletion = NO;
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


@end
