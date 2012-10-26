//
//  BookCoverView.m
//  Cook
//
//  Created by Jeff Tan-Ang on 18/10/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "BookView.h"
#import "BookCover.h"
#import "UIColor+Expanded.h"
#import "ViewHelper.h"
#import "AppHelper.h"
#import "EventHelper.h"
#import "NSString+Utilities.h"

@interface BookView ()

@property (nonatomic, strong) CKBook *book;
@property (nonatomic, strong) CALayer *rootBookLayer;
@property (nonatomic, strong) CALayer *bookCoverLayer;
@property (nonatomic, strong) CALayer *bookCoverContentsLayer;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIImageView *illustrationImageView;
@property (nonatomic, strong) UIImageView *overlayImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *taglineLabel;
@property (nonatomic, strong) UILabel *numRecipesLabel;
@property (nonatomic, assign) BOOL opened;

@end

@implementation BookView

#define kContentInsets          UIEdgeInsetsMake(20.0, 20.0, 20.0, 20.0)
#define kBookInsets             UIEdgeInsetsMake(17.0, 19.0, 22.0, 20.0)
#define RADIANS(degrees)        ((degrees * (float)M_PI) / 180.0f)

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self layoutBookCover];
    }
    return self;
}

- (void)layoutBookCover {
    [self initLayers];
    [self initBackground];
}

- (void)updateWithBook:(CKBook *)book {
    DLog(@"Update with book %@", book);
    
    // Update content if it's necessary.
    if (![self.book.cover isEqualToString:book.cover]) {
        self.backgroundImageView.image = [BookCover imageForCover:book.cover];
    }
    if (![self.book.illustration isEqualToString:book.illustration]) {
        self.illustrationImageView.image = [BookCover imageForIllustration:book.illustration];
    }
    if (![[self.book userName] isEqualToString:[book userName]]) {
        [self updateName:[book userName] book:book];
    }
    if (![self.book.name isEqualToString:book.name]) {
        [self updateTitle:book.name book:book];
    }
    if (![self.book.tagline isEqualToString:book.tagline]) {
        [self updateTagline:book.tagline book:book];
    }
//    if (!self.book || self.book.numRecipes != book.numRecipes) {
//        [self updateNumRecipes:book.numRecipes];
//    }
    self.book = book;
}

- (void)open:(BOOL)open {
    [self openBook:open];
}

- (UIEdgeInsets)contentEdgeInsets {
    return UIEdgeInsetsMake(10.0, 10.0, 13.0, 10.0);
}

- (CGSize)contentAvailableSize {
    UIEdgeInsets edgeInsets = [self contentEdgeInsets];
    return CGSizeMake(self.bounds.size.width - edgeInsets.left - edgeInsets.right,
                      self.bounds.size.height - edgeInsets.top - edgeInsets.bottom);
}
                   
- (UIFont *)coverNameFont {
    return [UIFont fontWithName:@"AvenirNext-DemiBold" size:18];
}

- (UIColor *)coverNameColour {
    return [self coverTitleColour];
}

- (UIColor *)coverNameShadowColour {
    return [self coverTitleShadowColour];
}

- (UIFont *)coverTitleFont {
    return [UIFont fontWithName:@"AvenirNext-Bold" size:78];
}

- (NSTextAlignment)coverTitleAlignment {
    return NSTextAlignmentCenter;
}

- (UIColor *)coverTitleColour {
    return [UIColor colorWithHexString:@"FFFFFF"];
}

