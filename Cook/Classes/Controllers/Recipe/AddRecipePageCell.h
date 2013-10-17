//
//  AddRecipePageCell.h
//  Cook
//
//  Created by Jeff Tan-Ang on 18/10/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddRecipePageCell : UICollectionViewCell

+ (CGSize)cellSize;

- (void)configurePage:(NSString *)page;

@end
