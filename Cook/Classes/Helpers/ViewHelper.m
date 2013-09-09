//
//  CKUIHelper.m
//  Cook
//
//  Created by Jonny Sagorin on 10/5/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//  User Interface helper for creation of user interface element
//

#import <QuartzCore/QuartzCore.h>
#import "ViewHelper.h"
#import "AppHelper.h"
#import "UIImage+ProportionalFill.h"
#import "CKEditingViewHelper.h"
#import "CKOffsetMotionEffect.h"
#import "Theme.h"

@implementation ViewHelper

#define kCardTag    1911

+ (UIButton *)okButtonWithTarget:(id)target selector:(SEL)selector {
    return [CKEditingViewHelper okayButtonWithTarget:target selector:selector];
}

+ (UIButton *)cancelButtonWithTarget:(id)target selector:(SEL)selector {
    return [CKEditingViewHelper cancelButtonWithTarget:target selector:selector];
}

+ (UIButton *)deleteButtonWithTarget:(id)target selector:(SEL)selector {
    return [CKEditingViewHelper deleteButtonWithTarget:target selector:selector];
}

+ (UIButton *)buttonWithTitle:(NSString*)title backgroundImage:(UIImage *)image target:(id)target selector:(SEL)selector {
    return [self buttonWithTitle:title backgroundImage:image size:image.size target:target selector:selector];
}

+ (UIButton *)buttonWithTitle:(NSString*)title backgroundImage:(UIImage *)image size:(CGSize)size target:(id)target
                     selector:(SEL)selector {
    UIButton *button = [self buttonWithImage:image target:target selector:selector];
    button.frame = CGRectMake(0.0, 0.0, size.width, size.height);
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    return button;
}

+ (UIButton *)buttonWithImage:(UIImage *)image target:(id)target selector:(SEL)selector {
    return [CKEditingViewHelper buttonWithImage:image target:target selector:selector];
}

+ (UIButton *)buttonWithImage:(UIImage *)image selectedImage:(UIImage *)selectedImage target:(id)target selector:(SEL)selector {
    return [CKEditingViewHelper buttonWithImage:image selectedImage:selectedImage target:target selector:selector];
}

+ (void)updateButton:(UIButton *)button withImage:(UIImage *)image {
    [self updateButton:button withImage:image selectedImage:nil];
}

+ (void)updateButton:(UIButton *)button withImage:(UIImage *)image selectedImage:(UIImage *)selectedImage {
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button setBackgroundImage:selectedImage forState:UIControlStateSelected];
}

+ (UIButton *)buttonWithImagePrefix:(NSString *)imagePrefix target:(id)target selector:(SEL)selector {
    UIImage *offImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_off.png",imagePrefix]];
    UIImage *onImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_on.png",imagePrefix]];
    UIButton *button = [self buttonWithImage:offImage target:target selector:selector];
    [button setBackgroundImage:onImage forState:UIControlStateSelected];
    [button setBackgroundImage:onImage forState:UIControlStateHighlighted];
    return button;
}

+ (UIButton *)closeButtonLight:(BOOL)light target:(id)target selector:(SEL)selector {
    UIImage *image = light ? [UIImage imageNamed:@"cook_book_inner_icon_close_light.png"] : [UIImage imageNamed:@"cook_book_inner_icon_close_dark.png"];
    return [self buttonWithImage:image target:target selector:selector];
}

#pragma mark - Sizes

+ (CGSize)bookSize {
    return CGSizeMake(300.0, 438.0);
}

+ (CGFloat)singleLineHeightForFont:(UIFont *)font {
    return [@"A" sizeWithFont:font constrainedToSize:[ViewHelper bookSize] lineBreakMode:NSLineBreakByTruncatingTail].height;
}

+ (CGSize)screenSize {
    return [[AppHelper sharedInstance] rootView].bounds.size;
}

+(NSString*)formatAsHoursSeconds:(float)timeInSeconds
{
    NSString *result = nil;
    float hours = floor(timeInSeconds/60/60);
    float minutes = (timeInSeconds - hours*60*60)/60;
    if (minutes > 1.0f) {
        result = [NSString stringWithFormat:@"%02.0f:%02.0f", hours,minutes];
    } else {
        result = [NSString stringWithFormat:@"%02.0f:00", hours];
    }
    
    return result;
}


+(void) adjustScrollContentSize:(UIScrollView*)scrollView forHeight:(float)height
{
   scrollView.contentSize = height > scrollView.frame.size.height ?
    CGSizeMake(scrollView.frame.size.width, height) :
    CGSizeMake(scrollView.frame.size.width, scrollView.frame.size.height);
}

+(CGPoint)centerPointForSmallerView:(UIView *)smallerView inLargerView:(UIView *)largerView
{
    return CGPointMake(floorf(0.5f*largerView.frame.size.width) - floorf(0.5f*smallerView.frame.size.width),
    floorf(0.5f*largerView.frame.size.height) - floorf(0.5f*smallerView.frame.size.height));
}