- (UIColor *)coverTitleShadowColour {
    return [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
}

- (UIFont *)coverTaglineFont {
    return [UIFont fontWithName:@"AvenirNext-DemiBold" size:14];
}

- (UIColor *)coverTaglineColour {
    return [self coverTitleColour];
}

- (UIColor *)coverTaglineShadowColor {
    return [self coverTitleShadowColour];
}

- (UIFont *)coverNumRecipesFont {
    return [UIFont fontWithName:@"AvenirNext-DemiBold" size:14];
}

- (UIColor *)coverNumRecipesColour {
    return [self coverTitleColour];
}

- (UIColor *)coverNumRecipesShadowColour {
    return [self coverTitleShadowColour];
}

- (UIImage *)coverBackgroundImage {
    return [UIImage imageNamed:[BookCover defaultCover]];
}

- (UIImage *)coverIllustrationImage {
    return [UIImage imageNamed:[BookCover defaultIllustration]];
}

- (UIImage *)coverOverlayImage {
    return [UIImage imageNamed:@"cook_book_overlay.png"];
}

#pragma mark - CAAnimation delegate methods

- (void)animationDidStart:(CAAnimation *)theAnimation {
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
    DLog(@"open: %@", [NSString CK_stringForBoolean:self.opened]);
    [EventHelper postOpenBook:self.opened];
}

#pragma mark - Private methods

- (void)initLayers {
    
    // Book root layer.
    CALayer *rootBookLayer = [CALayer layer];
    rootBookLayer.anchorPoint = CGPointMake(0.5, 0.5);
    rootBookLayer.frame = self.bounds;
    rootBookLayer.position = CGPointMake(floorf(self.bounds.size.width / 2),
                                         floorf(self.bounds.size.height / 2));
    rootBookLayer.backgroundColor = [UIColor clearColor].CGColor;
    [self.layer addSublayer:rootBookLayer];
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
    CALayer *bookCoverLayer = [self createBookCoverLayer];
    [self.rootBookLayer addSublayer:bookCoverLayer];
    self.bookCoverLayer = bookCoverLayer;
    
}

- (CALayer *)createBookCoverLayer {
    CALayer *rootBookCoverLayer = [CATransformLayer layer];
    rootBookCoverLayer.anchorPoint = CGPointMake(0.0, 0.5);
    rootBookCoverLayer.frame = self.bounds;
    rootBookCoverLayer.position = CGPointMake(0.0, floorf(self.bounds.size.height / 2));
    rootBookCoverLayer.doubleSided = YES;
    
    // Opened LHS layer.
    CALayer *leftOpenLayer = [CALayer layer];
    leftOpenLayer.anchorPoint = CGPointMake(0.5, 0.5);
    leftOpenLayer.frame = rootBookCoverLayer.bounds;
    leftOpenLayer.position = CGPointMake(floorf(self.bounds.size.width / 2), floorf(self.bounds.size.height / 2));
    leftOpenLayer.backgroundColor = [UIColor whiteColor].CGColor;
    leftOpenLayer.doubleSided = NO;
    leftOpenLayer.transform = CATransform3DMakeRotation(RADIANS(180.0), 0.0, 1.0, 0.0);
    [rootBookCoverLayer addSublayer:leftOpenLayer];
    
    // Front book cover contents.
    CALayer *bookCoverContentsLayer = [CALayer layer];
    bookCoverContentsLayer.anchorPoint = CGPointMake(0.0, 0.0);
    bookCoverContentsLayer.frame = rootBookCoverLayer.bounds;
    bookCoverContentsLayer.doubleSided = NO;
    [rootBookCoverLayer addSublayer:bookCoverContentsLayer];
    self.bookCoverContentsLayer = bookCoverContentsLayer;
    
    return rootBookCoverLayer;
}

- (void)initBackground {
    
    // Cover
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[self coverBackgroundImage]];
    backgroundImageView.frame = CGRectMake(floorf((self.frame.size.width - backgroundImageView.frame.size.width) / 2.0),
                                           floorf((self.frame.size.height - backgroundImageView.frame.size.height) / 2.0),
                                           backgroundImageView.frame.size.width,
                                           backgroundImageView.frame.size.height);
    [self.bookCoverContentsLayer addSublayer:backgroundImageView.layer];
    self.backgroundImageView = backgroundImageView;
    
    // Overlay
    UIImageView *overlayImageView = [[UIImageView alloc] initWithImage:[self coverOverlayImage]];
    overlayImageView.frame = backgroundImageView.frame;
    [self.bookCoverContentsLayer insertSublayer:overlayImageView.layer above:backgroundImageView.layer];
    self.overlayImageView = overlayImageView;
    
    // Illustration.
    UIImageView *illustrationImageView = [[UIImageView alloc] initWithImage:[self coverIllustrationImage]];
    illustrationImageView.frame = backgroundImageView.frame;
    [self.bookCoverContentsLayer insertSublayer:illustrationImageView.layer above:backgroundImageView.layer];
    self.illustrationImageView = illustrationImageView;
}

