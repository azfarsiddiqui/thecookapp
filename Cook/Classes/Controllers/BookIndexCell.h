//
//  BookIndexCell.h
//  Cook
//
//  Created by Jeff Tan-Ang on 22/03/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BookIndexCell : UICollectionViewCell

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *numRecipesLabel;

+ (CGSize)cellSize;
+ (CGFloat)requiredHeight;
+ (UIEdgeInsets)contentInsets;

- (void)configureCategory:(NSString *)category recipes:(NSArray *)recipes;
- (CGSize)availableSize;

@end
