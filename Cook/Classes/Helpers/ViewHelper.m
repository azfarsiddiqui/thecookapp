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

#define kContentInsets          (UIEdgeInsets){ 30.0, 15.0, 50.0, 15.0 }

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
    UIImage *imageSelected = light ? [UIImage imageNamed:@"cook_book_inner_icon_close_light_onpress.png"] : [UIImage imageNamed:@"cook_book_inner_icon_close_dark_onpress.png"];
    return [self buttonWithImage:image selectedImage:imageSelected target:target selector:selector];
}

+ (UIButton *)backButtonLight:(BOOL)light target:(id)target selector:(SEL)selector {
    UIImage *image = light ? [UIImage imageNamed:@"cook_book_inner_icon_back_light.png"] : [UIImage imageNamed:@"cook_book_inner_icon_back_dark.png"];
    UIImage *imageSelected = light ? [UIImage imageNamed:@"cook_book_inner_icon_back_light_onpress.png"] : [UIImage imageNamed:@"cook_book_inner_icon_back_dark_onpress.png"];
    return [self buttonWithImage:image selectedImage:imageSelected target:target selector:selector];
}

+ (UIButton *)addBackButtonToView:(UIView *)view light:(BOOL)light target:(id)target selector:(SEL)selector {
    UIButton *backButton = [ViewHelper backButtonLight:light target:target selector:selector];
    backButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
    backButton.frame = (CGRect){
        kContentInsets.left,
        kContentInsets.top,
        backButton.frame.size.width,
        backButton.frame.size.height
    };
    [view addSubview:backButton];
    return backButton;
}

+ (UIButton *)addCloseButtonToView:(UIView *)view light:(BOOL)light target:(id)target selector:(SEL)selector {
    UIButton *closeButton = [ViewHelper closeButtonLight:light target:target selector:selector];
    closeButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
    closeButton.frame = (CGRect){
        kContentInsets.left,
        kContentInsets.top,
        closeButton.frame.size.width,
        closeButton.frame.size.height
    };
    [view addSubview:closeButton];
    return closeButton;
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

#pragma mark - View effects

+ (void)removeViewWithAnimation:(UIView *)view completion:(void (^)())completion {
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         view.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         [view removeFromSuperview];
                         if (completion != nil) {
                             completion();
                         }
                     }];
}

#pragma mark - Alerts

+ (void)alertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self
                                              cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

@end
