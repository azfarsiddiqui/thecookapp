//
//  CKButtonView.h
//  CKButtonDemo
//
//  Created by Jeff Tan-Ang on 29/05/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKSignInButtonView;

@protocol CKSignInButtonViewDelegate <NSObject>

- (void)signInTappedForButtonView:(CKSignInButtonView *)buttonView;

@end

@interface CKSignInButtonView : UIView

- (id)initWithWidth:(CGFloat)width text:(NSString *)text activity:(BOOL)activity
           delegate:(id<CKSignInButtonViewDelegate>)delegate;
- (id)initWithSize:(CGSize)size text:(NSString *)text activity:(BOOL)activity
          delegate:(id<CKSignInButtonViewDelegate>)delegate;

- (void)setText:(NSString *)text activity:(BOOL)activity;
- (void)setText:(NSString *)text activity:(BOOL)activity animated:(BOOL)animated;
- (void)setText:(NSString *)text activity:(BOOL)activity animated:(BOOL)animated enabled:(BOOL)enabled;

- (UIFont *)textLabelFont;
- (UIColor *)textLabelColour;
- (UIImage *)normalBackgroundImage;
- (UIImage *)onPressBackgroundImage;
- (UIImage *)iconImage;

@end
