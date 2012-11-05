//
//  EditBookCell.h
//  Cook
//
//  Created by Jeff Tan-Ang on 5/11/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditBookCell : UICollectionViewCell

+ (CGSize)cellSize;
- (void)setCover:(NSString *)cover;
- (void)setIllustration:(NSString *)illustration;

@end
