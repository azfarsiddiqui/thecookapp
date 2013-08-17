//
//  IngredientsKeyboardAccessoryCell.h
//  Cook
//
//  Created by Jeff Tan-Ang on 18/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IngredientsKeyboardAccessoryCell : UICollectionViewCell

+ (CGSize)cellSize;

- (void)configureText:(NSString *)text;

@end
