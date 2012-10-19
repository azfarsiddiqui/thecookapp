//
//  BookCoverView.h
//  Cook
//
//  Created by Jeff Tan-Ang on 18/10/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BookCoverView : UIView

@property (nonatomic, strong) NSString *type;

- (void)layoutBookCover;
- (void)updateName:(NSString *)name;
- (void)updateTitle:(NSString *)title;

- (UIEdgeInsets)contentEdgeInsets;
- (CGSize)contentAvailableSize;

- (UIFont *)coverNameFont;
- (UIColor *)coverNameColor;
- (UIColor *)coverNameShadowColor;

- (UIFont *)coverTitleFont;
- (NSTextAlignment)coverTitleAlignment;
- (UIColor *)coverTitleColor;
- (UIColor *)coverTitleShadowColor;
- (UIImage *)coverBackgroundImage;
- (UIImage *)coverIllustrationImage;
- (UIImage *)coverOverlayImage;

@end
