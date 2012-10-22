//
//  BookCoverView.h
//  Cook
//
//  Created by Jeff Tan-Ang on 18/10/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKBook.h"

@interface BookView : UIView

@property (nonatomic, strong) NSString *type;

- (void)layoutBookCover;
- (void)updateWithBook:(CKBook *)book;
- (void)open:(BOOL)open;

- (UIEdgeInsets)contentEdgeInsets;
- (CGSize)contentAvailableSize;

- (UIFont *)coverNameFont;
- (UIColor *)coverNameColour;
- (UIColor *)coverNameShadowColour;
- (UIFont *)coverTitleFont;
- (NSTextAlignment)coverTitleAlignment;
- (UIColor *)coverTitleColour;
- (UIColor *)coverTitleShadowColour;
- (UIFont *)coverTaglineFont;
- (UIColor *)coverTaglineColour;
- (UIColor *)coverTaglineShadowColor;
- (UIFont *)coverNumRecipesFont;
- (UIColor *)coverNumRecipesColour;
- (UIColor *)coverNumRecipesShadowColour;
- (UIImage *)coverBackgroundImage;
- (UIImage *)coverIllustrationImage;
- (UIImage *)coverOverlayImage;

@end