- (void)updateName:(NSString *)name book:(CKBook *)book {
    NSString *displayName = [name uppercaseString];
    [self.nameLabel.layer removeFromSuperlayer];
    
    UIEdgeInsets edgeInsets = [self contentEdgeInsets];
    NSLineBreakMode lineBreakMode = NSLineBreakByTruncatingTail;
    CGFloat singleLineHeight = [ViewHelper singleLineHeightForFont:[self coverNameFont]];
    CGSize size = [displayName sizeWithFont:[self coverNameFont]
                          constrainedToSize:CGSizeMake([self contentAvailableSize].width, singleLineHeight)
                              lineBreakMode:lineBreakMode];
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(floorf((self.bounds.size.width - size.width) / 2.0),
                                                                   edgeInsets.top,
                                                                   size.width,
                                                                   size.height)];
    nameLabel.autoresizingMask = UIViewAutoresizingNone;
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.lineBreakMode = lineBreakMode;
    nameLabel.minimumScaleFactor = 0.7;
    nameLabel.font = [self coverNameFont];
    nameLabel.textColor = [self coverNameColour];
    nameLabel.shadowColor = [self coverNameShadowColour];
    nameLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    nameLabel.text = displayName;
    nameLabel.alpha = 0.0;
    [self.bookCoverContentsLayer insertSublayer:nameLabel.layer below:self.overlayImageView.layer];
    self.nameLabel = nameLabel;
    
    // Fade the title in.
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationCurveEaseOut
                     animations:^{
                         nameLabel.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                     }];
    
}

- (void)updateTagline:(NSString *)tagline book:(CKBook *)book {
    NSString *displayTagline = [tagline uppercaseString];
    [self.taglineLabel.layer removeFromSuperlayer];
    
    UIEdgeInsets edgeInsets = [self contentEdgeInsets];
    NSLineBreakMode lineBreakMode = NSLineBreakByTruncatingTail;
    CGFloat singleLineHeight = [ViewHelper singleLineHeightForFont:[self coverTaglineFont]];
    CGSize size = [displayTagline sizeWithFont:[self coverTaglineFont]
                             constrainedToSize:CGSizeMake([self contentAvailableSize].width, singleLineHeight)
                                 lineBreakMode:lineBreakMode];
    UILabel *taglineLabel = [[UILabel alloc] initWithFrame:CGRectMake(floorf((self.bounds.size.width - size.width) / 2.0),
                                                                      self.bounds.size.height - edgeInsets.bottom - size.height,
                                                                      size.width,
                                                                      size.height)];
    taglineLabel.autoresizingMask = UIViewAutoresizingNone;
    taglineLabel.backgroundColor = [UIColor clearColor];
    taglineLabel.lineBreakMode = lineBreakMode;
    taglineLabel.minimumScaleFactor = 0.7;
    taglineLabel.font = [self coverTaglineFont];
    taglineLabel.textColor = [self coverTaglineColour];
    taglineLabel.shadowColor = [self coverTaglineShadowColor];
    taglineLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    taglineLabel.text = displayTagline;
    taglineLabel.alpha = 0.0;
    [self.bookCoverContentsLayer insertSublayer:taglineLabel.layer below:self.overlayImageView.layer];
    self.taglineLabel = taglineLabel;
    
    // Fade the tagline in.
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationCurveEaseOut
                     animations:^{
                         taglineLabel.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                     }];
    
}

- (void)updateNumRecipes:(NSUInteger)numRecipes book:(CKBook *)book {
    NSString *displayNum = [NSString stringWithFormat:@"%d", numRecipes];
    [self.numRecipesLabel.layer removeFromSuperlayer];
    
    NSLineBreakMode lineBreakMode = NSLineBreakByTruncatingTail;
    UIEdgeInsets insets = UIEdgeInsetsMake(2.0, 6.0, 1.0, 6.0);
    CGFloat singleLineHeight = [ViewHelper singleLineHeightForFont:[self coverNumRecipesFont]];
    CGSize size = [displayNum sizeWithFont:[self coverNumRecipesFont]
                         constrainedToSize:CGSizeMake([self contentAvailableSize].width, singleLineHeight)
                             lineBreakMode:lineBreakMode];
    UILabel *numRecipesLabel = [[UILabel alloc] initWithFrame:CGRectMake(floorf((self.bounds.size.width - size.width) / 2.0),
                                                                         self.bounds.size.height - insets.bottom - size.height - 40.0,
                                                                         insets.left + size.width + insets.right,
                                                                         insets.top + size.height + insets.bottom)];
    numRecipesLabel.autoresizingMask = UIViewAutoresizingNone;
    numRecipesLabel.layer.cornerRadius = 10.0;
    numRecipesLabel.backgroundColor = [UIColor whiteColor];
    numRecipesLabel.lineBreakMode = lineBreakMode;
    numRecipesLabel.textAlignment = NSTextAlignmentCenter;
    numRecipesLabel.minimumScaleFactor = 0.7;
    numRecipesLabel.font = [self coverNumRecipesFont];
    numRecipesLabel.textColor = [self coverNumRecipesColour];
    numRecipesLabel.shadowColor = [self coverNumRecipesShadowColour];
    numRecipesLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    numRecipesLabel.text = displayNum;
    numRecipesLabel.alpha = 0.0;
    [self.bookCoverContentsLayer insertSublayer:numRecipesLabel.layer below:self.overlayImageView.layer];
    self.numRecipesLabel = numRecipesLabel;
    
    // Fade the tagline in.
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationCurveEaseOut
                     animations:^{
                         numRecipesLabel.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                     }];
    
}

