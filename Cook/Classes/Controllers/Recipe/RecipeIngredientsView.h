//
//  RecipeIngredientsView.h
//  Cook
//
//  Created by Jeff Tan-Ang on 9/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKBook;

@interface RecipeIngredientsView : UIView

@property (nonatomic, assign) CGSize maxSize;

- (id)initWithIngredients:(NSArray *)ingredients book:(CKBook *)book maxWidth:(CGFloat)maxWidth;
- (id)initWithIngredients:(NSArray *)ingredients book:(CKBook *)book maxSize:(CGSize)maxSize;
- (id)initWithIngredients:(NSArray *)ingredients book:(CKBook *)book maxSize:(CGSize)maxSize
            textAlignment:(NSTextAlignment)textAlignment;
- (id)initWithIngredients:(NSArray *)ingredients book:(CKBook *)book maxSize:(CGSize)maxSize
            textAlignment:(NSTextAlignment)textAlignment compact:(BOOL)compact;
- (void)updateIngredients:(NSArray *)ingredients;
- (void)updateIngredients:(NSArray *)ingredients book:(CKBook *)book;

@end
