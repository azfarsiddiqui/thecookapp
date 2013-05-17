//
//  IngredientsView.h
//  Cook
//
//  Created by Jeff Tan-Ang on 17/05/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IngredientsView : UIView

@property (nonatomic, strong) NSArray *ingredients;

- (id)initWithIngredients:(NSArray *)ingredients size:(CGSize)size;

@end
