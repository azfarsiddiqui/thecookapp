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

- (id)initWithIngredients:(NSArray *)ingredients book:(CKBook *)book maxWidth:(CGFloat)maxWidth measureLocale:(CKMeasurementType)measureType;
- (id)initWithIngredients:(NSArray *)ingredients book:(CKBook *)book maxSize:(CGSize)maxSize measureLocale:(CKMeasurementType)measureType;
- (id)initWithIngredients:(NSArray *)ingredients book:(CKBook *)book maxSize:(CGSize)maxSize
            textAlignment:(NSTextAlignment)textAlignment measureLocale:(CKMeasurementType)measureType;
- (id)initWithIngredients:(NSArray *)ingredients book:(CKBook *)book maxSize:(CGSize)maxSize
            textAlignment:(NSTextAlignment)textAlignment compact:(BOOL)compact measureLocale:(CKMeasurementType)measureType;
- (void)updateIngredients:(NSArray *)ingredients measureType:(CKMeasurementType)measureType;
- (void)updateIngredients:(NSArray *)ingredients book:(CKBook *)book measureType:(CKMeasurementType)measureType;

@end
