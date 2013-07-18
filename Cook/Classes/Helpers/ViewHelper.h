//
//  CKUIHelper.h
//  Cook
//
//  Created by Jonny Sagorin on 10/5/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ViewHelper : NSObject

+ (UIButton *)okButtonWithTarget:(id)target selector:(SEL)selector;
+ (UIButton *)cancelButtonWithTarget:(id)target selector:(SEL)selector;
+ (UIButton *)deleteButtonWithTarget:(id)target selector:(SEL)selector;
+ (UIButton *)buttonWithImage:(UIImage *)image target:(id)target selector:(SEL)selector;
+ (UIButton *)buttonWithImage:(UIImage *)image selectedImage:(UIImage *)selectedImage target:(id)target selector:(SEL)selector;
+ (UIButton *)buttonWithImagePrefix:(NSString*)imagePrefix target:(id)target selector:(SEL)selector;
+ (UIButton *)buttonWithTitle:(NSString*)title backgroundImage:(UIImage *)image target:(id)target selector:(SEL)selector;
+ (UIButton *)buttonWithTitle:(NSString*)title backgroundImage:(UIImage *)image size:(CGSize)size target:(id)target selector:(SEL)selector;

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
+ (void)applyMotionEffectsWithOffset:(CGFloat)offset view:(UIView *)view;

// Collection view.
+ (CGRect)visibleFrameForCollectionView:(UICollectionView *)collectionView;

// Shadows.
+ (void)addTopShadowView:(UIView *)view;

// Rounded corners.
+ (void)applyRoundedCornersToView:(UIView *)view corners:(UIRectCorner)corners size:(CGSize)size;

@end
