//
//  RecipeIngredientsView.h
//  Cook
//
//  Created by Jeff Tan-Ang on 9/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKMeasureConverter.h"

@class CKBook;

@interface RecipeIngredientsView : UIView

@property (nonatomic, assign) CGSize maxSize;
@property (nonatomic, assign) BOOL convertible;

- (id)initWithIngredients:(NSArray *)ingredients book:(CKBook *)book maxWidth:(CGFloat)maxWidth measureLocale:(CKMeasurementType)measureType isConvertible:(BOOL)isConvertible;
- (id)initWithIngredients:(NSArray *)ingredients book:(CKBook *)book maxSize:(CGSize)maxSize
            textAlignment:(NSTextAlignment)textAlignment measureLocale:(CKMeasurementType)measureType;
- (id)initWithIngredients:(NSArray *)ingredients book:(CKBook *)book maxSize:(CGSize)maxSize
            textAlignment:(NSTextAlignment)textAlignment compact:(BOOL)compact measureLocale:(CKMeasurementType)measureType isConvertible:(BOOL)isConvertible;
- (void)updateIngredients:(NSArray *)ingredients measureType:(CKMeasurementType)measureType convertible:(BOOL)isConvertible;
- (void)updateIngredients:(NSArray *)ingredients book:(CKBook *)book measureType:(CKMeasurementType)measureType convertible:(BOOL)isConvertible;

@end