+ (UIImage *)imageWithView:(UIView *)view {
    return [self imageWithView:view opaque:YES];
}

+ (UIImage *)imageWithView:(UIView *)view opaque:(BOOL)opaque {
    return [self imageWithView:view size:view.bounds.size opaque:opaque];
}

+ (UIImage *)imageWithView:(UIView *)view size:(CGSize)size opaque:(BOOL)opaque {
    
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
//    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0);
//    [view drawViewHierarchyInRect:view.bounds];
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
    
    if (!CGSizeEqualToSize(image.size, size)) {
        image = [image imageScaledToFitSize:size];
    }
    
    return image;
}

#pragma mark - UITextField methods

+ (void)setCaretOnFrontForInput:(UITextField *)input {
    [self selectTextForInput:input atRange:NSMakeRange(0, 0)];
}

+ (void)selectTextForInput:(UITextField *)input atRange:(NSRange)range {
    UITextPosition *start = [input positionFromPosition:[input beginningOfDocument] offset:range.location];
    UITextPosition *end = [input positionFromPosition:start offset:range.length];
    [input setSelectedTextRange:[input textRangeFromPosition:start toPosition:end]];
}

#pragma mark - Motion effects.

+ (void)applyMotionEffectsToView:(UIView *)view {
    [self applyMotionEffectsWithOffset:50.0 view:view];
}

+ (void)applyDraggyMotionEffectsToView:(UIView *)view {
    [self applyDraggyMotionEffectsToView:view offset:[ViewHelper standardMotionOffset]];
}

+ (void)applyDraggyMotionEffectsToView:(UIView *)view offset:(UIOffset)offset {
    CKOffsetMotionEffect *motionEffect = [[CKOffsetMotionEffect alloc] initWithOffset:offset];
    [view addMotionEffect:motionEffect];
}

+ (void)applyMotionEffectsWithOffset:(CGFloat)offset view:(UIView *)view {
    
    // Add some motion effects
    UIInterpolatingMotionEffect *xAxis = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x"
                                                                                         type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    xAxis.minimumRelativeValue = [NSNumber numberWithFloat:-offset];
    xAxis.maximumRelativeValue = [NSNumber numberWithFloat:offset];
    
    UIInterpolatingMotionEffect *yAxis = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y"
                                                                                         type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    yAxis.minimumRelativeValue = [NSNumber numberWithFloat:-offset];
    yAxis.maximumRelativeValue = [NSNumber numberWithFloat:offset];
    
    UIMotionEffectGroup *motionEffectGroup = [[UIMotionEffectGroup alloc] init];
    motionEffectGroup.motionEffects = @[xAxis, yAxis];
    [view addMotionEffect:motionEffectGroup];
}

+ (UIOffset)standardMotionOffset {
    return (UIOffset){ 20.0, 20.0 };
}

#pragma mark - Collection views

+ (CGRect)visibleFrameForCollectionView:(UICollectionView *)collectionView {
    return (CGRect){
        collectionView.contentOffset.x,
        collectionView.contentOffset.y,
        collectionView.bounds.size.width,
        collectionView.bounds.size.height
    };
}

#pragma mark - Shadows

+ (UIImage *)topShadowImageSubtle:(BOOL)subtle {
    return subtle ? [UIImage imageNamed:@"cook_book_inner_titlebar_dark_nophoto.png"] : [UIImage imageNamed:@"cook_book_inner_titlebar_dark.png"];
}
+ (UIImageView *)topShadowViewForView:(UIView *)view {
    return [self topShadowViewForView:view subtle:NO];
}

+ (UIImageView *)topShadowViewForView:(UIView *)view subtle:(BOOL)subtle {
    UIImage *topShadowImage = [self topShadowImageSubtle:subtle];
    UIImageView *topShadowView = [[UIImageView alloc] initWithImage:topShadowImage];
    topShadowView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
    topShadowView.frame = (CGRect){
        view.bounds.origin.x,
        view.bounds.origin.y,
        view.bounds.size.width,
        topShadowView.frame.size.height
    };
    return topShadowView;
}

+ (void)addTopShadowView:(UIView *)view {
    [view addSubview:[self topShadowViewForView:view]];
}

+ (void)addTopShadowView:(UIView *)view subtle:(BOOL)subtle {
    [view addSubview:[self topShadowViewForView:view subtle:subtle]];
}

#pragma mark - Rounded corners

+ (void)applyRoundedCornersToView:(UIView *)view corners:(UIRectCorner)corners size:(CGSize)size {
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds
                                                   byRoundingCorners:corners
                                                         cornerRadii:size];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = view.bounds;
    maskLayer.path = maskPath.CGPath;
    view.layer.mask = maskLayer;
}

#pragma mark - Connection messages

