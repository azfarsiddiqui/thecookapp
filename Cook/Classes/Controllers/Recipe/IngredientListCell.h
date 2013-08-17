//
//  IngredientListCell.h
//  Cook
//
//  Created by Jeff Tan-Ang on 1/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKListCell.h"

@interface IngredientListCell : CKListCell

@property (nonatomic, strong) UIView *ingredientsAccessoryView;

- (void)configureMeasure:(NSString *)measure;

@end