- (void)updateTitle:(NSString *)title book:(CKBook *)book {
    NSString *displayTitle = [title uppercaseString];
    [self.titleLabel.layer removeFromSuperlayer];
    
    NSLineBreakMode lineBreakMode = NSLineBreakByWordWrapping;
    CGSize size = [displayTitle sizeWithFont:[self coverTitleFont] constrainedToSize:self.bounds.size lineBreakMode:lineBreakMode];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, size.width, size.height)];
    titleLabel.autoresizingMask = UIViewAutoresizingNone;
    titleLabel.numberOfLines = 0;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.lineBreakMode = lineBreakMode;
    titleLabel.textAlignment = [self coverTitleAlignment];
    titleLabel.minimumScaleFactor = 0.7;
    titleLabel.font = [self coverTitleFont];
    titleLabel.textColor = [self coverTitleColour];
    titleLabel.shadowColor = [self coverTitleShadowColour];
    titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    titleLabel.text = displayTitle;
    titleLabel.alpha = 0.0;
    titleLabel.frame = [self titleLabelFrameForSize:size book:book];
    [self.bookCoverContentsLayer insertSublayer:titleLabel.layer below:self.overlayImageView.layer];
    self.titleLabel = titleLabel;
    
    // Fade the title in.
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationCurveEaseOut
                     animations:^{
                         titleLabel.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                     }];
    
}

- (void)openBook:(BOOL)open {
    DLog(@"open: %@", [NSString CK_stringForBoolean:open]);
    self.opened = open;
    
    // Root view to open the book in.
    UIView *rootView = [[AppHelper sharedInstance] rootView];
    
    // Root book animation changes.
    CGPoint rootBookStartPoint = CGPointMake(0.5, 0.5);
    CGPoint rootBookEndPoint = CGPointMake(0.0, 0.5);
//    CGFloat requiredScale = (rootView.bounds.size.height - 19.0) / self.bounds.size.height; // 8top + 11bot gaps
    CGFloat requiredScale = rootView.bounds.size.height / self.bounds.size.height;
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
    [self.rootBookLayer addAnimation:groupAnimation forKey:nil];
    [self.bookCoverLayer addAnimation:flipAnimation forKey:@"transform"];
}

- (CGRect)titleLabelFrameForSize:(CGSize)size book:(CKBook *)book  {
    BookCoverTitleAlignment titleAlignment = [BookCover titleAlignmentForIllustration:book.illustration];
    CGRect frame = CGRectMake(0.0, 0.0, size.width, size.height);
    CGPoint origin = frame.origin;
    switch (titleAlignment) {
        case BookCoverTitleAlignmentTopLeft:
            origin = CGPointMake(kContentInsets.left, kContentInsets.top);
            break;
        case BookCoverTitleAlignmentTopCentered:
            origin = CGPointMake(floorf((self.bounds.size.width - size.width) / 2.0), kContentInsets.top);
            break;
        case BookCoverTitleAlignmentMidCentered:
            origin = CGPointMake(floorf((self.bounds.size.width - size.width) / 2.0), floorf((self.bounds.size.height - size.height) / 2.0));
            break;
        case BookCoverTitleAlignmentBottomCentered:
            origin = CGPointMake(floorf((self.bounds.size.width - size.width) / 2.0), self.bounds.size.height - kContentInsets.bottom - size.height);
            break;
        default:
            break;
    }
    frame.origin = origin;
    return frame;
}

@end