+ (UIView *)messageCardViewWithText:(NSString *)text subtitle:(NSString *)subtitle {
    UIEdgeInsets contentInsets = (UIEdgeInsets) { 25.0, 30.0, 20.0, 30.0 };
    CGFloat titleSubtitleGap = 0.0;
    
    UIImage *cardImage = [[UIImage imageNamed:@"cook_message_popover.png"]
                          resizableImageWithCapInsets:(UIEdgeInsets){ 13.0, 12.0, 13.0, 12.0 }];
    
    // Title label.
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.font = [Theme cardViewTitleFont];
    label.textColor = [Theme cardViewTitleColour];
    label.text = text;
    [label sizeToFit];
    CGRect labelFrame = label.frame;
    
    // Subtitle label.
    UILabel *subtitleLabel = nil;
    CGRect subtitleFrame = CGRectZero;
    if ([subtitle length] > 0) {
        subtitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        subtitleLabel.backgroundColor = [UIColor clearColor];
        subtitleLabel.font = [Theme cardViewSubtitleFont];
        subtitleLabel.textColor = [Theme cardViewSubtitleColour];
        subtitleLabel.text = subtitle;
        [subtitleLabel sizeToFit];
        subtitleFrame = subtitleLabel.frame;
        subtitleFrame.origin.y = labelFrame.origin.y + labelFrame.size.height + titleSubtitleGap;
    }
    
    // Combined frame.
    CGRect cardFrame = CGRectUnion(labelFrame, subtitleFrame);
    UIImageView *cardImageView = [[UIImageView alloc] initWithImage:cardImage];
    cardFrame.size.width += contentInsets.left + contentInsets.right;
    cardFrame.size.height += contentInsets.top + contentInsets.bottom;
    cardImageView.frame = cardFrame;
    
    // Position labels.
    labelFrame.origin.x = floorf((cardImageView.bounds.size.width - labelFrame.size.width) / 2.0);
    labelFrame.origin.y = contentInsets.top;
    subtitleFrame.origin.x = floorf((cardImageView.bounds.size.width - subtitleFrame.size.width) / 2.0);
    subtitleFrame.origin.y = labelFrame.origin.y + labelFrame.size.height + titleSubtitleGap;
    label.frame = labelFrame;
    [cardImageView addSubview:label];
    if (subtitleLabel) {
        subtitleLabel.frame = subtitleFrame;
        [cardImageView addSubview:subtitleLabel];
    }
    
    return cardImageView;
}

+ (void)hideNoConnectionCardInView:(UIView *)view {
    [self showNoConnectionCard:NO view:view center:CGPointZero];
}

+ (void)showNoConnectionCard:(BOOL)show view:(UIView *)view center:(CGPoint)center {
    [self showCardText:@"CANNOT CONNECT" subtitle:@"CHECK YOUR WI-FI OR CELLULAR DATA" view:view show:show center:center];
}

+ (void)showCardText:(NSString *)text subtitle:(NSString *)subtitle view:(UIView *)view show:(BOOL)show
              center:(CGPoint)center {
    
    // Check for existing card.
    UIView *cardView = [view viewWithTag:kCardTag];
    BOOL alreadyVisible = (cardView != nil);

    if (show) {
        
        // Remove any existing one straigh away.
        [cardView removeFromSuperview];
        
        // Create a new card with the given text.
        cardView = [self messageCardViewWithText:text subtitle:subtitle];
        cardView.tag = kCardTag;
        cardView.center = center;
        
        // Straight replace.
        if (alreadyVisible) {
            [view addSubview:cardView];
        } else {
            cardView.alpha = 0.0;
            [view addSubview:cardView];
            
            // Fade it in.
            [UIView animateWithDuration:0.4
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 cardView.alpha = 1.0;
                             }
                             completion:^(BOOL finished) {
                             }];
        }
        
    } else {
        
        // Fade it out if there was something there.
        if (alreadyVisible) {
            
            // Fade it out then remove.
            [UIView animateWithDuration:0.1
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 cardView.alpha = 0.0;
                             }
                             completion:^(BOOL finished) {
                                 [cardView removeFromSuperview];
                             }];
        }
        
    }
}

+ (void)hideCardInView:(UIView *)view {
    [self showCardText:nil subtitle:nil view:view show:NO center:CGPointZero];
}

#pragma mark - Attributed String

+ (NSDictionary *)paragraphAttributesForFont:(UIFont *)font textColour:(UIColor *)textColour
                               textAlignment:(NSTextAlignment)textAlignment lineSpacing:(CGFloat)lineSpacing
                               lineBreakMode:(NSLineBreakMode)lineBreakMode {
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = lineBreakMode;
    paragraphStyle.lineSpacing = lineSpacing;
    paragraphStyle.alignment = textAlignment;
    return @{
             NSFontAttributeName : font,
             NSForegroundColorAttributeName : textColour,
             NSParagraphStyleAttributeName : paragraphStyle
             };
}

@end
