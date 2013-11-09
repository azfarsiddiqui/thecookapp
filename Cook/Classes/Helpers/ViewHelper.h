//
//  CKUIHelper.h
//  Cook
//
//  Created by Jonny Sagorin on 10/5/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ViewHelper : NSObject

// Buttons
+ (UIButton *)okButtonWithTarget:(id)target selector:(SEL)selector;
+ (UIButton *)cancelButtonWithTarget:(id)target selector:(SEL)selector;
+ (UIButton *)deleteButtonWithTarget:(id)target selector:(SEL)selector;
+ (UIButton *)buttonWithImage:(UIImage *)image target:(id)target selector:(SEL)selector;
+ (UIButton *)buttonWithImage:(UIImage *)image selectedImage:(UIImage *)selectedImage target:(id)target selector:(SEL)selector;
+ (UIButton *)buttonWithImagePrefix:(NSString*)imagePrefix target:(id)target selector:(SEL)selector;
+ (UIButton *)buttonWithTitle:(NSString*)title backgroundImage:(UIImage *)image target:(id)target selector:(SEL)selector;
+ (UIButton *)buttonWithTitle:(NSString*)title backgroundImage:(UIImage *)image size:(CGSize)size target:(id)target selector:(SEL)selector;
+ (void)updateButton:(UIButton *)button withImage:(UIImage *)image;
+ (void)updateButton:(UIButton *)button withImage:(UIImage *)image selectedImage:(UIImage *)selectedImage;
+ (UIButton *)closeButtonLight:(BOOL)light target:(id)target selector:(SEL)selector;
+ (UIButton *)backButtonLight:(BOOL)light target:(id)target selector:(SEL)selector;
+ (UIButton *)addBackButtonToView:(UIView *)view light:(BOOL)light target:(id)target selector:(SEL)selector;
+ (UIButton *)addCloseButtonToView:(UIView *)view light:(BOOL)light target:(id)target selector:(SEL)selector;

// Sizes.
+ (CGSize)bookSize;
+ (CGFloat)singleLineHeightForFont:(UIFont *)font;
+ (CGSize)screenSize;
+ (NSString*)formatAsHoursSeconds:(float)timeInSeconds ;
+ (void) adjustScrollContentSize:(UIScrollView*)scrollView forHeight:(float)height;
+ (CGPoint) centerPointForSmallerView:(UIView*)smallerView inLargerView:(UIView*)largerView;

// Convers view to images.
+ (UIImage *)imageWithView:(UIView *)view;
+ (UIImage *)imageWithView:(UIView *)view opaque:(BOOL)opaque;
+ (UIImage *)imageWithView:(UIView *)view size:(CGSize)size opaque:(BOOL)opaque;

// UITextField helpers.
+ (void)setCaretOnFrontForInput:(UITextField *)input;
+ (void)selectTextForInput:(UITextField *)input atRange:(NSRange)range;

// Motion effects.
+ (void)applyMotionEffectsToView:(UIView *)view;
+ (void)applyDraggyMotionEffectsToView:(UIView *)view;
+ (void)applyDraggyMotionEffectsToView:(UIView *)view offset:(UIOffset)offset;
+ (void)applyMotionEffectsWithOffset:(CGFloat)offset view:(UIView *)view;
+ (UIOffset)standardMotionOffset;

// Collection view.
+ (CGRect)visibleFrameForCollectionView:(UICollectionView *)collectionView;

// Shadows.
+ (UIImage *)topShadowImageSubtle:(BOOL)subtle;
+ (UIImageView *)topShadowViewForView:(UIView *)view;
+ (UIImageView *)topShadowViewForView:(UIView *)view subtle:(BOOL)subtle;
+ (void)addTopShadowView:(UIView *)view;
+ (void)addTopShadowView:(UIView *)view subtle:(BOOL)subtle;

// Rounded corners.
+ (void)applyRoundedCornersToView:(UIView *)view corners:(UIRectCorner)corners size:(CGSize)size;

// Attributed String
+ (NSDictionary *)paragraphAttributesForFont:(UIFont *)font textColour:(UIColor *)textColour
                               textAlignment:(NSTextAlignment)textAlignment lineSpacing:(CGFloat)lineSpacing
                               lineBreakMode:(NSLineBreakMode)lineBreakMode;

// View effects.
+ (void)removeViewWithAnimation:(UIView *)view completion:(void (^)())completion;

// Alerts
+ (void)alertWithTitle:(NSString *)title message:(NSString *)message;

@end
