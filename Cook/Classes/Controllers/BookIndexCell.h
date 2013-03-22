//
//  BookIndexCell.h
//  Cook
//
//  Created by Jeff Tan-Ang on 22/03/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BookIndexCell : UICollectionViewCell

+ (CGSize)cellSize;

- (void)configureCategory:(NSString *)category recipes:(NSArray *)recipes;

@end
