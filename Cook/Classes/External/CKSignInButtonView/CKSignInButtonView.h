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

- (void)signInTappedForButtonView:(CKSignInButtonView *)signInButton;

@end

@interface CKSignInButtonView : UIView

- (id)initWithWidth:(CGFloat)width image:(UIImage *)image text:(NSString *)text activity:(BOOL)activity
           delegate:(id<CKSignInButtonViewDelegate>)delegate;
- (id)initWithImage:(UIImage *)image text:(NSString *)text activity:(BOOL)activity
           delegate:(id<CKSignInButtonViewDelegate>)delegate;
- (id)initWithSize:(CGSize)size image:(UIImage *)image text:(NSString *)text activity:(BOOL)activity
          delegate:(id<CKSignInButtonViewDelegate>)delegate;

- (void)setText:(NSString *)text activity:(BOOL)activity;

@end
